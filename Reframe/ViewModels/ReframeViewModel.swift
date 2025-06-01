import Foundation
import SwiftUI
import FirebaseAuth

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

@MainActor
class ReframeViewModel: ObservableObject {
    @Published var originalThought: String = ""
    @Published var reframedThought: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var reframes: [Reframe] = []
    @Published var state: ReframeState = .idle
    @Published var showReflectSuggestion: Bool = false
    @Published var currentReframe: Reframe?
    
    private let reframeService = ReframeService.shared
    private let aiService = AIService.shared
    
    var remainingReframes: Int {
        let remaining = reframeService.remainingReframes()
        return remaining
    }
    
    var canCreateReframe: Bool {
        let canCreate = reframeService.canCreateReframe()
        return canCreate
    }
    
    var isGuestMode: Bool {
        return Auth.auth().currentUser == nil
    }
    
    func createReframe() async {
        guard !originalThought.isEmpty else {
            errorMessage = "Please enter a thought to reframe"
            showError = true
            return
        }
        
        print("Starting reframe process for thought: \(originalThought)")
        state = .classifying
        errorMessage = nil
        
        do {
            // Step 1: Classify the thought
            print("Classifying thought...")
            let classification = try await aiService.classifyThought(originalThought)
            print("Classification result: \(classification)")
            
            switch classification {
            case .negative:
                // Step 2: Generate reframe for negative thought
                print("Generating reframe for negative thought...")
                state = .generating
                let reframe = try await aiService.generateReframe(for: originalThought)
                print("Generated reframe: \(reframe)")
                
                // Step 3: Save to Firestore
                print("Saving reframe to Firestore...")
                let newReframe = try await reframeService.createReframe(
                    originalThought: originalThought,
                    reframedThought: reframe
                )
                print("Saved reframe with ID: \(newReframe.id ?? "unknown")")
                
                // Update UI state
                await MainActor.run {
                    self.reframedThought = reframe
                    self.currentReframe = newReframe
                    self.state = .success
                }
                
                print("Loading reframes to update UI...")
                await loadReframes()
                print("Reframe process completed successfully")
                
            case .positive:
                // For positive thoughts, generate an affirmation
                print("Generating affirmation for positive thought...")
                state = .generating
                let affirmation = try await aiService.generateAffirmation(for: originalThought)
                print("Generated affirmation: \(affirmation)")
                
                // Save as a positive reflection
                print("Saving positive reflection to Firestore...")
                let newReframe = try await reframeService.createReframe(
                    originalThought: originalThought,
                    reframedThought: affirmation,
                    category: "Positive Reflection"
                )
                print("Saved reflection with ID: \(newReframe.id ?? "unknown")")
                
                // Update UI state
                await MainActor.run {
                    self.reframedThought = affirmation
                    self.currentReframe = newReframe
                    self.showReflectSuggestion = true
                    self.state = .success
                }
                
                print("Loading reframes to update UI...")
                await loadReframes()
                print("Reflection process completed successfully")
                
            case .nonsense:
                await MainActor.run {
                    self.state = .error("I'm not quite sure how to reflect on that. Try sharing something that's been on your mind.")
                    self.errorMessage = "I'm not quite sure how to reflect on that. Try sharing something that's been on your mind."
                    self.showError = true
                }
                // Reset the state after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.resetState()
                }
            }
            
            // Clear input after successful processing
            await MainActor.run {
                self.originalThought = ""
            }
            
        } catch {
            print("Error in reframe process: \(error.localizedDescription)")
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