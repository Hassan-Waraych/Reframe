import SwiftUI

struct EmotionalNeed: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
}

struct EmotionalFramingScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @State private var selectedNeeds: Set<String> = []
    @State private var isAnimating = false
    
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
                    Text("When do you need Reframe most?")
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text("Select all areas where you'd like support")
                        .font(.custom("Nunito-Regular", size: 16))
                        .foregroundColor(themeManager.colors.textLight)
                    
                    if !selectedNeeds.isEmpty {
                        Text("\(selectedNeeds.count) selected")
                            .font(.custom("Quicksand-SemiBold", size: 14))
                            .foregroundColor(themeManager.colors.primary)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Needs Grid
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                    ForEach(emotionalNeeds) { need in
                        NeedCard(need: need, isSelected: selectedNeeds.contains(need.id)) {
                            if selectedNeeds.contains(need.id) {
                                selectedNeeds.remove(need.id)
                            } else {
                                selectedNeeds.insert(need.id)
                            }
                        }
                    }
                }
                
                // Footer Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        // Save selected needs
                        if let encoded = try? JSONEncoder().encode(Array(selectedNeeds)) {
                            UserDefaults.standard.set(encoded, forKey: "selectedEmotionalNeeds")
                        }
                        coordinator.next()
                    }) {
                        Text("Continue")
                            .font(.custom("Nunito-SemiBold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        themeManager.colors.primary,
                                        themeManager.colors.primaryDark
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: themeManager.colors.primary.opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    .opacity(selectedNeeds.isEmpty ? 0.5 : 1)
                    .disabled(selectedNeeds.isEmpty)
                    
                    Button(action: {
                        coordinator.skip()
                    }) {
                        Text("Skip for now")
                            .font(.custom("Nunito-Medium", size: 16))
                            .foregroundColor(themeManager.colors.textLight)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }
            }
            .padding(24)
        }
        .background(themeManager.colors.background)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
            // Load previously selected needs
            if let savedNeeds = UserDefaults.standard.data(forKey: "selectedEmotionalNeeds"),
               let decoded = try? JSONDecoder().decode([String].self, from: savedNeeds) {
                selectedNeeds = Set(decoded)
            }
        }
    }
}

struct NeedCard: View {
    let need: EmotionalNeed
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: need.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? themeManager.colors.primary : themeManager.colors.text)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(need.title)
                        .font(.custom("Quicksand-SemiBold", size: 16))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text(need.description)
                        .font(.custom("Nunito-Regular", size: 14))
                        .foregroundColor(themeManager.colors.textLight)
                        .lineSpacing(4)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(themeManager.colors.primary)
                }
            }
            .padding(16)
            .background(themeManager.colors.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? themeManager.colors.primary : themeManager.colors.border, lineWidth: 2)
            )
        }
    }
}

#Preview {
    EmotionalFramingScreen()
        .environmentObject(ThemeManager())
        .environmentObject(OnboardingCoordinator())
} 