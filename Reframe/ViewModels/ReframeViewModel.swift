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
        
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Replace with actual AI reframe generation
            let aiReframe = "This is a temporary reframe. AI integration coming soon!"
            
            try await reframeService.createReframe(
                originalThought: originalThought,
                reframedThought: aiReframe
            )
            
            reframedThought = aiReframe
            await loadReframes()
            
            // Clear input after successful reframe
            originalThought = ""
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func loadReframes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            reframes = try await reframeService.getReframes()
        } catch {
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