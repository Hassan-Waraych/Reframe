import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class CoachHomeViewModel: ObservableObject {
    @Published var currentCoach: Coach?
    @Published var historyItems: [CoachHistoryItem] = []
    @Published var messages: [CoachMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var availableCoaches: [Coach] = []
    @Published var coachUsageCount: Int = 0
    
    private let coachService = CoachService.shared
    private let authService = AuthService.shared
    
    var remainingCoachSessions: Int {
        let limit = authService.isPremiumUser() ? 25 : 1
        return limit - coachUsageCount
    }
    
    var canUseCoach: Bool {
        return remainingCoachSessions > 0
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get current user ID
            guard let userId = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "CoachHomeViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            }
            
            // Load assigned coach
            currentCoach = try await coachService.getCurrentCoach(for: userId)
            
            // Load history items
            historyItems = try await coachService.getHistory()
            
            // Load available coaches
            availableCoaches = Coach.coaches
            
            // Load today's coach usage count
            let db = Firestore.firestore()
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            
            let snapshot = try await db.collection("coachMessages")
                .whereField("userId", isEqualTo: userId)
                .whereField("timestamp", isGreaterThanOrEqualTo: startOfDay)
                .getDocuments()
            
            coachUsageCount = snapshot.documents.count
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func submitMessage(_ content: String) async {
        guard let coach = currentCoach else { return }
        
        // Check if user has reached their daily limit
        if !canUseCoach {
            errorMessage = "You've reached your daily coach session limit. Upgrade to premium for 25 sessions per day."
            showError = true
            return
        }
        
        do {
            // Send message and get response
            _ = try await coachService.sendMessage(content, coachId: coach.id)
            
            // Increment usage count
            coachUsageCount += 1
            
            // Reload history to show new conversation
            await loadData()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func markAsHelpful(_ item: CoachHistoryItem) async {
        do {
            // First check if we have a journal entry for this item
            if let journalEntry = JournalService.shared.getJournalEntryForCoach(historyItem: item) {
                // If already logged, update the existing entry to be a favorite
                try await JournalService.shared.updateEntryFavoriteStatus(journalEntry, isFavorite: true)
            } else {
                // If not logged yet, add as a favorite
                try await JournalService.shared.logCoachToJournal(historyItem: item)
                
                // Wait a moment for the entry to be available
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                if let newEntry = JournalService.shared.getJournalEntryForCoach(historyItem: item) {
                    try await JournalService.shared.updateEntryFavoriteStatus(newEntry, isFavorite: true)
                }
            }
            
            // Update the history item in Firestore
            try await coachService.markHistoryItemAsHelpful(item.id)
            
            // Update local state
            if let index = historyItems.firstIndex(where: { $0.id == item.id }) {
                historyItems[index].wasHelpful = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func saveToJournal(_ item: CoachHistoryItem) async {
        do {
            try await JournalService.shared.logCoachToJournal(historyItem: item)
            
            // Update local state
            if let index = historyItems.firstIndex(where: { $0.id == item.id }) {
                historyItems[index] = CoachHistoryItem(
                    id: item.id,
                    userId: item.userId,
                    coachId: item.coachId,
                    userMessage: item.userMessage,
                    coachResponse: item.coachResponse,
                    timestamp: item.timestamp,
                    wasHelpful: item.wasHelpful,
                    isSavedToJournal: true
                )
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func resetState() {
        errorMessage = nil
        showError = false
    }
} 