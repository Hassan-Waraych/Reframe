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
                
                // 3. Mood Trend Chart (Premium Only)
                if viewModel.authService.isPremiumUser() {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Mood Trend Chart")
                            .font(.custom("Quicksand-Bold", size: 20))
                            .foregroundColor(themeManager.colors.text)
                            .padding(.horizontal)
                        
                        PremiumMoodTrendChartView()
                            .padding(.horizontal)
                    }
                }
                
                // 4. Advanced Analytics (Premium Only) - Only show for free users
                if !viewModel.authService.isPremiumUser() {
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

// MARK: - Premium Mood Trend Chart View
struct PremiumMoodTrendChartView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedDataPoint: MoodDataPoint?
    @State private var animateChart = false
    
    // Mock data - easily replaceable with real data
    private let moodData: [MoodDataPoint] = [
        MoodDataPoint(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, moodScore: 6.2, breakdown: [MoodActivity(icon: "📓", label: "3 Journal Entries"), MoodActivity(icon: "💬", label: "1 Coach Session")]),
        MoodDataPoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, moodScore: 7.1, breakdown: [MoodActivity(icon: "📓", label: "2 Journal Entries"), MoodActivity(icon: "🪞", label: "2 Reflections")]),
        MoodDataPoint(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, moodScore: 5.8, breakdown: [MoodActivity(icon: "📓", label: "1 Journal Entry")]),
        MoodDataPoint(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, moodScore: 8.3, breakdown: [MoodActivity(icon: "💬", label: "2 Coach Sessions"), MoodActivity(icon: "🪞", label: "1 Reflection")]),
        MoodDataPoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, moodScore: 7.5, breakdown: [MoodActivity(icon: "📓", label: "2 Journal Entries"), MoodActivity(icon: "🪞", label: "1 Reflection")]),
        MoodDataPoint(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, moodScore: 8.9, breakdown: [MoodActivity(icon: "💬", label: "1 Coach Session"), MoodActivity(icon: "🪞", label: "2 Reflections")]),
        MoodDataPoint(date: Date(), moodScore: 8.1, breakdown: [MoodActivity(icon: "📓", label: "2 Journal Entries"), MoodActivity(icon: "💬", label: "1 Coach Session")])
    ]
    
    private var averageMood: Double {
        moodData.map { $0.moodScore }.reduce(0, +) / Double(moodData.count)
    }
    
    private var moodChange: Double {
        let firstWeek = moodData.prefix(3).map { $0.moodScore }.reduce(0, +) / 3
        let secondWeek = moodData.suffix(3).map { $0.moodScore }.reduce(0, +) / 3
        return ((secondWeek - firstWeek) / firstWeek) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Title
            Text("Mood Over Time")
                .font(.custom("Nunito-Regular", size: 18))
                .foregroundColor(themeManager.colors.text)
                .padding(.top, 8)
            // Stat
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(String(format: "%.1f", averageMood))
                    .font(.custom("Quicksand-Bold", size: 40))
                    .foregroundColor(themeManager.colors.text)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("Last 7 Days")
                            .font(.custom("Nunito-Regular", size: 16))
                            .foregroundColor(themeManager.colors.textLight)
                        Text(String(format: "%+.0f%%", moodChange))
                            .font(.custom("Nunito-Bold", size: 16))
                            .foregroundColor(.green)
                    }
                }
            }
            // Tap-off area above chart
            if selectedDataPoint != nil {
                Color.clear
                    .contentShape(Rectangle())
                    .frame(height: 16)
                    .onTapGesture {
                        withAnimation { selectedDataPoint = nil }
                    }
            }
            // Chart
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    ZStack {
                        ChartLineThroughPoints(data: moodData, animate: animateChart)
                        ForEach(Array(moodData.enumerated()), id: \.offset) { index, dataPoint in
                            ChartDataPoint(
                                dataPoint: dataPoint,
                                index: index,
                                totalPoints: moodData.count,
                                geometry: geometry,
                                isSelected: selectedDataPoint?.date == dataPoint.date,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedDataPoint = selectedDataPoint?.date == dataPoint.date ? nil : dataPoint
                                    }
                                }
                            )
                        }
                    }
                }
                .frame(height: 160)
                HStack {
                    ForEach(Array(moodData.enumerated()), id: \.offset) { index, dataPoint in
                        Text(dayLabel(for: dataPoint.date))
                            .font(.custom("Nunito-Regular", size: 14))
                            .foregroundColor(themeManager.colors.textLight)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 8)
            }
            // Data point breakdown overlay
            if let selected = selectedDataPoint {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Breakdown for " + dayLabel(for: selected.date))
                        .font(.custom("Nunito-Bold", size: 16))
                        .foregroundColor(themeManager.colors.text)
                    ForEach(selected.breakdown, id: \.label) { activity in
                        HStack(spacing: 8) {
                            Text(activity.icon)
                                .font(.system(size: 18))
                            Text(activity.label)
                                .font(.custom("Nunito-Regular", size: 15))
                                .foregroundColor(themeManager.colors.text)
                        }
                    }
                }
                .padding(.vertical, 8)
                // Tap-off area below breakdown
                Color.clear
                    .contentShape(Rectangle())
                    .frame(height: 24)
                    .onTapGesture {
                        withAnimation { selectedDataPoint = nil }
                    }
            }
            // Mood details
            VStack(alignment: .leading, spacing: 16) {
                Text("Mood Details")
                    .font(.custom("Quicksand-Bold", size: 18))
                    .foregroundColor(themeManager.colors.text)
                VStack(alignment: .leading, spacing: 12) {
                    MoodDetailRow(icon: "😊", title: String(format: "%.1f", averageMood), subtitle: "Average mood score")
                    MoodDetailRow(icon: "😃", title: "Happy", subtitle: "Most frequent mood")
                    MoodDetailRow(icon: "📈", title: String(format: "Improved by %.0f%%", moodChange), subtitle: "Mood changes")
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                animateChart = true
            }
        }
        .padding(.horizontal, 0)
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views and Models
struct MoodDataPoint {
    let date: Date
    let moodScore: Double // 0-10 scale
    let breakdown: [MoodActivity]
}

