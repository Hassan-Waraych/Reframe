import SwiftUI

struct AchievementsScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedAchievement: Achievement?
    @State private var showDetail = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress Overview
                VStack(spacing: 16) {
                    Text("My Progress")
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    
                    ProgressOverviewCard()
                }
                .padding(.horizontal)
                
                // Achievements Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Achievement.mockAchievements) { achievement in
                        AchievementCard(achievement: achievement)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedAchievement = achievement
                                    showDetail = true
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 24)
        }
        .background(themeManager.colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if showDetail, let achievement = selectedAchievement {
                AchievementDetailView(
                    achievement: achievement,
                    isPresented: $showDetail
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

struct ProgressOverviewCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Overall Progress")
                        .font(.custom("Quicksand-SemiBold", size: 16))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text("\(Int(Achievement.mockAchievements.filter { !$0.isLocked }.count * 100 / Achievement.mockAchievements.count))% Complete")
                        .font(.custom("Nunito-Bold", size: 24))
                        .foregroundColor(themeManager.colors.primary)
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: Double(Achievement.mockAchievements.filter { !$0.isLocked }.count) / Double(Achievement.mockAchievements.count)
                )
                .frame(width: 60, height: 60)
            }
            
            // Progress Graph
            ProgressGraphView()
                .frame(height: 100)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.colors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

struct CircularProgressView: View {
    let progress: Double
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(themeManager.colors.surface, lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            themeManager.colors.primary,
                            themeManager.colors.primaryDark
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(), value: progress)
        }
    }
}

struct ProgressGraphView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let points = [
                    CGPoint(x: 0, y: height * 0.8),
                    CGPoint(x: width * 0.2, y: height * 0.7),
                    CGPoint(x: width * 0.4, y: height * 0.6),
                    CGPoint(x: width * 0.6, y: height * 0.5),
                    CGPoint(x: width * 0.8, y: height * 0.4),
                    CGPoint(x: width, y: height * 0.3)
                ]
                
                path.move(to: points[0])
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        themeManager.colors.primary,
                        themeManager.colors.primaryDark
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
            )
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isLocked ? themeManager.colors.surface : achievement.category.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(achievement.isLocked ? themeManager.colors.textLight : achievement.category.color)
            }
            
            Text(achievement.title)
                .font(.custom("Quicksand-SemiBold", size: 14))
                .foregroundColor(achievement.isLocked ? themeManager.colors.textLight : themeManager.colors.text)
                .multilineTextAlignment(.center)
            
            ProgressBar(progress: achievement.progress)
                .frame(height: 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.colors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

struct ProgressBar: View {
    let progress: Double
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(themeManager.colors.surface)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                themeManager.colors.primary,
                                themeManager.colors.primaryDark
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
            }
        }
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(achievement.isLocked ? themeManager.colors.surface : achievement.category.color.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 40))
                        .foregroundColor(achievement.isLocked ? themeManager.colors.textLight : achievement.category.color)
                }
                
                VStack(spacing: 8) {
                    Text(achievement.title)
                        .font(.custom("Quicksand-Bold", size: 24))
                        .foregroundColor(achievement.isLocked ? themeManager.colors.textLight : themeManager.colors.text)
                    
                    Text(achievement.subtitle)
                        .font(.custom("Nunito-Regular", size: 16))
                        .foregroundColor(themeManager.colors.textLight)
                        .multilineTextAlignment(.center)
                }
                
                if let dateEarned = achievement.dateEarned {
                    Text("Earned on \(dateEarned.formatted(date: .abbreviated, time: .omitted))")
                        .font(.custom("Nunito-Medium", size: 14))
                        .foregroundColor(themeManager.colors.textLight)
                }
                
                ProgressBar(progress: achievement.progress)
                    .frame(height: 6)
                    .padding(.horizontal, 40)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(themeManager.colors.background)
            )
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    AchievementsScreen()
        .environmentObject(ThemeManager())
} 