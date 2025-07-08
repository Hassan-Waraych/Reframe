import SwiftUI
import StoreKit

struct OnboardingPaywallScreen: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var coordinator: OnboardingCoordinator
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
                    .padding(.top, 20)
                
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
                            .frame(height: 80)
                            .padding(.horizontal, -20)
                            .padding(.vertical, 4)
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
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                
                Spacer()
                
                // Subscribe Buttons
                VStack(spacing: 8) {
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
                                        .font(.custom("Quicksand-Bold", size: 14))
                                    Text(monthlyProduct.displayPrice + "/month")
                                        .font(.custom("Nunito-Regular", size: 11))
                                        .opacity(0.8)
                                }
                                Spacer()
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
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
                            .cornerRadius(14)
                            .shadow(color: themeManager.colors.primary.opacity(0.3), radius: 10, x: 0, y: 4)
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
                                            .font(.custom("Quicksand-Bold", size: 14))
                                        Text("SAVE 50%")
                                            .font(.custom("Nunito-Bold", size: 9))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                            .background(Color.yellow)
                                            .foregroundColor(.black)
                                            .cornerRadius(3)
                                    }
                                    Text(yearlyProduct.displayPrice + "/year")
                                        .font(.custom("Nunito-Regular", size: 11))
                                        .opacity(0.8)
                                }
                                Spacer()
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
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
                            .cornerRadius(14)
                            .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 4)
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
                            .font(.custom("Nunito-SemiBold", size: 12))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    .disabled(storeKitService.isLoading)
                    
                    // Maybe Later
                    Button(action: {
                        coordinator.next()
                    }) {
                        Text("Maybe Later")
                            .font(.custom("Nunito-SemiBold", size: 14))
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
            // Purchase successful, continue to next step
            await MainActor.run {
                coordinator.next()
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
            // Restore successful, continue to next step
            await MainActor.run {
                coordinator.next()
            }
        } catch {
            await MainActor.run {
                showError = true
            }
        }
    }
}

#Preview {
    OnboardingPaywallScreen()
        .environmentObject(ThemeManager())
        .environmentObject(OnboardingCoordinator())
} 