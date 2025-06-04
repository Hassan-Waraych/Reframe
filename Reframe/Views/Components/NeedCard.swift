import SwiftUI

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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text(need.description)
                        .font(.system(size: 14))
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
    NeedCard(
        need: EmotionalNeed(
            id: "overthinking",
            title: "Overthinking",
            description: "Help me break free from repetitive negative thoughts",
            icon: "brain"
        ),
        isSelected: true,
        action: {}
    )
    .environmentObject(ThemeManager())
} 