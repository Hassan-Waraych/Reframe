import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

struct HomeScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int
    @StateObject private var viewModel = ReframeViewModel()
    @StateObject private var reframeService = ReframeService.shared
    @StateObject private var quoteService = QuoteService()
    @State private var selectedMode: HomeOption = .reframe
    @State private var isAnimating = false
    @State private var showQuote = false
    @State private var showReframeResult = false
    @State private var showPremiumModal = false
    
    var body: some View {
        ZStack {
            // Special effects for Sunset Serenity theme
            themeManager.sunsetParticles()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Greeting and Streak aligned left
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Good \(greeting())")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundColor(themeManager.colors.text)
                        if viewModel.currentStreak > 0 {
                            StreakView(streakCount: viewModel.currentStreak)
                        }
                    }
                    .padding(.horizontal)

                    // Quote Card
                    if let quote = quoteService.currentQuote {
                        QuoteCard(quote: quote.text, isAnimating: $quoteService.isAnimating)
                            .padding(.horizontal)
                    }

                    // Weekly Mood View
                    WeeklyMoodView()
                        .padding(.horizontal)

                    // Option Buttons
                    HStack(spacing: 16) {
                        HomeOptionButton(
                            title: "Reframe",
                            icon: "arrow.triangle.2.circlepath",
                            isSelected: selectedMode == .reframe
                        ) {
                            withAnimation(.spring()) {
                                selectedMode = .reframe
                                viewModel.selectedMode = .reframe
                            }
                        }
                        HomeOptionButton(
                            title: "Reflect",
                            icon: "brain.head.profile",
                            isSelected: selectedMode == .reflect
                        ) {
                            withAnimation(.spring()) {
                                selectedMode = .reflect
                                viewModel.selectedMode = .reflect
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Input Section
                    ReframeInputView(
                        viewModel: viewModel,
                        selectedMode: selectedMode,
                        showReframeResult: $showReframeResult
                    )
                    .padding(.horizontal)

                    // Progress Section
                    if !viewModel.authService.isPremiumUser() {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                                            Text("Reframes Used")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(themeManager.colors.text)
                            Spacer()
                            Text("\(2 - viewModel.remainingReframes)/2")
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .foregroundColor(themeManager.colors.textLight)
                            }
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(themeManager.colors.surface)
                                        .frame(height: 12)
                                    RoundedRectangle(cornerRadius: 8)
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
                                        .frame(width: geometry.size.width * CGFloat(2 - viewModel.remainingReframes) / 2, height: 12)
                                }
                            }
                            .frame(height: 12)
                            
                            Button(action: {
                                showPremiumModal = true
                            }) {
                                Text("Upgrade for unlimited reframes")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(themeManager.colors.primary)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Today's Plan Section
                    TodaysPlanView()
                        .padding(.horizontal)

                    // Latest Reframe
                    if let latestReframe = viewModel.reframes.first(where: { $0.category != "Reflection" }) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Latest Reframe")
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .foregroundColor(themeManager.colors.text)
                                .padding(.horizontal)
                            Button {
                                withAnimation(.spring()) {
                                    viewModel.currentReframe = latestReframe
                                    showReframeResult = true
                                }
                            } label: {
                                CompactReframeView(reframe: latestReframe)
                                    .padding(.horizontal)
                            }
                        }
                    }

                    // Removed FeatureGrid - moved to Discover tab
                }
                .padding(.vertical, 24)
            }
            .background(themeManager.customBackground())
            .navigationBarHidden(true)
            
            // Reframe Result Overlay
            if showReframeResult, let reframe = viewModel.currentReframe {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                ReframeResultView(reframe: reframe, viewModel: viewModel) {
                    Task {
                        withAnimation(.spring()) {
                            showReframeResult = false
                            viewModel.resetState()
                        }
                        await viewModel.loadStreak()
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Nonsense Cooldown Overlay
            if viewModel.showNonsenseCooldown, let cooldownEndDate = reframeService.getNonsenseCooldownEndDate() {
                NonsenseCooldownView(cooldownEndDate: cooldownEndDate) {
                    withAnimation(.spring()) {
                        viewModel.showNonsenseCooldown = false
                    }
                }
                .transition(.opacity)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .task {
            await viewModel.loadReframes()
            await viewModel.loadStreak()
        }
        .fullScreenCover(isPresented: $showPremiumModal) {
            PremiumModalScreen()
        }
    }
    
    private func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Morning"
        case 12..<17: return "Afternoon"
        default: return "Evening"
        }
    }
}

#Preview {
    HomeScreen(selectedTab: .constant(0))
        .environmentObject(ThemeManager())
} 