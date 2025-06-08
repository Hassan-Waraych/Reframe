import Foundation
import FirebaseFirestore
import FirebaseAuth

class JournalService: ObservableObject {
    static let shared = JournalService()
    private let db = Firestore.firestore()
    private var entriesListener: ListenerRegistration?
    
    @Published var entries: [JournalEntry] = []
    @Published var errorMessage: String?
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let userId = user?.uid {
                self?.setupEntriesListener()
            } else {
                self?.cleanupEntriesListener()
                self?.entries = []
            }
        }
    }
    
    private func cleanupEntriesListener() {
        entriesListener?.remove()
        entriesListener = nil
    }
    
    private func setupEntriesListener() {
        cleanupEntriesListener()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        entriesListener = db.collection("journal_entries")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                do {
                    let loadedEntries = try documents.compactMap { document -> JournalEntry? in
                        var entry = try document.data(as: JournalEntry.self)
                        entry.id = document.documentID
                        return entry
                    }
                    
                    DispatchQueue.main.async {
                        self?.entries = loadedEntries
                    }
                } catch {
                    self?.errorMessage = error.localizedDescription
                }
            }
    }
    
    func addEntry(content: String, originalThought: String? = nil, category: String = "Reflection", reframeId: String? = nil, isFavorite: Bool = false) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "JournalService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please sign in to add journal entries"])
        }
        
        let entry = JournalEntry(
            userId: userId,
            content: content,
            originalThought: originalThought,
            timestamp: Date(),
            category: category,
            reframeId: reframeId,
            isFavorite: isFavorite
        )
        
        do {
            try await db.collection("journal_entries").addDocument(from: entry)
        } catch {
            throw error
        }
    }
    
    func isReframeLogged(reframe: Reframe) -> Bool {
        guard let reframeId = reframe.id else { return false }
        return entries.contains { entry in
            entry.category == "Reframe" && entry.reframeId == reframeId
        }
    }
    
    func getJournalEntryForReframe(reframe: Reframe) -> JournalEntry? {
        guard let reframeId = reframe.id else { return nil }
        return entries.first { entry in
            entry.category == "Reframe" && entry.reframeId == reframeId
        }
    }
    
    func getJournalEntryForCoach(historyItem: CoachHistoryItem) -> JournalEntry? {
        return entries.first { entry in
            entry.category == "Coach" && 
            entry.content.contains(historyItem.userMessage) && 
            entry.content.contains(historyItem.coachResponse)
        }
    }
    
    func updateEntryFavoriteStatus(_ entry: JournalEntry, isFavorite: Bool) async throws {
        guard let id = entry.id else { return }
        
        // Update the journal entry's favorite status
        try await db.collection("journal_entries").document(id).updateData([
            "isFavorite": isFavorite
        ])
        
        // If this is a reframe entry, update the reframe's helped status
        if let reframeId = entry.reframeId {
            try await db.collection("reframes").document(reframeId).updateData([
                "helped": isFavorite
            ])
        }
    }
    
    func logReframeToJournal(reframe: Reframe) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "JournalService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please sign in to add journal entries"])
        }
        
        // Check if reframe is already logged
        if isReframeLogged(reframe: reframe) {
            throw NSError(domain: "JournalService", code: -2, userInfo: [NSLocalizedDescriptionKey: "This reframe has already been logged to the journal"])
        }
        
        let content = """
        Original Thought: \(reframe.originalThought)
        
        Reframed Thought: \(reframe.reframedThought)
        """
        
        // Always create new entries as non-favorite
        let entry = JournalEntry(
            userId: userId,
            content: content,
            timestamp: Date(),
            category: "Reframe",
            reframeId: reframe.id,
            isFavorite: false
        )
        
        do {
            try await db.collection("journal_entries").addDocument(from: entry)
        } catch {
            throw error
        }
    }
    
    func deleteEntry(_ entry: JournalEntry) async throws {
        guard let id = entry.id else { return }
        
        // If this is a reframe entry, update the reframe's helped status to false
        if let reframeId = entry.reframeId {
            try await db.collection("reframes").document(reframeId).updateData([
                "helped": false
            ])
        }
        
        // Delete the journal entry
        try await db.collection("journal_entries").document(id).delete()
    }
    
    func clearAllEntries() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "JournalService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please sign in to clear journal entries"])
        }
        
        let snapshot = try await db.collection("journal_entries")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    func logCoachToJournal(historyItem: CoachHistoryItem) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "JournalService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please sign in to add journal entries"])
        }
        
        let content = """
        Your Message: \(historyItem.userMessage)
        
        Coach's Response: \(historyItem.coachResponse)
        """
        
        let entry = JournalEntry(
            userId: userId,
            content: content,
            timestamp: historyItem.timestamp,
            category: "Coach",
            isFavorite: historyItem.wasHelpful
        )
        
        do {
            try await db.collection("journal_entries").addDocument(from: entry)
        } catch {
            throw error
        }
    }
    
    deinit {
        cleanupEntriesListener()
    }
} 