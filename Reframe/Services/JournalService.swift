import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreData

class JournalService: ObservableObject {
    static let shared = JournalService()
    private let db = Firestore.firestore()
    private var entriesListener: ListenerRegistration?
    private let localStorage = LocalStorageService.shared
    
    @Published var entries: [JournalEntry] = []
    @Published var errorMessage: String?
    
    private init() {
        setupAuthStateListener()
        setupLocalStorageObservers()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let userId = user?.uid {
                self?.setupEntriesListener()
            } else {
                self?.cleanupEntriesListener()
                self?.loadLocalEntries()
            }
        }
    }
    
    private func setupLocalStorageObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLocalJournalEntryUpdate),
            name: .localJournalEntryUpdated,
            object: nil
        )
    }
    
    @objc private func handleLocalJournalEntryUpdate() {
        if Auth.auth().currentUser == nil {
            loadLocalEntries()
        }
    }
    
    private func loadLocalEntries() {
        let localEntries = localStorage.getLocalJournalEntries()
        entries = localEntries.compactMap { localEntry -> JournalEntry? in
            guard let content = localEntry.content,
                  let createdAt = localEntry.createdAt,
                  let id = localEntry.id else { return nil }
            
            // Determine category and content structure
            let category: String
            let originalThought: String?
            let reframeId: String?
            
            if content.contains("Original Thought:") && content.contains("Reframed Thought:") {
                category = "Reframe"
                let components = content.components(separatedBy: "\n\n")
                originalThought = components.count > 0 ? components[0].replacingOccurrences(of: "Original Thought: ", with: "") : nil
                reframeId = id // Use the same ID for reframe entries
            } else if content.contains("Your Message:") && content.contains("Coach's Response:") {
                category = "Coach"
                originalThought = nil
                reframeId = nil
            } else {
                category = "Reflection"
                originalThought = nil
                reframeId = nil
            }
            
            var entry = JournalEntry(
                userId: "guest",
                content: content,
                originalThought: originalThought,
                timestamp: createdAt,
                category: category,
                reframeId: reframeId,
                isFavorite: localEntry.isFavorite
            )
            entry.id = id
            return entry
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
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let loadedEntries = documents.compactMap { document -> JournalEntry? in
                    let data = document.data()
                    guard let content = data["content"] as? String,
                          let category = data["category"] as? String,
                          let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() else {
                        print("Failed to parse journal entry document: \(document.documentID)")
                        return nil
                    }
                    
                    // Parse content based on category
                    let originalThought: String?
                    let reframeId = data["reframeId"] as? String
                    
                    if category == "Reframe" {
                        let components = content.components(separatedBy: "\n\n")
                        originalThought = components.count > 0 ? components[0].replacingOccurrences(of: "Original Thought: ", with: "") : nil
                    } else {
                        originalThought = nil
                    }
                    
                    var entry = JournalEntry(
                        userId: userId,
                        content: content,
                        originalThought: originalThought,
                        timestamp: createdAt,
                        category: category,
                        reframeId: reframeId,
                        isFavorite: data["isFavorite"] as? Bool ?? false
                    )
                    entry.id = document.documentID
                    return entry
                }
                
                DispatchQueue.main.async {
                    self?.entries = loadedEntries
                }
            }
    }
    
    func addEntry(content: String, originalThought: String? = nil, category: String = "Reflection", reframeId: String? = nil, isFavorite: Bool = false) async throws {
        if Auth.auth().currentUser == nil {
            // For guest users, save to local storage
            _ = localStorage.saveJournalEntry(content: content, category: category, reframeId: reframeId)
            loadLocalEntries()
            return
        }
        
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
        if Auth.auth().currentUser == nil {
            // For guest users, update in local storage
            if let id = entry.id {
                localStorage.updateJournalEntry(id: id, isFavorite: isFavorite)
                loadLocalEntries()
            }
            return
        }
        
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
        if Auth.auth().currentUser == nil {
            // For guest users, save to local storage
            let content = """
            Original Thought: \(reframe.originalThought)
            
            Reframed Thought: \(reframe.reframedThought)
            """
            _ = localStorage.saveJournalEntry(content: content, category: "Reframe", reframeId: reframe.id)
            loadLocalEntries()
            return
        }
        
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
        if Auth.auth().currentUser == nil {
            // For guest users, delete from local storage
            if let id = entry.id {
                localStorage.deleteJournalEntry(id: id)
                loadLocalEntries()
            }
            return
        }
        
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
        if Auth.auth().currentUser == nil {
            // For guest users, clear from local storage
            localStorage.clearAllJournalEntries()
            loadLocalEntries()
            return
        }
        
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
        if Auth.auth().currentUser == nil {
            // For guest users, save to local storage
            let content = """
            Your Message: \(historyItem.userMessage)
            
            Coach's Response: \(historyItem.coachResponse)
            """
            _ = localStorage.saveJournalEntry(content: content)
            loadLocalEntries()
            return
        }
        
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
        NotificationCenter.default.removeObserver(self)
    }
} 