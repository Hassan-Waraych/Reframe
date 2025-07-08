import SwiftUI

struct FirstThoughtScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @StateObject private var viewModel = ReframeViewModel()
    @State private var selectedOption: HomeOption = .reframe
    @State private var isAnimating = false
    @State private var showReframeResult = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Let's start with your first thought")
                    .font(.custom("Quicksand-Bold", size: 28))
                    .foregroundColor(themeManager.colors.text)
                
                Text("Share a negative thought you'd like to reframe or reflect on")
                    .font(.custom("Nunito-Regular", size: 16))
                    .foregroundColor(themeManager.colors.textLight)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 48)
            
            // Option Toggle
            HStack(spacing: 12) {
                OnboardingOptionButton(
                    title: "Reframe",
                    isSelected: selectedOption == .reframe,
                    color: themeManager.colors.primary
                ) {
                    withAnimation(.spring()) {
                        selectedOption = .reframe
                        viewModel.selectedMode = .reframe
                    }
                }
                
                OnboardingOptionButton(
                    title: "Reflect",
                    isSelected: selectedOption == .reflect,
                    color: themeManager.colors.secondary
                ) {
                    withAnimation(.spring()) {
                        selectedOption = .reflect
                        viewModel.selectedMode = .reflect
                    }
                }
            }
            
            // Use existing ReframeInputView
            ReframeInputView(
                viewModel: viewModel,
                selectedMode: selectedOption,
                showReframeResult: $showReframeResult
            )
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.custom("Nunito-Regular", size: 14))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
            
            Spacer()
            
            // Skip Button
            Button(action: {
                coordinator.completeOnboarding()
            }) {
                Text("Skip for now")
                    .font(.custom("Nunito-Medium", size: 16))
                    .foregroundColor(themeManager.colors.textLight)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16)
        }
        .padding(.horizontal, 24)
        .background(themeManager.colors.background)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
        .onChange(of: showReframeResult) { showResult in
            if showResult {
                // Show result for a moment, then complete onboarding
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    coordinator.completeOnboarding()
                }
            }
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .overlay(
            Group {
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
        )
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }
}

#Preview {
    FirstThoughtScreen()
        .environmentObject(ThemeManager())
        .environmentObject(OnboardingCoordinator())
} 