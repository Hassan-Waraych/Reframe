import SwiftUI

struct FirstThoughtScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @State private var thought = ""
    @State private var selectedOption: ThoughtOption = .reframe
    @State private var isAnimating = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    enum ThoughtOption: String, Codable {
        case reframe
        case reflect
    }
    
    var gradientColors: [Color] {
        selectedOption == .reframe ? 
            [themeManager.colors.primary, themeManager.colors.primaryDark] :
            [themeManager.colors.secondary, Color(hex: "7B4B8E")]
    }
    
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
                    }
                }
                
                OnboardingOptionButton(
                    title: "Reflect",
                    isSelected: selectedOption == .reflect,
                    color: themeManager.colors.secondary
                ) {
                    withAnimation(.spring()) {
                        selectedOption = .reflect
                    }
                }
            }
            
            // Thought Input
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 22))
                        .foregroundColor(themeManager.colors.textLight)
                    
                    Text(selectedOption == .reframe ? "e.g., I'm not good enough for this job" : "Reflect on your thought...")
                        .font(.custom("Nunito-Regular", size: 16))
                        .foregroundColor(themeManager.colors.textLight)
                }
                
                TextEditor(text: $thought)
                    .font(.custom("Nunito-Regular", size: 18))
                    .foregroundColor(themeManager.colors.text)
                    .frame(minHeight: 140, maxHeight: 220)
                    .padding(16)
                    .background(themeManager.colors.surface)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(themeManager.colors.border, lineWidth: 1.5)
                    )
                    .scrollContentBackground(.hidden)
            }
            
            if let error = errorMessage {
                Text(error)
                    .font(.custom("Nunito-Regular", size: 14))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                Button(action: handleThoughtSubmission) {
                    Text(isLoading ? "Processing..." : (selectedOption == .reframe ? "Reframe My Thought" : "Reflect"))
                        .font(.custom("Nunito-SemiBold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: gradientColors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(26)
                        .shadow(
                            color: selectedOption == .reframe ? 
                                themeManager.colors.primary.opacity(0.3) : 
                                themeManager.colors.secondary.opacity(0.3),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                }
                .disabled(isLoading || thought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity((isLoading || thought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.5 : 1)
                
                Button(action: {
                    coordinator.next()
                }) {
                    Text("Skip for now")
                        .font(.custom("Nunito-Medium", size: 16))
                        .foregroundColor(themeManager.colors.textLight)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
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
    }
    
    private func handleThoughtSubmission() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            // Save the thought if needed
            if !thought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                UserDefaults.standard.set(thought, forKey: "firstThought")
            }
            // Complete onboarding and redirect to home
            coordinator.completeOnboarding()
        }
    }
}

struct OptionButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var gradientColors: [Color] {
        isSelected ? [color, color.opacity(0.8)] : [themeManager.colors.surface, themeManager.colors.surface]
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Nunito-SemiBold", size: 16))
                .foregroundColor(isSelected ? .white : themeManager.colors.text)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(isSelected ? color : themeManager.colors.border, lineWidth: 2)
                )
        }
    }
}

#Preview {
    FirstThoughtScreen()
        .environmentObject(ThemeManager())
        .environmentObject(OnboardingCoordinator())
} 