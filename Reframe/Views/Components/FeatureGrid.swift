import SwiftUI

struct FeatureButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.colors.primary)
                
                Text(title)
                    .font(.custom("Quicksand-Bold", size: 16))
                    .foregroundColor(themeManager.colors.text)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(themeManager.colors.surface)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct FeatureGrid: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showAchievements = false
    @State private var showGuidedJournal = false
    @State private var showQuickCalm = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                FeatureButton(title: "Milestones", icon: "trophy.fill") {
                    showAchievements = true
                }
                
                FeatureButton(title: "Guided Prompts", icon: "text.bubble.fill") {
                    showGuidedJournal = true
                }
            }
            
            HStack(spacing: 16) {
                FeatureButton(title: "Quick Calm", icon: "heart.fill") {
                    showQuickCalm = true
                }
                
                FeatureButton(title: "Daily Wisdom", icon: "lightbulb.fill") {
                    // Action will be added later
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showAchievements) {
            NavigationView {
                AchievementsScreen()
            }
        }
        .sheet(isPresented: $showGuidedJournal) {
            GuidedJournalScreen()
        }
        .sheet(isPresented: $showQuickCalm) {
            QuickCalmScreen()
        }
    }
}

#Preview {
    FeatureGrid()
        .environmentObject(ThemeManager())
} 