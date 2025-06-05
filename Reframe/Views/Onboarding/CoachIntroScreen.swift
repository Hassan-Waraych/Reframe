import SwiftUI

struct CoachIntroScreen: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: OnboardingCoordinator
    let coach: Coach
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meet Your Coach")
                        .font(.system(size: themeManager.typography.fontSize.h2, weight: .bold))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text("Your personalized guide to emotional well-being")
                        .font(.system(size: themeManager.typography.fontSize.body))
                        .foregroundColor(themeManager.colors.textLight)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Coach Card
                VStack(spacing: 24) {
                    // Emoji and Name
                    VStack(spacing: 16) {
                        Text(coach.emoji)
                            .font(.system(size: 64))
                        
                        Text(coach.name)
                            .font(.system(size: themeManager.typography.fontSize.h2, weight: .bold))
                            .foregroundColor(themeManager.colors.text)
                    }
                    
                    // Description
                    Text(coach.description)
                        .font(.system(size: themeManager.typography.fontSize.body))
                        .foregroundColor(themeManager.colors.text)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Tone Summary
                    VStack(spacing: 8) {
                        Text("Their Approach")
                            .font(.system(size: themeManager.typography.fontSize.h3, weight: .semibold))
                            .foregroundColor(themeManager.colors.text)
                        
                        Text(coach.toneSummary)
                            .font(.system(size: themeManager.typography.fontSize.body))
                            .foregroundColor(themeManager.colors.textLight)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(24)
                .background(themeManager.colors.surface)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                // Continue Button
                Button(action: {
                    coordinator.next()
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(themeManager.colors.primary)
                        .cornerRadius(16)
                }
            }
            .padding(24)
        }
        .background(themeManager.colors.background)
    }
}

#Preview {
    CoachIntroScreen(coach: Coach(
        id: "theo",
        name: "Theo",
        emoji: "🍃",
        description: "Grounded and calm. Helps manage anxiety and perfectionism.",
        toneSummary: "Soothing, mindful, realistic reassurance.",
        covers: ["anxiety", "perfectionism", "stress"],
        background: "Theo brings a unique blend of mindfulness and practical wisdom to his coaching. With a background in meditation and cognitive behavioral therapy, he helps you find peace in chaos and clarity in confusion.",
        specialties: [
            "Mindfulness techniques",
            "Anxiety management",
            "Perfectionism reframing",
            "Stress reduction"
        ],
        approach: "Theo believes in meeting you where you are, using gentle guidance to help you find your own path to peace. He combines practical exercises with deep listening to help you build resilience and find balance.",
        quote: "Peace isn't the absence of chaos, but the ability to find calm within it."
    ))
    .environmentObject(ThemeManager())
    .environmentObject(OnboardingCoordinator())
} 