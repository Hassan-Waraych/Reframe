import SwiftUI

/// A view component that handles the reframe input and submission
struct ReframeInputView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: ReframeViewModel
    let selectedMode: HomeOption
    @Binding var showReframeResult: Bool
    @Binding var currentQuote: String
    let quotes: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedMode == .reframe ? "What's on your mind?" : "What would you like to reflect on?")
                .font(.custom("Quicksand-SemiBold", size: 20))
                .foregroundColor(themeManager.colors.text)
            
            ZStack(alignment: .topLeading) {
                if viewModel.originalThought.isEmpty {
                    Text(selectedMode == .reframe ? "Type your thoughts here..." : "Write your reflection here...")
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
                    .disabled(selectedMode == .reframe ? !viewModel.canCreateReframe : false)
            }
            
            Button(action: {
                Task {
                    if selectedMode == .reframe {
                        await viewModel.createReframe()
                        withAnimation(.spring()) {
                            currentQuote = quotes.randomElement() ?? quotes[0]
                        }
                    } else {
                        await viewModel.createReflection()
                    }
                    withAnimation(.spring()) {
                        showReframeResult = true
                    }
                }
            }) {
                HStack {
                    if viewModel.state == .classifying || viewModel.state == .generating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                        Text(viewModel.state == .classifying ? "Analyzing..." : "Saving...")
                    } else {
                        Text(selectedMode == .reframe ? "Submit" : "Save Reflection")
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
            .disabled(viewModel.isLoading || viewModel.originalThought.isEmpty || (selectedMode == .reframe && !viewModel.canCreateReframe))
            .opacity((viewModel.isLoading || viewModel.originalThought.isEmpty || (selectedMode == .reframe && !viewModel.canCreateReframe)) ? 0.6 : 1)
        }
    }
}

#Preview {
    ReframeInputView(
        viewModel: ReframeViewModel(),
        selectedMode: .reframe,
        showReframeResult: .constant(false),
        currentQuote: .constant("Your daily dose of wisdom will appear here..."),
        quotes: ["Quote 1", "Quote 2", "Quote 3"]
    )
    .environmentObject(ThemeManager())
} 