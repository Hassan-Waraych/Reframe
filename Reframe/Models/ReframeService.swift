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
            return
        }
        
        // Get today's start timestamp
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayTimestamp = Timestamp(date: today)
        
        reframeListener = db.collection("reframes")
            .whereField("userId", isEqualTo: userId)
            .whereField("timestamp", isGreaterThanOrEqualTo: todayTimestamp)
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
    
    func canCreateReframe() -> Bool {
        guard Auth.auth().currentUser != nil else { return false }
        return dailyReframeCount < DAILY_LIMIT
    }
    
    func remainingReframes() -> Int {
        guard Auth.auth().currentUser != nil else { return 0 }
        return max(0, DAILY_LIMIT - dailyReframeCount)
    }
    
    func createReframe(originalThought: String, reframedThought: String, category: String? = nil) async throws -> Reframe {
        print("Creating reframe in Firestore...")
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found - user not authenticated")
            throw NSError(domain: "ReframeService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please sign in to create reframes"])
        }
        
        guard canCreateReframe() else {
            print("Daily reframe limit reached")
            throw NSError(domain: "ReframeService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Daily reframe limit reached"])
        }
        
        print("Creating reframe object...")
        let reframe = Reframe(
            userId: userId,
            originalThought: originalThought,
            reframedThought: reframedThought,
            timestamp: Date(),
            category: category,
            helped: nil
        )
        
        do {
            print("Saving reframe to Firestore...")
            let docRef = try await db.collection("reframes").addDocument(from: reframe)
            print("Reframe saved successfully with ID: \(docRef.documentID)")
            var savedReframe = reframe
            savedReframe.id = docRef.documentID
            return savedReframe
        } catch {
            print("Error saving reframe to Firestore: \(error.localizedDescription)")
            throw error
        }
    }
    
    func markReframeAsHelpful(_ reframe: Reframe) async throws {
        guard let id = reframe.id else { return }
        
        try await db.collection("reframes").document(id).updateData([
            "helped": true
        ])
    }
    
    func getReframes() async throws -> [Reframe] {
        print("Fetching reframes from Firestore...")
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found - user not authenticated")
            throw NSError(domain: "ReframeService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please sign in to view reframes"])
        }
        
        let snapshot = try await db.collection("reframes")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        print("Found \(snapshot.documents.count) reframes")
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