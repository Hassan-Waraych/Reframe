import SwiftUI

struct ValuePitchScreen: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: OnboardingCoordinator
    @State private var animateContent = false
    @State private var animateFeatures = false
    @State private var animateButton = false
    
    let features = [
        ValueFeature(icon: "🧠", title: "Daily Reframes", description: "2/day free – unlimited with Premium", isPremium: false),
        ValueFeature(icon: "💬", title: "AI Coaching", description: "3/week free – 25/day with Premium", isPremium: false),
        ValueFeature(icon: "📝", title: "Guided Journaling", description: "All free", isPremium: false),
        ValueFeature(icon: "📊", title: "Progress Tracking", description: "All free", isPremium: false),
        ValueFeature(icon: "🔄", title: "Coach Switching", description: "Premium only", isPremium: true),
        ValueFeature(icon: "📱", title: "Premium Widgets", description: "Premium only", isPremium: true),
        ValueFeature(icon: "🎨", title: "Exclusive Themes", description: "Premium only", isPremium: true),
    ]
    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    themeManager.colors.background,
                    themeManager.colors.surface.opacity(0.3),
                    themeManager.colors.background
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating particles effect
            ZStack {
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    themeManager.colors.primary.opacity(0.3),
                                    themeManager.colors.primary.opacity(0.1),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                        .position(
                            x: CGFloat.random(in: 50...350),
                            y: CGFloat.random(in: 100...800)
                        )
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true),
                            value: UUID()
                        )
                }
            }
            .allowsHitTesting(false)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header Section
                    VStack(spacing: 16) {
                        // Main Title
                        Text("What's Inside Reframe")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(themeManager.colors.text)
                            .multilineTextAlignment(.center)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // Subtitle
                        Text("Discover the tools that will help you transform your thoughts and build emotional resilience.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.colors.textLight)
                            .multilineTextAlignment(.center)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                    }
                    
                    // Features Grid
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(Array(features.enumerated()), id: \.element.title) { index, feature in
                            FeatureRow(feature: feature)
                                .opacity(animateFeatures ? 1 : 0)
                                .offset(x: animateFeatures ? 0 : -50)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateFeatures)
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    // CTA Section
                    VStack(spacing: 16) {
                        // Continue Button
                        Button(action: {
                            coordinator.next()
                        }) {
                            HStack(spacing: 12) {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .bold))
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
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
                            .cornerRadius(20)
                            .shadow(color: themeManager.colors.primary.opacity(0.4), radius: 15, x: 0, y: 8)
                            .scaleEffect(animateButton ? 1.0 : 0.95)
                        }
                        .opacity(animateButton ? 1 : 0)
                        .offset(y: animateButton ? 0 : 30)
                        

                    }
                }
                .padding(24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateFeatures = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateButton = true
                }
            }
        }
    }
}

struct ValueFeature {
    let icon: String
    let title: String
    let description: String
    let isPremium: Bool
}

struct FeatureRow: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let feature: ValueFeature
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                feature.isPremium ? Color.yellow.opacity(0.3) : themeManager.colors.primary.opacity(0.2),
                                feature.isPremium ? Color.orange.opacity(0.2) : themeManager.colors.primary.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Text(feature.icon)
                    .font(.system(size: 20))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(feature.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.colors.text)
                    
                    if feature.isPremium {
                        Text("PREMIUM")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(4)
                    }
                }
                
                Text(feature.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(feature.isPremium ? themeManager.colors.primary : themeManager.colors.textLight)
            }
            
            Spacer()
            
            // Icon (checkmark for free, lock for premium)
            if feature.isPremium {
                Image(systemName: "lock.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.yellow)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(themeManager.colors.primary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            feature.isPremium ? Color.yellow.opacity(0.3) : Color.clear,
                            lineWidth: feature.isPremium ? 1 : 0
                        )
                )
                .shadow(
                    color: feature.isPremium ? Color.yellow.opacity(0.2) : Color.black.opacity(0.05),
                    radius: feature.isPremium ? 12 : 8,
                    x: 0,
                    y: feature.isPremium ? 6 : 4
                )
        )
        .scaleEffect(feature.isPremium ? 1.02 : 1.0)
    }
}

#Preview {
    ValuePitchScreen()
        .environmentObject(ThemeManager())
        .environmentObject(OnboardingCoordinator())
} 