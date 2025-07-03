import SwiftUI
import StoreKit

struct PremiumModalScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var storeKitService = StoreKitService.shared
    @State private var animateContent = false
    @State private var selectedProduct: Product?
    @State private var showError = false
    
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
                
                // Subscribe Buttons
                VStack(spacing: 12) {
                    // Monthly Subscription
                    if let monthlyProduct = storeKitService.getMonthlyProduct() {
                        Button(action: {
                            selectedProduct = monthlyProduct
                            Task {
                                await purchaseProduct(monthlyProduct)
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Monthly Premium")
                                        .font(.custom("Quicksand-Bold", size: 16))
                                    Text(monthlyProduct.displayPrice + "/month")
                                        .font(.custom("Nunito-Regular", size: 12))
                                        .opacity(0.8)
                                }
                                Spacer()
                                Image(systemName: "sparkles")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
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
                        .disabled(storeKitService.isLoading)
                    }
                    
                    // Yearly Subscription (with savings)
                    if let yearlyProduct = storeKitService.getYearlyProduct() {
                        Button(action: {
                            selectedProduct = yearlyProduct
                            Task {
                                await purchaseProduct(yearlyProduct)
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 4) {
                                        Text("Yearly Premium")
                                            .font(.custom("Quicksand-Bold", size: 16))
                                        Text("SAVE 50%")
                                            .font(.custom("Nunito-Bold", size: 10))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.yellow)
                                            .foregroundColor(.black)
                                            .cornerRadius(4)
                                    }
                                    Text(yearlyProduct.displayPrice + "/year")
                                        .font(.custom("Nunito-Regular", size: 12))
                                        .opacity(0.8)
                                }
                                Spacer()
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.orange,
                                        Color.yellow
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.orange.opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .disabled(storeKitService.isLoading)
                    }
                    
                    // Restore Purchases
                    Button(action: {
                        Task {
                            await restorePurchases()
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.custom("Nunito-SemiBold", size: 14))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    .disabled(storeKitService.isLoading)
                    
                    // Maybe Later
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
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(storeKitService.errorMessage ?? "An error occurred during purchase")
        }
    }
    
    // MARK: - Purchase Methods
    
    private func purchaseProduct(_ product: Product) async {
        do {
            try await storeKitService.purchase(product)
            // Purchase successful, dismiss the modal
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
    
    private func restorePurchases() async {
        do {
            try await storeKitService.restorePurchases()
            // Restore successful, dismiss the modal
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                showError = true
            }
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