import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class OnboardingCoordinator: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var hasCompletedOnboarding = false
    @Published var assignedCoach: Coach?
    
    enum OnboardingStep {
        case welcome
        case emotionalFraming
        case motivationPrompt
        case coachIntro
        case valuePitch
        case signUp
        case premiumPaywall
        case firstThought
    }
    
    init() {
        // Load completion state
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func next() {
        switch currentStep {
        case .welcome:
            currentStep = .emotionalFraming
        case .emotionalFraming:
            currentStep = .motivationPrompt
        case .motivationPrompt:
            // Assign coach based on emotional needs
            if let savedNeeds = UserDefaults.standard.data(forKey: "selectedEmotionalNeeds"),
               let decoded = try? JSONDecoder().decode([String].self, from: savedNeeds) {
                Task {
                    do {
                        // Get only free coaches
                        let freeCoaches = Coach.coaches.filter { !$0.isPremium }
                        
                        // Find coaches that cover the selected emotional needs
                        let matchingCoaches = freeCoaches.filter { coach in
                            // Check if coach covers any of the selected needs
                            !Set(coach.covers).isDisjoint(with: Set(decoded))
                        }
                        
                        // If no exact matches, use a random free coach
                        assignedCoach = matchingCoaches.randomElement() ?? freeCoaches.randomElement()
                        
                        // Save emotional needs and coach to Firestore if user is already signed in
                        if let userId = Auth.auth().currentUser?.uid {
                            let db = Firestore.firestore()
                            try await db.collection("users").document(userId).setData([
                                "emotionalNeeds": decoded,
                                "coachId": assignedCoach?.id ?? "",
                                "coachAssignedAt": FieldValue.serverTimestamp()
                            ], merge: true)
                        }
                        
                        await MainActor.run {
                            currentStep = .coachIntro
                        }
                    } catch {
                        await MainActor.run {
                            currentStep = .valuePitch
                        }
                    }
                }
            } else {
                currentStep = .valuePitch
            }
        case .coachIntro:
            currentStep = .valuePitch
        case .valuePitch:
            currentStep = .signUp
        case .signUp:
            currentStep = .premiumPaywall
        case .premiumPaywall:
            currentStep = .firstThought
        case .firstThought:
            completeOnboarding()
        }
    }
    
    func skip() {
        switch currentStep {
        case .emotionalFraming:
            currentStep = .motivationPrompt
        case .motivationPrompt:
            currentStep = .valuePitch
        case .coachIntro:
            currentStep = .valuePitch
        case .valuePitch:
            currentStep = .signUp
        case .signUp:
            currentStep = .premiumPaywall
        case .premiumPaywall:
            currentStep = .firstThought
        case .firstThought:
            completeOnboarding()
        default:
            break
        }
    }
    
    func reset() {
        currentStep = .welcome
        hasCompletedOnboarding = false
        assignedCoach = nil
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    // Helper function to save coach to user's account
    func saveCoachToUserAccount() async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              let coach = assignedCoach else { return }
        
        let db = Firestore.firestore()
        try await db.collection("users").document(userId).setData([
            "coachId": coach.id,
            "coachAssignedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
}

struct OnboardingView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        ZStack {
            switch coordinator.currentStep {
            case .welcome:
                WelcomeScreen()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            case .emotionalFraming:
                EmotionalFramingScreen()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            case .motivationPrompt:
                MotivationPromptScreen()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            case .coachIntro:
                if let coach = coordinator.assignedCoach {
                    CoachIntroScreen(coach: coach)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                }
            case .valuePitch:
                ValuePitchScreen()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            case .signUp:
                SignUpScreen()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            case .premiumPaywall:
                OnboardingPaywallScreen()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            case .firstThought:
                FirstThoughtScreen()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            }
        }
        .animation(.spring(), value: coordinator.currentStep)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(ThemeManager())
        .environmentObject(OnboardingCoordinator())
        .environmentObject(AuthService.shared)
} 