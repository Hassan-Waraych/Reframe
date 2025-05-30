import SwiftUI

struct OnboardingOptionButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Nunito-SemiBold", size: 16))
                .foregroundColor(isSelected ? .white : themeManager.colors.text)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: isSelected ? 
                            [color, color.opacity(0.8)] :
                            [themeManager.colors.surface, themeManager.colors.surface]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(isSelected ? color : themeManager.colors.border, lineWidth: 2)
                )
        }
    }
}

#Preview {
    OnboardingOptionButton(
        title: "Option",
        isSelected: true,
        color: .blue
    ) {
        print("Button tapped")
    }
    .environmentObject(ThemeManager())
} 