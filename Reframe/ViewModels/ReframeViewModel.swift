import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
class ReframeViewModel: ObservableObject {
    @Published var originalThought: String = ""
    @Published var reframedThought: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var reframes: [Reframe] = []
    
    private let reframeService = ReframeService.shared
    
    var remainingReframes: Int {
        let remaining = reframeService.remainingReframes()
        print("Debug: ViewModel - Remaining reframes: \(remaining)")
        return remaining
    }
    
    var canCreateReframe: Bool {
        let canCreate = reframeService.canCreateReframe()
        print("Debug: ViewModel - Can create reframe: \(canCreate)")
        return canCreate
    }
    
    var isGuestMode: Bool {
        return Auth.auth().currentUser == nil
    }
    
    // Test function to verify button press
    func testButton() {
        print("Debug: Test button pressed in ViewModel")
    }
    
    func createReframe() async {
        print("Debug: ViewModel - createReframe called")
        print("Debug: ViewModel - Original thought: '\(originalThought)'")
        
        guard !originalThought.isEmpty else {
            print("Debug: ViewModel - Cannot create reframe - original thought is empty")
            errorMessage = "Please enter a thought to reframe"
            showError = true
            return
        }
        
        print("Debug: ViewModel - Starting reframe creation")
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Replace with actual AI reframe generation
            let aiReframe = "This is a temporary reframe. AI integration coming soon!"
            print("Debug: ViewModel - Generated AI reframe: \(aiReframe)")
            
            try await reframeService.createReframe(
                originalThought: originalThought,
                reframedThought: aiReframe
            )
            
            print("Debug: ViewModel - Reframe created successfully")
            reframedThought = aiReframe
            await loadReframes()
            
            // Clear input after successful reframe
            originalThought = ""
        } catch {
            print("Debug: ViewModel - Error creating reframe: \(error)")
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func loadReframes() async {
        print("Debug: Starting to load reframes")
        isLoading = true
        errorMessage = nil
        
        do {
            reframes = try await reframeService.getReframes()
            print("Debug: Loaded \(reframes.count) reframes")
        } catch {
            print("Debug: Error loading reframes: \(error)")
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func deleteReframe(_ reframe: Reframe) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await reframeService.deleteReframe(reframe)
            await loadReframes()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
} 