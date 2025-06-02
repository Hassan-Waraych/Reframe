import SwiftUI

/// A compact view component that displays a reframe in a condensed format
struct CompactReframeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let reframe: Reframe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reframe.originalThought)
                .font(.custom("Nunito-Regular", size: 14))
                .foregroundColor(themeManager.colors.textLight)
                .lineLimit(1)
            
            Text(reframe.reframedThought)
                .font(.custom("Nunito-SemiBold", size: 16))
                .foregroundColor(themeManager.colors.text)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.colors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.colors.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    CompactReframeView(reframe: Reframe(
        userId: "preview",
        originalThought: "I'm not good enough",
        reframedThought: "I am capable of growth and improvement",
        timestamp: Date(),
        category: nil
    ))
    .environmentObject(ThemeManager())
} 