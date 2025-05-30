import SwiftUI

struct HomeOptionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var gradientColors: [Color] {
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
            .shadow(color: isSelected ? (title == "Reframe" ? themeManager.colors.primary : themeManager.colors.secondary).opacity(0.3) : Color.black.opacity(0.05),
                   radius: isSelected ? 12 : 4,
                   x: 0,
                   y: isSelected ? 6 : 2)
        }
    }
}

#Preview {
    HomeOptionButton(
        title: "Reframe",
        icon: "arrow.triangle.2.circlepath",
        isSelected: true
    ) {
        print("Button tapped")
    }
    .environmentObject(ThemeManager())
} 