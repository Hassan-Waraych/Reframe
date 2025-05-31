import SwiftUI

struct SignUpScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @Environment(\.dismiss) private var dismiss
    
    let isFromSettings: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var isAnimating = false
    @State private var isLoginMode = false
    @State private var keyboardHeight: CGFloat = 0
    
    init(isFromSettings: Bool = false) {
        self.isFromSettings = isFromSettings
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    HStack {
                        if isFromSettings {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(themeManager.colors.text)
                                    .frame(width: 40, height: 40)
                                    .background(themeManager.colors.surface)
                                    .clipShape(Circle())
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isLoginMode ? "Welcome back" : "Create your account")
                            .font(.custom("Quicksand-Bold", size: 28))
                            .foregroundColor(themeManager.colors.text)
                        
                        Text(isLoginMode ? "Sign in to continue your journey" : "Start your journey to better mental clarity")
                            .font(.custom("Nunito-Regular", size: 16))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    
                    // Form
                    VStack(spacing: 16) {
                        // Email Input
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.colors.textLight)
                            
                            TextField("Email", text: $email)
                                .font(.custom("Nunito-Regular", size: 16))
                                .foregroundColor(themeManager.colors.text)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disabled(authService.isLoading)
                        }
                        .padding(16)
                        .background(themeManager.colors.surface)
                        .cornerRadius(12)
                        
                        // Password Input
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.colors.textLight)
                            
                            SecureField("Password", text: $password)
                                .font(.custom("Nunito-Regular", size: 16))
                                .foregroundColor(themeManager.colors.text)
                                .textContentType(isLoginMode ? .password : .newPassword)
                                .disabled(authService.isLoading)
                        }
                        .padding(16)
                        .background(themeManager.colors.surface)
                        .cornerRadius(12)
                        
                        if let error = authService.errorMessage {
                            Text(error)
                                .font(.custom("Nunito-Regular", size: 14))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                        }
                        
                        // Action Button
                        Button(action: handleAuthAction) {
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        themeManager.colors.primary,
                                        themeManager.colors.primaryDark
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .cornerRadius(16)
                                
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(isLoginMode ? "Sign In" : "Create Account")
                                        .font(.custom("Nunito-SemiBold", size: 18))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .shadow(color: themeManager.colors.primary.opacity(0.3), radius: 12, x: 0, y: 6)
                        .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                        .opacity((authService.isLoading || email.isEmpty || password.isEmpty) ? 0.5 : 1)
                        
                        // Toggle between Sign Up and Login
                        Button(action: {
                            withAnimation {
                                isLoginMode.toggle()
                                authService.errorMessage = nil
                            }
                        }) {
                            Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                                .font(.custom("Nunito-Medium", size: 16))
                                .foregroundColor(themeManager.colors.primary)
                        }
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(themeManager.colors.border)
                                .frame(height: 1)
                            
                            Text("or")
                                .font(.custom("Nunito-Regular", size: 14))
                                .foregroundColor(themeManager.colors.textLight)
                                .padding(.horizontal, 16)
                            
                            Rectangle()
                                .fill(themeManager.colors.border)
                                .frame(height: 1)
                        }
                        
                        // Social Buttons
                        VStack(spacing: 12) {
                            Button(action: handleGoogleSignIn) {
                                HStack {
                                    Image("google_logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                    
                                    Text("Continue with Google")
                                        .font(.custom("Nunito-SemiBold", size: 16))
                                        .foregroundColor(themeManager.colors.text)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(themeManager.colors.surface)
                                .cornerRadius(16)
                            }
                            
                            Button(action: handleAppleSignIn) {
                                HStack {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: 24))
                                        .foregroundColor(themeManager.colors.text)
                                    
                                    Text("Continue with Apple")
                                        .font(.custom("Nunito-SemiBold", size: 16))
                                        .foregroundColor(themeManager.colors.text)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(themeManager.colors.surface)
                                .cornerRadius(16)
                            }
                        }
                        
                        if !isFromSettings {
                            // Guest Mode Button
                            Button(action: {
                                coordinator.handleGuestMode()
                            }) {
                                Text("Continue as Guest")
                                    .font(.custom("Nunito-Medium", size: 16))
                                    .foregroundColor(themeManager.colors.textLight)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                            }
                        }
                    }
                }
                .padding(24)
                .frame(minHeight: geometry.size.height)
            }
            .background(themeManager.colors.background)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    isAnimating = true
                }
            }
            .ignoresSafeArea(.keyboard)
        }
    }
    
    private func handleAuthAction() {
        Task {
            do {
                if isLoginMode {
                    try await authService.signIn(email: email, password: password)
                } else {
                    try await authService.signUp(email: email, password: password)
                }
                
                if isFromSettings {
                    dismiss()
                } else {
                    coordinator.completeOnboarding()
                }
            } catch {
                print("Debug: Auth error: \(error.localizedDescription)")
                // Error is handled by the authService
            }
        }
    }
    
    private func handleGoogleSignIn() {
        Task {
            do {
                try await authService.signInWithGoogle()
                if isFromSettings {
                    dismiss()
                } else {
                    coordinator.completeOnboarding()
                }
            } catch {
                print("Debug: Google sign in error: \(error.localizedDescription)")
                // Error is handled by the authService
            }
        }
    }
    
    private func handleAppleSignIn() {
        Task {
            do {
                try await authService.signInWithApple()
                if isFromSettings {
                    dismiss()
                } else {
                    coordinator.completeOnboarding()
                }
            } catch {
                print("Debug: Apple sign in error: \(error.localizedDescription)")
                // Error is handled by the authService
            }
        }
    }
}

#Preview {
    SignUpScreen()
        .environmentObject(ThemeManager())
        .environmentObject(OnboardingCoordinator())
        .environmentObject(AuthService.shared)
} 