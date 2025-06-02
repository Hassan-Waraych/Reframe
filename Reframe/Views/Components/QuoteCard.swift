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
                    .font(.custom("Quicksand-SemiBold", size: 20))
                    .foregroundColor(themeManager.colors.text)
            }
            
            Text(quote)
                .font(.custom("Nunito-Regular", size: 16))
                .foregroundColor(themeManager.colors.textLight)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.colors.surface)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    QuoteCard(quote: "Your daily dose of wisdom will appear here...", isAnimating: .constant(true))
        .environmentObject(ThemeManager())
} 