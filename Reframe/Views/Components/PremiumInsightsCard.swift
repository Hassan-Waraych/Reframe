import SwiftUI

struct PremiumInsightsCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let description: String
    let isLocked: Bool
    @State private var showPremiumModal = false
    
    var body: some View {
        Button(action: {
            if isLocked {
                showPremiumModal = true
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.custom("Quicksand-Bold", size: 16))
                        .foregroundColor(themeManager.colors.text)
                    
                    Spacer()
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                }
                
                Text(description)
                    .font(.custom("Nunito-Regular", size: 14))
                    .foregroundColor(themeManager.colors.textLight)
                    .multilineTextAlignment(.leading)
                
                // Enhanced mock content
                VStack(spacing: 8) {
                    // Chart content with conditional blur
                    Group {
                        switch chartType {
                        case .moodTrend:
                            MoodTrendChartView()
                        case .calendarHeatmap:
                            CalendarHeatmapView()
                        case .entryBreakdown:
                            EntryBreakdownChartView()
                        case .personalizedInsight:
                            PersonalizedInsightView()
                        }
                    }
                    .blur(radius: isLocked ? 1.0 : 0)
                    .opacity(isLocked ? 0.8 : 1.0)
                    
                    if isLocked {
                        Button(action: {
                            showPremiumModal = true
                        }) {
                            Text("Unlock with Premium")
                                .font(.custom("Nunito-SemiBold", size: 14))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            themeManager.colors.primary,
                                            themeManager.colors.primaryDark
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                                .shadow(color: themeManager.colors.primary.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                }
            }
            .padding(16)
            .background(themeManager.colors.surface)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isLocked ? themeManager.colors.border.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )

        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showPremiumModal) {
            PremiumModalScreen()
        }
    }
    
    private var chartType: ChartType {
        if title.contains("Mood Trend") {
            return .moodTrend
        } else if title.contains("Calendar Heatmap") {
            return .calendarHeatmap
        } else if title.contains("Entry Type") {
            return .entryBreakdown
        } else if title.contains("Personalized") {
            return .personalizedInsight
        } else {
            return .moodTrend
        }
    }
}

enum ChartType {
    case moodTrend, calendarHeatmap, entryBreakdown, personalizedInsight
}

// MARK: - Chart Components

