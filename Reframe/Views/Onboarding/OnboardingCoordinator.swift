import SwiftUI

class OnboardingCoordinator: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var hasCompletedOnboarding = false
    
    enum OnboardingStep {
        case welcome
        case emotionalFraming
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