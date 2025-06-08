import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Service responsible for managing reframe data in Firestore and local storage
class ReframeService: ObservableObject {
    static let shared = ReframeService()
    private let db = Firestore.firestore()
    private var reframeListener: ListenerRegistration?
    private let localStorage = LocalStorageService.shared
    
    // MARK: - Published Properties
    @Published var dailyReframeCount: Int = 0
    @Published var lastReframeDate: Date?
    @Published var errorMessage: String?
    @Published var nonsenseTracker: NonsenseTracker?
    
    // MARK: - Constants
    private let DAILY_LIMIT = 5
    private let NONSENSE_LIMIT = 10
    private let NONSENSE_COOLDOWN: TimeInterval = 24 * 3600 // 24 hours
    
    // MARK: - Initialization
    private init() {
        setupAuthStateListener()
    }
    
    // MARK: - Private Methods
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let userId = user?.uid {
                self?.setupReframeCountListener()
                self?.setupNonsenseTrackerListener(userId: userId)
            } else {
                self?.cleanupReframeListener()
                self?.dailyReframeCount = 0
                self?.lastReframeDate = nil
                self?.nonsenseTracker = nil
            }
        }
    }
    
    private func cleanupReframeListener() {
        reframeListener?.remove()
        reframeListener = nil
    }
    
    private func setupReframeCountListener() {
        cleanupReframeListener()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayTimestamp = Timestamp(date: today)
        
        reframeListener = db.collection("reframes")
            .whereField("userId", isEqualTo: userId)
            .whereField("timestamp", isGreaterThanOrEqualTo: todayTimestamp)
            .whereField("category", isNotEqualTo: "Reflection") // Only count non-reflection entries
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                let count = snapshot?.documents.count ?? 0
                
                DispatchQueue.main.async {
                    self?.dailyReframeCount = count
                    if let lastDocument = snapshot?.documents.last,
                       let timestamp = lastDocument.data()["timestamp"] as? Timestamp {
                        self?.lastReframeDate = timestamp.dateValue()
                    }
                }
            }
    }
    
    private func setupNonsenseTrackerListener(userId: String) {
        db.collection("nonsense_tracking")
            .document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let data = snapshot?.data() {
                    do {
                        self?.nonsenseTracker = try snapshot?.data(as: NonsenseTracker.self)
                    } catch {
                        print("Error decoding nonsense tracker: \(error)")
                    }
                }
            }
    }
    
    private func updateNonsenseTracker() async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        
        var newCount = 1
        var cooldownEndDate: Date? = nil
        
        if let tracker = nonsenseTracker {
            // Reset count if it's a new day
            if !calendar.isDate(tracker.lastNonsenseDate, inSameDayAs: today) {
                newCount = 1
            } else {
                newCount = tracker.count + 1
            }
            
            // Set cooldown if limit reached
            if newCount >= NONSENSE_LIMIT {
                cooldownEndDate = now.addingTimeInterval(NONSENSE_COOLDOWN)
            }
        }
        
        let newTracker = NonsenseTracker(
            userId: userId,
            count: newCount,
            lastNonsenseDate: now,
            cooldownEndDate: cooldownEndDate
        )
        
        try await db.collection("nonsense_tracking")
            .document(userId)
            .setData(from: newTracker)
        
        await MainActor.run {
            self.nonsenseTracker = newTracker
        }
    }
    
    // MARK: - Public Methods
    func canCreateReframe() -> Bool {
        if Auth.auth().currentUser == nil {
            // For guest users, check local storage
            let localReframes = localStorage.getLocalReframes()
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let todayReframes = localReframes.filter { reframe in
                if let createdAt = reframe.createdAt {
                    return calendar.isDate(createdAt, inSameDayAs: today) && reframe.category != "Reflection"
                }
                return false
            }
            return todayReframes.count < DAILY_LIMIT
        }
        return dailyReframeCount < DAILY_LIMIT
    }
    
    func remainingReframes() -> Int {
        if Auth.auth().currentUser == nil {
            // For guest users, check local storage
            let localReframes = localStorage.getLocalReframes()
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let todayReframes = localReframes.filter { reframe in
                if let createdAt = reframe.createdAt {
                    return calendar.isDate(createdAt, inSameDayAs: today) && reframe.category != "Reflection"
                }
                return false
            }
            return max(0, DAILY_LIMIT - todayReframes.count)
        }
        return max(0, DAILY_LIMIT - dailyReframeCount)
    }
    
    func canSubmitNonsense() -> Bool {
        if Auth.auth().currentUser == nil {
            // For guest users, always allow nonsense submissions
            return true
        }
        
        guard let tracker = nonsenseTracker else { return true }
        
        // Check if in cooldown
        if let cooldownEndDate = tracker.cooldownEndDate {
            return Date() > cooldownEndDate
        }
        
        // Check if limit reached
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if calendar.isDate(tracker.lastNonsenseDate, inSameDayAs: today) {
            return tracker.count < NONSENSE_LIMIT
        }
        
        return true
    }
    
    func getNonsenseCooldownEndDate() -> Date? {
        return nonsenseTracker?.cooldownEndDate
    }
    
    func createReframe(originalThought: String, reframedThought: String, category: String? = nil) async throws -> Reframe {
        if Auth.auth().currentUser == nil {
            // For guest users, save to local storage
            let reframeId = localStorage.saveReframe(
                originalThought: originalThought,
                reframedThought: reframedThought,
                category: category ?? "Reframe"
            )
            
            // Create a Reframe object for consistency
            return Reframe(
                id: reframeId,
                userId: "guest",
                originalThought: originalThought,
                reframedThought: reframedThought,
                timestamp: Date(),
                category: category,
                helped: false
            )
        }
        
        // Skip limit checks for reflections
        if category != "Reflection" {
            // Check nonsense limits if this is a nonsense input
            if category == "Nonsense" {
                guard canSubmitNonsense() else {
                    throw NSError(domain: "ReframeService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Please wait before submitting more unclear thoughts"])
                }
                try await updateNonsenseTracker()
            } else {
                // Regular reframe limits
                guard canCreateReframe() else {
                    throw NSError(domain: "ReframeService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Daily reframe limit reached"])
                }
            }
        }
        
        let reframe = Reframe(
            userId: Auth.auth().currentUser!.uid,
            originalThought: originalThought,
            reframedThought: reframedThought,
            timestamp: Date(),
            category: category,
            helped: false
        )
        
        do {
            let docRef = try await db.collection("reframes").addDocument(from: reframe)
            var savedReframe = reframe
            savedReframe.id = docRef.documentID
            return savedReframe
        } catch {
            throw error
        }
    }
    
    func getReframes() async throws -> [Reframe] {
        if Auth.auth().currentUser == nil {
            // For guest users, get from local storage
            let localReframes = localStorage.getLocalReframes()
            return localReframes.compactMap { localReframe in
                guard let content = localReframe.content else { return nil }
                
                let components = content.components(separatedBy: "\n\n")
                guard components.count >= 2 else { return nil }
                
                let originalThought = components[0].replacingOccurrences(of: "Original Thought: ", with: "")
                let reframedThought = components[1].replacingOccurrences(of: "Reframed Thought: ", with: "")
                
                return Reframe(
                    id: localReframe.id,
                    userId: "guest",
                    originalThought: originalThought,
                    reframedThought: reframedThought,
                    timestamp: localReframe.createdAt ?? Date(),
                    category: localReframe.category,
                    helped: localReframe.helped
                )
            }
        }
        
        let snapshot = try await db.collection("reframes")
            .whereField("userId", isEqualTo: Auth.auth().currentUser!.uid)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document -> Reframe? in
            var reframe = try document.data(as: Reframe.self)
            reframe.id = document.documentID
            return reframe
        }
    }
    
    func deleteReframe(_ reframe: Reframe) async throws {
        if Auth.auth().currentUser == nil {
            // For guest users, delete from local storage
            if let id = reframe.id {
                localStorage.deleteReframe(id: id)
            }
            return
        }
        
        guard let id = reframe.id else { return }
        try await db.collection("reframes").document(id).delete()
    }
    
    func updateReframe(_ id: String, helped: Bool) async throws {
        if Auth.auth().currentUser == nil {
            // For guest users, update in local storage
            localStorage.updateReframe(id: id, helped: helped)
            return
        }
        
        try await db.collection("reframes").document(id).updateData([
            "helped": helped
        ])
    }
    
    func resetDailyCount() {
        dailyReframeCount = 0
        lastReframeDate = nil
    }
    
    func clearAllReframes() async throws {
        if Auth.auth().currentUser == nil {
            // For guest users, clear local storage
            localStorage.clearAllReframes()
            return
        }
        
        let snapshot = try await db.collection("reframes")
            .whereField("userId", isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    deinit {
        cleanupReframeListener()
    }
} 