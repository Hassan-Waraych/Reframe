import SwiftUI

struct CoachCarousel: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var offset: CGFloat = 0
    
    // Sort coaches to show premium first, then duplicate the list for smooth looping
    private var sortedCoaches: [Coach] {
        let sorted = Coach.coaches.sorted { $0.isPremium && !$1.isPremium }
        return sorted + sorted // Duplicate the list for smooth looping
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(sortedCoaches) { coach in
                        CoachCard(coach: coach)
                            .frame(width: 140)
                    }
                }
                .offset(x: offset)
            }
            .disabled(true)
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    // Move by exactly one set of coaches
                    offset = -CGFloat(Coach.coaches.count * 148)
                }
            }
        }
    }
}

struct CoachCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let coach: Coach
    
    var body: some View {
        VStack(spacing: 6) {
            // Coach Emoji
            Text(coach.emoji)
                .font(.system(size: 28))
            
            // Coach Name
            Text(coach.name)
                .font(.custom("Quicksand-SemiBold", size: 14))
                .foregroundColor(themeManager.colors.text)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            // Premium Badge
            if coach.isPremium {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow)
                    .padding(3)
                    .background(Color.black.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    coach.isPremium ? 
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "FFD700").opacity(0.1),
                                Color(hex: "FFD700").opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [
                                themeManager.colors.surface,
                                themeManager.colors.surface
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    coach.isPremium ? Color(hex: "FFD700").opacity(0.3) : themeManager.colors.border,
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    CoachCarousel()
        .frame(height: 120)
        .environmentObject(ThemeManager())
} 