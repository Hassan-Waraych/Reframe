import SwiftUI

struct WelcomeScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon Container
            VStack {
                ZStack {
                    Circle()
                        .fill(themeManager.colors.primary.opacity(0.2))
                        .frame(width: 200, height: 200)
                    
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 80))
                        .foregroundColor(themeManager.colors.primary)
                }
            }
            .frame(maxHeight: .infinity)
            
            // Text Content
            VStack(spacing: 16) {
                Text("A new way to talk to yourself")
                    .font(.custom("Quicksand-Bold", size: 32))
                    .foregroundColor(themeManager.colors.text)
                    .multilineTextAlignment(.center)
                
                Text("Transform negative thoughts into positive perspectives with AI-powered reframing")
                    .font(.custom("Nunito-Regular", size: 16))
                    .foregroundColor(themeManager.colors.textLight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.bottom, 48)
            
            // Get Started Button
            Button(action: {
                coordinator.next()
            }) {
                Text("Get Started")
                    .font(.custom("Nunito-SemiBold", size: 18))
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
                    .shadow(color: themeManager.colors.primary.opacity(0.3), radius: 12, x: 0, y: 6)
            }
        }
        .padding(24)
        .background(themeManager.colors.background)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    WelcomeScreen()
        .environmentObject(ThemeManager())
        .environmentObject(OnboardingCoordinator())
} 