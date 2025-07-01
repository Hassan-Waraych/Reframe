import Foundation
import SwiftUI
import FirebaseAuth

/// Represents the current state of the reframe process
enum ReframeState: Equatable {
    case idle
    case classifying
    case generating
    case success
    case error(String)
    
    static func == (lhs: ReframeState, rhs: ReframeState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.classifying, .classifying),
             (.generating, .generating),
             (.success, .success):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

/// ViewModel responsible for managing the reframe feature's state and business logic
@MainActor
class ReframeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var originalThought: String = ""
    @Published var reframedThought: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var reframes: [Reframe] = []
    @Published var state: ReframeState = .idle
    @Published var showReflectSuggestion: Bool = false
    @Published var currentReframe: Reframe?
    @Published var showNonsenseCooldown: Bool = false
    @Published var selectedMode: HomeOption = .reframe
    @Published var isCurrentReframeLogged: Bool = false
    @Published var currentStreak: Int = 0
    
    // MARK: - Dependencies
    private let reframeService: ReframeService
    private let aiService: AIService
    let journalService: JournalService
    private let streakService: StreakService
    let authService: AuthService
    
    init(reframeService: ReframeService = .shared,
         aiService: AIService = .shared,
         journalService: JournalService = .shared,
         streakService: StreakService = .shared,
         authService: AuthService = .shared) {
        self.reframeService = reframeService
        self.aiService = aiService
        self.journalService = journalService
        self.streakService = streakService
        self.authService = authService
    }
    
    // MARK: - Computed Properties
    var remainingReframes: Int {
        // Only count non-reflection entries
        let usedReframes = reframes.filter { $0.category != "Reflection" }.count
        let limit = authService.isPremiumUser() ? Int.max : 3
        return limit - usedReframes
    }
    
    var canCreateReframe: Bool {
        // Only check limit for reframes, not reflections
        if selectedMode == .reflect {
            return true
        }
        return remainingReframes > 0
    }
    
    var isGuestMode: Bool {
        Auth.auth().currentUser == nil
    }
    
