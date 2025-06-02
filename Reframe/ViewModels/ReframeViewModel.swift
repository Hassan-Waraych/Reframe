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
    
    // MARK: - Dependencies
    private let reframeService = ReframeService.shared
    private let aiService = AIService.shared
    
    // MARK: - Computed Properties
    var remainingReframes: Int {
        reframeService.remainingReframes()
    }
    
    var canCreateReframe: Bool {
        reframeService.canCreateReframe()
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
                
                await MainActor.run {
                    self.reframedThought = reframe
                    self.currentReframe = newReframe
                    self.state = .success
                }
                
                await loadReframes()
                
            case .positive:
                state = .generating
                let affirmation = try await aiService.generateAffirmation(for: originalThought)
                let newReframe = try await reframeService.createReframe(
                    originalThought: originalThought,
                    reframedThought: affirmation,
                    category: "Positive Reflection"
                )
                
                await MainActor.run {
                    self.reframedThought = affirmation
                    self.currentReframe = newReframe
                    self.showReflectSuggestion = true
                    self.state = .success
                }
                
                await loadReframes()
                
            case .nonsense:
                do {
                    let nonsenseReframe = try await reframeService.createReframe(
                        originalThought: originalThought,
                        reframedThought: "I'm not quite sure how to reflect on that. Try sharing something that's been on your mind.",
                        category: "Nonsense"
                    )
                    
                    await MainActor.run {
                        self.currentReframe = nonsenseReframe
                        self.state = .success
                    }
                } catch {
                    if let error = error as NSError?, error.code == -3 {
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
    }
    
    func markAsHelpful() async {
        guard let reframe = currentReframe else { return }
        
        do {
            try await reframeService.markReframeAsHelpful(reframe)
            await loadReframes()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
} 