struct MoodActivity {
    let icon: String
    let label: String
}

struct ChartLineThroughPoints: View {
    let data: [MoodDataPoint]
    let animate: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let spacing = width / CGFloat(data.count - 1)
            Path { path in
                guard data.count > 1 else { return }
                for (index, point) in data.enumerated() {
                    let x = CGFloat(index) * spacing
                    let y = height - (CGFloat(point.moodScore) / 10.0 * height)
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .trim(from: 0, to: animate ? 1 : 0)
            .stroke(
                themeManager.colors.primary,
                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
            )
            .animation(.easeInOut(duration: 1.2), value: animate)
        }
    }
}

struct ChartDataPoint: View {
    let dataPoint: MoodDataPoint
    let index: Int
    let totalPoints: Int
    let geometry: GeometryProxy
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        let width = geometry.size.width
        let height = geometry.size.height
        let spacing = width / CGFloat(totalPoints - 1)
        let x = CGFloat(index) * spacing
        let y = height - (CGFloat(dataPoint.moodScore) / 10.0 * height)
        Circle()
            .fill(themeManager.colors.primary)
            .frame(width: isSelected ? 18 : 12, height: isSelected ? 18 : 12)
            .shadow(color: themeManager.colors.primary.opacity(0.3), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
            .position(x: x, y: y)
            .onTapGesture {
                onTap()
            }
            .scaleEffect(isSelected ? 1.2 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct MoodDetailRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 22))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Quicksand-Bold", size: 16))
                    .foregroundColor(themeManager.colors.text)
                Text(subtitle)
                    .font(.custom("Nunito-Regular", size: 13))
                    .foregroundColor(themeManager.colors.textLight)
            }
        }
    }
}

#Preview {
    InsightsScreen(selectedTab: .constant(3))
        .environmentObject(ThemeManager())
} 