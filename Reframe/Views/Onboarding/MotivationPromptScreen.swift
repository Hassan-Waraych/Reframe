import SwiftUI

struct MotivationPromptScreen: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: OnboardingCoordinator
    @State private var selectedMotivations: Set<String> = []
    @State private var animateContent = false
    @State private var animateCards = false
    
    let motivations = [
        MotivationOption(id: "confidence", title: "Build Confidence", description: "Develop unshakeable self-belief", icon: "shield.fill", color: Color.blue),
        MotivationOption(id: "stress", title: "Manage Stress", description: "Find calm in chaos", icon: "leaf.fill", color: Color.green),
        MotivationOption(id: "mood", title: "Improve Mood", description: "Cultivate lasting happiness", icon: "heart.fill", color: Color.pink),
        MotivationOption(id: "resilience", title: "Grow Resilience", description: "Bounce back stronger", icon: "flame.fill", color: Color.orange)
    ]
    
    var body: some View {
        ZStack {
            // Background
            themeManager.colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What would you most like to achieve?")
                            .font(.system(size: themeManager.typography.fontSize.h2, weight: .bold))
                            .foregroundColor(themeManager.colors.text)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        Text("Choose what matters most to you")
                            .font(.system(size: themeManager.typography.fontSize.body))
                            .foregroundColor(themeManager.colors.textLight)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Motivation Cards Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(Array(motivations.enumerated()), id: \.element.id) { index, motivation in
                            MotivationCard(
                                motivation: motivation,
                                isSelected: selectedMotivations.contains(motivation.id),
                                action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        if selectedMotivations.contains(motivation.id) {
                                            selectedMotivations.remove(motivation.id)
                                        } else {
                                            selectedMotivations.insert(motivation.id)
                                        }
                                    }
                                }
                            )
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 50)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateCards)
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Continue Button
                    Button(action: {
                        coordinator.next()
                    }) {
                        HStack(spacing: 8) {
                            Text("Continue")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
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
                        .shadow(color: themeManager.colors.primary.opacity(0.3), radius: 10, x: 0, y: 4)
                    }
                    .disabled(selectedMotivations.isEmpty)
                    .opacity(selectedMotivations.isEmpty ? 0.5 : 1)
                    .scaleEffect(selectedMotivations.isEmpty ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedMotivations.isEmpty)
                    
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
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateCards = true
                }
            }
        }
    }
}

struct MotivationOption: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct MotivationCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let motivation: MotivationOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    motivation.color.opacity(0.2),
                                    motivation.color.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: motivation.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(motivation.color)
                }
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
                
                // Text Content
                VStack(spacing: 4) {
                    Text(motivation.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.colors.text)
                        .multilineTextAlignment(.center)
                    
                    Text(motivation.description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.colors.textLight)
                        .multilineTextAlignment(.center)
                }
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(motivation.color)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? motivation.color : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .shadow(
                color: isSelected ? motivation.color.opacity(0.3) : Color.black.opacity(0.05),
                radius: isSelected ? 12 : 8,
                x: 0,
                y: isSelected ? 6 : 4
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

#Preview {
    MotivationPromptScreen()
        .environmentObject(ThemeManager())
        .environmentObject(OnboardingCoordinator())
} 