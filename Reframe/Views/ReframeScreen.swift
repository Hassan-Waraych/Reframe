import SwiftUI

struct ReframeScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = ReframeViewModel()
    @State private var showDeleteConfirmation = false
    @State private var reframeToDelete: Reframe?
    
    init() {
        print("Debug: ReframeScreen initialized")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Test Button
                Button(action: {
                    print("Debug: Test button pressed in view")
                    viewModel.testButton()
                }) {
                    Text("Test Button")
                        .font(.custom("Nunito-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
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
                        .disabled(!viewModel.canCreateReframe)
                        .onChange(of: viewModel.originalThought) { newValue in
                            print("Debug: Text field changed to: \(newValue)")
                        }
                    
                    // Simple Button Implementation
                    Button {
                        print("Debug: Reframe button pressed in view")
                        Task {
                            await viewModel.createReframe()
                        }
                    } label: {
                        Text("Reframe Thought")
                            .font(.custom("Nunito-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                    .disabled(viewModel.isLoading || viewModel.originalThought.isEmpty || !viewModel.canCreateReframe)
                    .opacity((viewModel.isLoading || viewModel.originalThought.isEmpty || !viewModel.canCreateReframe) ? 0.5 : 1)
                }
                .padding(.horizontal)
                
                // Reframes List
                if !viewModel.reframes.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Reframes")
                            .font(.custom("Quicksand-Bold", size: 20))
                            .foregroundColor(themeManager.colors.text)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.reframes) { reframe in
                            ReframeItemView(reframe: reframe) {
                                reframeToDelete = reframe
                                showDeleteConfirmation = true
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
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .task {
            await viewModel.loadReframes()
        }
    }
}

#Preview {
    ReframeScreen()
} 