import SwiftUI

struct InsightsScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int
    @StateObject private var viewModel = ReframeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Insights")
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text("Track your journey and progress")
                        .font(.custom("Nunito-Regular", size: 16))
                        .foregroundColor(themeManager.colors.textLight)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // 1. Calendar View (Free)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Activity Calendar")
                        .font(.custom("Quicksand-Bold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                        .padding(.horizontal)
                    
                    CalendarGridView()
                        .padding(.horizontal)
                }
                
                // 2. Streak Counter (Free)
                VStack(alignment: .center, spacing: 16) {
                    Text("Your Streak")
                        .font(.custom("Quicksand-Bold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                    
                    if viewModel.currentStreak > 0 {
                        StreakView(streakCount: viewModel.currentStreak)
                            .padding(.horizontal)
                    } else {
                        // Placeholder for when no streak
                        HStack(spacing: 8) {
                            Text("🔥")
                                .font(.system(size: 20))
                            
                            Text("Start your streak today!")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(themeManager.colors.textLight)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.colors.surface)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal)
                    }
                }
                
                // 3. Advanced Analytics (Premium Only) - Placeholder for now
                VStack(alignment: .leading, spacing: 16) {
                    Text("Advanced Insights")
                        .font(.custom("Quicksand-Bold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                        .padding(.horizontal)
                    
                    Text("Unlock trends and mood analytics")
                        .font(.custom("Nunito-Regular", size: 14))
                        .foregroundColor(themeManager.colors.textLight)
                        .padding(.horizontal)
                    
                    // Placeholder for premium features
                    VStack(spacing: 12) {
                        PremiumInsightsCard(
                            title: "📈 Mood Trend Chart",
                            description: "Track your emotional patterns over time",
                            isLocked: true
                        )
                        
                        PremiumInsightsCard(
                            title: "📅 Calendar Heatmap",
                            description: "Visualize your daily mood intensity",
                            isLocked: true
                        )
                        
                        PremiumInsightsCard(
                            title: "📊 Entry Type Breakdown",
                            description: "See your balance of reframes vs reflections",
                            isLocked: true
                        )
                        
                        PremiumInsightsCard(
                            title: "🧭 Personalized Insights",
                            description: "AI-powered recommendations based on your patterns",
                            isLocked: true
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 24)
        }
        .background(themeManager.colors.background)
        .navigationBarHidden(true)
        .task {
            await viewModel.loadStreak()
        }
    }
}

#Preview {
    InsightsScreen(selectedTab: .constant(3))
        .environmentObject(ThemeManager())
} 