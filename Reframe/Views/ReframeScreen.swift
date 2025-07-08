import SwiftUI

struct ReframeScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = ReframeViewModel()
    @State private var showDeleteConfirmation = false
    @State private var reframeToDelete: Reframe?
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Reframe")
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    
                    Spacer()
                    
                    ReframeCountView(viewModel: viewModel)
                }
                .padding(.horizontal)
                
                // Input Section
                VStack(spacing: 16) {
                    TextField("What's on your mind?", text: $viewModel.originalThought, axis: .vertical)
                        .font(.custom("Nunito-Regular", size: 16))
                        .foregroundColor(themeManager.colors.text)
                        .padding(16)
                        .background(themeManager.colors.surface)
                        .cornerRadius(12)
                        .lineLimit(3...6)
                        .disabled(!viewModel.canCreateReframe || viewModel.state == .classifying || viewModel.state == .generating)
                        .focused($isInputFocused)
                    
                    // Submit Button
                    Button {
                        // Dismiss keyboard first
                        isInputFocused = false
                        
                        Task {
                            await viewModel.createReframe()
                        }
                    } label: {
                        HStack {
                            if case .classifying = viewModel.state {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                                Text("Analyzing...")
                            } else if case .generating = viewModel.state {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                                Text("Generating...")
                            } else {
                                Text("Reframe Thought")
                            }
                        }
                        .font(.custom("Nunito-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
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
                        .cornerRadius(16)
                    }
                    .disabled(
                        viewModel.isLoading ||
                        viewModel.originalThought.isEmpty ||
                        !viewModel.canCreateReframe ||
                        viewModel.state == .classifying ||
                        viewModel.state == .generating
                    )
                }
                .padding(.horizontal)
                
                // Current Reframe Section
                if case .success = viewModel.state, let reframe = viewModel.currentReframe {
                    VStack(spacing: 16) {
                        // Original Thought
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Original Thought")
                                .font(.custom("Nunito-Regular", size: 14))
                                .foregroundColor(themeManager.colors.textLight)
                            
                            Text(reframe.originalThought)
                                .font(.custom("Nunito-Regular", size: 16))
                                .foregroundColor(themeManager.colors.text)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(themeManager.colors.surface)
                                .cornerRadius(8)
                        }
                        
                        // Reframed Thought
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reframe")
                                .font(.custom("Nunito-Regular", size: 14))
                                .foregroundColor(themeManager.colors.textLight)
                            
                            Text(reframe.reframedThought)
                                .font(.custom("Nunito-Regular", size: 16))
                                .foregroundColor(themeManager.colors.text)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(themeManager.colors.primary.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button {
                                Task {
                                    await viewModel.markAsHelpful()
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
                                .background(themeManager.colors.primary)
                                .cornerRadius(12)
                            }
                            
                            Button {
                                viewModel.resetState()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Try Another")
                                }
                                .font(.custom("Nunito-SemiBold", size: 16))
                                .foregroundColor(themeManager.colors.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(themeManager.colors.primary.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        if viewModel.showReflectSuggestion {
                            VStack(spacing: 8) {
                                Text("This is a positive thought! 💫")
                                    .font(.custom("Nunito-SemiBold", size: 14))
                                    .foregroundColor(themeManager.colors.textLight)
                                
                                Text("You can save your daily reframe limit by using the Reflect tab instead - it's perfect for capturing and celebrating these moments.")
                                    .font(.custom("Nunito-Regular", size: 14))
                                    .foregroundColor(themeManager.colors.textLight)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Error Message
                if case .error(let message) = viewModel.state {
                    Text(message)
                        .font(.custom("Nunito-Regular", size: 14))
                        .foregroundColor(themeManager.colors.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.opacity)
                }
                
                // Reframes List
                if !viewModel.reframes.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Reframes")
                            .font(.custom("Quicksand-Bold", size: 20))
                            .foregroundColor(themeManager.colors.text)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.reframes) { reframe in
                            VStack(spacing: 12) {
                                ReframeItemView(reframe: reframe) {
                                    reframeToDelete = reframe
                                    showDeleteConfirmation = true
                                }
                                
                                if reframe.category == "Positive Reflection" {
                                    Text("💫 This was saved as a positive reflection - you can use the Reflect tab for these!")
                                        .font(.custom("Nunito-Regular", size: 12))
                                        .foregroundColor(themeManager.colors.textLight)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 8)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(themeManager.colors.background)
        .alert("Delete Reframe", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                reframeToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let reframe = reframeToDelete {
                    Task {
                        await viewModel.deleteReframe(reframe)
                    }
                }
                reframeToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this reframe? This action cannot be undone.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.resetState()
            }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .task {
            await viewModel.loadReframes()
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            isInputFocused = false
        }
    }
}

#Preview {
    ReframeScreen()
        .environmentObject(ThemeManager())
} 