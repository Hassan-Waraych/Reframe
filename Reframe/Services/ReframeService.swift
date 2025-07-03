import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Service responsible for managing reframe data in Firestore
class ReframeService: ObservableObject {
    static let shared = ReframeService()
    private let db = Firestore.firestore()
    private var reframeListener: ListenerRegistration?
    
    // MARK: - Published Properties
    @Published var dailyReframeCount: Int = 0
    @Published var lastReframeDate: Date?
    @Published var errorMessage: String?
    @Published var nonsenseTracker: NonsenseTracker?
    
    // MARK: - Constants
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
                        // Handle error silently in production
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
        guard Auth.auth().currentUser != nil else { return false }
        let limit = AuthService.shared.isPremiumUser() ? Int.max : 2
        return dailyReframeCount < limit
    }
    
    func remainingReframes() -> Int {
        guard Auth.auth().currentUser != nil else { return 0 }
        let limit = AuthService.shared.isPremiumUser() ? Int.max : 2
        return max(0, limit - dailyReframeCount)
    }
    
    func canSubmitNonsense() -> Bool {
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
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ReframeService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please sign in to create reframes"])
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
            userId: userId,
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
            
            // Check milestones after creating reframe
            await checkMilestonesAfterReframe(category: category)
            
            return savedReframe
        } catch {
            throw error
        }
    }
    
    private func checkMilestonesAfterReframe(category: String?) async {
        // Add a small delay to ensure the reframe is properly saved
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let milestoneService = MilestoneService.shared
        
        if category == "Reflection" {
            await milestoneService.checkFirstReflection()
            await milestoneService.checkReflectionCountMilestones()
        } else {
            await milestoneService.checkFirstReframe()
            await milestoneService.checkReframeCountMilestones()
        }
    }
    
    func getReframes() async throws -> [Reframe] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ReframeService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please sign in to view reframes"])
        }
        
        let snapshot = try await db.collection("reframes")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document -> Reframe? in
            var reframe = try document.data(as: Reframe.self)
            reframe.id = document.documentID
            return reframe
        }
    }
    
    func deleteReframe(_ reframe: Reframe) async throws {
        guard let id = reframe.id else { return }
        try await db.collection("reframes").document(id).delete()
    }
    
    func updateReframe(_ id: String, helped: Bool) async throws {
        try await db.collection("reframes").document(id).updateData([
            "helped": helped
        ])
    }
    
    func resetDailyCount() {
        dailyReframeCount = 0
        lastReframeDate = nil
    }
    
    func clearAllReframes() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ReframeService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please sign in to clear reframes"])
        }
        
        let snapshot = try await db.collection("reframes")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
        
        // Reset the daily count
        resetDailyCount()
    }
    
    deinit {
        cleanupReframeListener()
    }
} 