struct MoodTrendChartView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    // Mock mood data (1-5 scale)
    private let moodData: [Double] = [3.2, 4.1, 2.8, 4.5, 3.9, 4.2, 3.7, 4.0, 3.5, 4.3, 3.8, 4.1, 3.9, 4.0]
    private let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack(spacing: 8) {
            // Chart area
            GeometryReader { geometry in
                ZStack {
                    // Background grid
                    VStack(spacing: 0) {
                        ForEach(0..<5) { i in
                            Divider()
                                .background(themeManager.colors.border.opacity(0.2))
                            if i < 4 {
                                Spacer()
                            }
                        }
                    }
                    
                    // Mood line
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let stepX = width / CGFloat(moodData.count - 1)
                        
                        for (index, value) in moodData.enumerated() {
                            let x = CGFloat(index) * stepX
                            let y = height - (CGFloat(value - 1) / 4.0) * height
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                themeManager.colors.primary,
                                themeManager.colors.secondary
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    
                    // Area under line
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let stepX = width / CGFloat(moodData.count - 1)
                        
                        path.move(to: CGPoint(x: 0, y: height))
                        
                        for (index, value) in moodData.enumerated() {
                            let x = CGFloat(index) * stepX
                            let y = height - (CGFloat(value - 1) / 4.0) * height
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        
                        path.addLine(to: CGPoint(x: width, y: height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                themeManager.colors.primary.opacity(0.2),
                                themeManager.colors.secondary.opacity(0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Data points
                    ForEach(0..<moodData.count, id: \.self) { index in
                        let x = CGFloat(index) * (geometry.size.width / CGFloat(moodData.count - 1))
                        let y = geometry.size.height - (CGFloat(moodData[index] - 1) / 4.0) * geometry.size.height
                        
                        Circle()
                            .fill(themeManager.colors.primary)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                    }
                }
            }
            .frame(height: 80)
            
            // X-axis labels
            HStack {
                ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                    if index % 2 == 0 {
                        Text(label)
                            .font(.custom("Nunito-Regular", size: 10))
                            .foregroundColor(themeManager.colors.textLight)
                    } else {
                        Text(label)
                            .font(.custom("Nunito-Regular", size: 10))
                            .foregroundColor(themeManager.colors.textLight.opacity(0))
                    }
                }
            }
        }
    }
}

struct CalendarHeatmapView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    // Mock mood intensity data (0-1 scale)
    private let moodIntensities: [Double] = Array(0..<30).map { _ in Double.random(in: 0.2...1.0) }
    
    var body: some View {
        VStack(spacing: 8) {
            // Month grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
                ForEach(0..<30, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorForIntensity(moodIntensities[index]))
                        .frame(height: 20)
                        .overlay(
                            Text("\(index + 1)")
                                .font(.custom("Nunito-Regular", size: 8))
                                .foregroundColor(themeManager.colors.text.opacity(0.7))
                        )
                }
            }
            
            // Legend
            HStack(spacing: 8) {
                Text("Low")
                    .font(.custom("Nunito-Regular", size: 10))
                    .foregroundColor(themeManager.colors.textLight)
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colorForIntensity(Double(i) / 4.0))
                            .frame(width: 12, height: 8)
                    }
                }
                
                Text("High")
                    .font(.custom("Nunito-Regular", size: 10))
                    .foregroundColor(themeManager.colors.textLight)
            }
        }
    }
    
    private func colorForIntensity(_ intensity: Double) -> Color {
        let lowColor = Color(hex: "E8F4F8") // Light blue
        let highColor = Color(hex: "FF7F6B") // Warm coral
        
        return lowColor.interpolated(to: highColor, amount: intensity)
    }
}

struct EntryBreakdownChartView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    // Mock data
    private let data = [
        ("Reframes", 0.45, Color.orange),
        ("Reflections", 0.35, Color.purple),
        ("Coach", 0.20, Color.green)
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            // Horizontal bars
            VStack(spacing: 6) {
                ForEach(data, id: \.0) { item in
                    HStack(spacing: 8) {
                        Text(item.0)
                            .font(.custom("Nunito-Medium", size: 12))
                            .foregroundColor(themeManager.colors.text)
                            .frame(width: 60, alignment: .leading)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(themeManager.colors.surface)
                                    .frame(height: 16)
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(item.2)
                                    .frame(width: geometry.size.width * item.1, height: 16)
                            }
                        }
                        .frame(height: 16)
                        
                        Text("\(Int(item.1 * 100))%")
                            .font(.custom("Nunito-Bold", size: 12))
                            .foregroundColor(themeManager.colors.text)
                            .frame(width: 30, alignment: .trailing)
                    }
                }
            }
        }
    }
}

struct PersonalizedInsightView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🧭")
                    .font(.system(size: 16))
                
                Spacer()
            }
            
            Text("You tend to journal most on Mondays and Thursdays. Great consistency! Try adding reflections on weekends for even more balance.")
                .font(.custom("Nunito-Regular", size: 14))
                .foregroundColor(themeManager.colors.text)
                .multilineTextAlignment(.leading)
                .lineLimit(4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(themeManager.colors.primary.opacity(0.05))
        )
    }
}

// MARK: - Color Interpolation Extension
extension Color {
    func interpolated(to other: Color, amount: Double) -> Color {
        let from = UIColor(self)
        let to = UIColor(other)
        
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        
        from.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        to.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        let red = fromRed + (toRed - fromRed) * amount
        let green = fromGreen + (toGreen - fromGreen) * amount
        let blue = fromBlue + (toBlue - fromBlue) * amount
        let alpha = fromAlpha + (toAlpha - fromAlpha) * amount
        
        return Color(UIColor(red: red, green: green, blue: blue, alpha: alpha))
    }
}

#Preview {
    VStack(spacing: 16) {
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
    .padding()
    .environmentObject(ThemeManager())
} 