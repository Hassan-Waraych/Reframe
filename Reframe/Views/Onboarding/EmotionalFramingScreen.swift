import SwiftUI

struct EmotionalFramingScreen: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: OnboardingCoordinator
    @State private var selectedNeeds: Set<String> = []
    
    let emotionalNeeds = [
        EmotionalNeed(id: "overthinking", title: "Overthinking", description: "Help me break free from repetitive negative thoughts", icon: "brain"),
        EmotionalNeed(id: "self-doubt", title: "Self-Doubt", description: "Build confidence and trust in my abilities", icon: "shield"),
        EmotionalNeed(id: "anxiety", title: "Anxiety", description: "Find calm and perspective in stressful moments", icon: "leaf"),
        EmotionalNeed(id: "perfectionism", title: "Perfectionism", description: "Embrace progress over perfection", icon: "star"),
        EmotionalNeed(id: "relationships", title: "Relationships", description: "Navigate social situations with more clarity", icon: "person.2"),
        EmotionalNeed(id: "stress", title: "Stress Management", description: "Develop healthier coping mechanisms", icon: "figure.walk"),
        EmotionalNeed(id: "self-worth", title: "Self-Worth", description: "Build a stronger sense of self-value", icon: "heart"),
        EmotionalNeed(id: "change", title: "Life Changes", description: "Adapt to transitions and new situations", icon: "arrow.triangle.branch")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("What brings you here?")
                        .font(.system(size: themeManager.typography.fontSize.h2, weight: .bold))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text("Select the areas you'd like to work on")
                        .font(.system(size: themeManager.typography.fontSize.body))
                        .foregroundColor(themeManager.colors.textLight)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Needs Grid
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                    ForEach(emotionalNeeds) { need in
                        NeedCard(
                            need: need,
                            isSelected: selectedNeeds.contains(need.id),
                            action: {
                                if selectedNeeds.contains(need.id) {
                                    selectedNeeds.remove(need.id)
                                } else {
                                    selectedNeeds.insert(need.id)
                                }
                            }
                        )
                    }
                }
                
                // Continue Button
                Button(action: {
                    // Save selected needs to UserDefaults
                    if let encoded = try? JSONEncoder().encode(Array(selectedNeeds)) {
                        UserDefaults.standard.set(encoded, forKey: "selectedEmotionalNeeds")
                    }
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
                .disabled(selectedNeeds.isEmpty)
                .opacity(selectedNeeds.isEmpty ? 0.5 : 1)
                
                // Skip Button
                Button(action: {
                    coordinator.next()
                }) {
                    Text("Skip for now")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.colors.textLight)
                }
            }
            .padding(24)
        }
        .background(themeManager.colors.background)
        .onAppear {
            // Load previously selected needs if any
            if let savedNeeds = UserDefaults.standard.data(forKey: "selectedEmotionalNeeds"),
               let decoded = try? JSONDecoder().decode([String].self, from: savedNeeds) {
                selectedNeeds = Set(decoded)
            }
        }
    }
}

#Preview {
    EmotionalFramingScreen()
        .environmentObject(ThemeManager())
        .environmentObject(OnboardingCoordinator())
} 