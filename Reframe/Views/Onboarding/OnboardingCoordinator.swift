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
        case coachIntro
        case signUp
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
            // Assign coach based on emotional needs
            if let savedNeeds = UserDefaults.standard.data(forKey: "selectedEmotionalNeeds"),
               let decoded = try? JSONDecoder().decode([String].self, from: savedNeeds) {
                Task {
                    do {
                        if let userId = Auth.auth().currentUser?.uid {
                            // Save emotional needs to user document
                            let db = Firestore.firestore()
                            try await db.collection("users").document(userId).setData([
                                "emotionalNeeds": decoded
                            ], merge: true)
                            
                            // Assign coach
                            assignedCoach = try await CoachService.shared.assignCoach(for: userId)
                            await MainActor.run {
                                currentStep = .coachIntro
                            }
                        } else {
                            // For guest users, assign a random coach
                            assignedCoach = Coach.coaches.randomElement() ?? Coach.coaches[0]
                            await MainActor.run {
                                currentStep = .signUp
                            }
                        }
                    } catch {
                        print("Error assigning coach: \(error)")
                        await MainActor.run {
                            currentStep = .signUp
                        }
                    }
                }
            } else {
                currentStep = .signUp
            }
        case .coachIntro:
            currentStep = .signUp
        case .signUp:
            currentStep = .firstThought
        case .firstThought:
            completeOnboarding()
        }
    }
    
    func skip() {
        switch currentStep {
        case .emotionalFraming:
            currentStep = .signUp
        case .coachIntro:
            currentStep = .signUp
        case .signUp:
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
    
    func handleGuestMode() {
        // Skip to first thought for guest users
        currentStep = .firstThought
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
            case .coachIntro:
                if let coach = coordinator.assignedCoach {
                    CoachIntroScreen(coach: coach)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                }
            case .signUp:
                SignUpScreen()
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