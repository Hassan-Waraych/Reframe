import SwiftUI

/// A card component that displays a daily quote with animation
struct QuoteCard: View {
    let quote: String
    @Binding var isAnimating: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.colors.primary)
                
                Text("Daily Quote")
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundColor(themeManager.colors.text)
            }
            
            Text(quote)
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(themeManager.colors.textLight)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
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
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
    }
}

#Preview {
    QuoteCard(quote: "Your daily dose of wisdom will appear here...", isAnimating: .constant(true))
        .environmentObject(ThemeManager())
} 