    // MARK: - Public Methods
    func createReframe() async {
        guard !originalThought.isEmpty else {
            errorMessage = "Please enter a thought to reframe"
            showError = true
            return
        }
        
        state = .classifying
        errorMessage = nil
        
        do {
            let classification = try await aiService.classifyThought(originalThought)
            
            switch classification {
            case .negative:
                state = .generating
                let reframe = try await aiService.generateReframe(for: originalThought)
                let newReframe = try await reframeService.createReframe(
                    originalThought: originalThought,
                    reframedThought: reframe
                )
                
                // Update streak
                try await streakService.updateStreak()
                currentStreak = try await streakService.getCurrentStreak()
                
                await MainActor.run {
                    self.reframedThought = reframe
                    self.currentReframe = newReframe
                    self.isCurrentReframeLogged = journalService.isReframeLogged(reframe: newReframe)
                    self.state = .success
                }
                
                await loadReframes()
                
                // Force check milestones after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Task {
                        await MilestoneService.shared.forceCheckMilestones()
                    }
                }
                
            case .positive:
                state = .generating
                let affirmation = try await aiService.generateAffirmation(for: originalThought)
                let newReframe = try await reframeService.createReframe(
                    originalThought: originalThought,
                    reframedThought: affirmation,
                    category: "Positive Reflection"
                )
                
                // Update streak
                try await streakService.updateStreak()
                currentStreak = try await streakService.getCurrentStreak()
            
                await MainActor.run {
                    self.reframedThought = affirmation
                    self.currentReframe = newReframe
                    self.isCurrentReframeLogged = journalService.isReframeLogged(reframe: newReframe)
                    self.showReflectSuggestion = true
                    self.state = .success
                }
                
                await loadReframes()
                
                // Force check milestones after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Task {
                        await MilestoneService.shared.forceCheckMilestones()
                    }
                }
                
            case .nonsense:
                do {
                    let nonsenseReframe = try await reframeService.createReframe(
                        originalThought: originalThought,
                        reframedThought: "I'm not quite sure how to reflect on that. Try sharing something that's been on your mind.",
                        category: "Nonsense"
                    )
                    
                    // Update streak
                    try await streakService.updateStreak()
                    currentStreak = try await streakService.getCurrentStreak()
                    
                    await MainActor.run {
                        self.currentReframe = nonsenseReframe
                        self.isCurrentReframeLogged = journalService.isReframeLogged(reframe: nonsenseReframe)
                        self.state = .success
                    }
                } catch let error as NSError {
                    if error.code == -3 {
                        await MainActor.run {
                            self.showNonsenseCooldown = true
                            self.state = .idle
                        }
                    } else {
                        throw error
                    }
                }
            }
            
            await MainActor.run {
                self.originalThought = ""
            }
            
        } catch {
            await MainActor.run {
                self.state = .error(error.localizedDescription)
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    func createReflection() async {
        guard !originalThought.isEmpty else {
            errorMessage = "Please enter your reflection"
            showError = true
            return
        }
        
        state = .generating
        errorMessage = nil
        
        do {
            // Create the reframe entry
            let newReframe = try await reframeService.createReframe(
                originalThought: originalThought,
                reframedThought: originalThought, // For reflections, we keep the original thought
                category: "Reflection"
            )
            
            // Add to journal
            try await journalService.addEntry(content: originalThought)
            
            // Update streak
            try await streakService.updateStreak()
            currentStreak = try await streakService.getCurrentStreak()
            
            await MainActor.run {
                self.currentReframe = newReframe
                self.state = .success
            }
            
            await loadReframes()
            
            await MainActor.run {
                self.originalThought = ""
            }
            
        } catch {
            await MainActor.run {
                self.state = .error(error.localizedDescription)
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    func loadReframes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loadedReframes = try await reframeService.getReframes()
            await MainActor.run {
                self.reframes = loadedReframes
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    func deleteReframe(_ reframe: Reframe) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await reframeService.deleteReframe(reframe)
            await loadReframes()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    func resetState() {
        state = .idle
        showReflectSuggestion = false
        errorMessage = nil
        showError = false
        currentReframe = nil
        reframedThought = ""
        isCurrentReframeLogged = false
    }
    
    func markAsHelpful() async {
        guard let reframe = currentReframe else { return }
        
        do {
            // Update the reframe in Firestore
            try await reframeService.updateReframe(reframe.id ?? "", helped: true)
            
            // Handle journal entry
            if isCurrentReframeLogged {
                // If already logged, update the existing entry to be a favorite
                if let existingEntry = journalService.getJournalEntryForReframe(reframe: reframe) {
                    try await journalService.updateEntryFavoriteStatus(existingEntry, isFavorite: true)
                }
            } else {
                // If not logged yet, add as a favorite
                try await journalService.logReframeToJournal(reframe: reframe)
                
                // Wait a moment for the entry to be available
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                if let newEntry = journalService.getJournalEntryForReframe(reframe: reframe) {
                    try await journalService.updateEntryFavoriteStatus(newEntry, isFavorite: true)
                    await MainActor.run {
                        self.isCurrentReframeLogged = true
                    }
                }
            }
            
            // Update local state
            await MainActor.run {
                if let index = reframes.firstIndex(where: { $0.id == reframe.id }) {
                    var updatedReframe = reframe
                    updatedReframe.helped = true
                    reframes[index] = updatedReframe
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    func logToJournal() async {
        guard let reframe = currentReframe else { return }
        
        do {
            try await journalService.logReframeToJournal(reframe: reframe)
            await MainActor.run {
                self.isCurrentReframeLogged = true
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    func loadStreak() async {
        do {
            currentStreak = try await streakService.getCurrentStreak()
        } catch {
            print("Error loading streak: \(error.localizedDescription)")
        }
    }
} 