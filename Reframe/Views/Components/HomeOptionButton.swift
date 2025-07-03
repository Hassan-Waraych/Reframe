import SwiftUI

struct HomeOptionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var gradientColors: [Color] {
        if themeManager.selectedTheme == .sunsetSerenity {
            if title == "Reframe" {
                return isSelected ? [
                    Color(hex: "FF6B35"), // Sunset orange
                    Color(hex: "E55A2B")  // Darker orange
                ] : [
                    Color.white.opacity(0.9),
                    Color(hex: "FFF8F0").opacity(0.8)
                ]
            } else {
                return isSelected ? [
                    Color(hex: "9B5DE5"), // Lavender
                    Color(hex: "7B4B8E")  // Darker purple
                ] : [
                    Color.white.opacity(0.9),
                    Color(hex: "FFF8F0").opacity(0.8)
                ]
            }
        } else {
            if title == "Reframe" {
                return isSelected ? [
                    themeManager.colors.primary,
                    themeManager.colors.primaryDark
                ] : [
                    themeManager.colors.surface,
                    themeManager.colors.surface
                ]
            } else {
                return isSelected ? [
                    themeManager.colors.secondary,
                    Color(hex: "7B4B8E") // Darker purple
                ] : [
                    themeManager.colors.surface,
                    themeManager.colors.surface
                ]
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                
                Text(title)
                    .font(.custom("Nunito-SemiBold", size: 18))
            }
            .foregroundColor(isSelected ? .white : themeManager.colors.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .overlay(
                Group {
                    if themeManager.selectedTheme == .sunsetSerenity && isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "FFD700").opacity(0.8),
                                        Color(hex: "FF6B35").opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    }
                }
            )
            .shadow(color: isSelected ? 
                (themeManager.selectedTheme == .sunsetSerenity ? 
                    (title == "Reframe" ? Color(hex: "FF6B35") : Color(hex: "9B5DE5")) : 
                    (title == "Reframe" ? themeManager.colors.primary : themeManager.colors.secondary)
                ).opacity(0.4) : 
                (themeManager.selectedTheme == .sunsetSerenity ? Color(hex: "FF6B35").opacity(0.15) : Color.black.opacity(0.05)),
                   radius: isSelected ? 15 : 6,
                   x: 0,
                   y: isSelected ? 8 : 3)
        }
    }
}

#Preview {
    HomeOptionButton(
        title: "Reframe",
        icon: "arrow.triangle.2.circlepath",
        isSelected: true
    ) {
        // Button action
    }
    .environmentObject(ThemeManager())
} 