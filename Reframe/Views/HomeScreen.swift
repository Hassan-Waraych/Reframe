import SwiftUI
import Combine

enum HomeOption {
    case reframe
    case reflect
}

struct HomeScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int
    @StateObject private var viewModel = ReframeViewModel()
    @StateObject private var reframeService = ReframeService.shared
    @State private var selectedMode: HomeOption = .reframe
    @State private var isAnimating = false
    @State private var showQuote = false
    @State private var currentQuote = "Your daily dose of wisdom will appear here..."
    @State private var showReframeResult = false
    
    let quotes = [
        "The only way to do great work is to love what you do.",
        "Life is what happens while you're busy making other plans.",
        "The future belongs to those who believe in the beauty of their dreams."
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Header with greeting
                Text(greeting())
                    .font(.custom("Quicksand-Bold", size: 32))
                    .foregroundColor(themeManager.colors.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Quote Card
                QuoteCard(quote: currentQuote, isAnimating: $isAnimating)
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                
                // Option Buttons
                HStack(spacing: 16) {
                    HomeOptionButton(
                        title: "Reframe",
                        icon: "arrow.triangle.2.circlepath",
                        isSelected: selectedMode == .reframe
                    ) {
                        withAnimation(.spring()) {
                            selectedMode = .reframe
                        }
                    }
                    
                    HomeOptionButton(
                        title: "Reflect",
                        icon: "brain.head.profile",
                        isSelected: selectedMode == .reflect
                    ) {
                        withAnimation(.spring()) {
                            selectedMode = .reflect
                        }
                    }
                }
                .padding(.horizontal)
                
                // Input Section
                ReframeInputView(
                    viewModel: viewModel,
                    selectedMode: selectedMode,
                    showReframeResult: $showReframeResult,
                    currentQuote: $currentQuote,
                    quotes: quotes
                )
                    .padding(.horizontal)
                
                // Progress Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Reframes Used")
                            .font(.custom("Quicksand-SemiBold", size: 16))
                            .foregroundColor(themeManager.colors.text)
                        
                        Spacer()
                        
                        Text("\(5 - viewModel.remainingReframes)/5")
                            .font(.custom("Nunito-Medium", size: 16))
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
                                .frame(width: geometry.size.width * CGFloat(5 - viewModel.remainingReframes) / 5, height: 12)
                        }
                    }
                    .frame(height: 12)
                }
                .padding(.horizontal)
                
                // Latest Reframe
                if let latestReframe = viewModel.reframes.first {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Latest Reframe")
                            .font(.custom("Quicksand-Bold", size: 20))
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
                
                Spacer()
            }
            .padding(.vertical, 24)
            .background(themeManager.colors.background)
            .navigationBarHidden(true)
            
            // Reframe Result Overlay
            if showReframeResult, let reframe = viewModel.currentReframe {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                ReframeResultView(reframe: reframe, viewModel: viewModel) {
                    withAnimation(.spring()) {
                        showReframeResult = false
                        viewModel.resetState()
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
        }
    }
    
    private func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
}

#Preview {
    HomeScreen(selectedTab: .constant(0))
        .environmentObject(ThemeManager())
} 