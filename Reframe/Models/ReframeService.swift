import Foundation
import FirebaseFirestore
import FirebaseAuth

class ReframeService: ObservableObject {
    static let shared = ReframeService()
    private let db = Firestore.firestore()
    private var reframeListener: ListenerRegistration?
    
    @Published var dailyReframeCount: Int = 0
    @Published var lastReframeDate: Date?
    @Published var errorMessage: String?
    
    private let DAILY_LIMIT = 5
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("Debug: Auth state changed in ReframeService - User: \(user?.uid ?? "nil")")
            if user != nil {
                self?.setupReframeCountListener()
            } else {
                self?.cleanupReframeListener()
                self?.dailyReframeCount = 0
                self?.lastReframeDate = nil
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
            print("Debug: No authenticated user for reframe count")
            return
        }
        
        // Get today's start timestamp
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayTimestamp = Timestamp(date: today)
        
        print("Debug: Setting up reframe count listener for user: \(userId)")
        
        reframeListener = db.collection("reframes")
            .whereField("userId", isEqualTo: userId)
            .whereField("timestamp", isGreaterThanOrEqualTo: todayTimestamp)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Debug: Error fetching reframes: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                let count = snapshot?.documents.count ?? 0
                print("Debug: Number of documents found: \(count)")
                
                DispatchQueue.main.async {
                    self?.dailyReframeCount = count
                    if let lastDocument = snapshot?.documents.last,
                       let timestamp = lastDocument.data()["timestamp"] as? Timestamp {
                        self?.lastReframeDate = timestamp.dateValue()
                    }
                }
            }
    }
    
    func canCreateReframe() -> Bool {
        guard Auth.auth().currentUser != nil else { return false }
        return dailyReframeCount < DAILY_LIMIT
    }
    
    func remainingReframes() -> Int {
        guard Auth.auth().currentUser != nil else { return 0 }
        return max(0, DAILY_LIMIT - dailyReframeCount)
    }
    
    func createReframe(originalThought: String, reframedThought: String, category: String? = nil) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ReframeService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please sign in to create reframes"])
        }
        
        guard canCreateReframe() else {
            throw NSError(domain: "ReframeService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Daily reframe limit reached"])
        }
        
        let reframe = Reframe(
            userId: userId,
            originalThought: originalThought,
            reframedThought: reframedThought,
            timestamp: Date(),
            category: category
        )
        
        do {
            let docRef = try await db.collection("reframes").addDocument(from: reframe)
            print("Debug: Successfully created reframe with ID: \(docRef.documentID)")
        } catch {
            print("Debug: Error creating reframe: \(error)")
            throw error
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
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: Reframe.self)
        }
    }
    
    func deleteReframe(_ reframe: Reframe) async throws {
        guard let id = reframe.id else { return }
        try await db.collection("reframes").document(id).delete()
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
    }
    
    deinit {
        cleanupReframeListener()
    }
} 