import SwiftUI

struct StreakView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let streakCount: Int
    @State private var showModal = false
    
    var body: some View {
        if streakCount > 0 {
            Button(action: { showModal = true }) {
                HStack(spacing: 8) {
                    Text("🔥")
                        .font(.system(size: 20))
                    
                    Text("Streak: ")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text("\(streakCount) " + (streakCount == 1 ? "day" : "days"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.colors.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    themeManager.colors.primary.opacity(0.1),
                                    themeManager.colors.primary.opacity(0.05)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: themeManager.colors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showModal) {
                StreakModalView(streakCount: streakCount)
                    .environmentObject(themeManager)
            }
        }
    }
}

struct StreakModalView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let streakCount: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("🔥")
                .font(.system(size: 48))
                .padding(.top, 24)
            Text("Streak!")
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(themeManager.colors.primary)
            Text("You've kept up your streak for \(streakCount) " + (streakCount == 1 ? "day" : "days") + " in a row!")
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundColor(themeManager.colors.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text("Consistency is powerful. Even small steps each day can lead to big changes. Be proud of yourself for showing up! 🌱")
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(themeManager.colors.textLight)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Button(action: { dismiss() }) {
                Text("Close")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [themeManager.colors.primary, themeManager.colors.primaryDark]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: themeManager.colors.primary.opacity(0.18), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(themeManager.colors.background.ignoresSafeArea())
    }
}

#Preview {
    StreakView(streakCount: 3)
        .environmentObject(ThemeManager())
} 