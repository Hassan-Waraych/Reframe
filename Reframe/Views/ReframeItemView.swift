import SwiftUI

struct ReframeItemView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let reframe: Reframe
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Original Thought
            VStack(alignment: .leading, spacing: 8) {
                Text("Original Thought")
                    .font(.custom("Nunito-Regular", size: 14))
                    .foregroundColor(themeManager.colors.textLight)
                
                Text(reframe.originalThought)
                    .font(.custom("Nunito-Regular", size: 16))
                    .foregroundColor(themeManager.colors.text)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeManager.colors.surface)
                    .cornerRadius(8)
            }
            
            // Reframed Thought
            VStack(alignment: .leading, spacing: 8) {
                Text("Reframed Thought")
                    .font(.custom("Nunito-Regular", size: 14))
                    .foregroundColor(themeManager.colors.textLight)
                
                Text(reframe.reframedThought)
                    .font(.custom("Nunito-Regular", size: 16))
                    .foregroundColor(themeManager.colors.text)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeManager.colors.primary.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Footer
            HStack {
                if let category = reframe.category {
                    Text(category)
                        .font(.custom("Nunito-Regular", size: 12))
                        .foregroundColor(themeManager.colors.textLight)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.colors.surface)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text(reframe.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.custom("Nunito-Regular", size: 12))
                    .foregroundColor(themeManager.colors.textLight)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.colors.error)
                }
                .padding(.leading, 8)
            }
        }
        .padding(16)
        .background(themeManager.colors.background)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ReframeItemView(
        reframe: Reframe(
            userId: "preview",
            originalThought: "I'm not good enough",
            reframedThought: "I am capable of growth and learning",
            timestamp: Date(),
            category: "Self-worth"
        ),
        onDelete: {}
    )
    .environmentObject(ThemeManager())
} 