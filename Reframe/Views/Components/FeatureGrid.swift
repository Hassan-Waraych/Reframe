import SwiftUI
import Foundation

struct FeatureButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.colors.primary)
                
                Text(title)
                    .font(.custom("Quicksand-Bold", size: 16))
                    .foregroundColor(themeManager.colors.text)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(themeManager.colors.surface)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct FeatureGrid: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showAchievements = false
    @State private var showGuidedJournal = false
    @State private var showQuickCalm = false
    @State private var showDailyBoost = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                FeatureButton(title: "Milestones", icon: "trophy.fill") {
                    showAchievements = true
                }
                
                FeatureButton(title: "Guided Prompts", icon: "text.bubble.fill") {
                    showGuidedJournal = true
                }
            }
            
            HStack(spacing: 16) {
                FeatureButton(title: "Quick Calm", icon: "heart.fill") {
                    showQuickCalm = true
                }
                
                FeatureButton(title: "Daily Wisdom", icon: "leaf.fill") {
                    showDailyBoost = true
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showAchievements) {
            NavigationView {
                AchievementsScreen()
            }
        }
        .sheet(isPresented: $showGuidedJournal) {
            GuidedJournalScreen()
        }
        .sheet(isPresented: $showQuickCalm) {
            QuickCalmScreen()
        }
        .fullScreenCover(isPresented: $showDailyBoost) {
            // Deterministic shuffle based on month/year, then pick for the day
            let calendar = Calendar.current
            let today = Date()
            let year = calendar.component(.year, from: today)
            let month = calendar.component(.month, from: today)
            let dayOfCycle = (calendar.ordinality(of: .day, in: .year, for: today) ?? 1) % dailyBoostStrategies.count
            // Seed for deterministic shuffle: year * 100 + month
            var rng = SeededGenerator(seed: UInt64(year * 100 + month))
            let shuffled = dailyBoostStrategies.shuffled(using: &rng)
            let strategy = shuffled[dayOfCycle]
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.87, green: 0.67, blue: 0.39), // light brown
                        Color(red: 0.74, green: 0.51, blue: 0.22)  // medium brown
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                // Brown wave at the bottom
                VStack {
                    Spacer()
                    WaveShape()
                        .fill(Color(red: 0.56, green: 0.34, blue: 0.13))
                        .frame(height: 80)
                        .edgesIgnoringSafeArea(.bottom)
                }
                VStack(spacing: 24) {
                    Spacer()
                    Image("TreeIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 340, maxHeight: 320)
                        .background(Color.clear)
                        .padding(.bottom, 8)
                    Text(strategy.title)
                        .font(.custom("Snell Roundhand", size: 36).weight(.bold))
                        .foregroundColor(Color(red: 0.22, green: 0.13, blue: 0.07))
                        .padding(.bottom, 2)
                    Text(strategy.description)
                        .font(.custom("Georgia", size: 18))
                        .foregroundColor(Color(red: 0.22, green: 0.13, blue: 0.07))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .lineLimit(4)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    Button(action: { showDailyBoost = false }) {
                        Text("Close")
                            .font(.custom("Georgia", size: 20).weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 0.22, green: 0.13, blue: 0.07))
                            .cornerRadius(16)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addCurve(to: CGPoint(x: rect.width, y: 0),
                      control1: CGPoint(x: rect.width * 0.25, y: 40),
                      control2: CGPoint(x: rect.width * 0.75, y: -40))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed }
    mutating func next() -> UInt64 {
        // Xorshift64*
        var x = state
        x ^= x >> 12; x ^= x << 25; x ^= x >> 27
        state = x
        return x &* 2685821657736338717
    }
}

#Preview {
    FeatureGrid()
        .environmentObject(ThemeManager())
} 