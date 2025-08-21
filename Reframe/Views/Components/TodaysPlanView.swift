import SwiftUI

struct TodaysPlanView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showMoodPicker = false
    let onMoodCheckInTapped: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.clipboard.fill")
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.colors.primary)
                
                Text("Today's Intentions")
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundColor(themeManager.colors.text)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Mood Check-in Button
                Button(action: {
                    onMoodCheckInTapped?()
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Share Your Mood")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                            
                            Text("Let's check in on how you're feeling today")
                                .font(.system(size: 13, weight: .regular, design: .default))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(16)
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
                    .cornerRadius(12)
                    .shadow(color: themeManager.colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            themeManager.selectedTheme == .sunsetSerenity ?
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.98),
                    Color(hex: "FFF0E6").opacity(0.95),
                    Color(hex: "FFE8D6").opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) : LinearGradient(
                gradient: Gradient(colors: [
                    themeManager.colors.surface,
                    themeManager.colors.surface
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            Group {
                if themeManager.selectedTheme == .sunsetSerenity {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FF6B35").opacity(0.4),
                                    Color(hex: "9B5DE5").opacity(0.3),
                                    Color(hex: "FF6B35").opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            }
        )
        .cornerRadius(20)
        .shadow(color: themeManager.selectedTheme == .sunsetSerenity ? Color(hex: "FF6B35").opacity(0.15) : Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        // New mood check-in flow will be triggered here
    }
}

#Preview {
    TodaysPlanView(onMoodCheckInTapped: nil)
        .environmentObject(ThemeManager())
}
