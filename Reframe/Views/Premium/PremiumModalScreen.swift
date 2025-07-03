import SwiftUI

struct PremiumModalScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            // Background
            themeManager.colors.background
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Header
                PremiumHeader()
                    .padding(.top, 16)
                
                // Features List
                VStack(spacing: 12) {
                    // Unlimited Reframes
                    FeatureCard(
                        icon: "♾️",
                        title: "Unlimited Reframes",
                        description: "Reframe as many thoughts as you want"
                    )
                    
                    // Unlock All Coaches
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureCard(
                            icon: "🧠",
                            title: "Unlock All Coaches",
                            description: "Access all coaches and switch anytime"
                        )
                        
                        CoachCarousel()
                            .frame(height: 90)
                            .padding(.horizontal, -20)
                    }
                    
                    // Coach Sessions
                    FeatureCard(
                        icon: "💬",
                        title: "25 Coach Sessions Per Day",
                        description: "Talk to your AI coach with more flexibility"
                    )
                    
                    // Widgets
                    FeatureCard(
                        icon: "📱",
                        title: "All Widgets",
                        description: "Access all home screen widget options"
                    )
                    
                    // Themes
                    FeatureCard(
                        icon: "🎨",
                        title: "All Themes",
                        description: "Customize the app to match your vibe"
                    )
                    
                    // Priority Access
                    FeatureCard(
                        icon: "🚀",
                        title: "Priority Insights & Early Access",
                        description: "Try upcoming features and view in-depth self trends"
                    )
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                
                Spacer()
                
                // Subscribe Button
                VStack(spacing: 8) {
                    Button(action: {
                        // Subscription handling will be implemented
                    }) {
                        HStack {
                            Text("Upgrade to Premium")
                                .font(.custom("Quicksand-Bold", size: 18))
                            Image(systemName: "sparkles")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
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
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Maybe Later")
                            .font(.custom("Nunito-SemiBold", size: 16))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(themeManager.colors.background)
            }
            .background(themeManager.colors.background)
            .offset(y: animateContent ? 0 : 100)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
        }
    }
}

struct PremiumHeader: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            // Placeholder for Lottie animation
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            themeManager.colors.primary,
                            themeManager.colors.primaryDark
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 4) {
                Text("Upgrade to Premium")
                    .font(.custom("Quicksand-Bold", size: 24))
                    .foregroundColor(themeManager.colors.text)
                
                Text("Unlock the full potential of Reframe")
                    .font(.custom("Nunito-Regular", size: 14))
                    .foregroundColor(themeManager.colors.textLight)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct FeatureCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Quicksand-SemiBold", size: 16))
                    .foregroundColor(themeManager.colors.text)
                
                Text(description)
                    .font(.custom("Nunito-Regular", size: 13))
                    .foregroundColor(themeManager.colors.textLight)
            }
            
            Spacer()
        }
        .padding(10)
        .background(themeManager.colors.surface)
        .cornerRadius(16)
    }
}

#Preview {
    PremiumModalScreen()
        .environmentObject(ThemeManager())
} 