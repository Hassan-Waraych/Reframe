import SwiftUI

enum HomeOption {
    case reframe
    case reflect
}

struct HomeScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int
    @StateObject private var viewModel = ReframeViewModel()
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
                
                // Quote Card with enhanced animation
                QuoteCard(quote: currentQuote, isAnimating: $isAnimating)
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                
                // Option Buttons with enhanced styling
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
                
                // Input Section with enhanced styling
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's on your mind?")
                        .font(.custom("Quicksand-SemiBold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                    
                    ZStack(alignment: .topLeading) {
                        if viewModel.originalThought.isEmpty {
                            Text("Type your thoughts here...")
                                .font(.custom("Nunito-Regular", size: 16))
                                .foregroundColor(themeManager.colors.textLight)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        
                        TextEditor(text: $viewModel.originalThought)
                            .font(.custom("Nunito-Regular", size: 16))
                            .foregroundColor(themeManager.colors.text)
                            .frame(height: 100)
                            .padding(4)
                            .background(themeManager.colors.surface)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(themeManager.colors.border, lineWidth: 1)
                            )
                            .scrollContentBackground(.hidden)
                            .disabled(!viewModel.canCreateReframe)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.createReframe()
                            withAnimation(.spring()) {
                                showQuote = true
                                currentQuote = quotes.randomElement() ?? quotes[0]
                                showReframeResult = true
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.state == .classifying || viewModel.state == .generating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                                Text(viewModel.state == .classifying ? "Analyzing..." : "Generating...")
                            } else {
                                Text("Submit")
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                        .font(.custom("Nunito-SemiBold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: selectedMode == .reframe ? [
                                    themeManager.colors.primary,
                                    themeManager.colors.primaryDark
                                ] : [
                                    themeManager.colors.secondary,
                                    Color(hex: "7B4B8E")
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: (selectedMode == .reframe ? themeManager.colors.primary : themeManager.colors.secondary).opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    .disabled(viewModel.isLoading || viewModel.originalThought.isEmpty || !viewModel.canCreateReframe)
                    .opacity((viewModel.isLoading || viewModel.originalThought.isEmpty || !viewModel.canCreateReframe) ? 0.6 : 1)
                }
                .padding(.horizontal)
                
                // Progress Section with enhanced styling
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
                
                // Latest Reframe (Compact Version)
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

struct CompactReframeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let reframe: Reframe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reframe.originalThought)
                .font(.custom("Nunito-Regular", size: 14))
                .foregroundColor(themeManager.colors.textLight)
                .lineLimit(1)
            
            Text(reframe.reframedThought)
                .font(.custom("Nunito-SemiBold", size: 16))
                .foregroundColor(themeManager.colors.text)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.colors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.colors.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ReframeResultView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let reframe: Reframe
    let viewModel: ReframeViewModel
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("Your Reframe")
                    .font(.custom("Quicksand-Bold", size: 24))
                    .foregroundColor(themeManager.colors.text)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(themeManager.colors.textLight)
                }
            }
            
            // Original Thought
            VStack(alignment: .leading, spacing: 8) {
                Text("Original Thought")
                    .font(.custom("Nunito-Regular", size: 14))
                    .foregroundColor(themeManager.colors.textLight)
                
                Text(reframe.originalThought)
                    .font(.custom("Nunito-Regular", size: 16))
                    .foregroundColor(themeManager.colors.text)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.colors.surface)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
            }
            
            // Reframed Thought
            VStack(alignment: .leading, spacing: 8) {
                Text("Reframe")
                    .font(.custom("Nunito-Regular", size: 14))
                    .foregroundColor(themeManager.colors.textLight)
                
                Text(reframe.reframedThought)
                    .font(.custom("Nunito-Regular", size: 16))
                    .foregroundColor(themeManager.colors.text)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.colors.primary.opacity(0.1))
                            .shadow(color: themeManager.colors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
            }
            
            // Action Buttons
            VStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.markAsHelpful()
                        onDismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("That Helped")
                    }
                    .font(.custom("Nunito-SemiBold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
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
                    .cornerRadius(12)
                }
                
                Button {
                    // TODO: Implement journal logging
                } label: {
                    HStack {
                        Image(systemName: "book.fill")
                        Text("Log to Journal")
                    }
                    .font(.custom("Nunito-SemiBold", size: 16))
                    .foregroundColor(themeManager.colors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(themeManager.colors.primary.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button {
                    onDismiss()
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Try Another")
                    }
                    .font(.custom("Nunito-SemiBold", size: 16))
                    .foregroundColor(themeManager.colors.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(themeManager.colors.surface)
                    .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.colors.background)
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal)
    }
}

#Preview {
    HomeScreen(selectedTab: .constant(0))
        .environmentObject(ThemeManager())
} 