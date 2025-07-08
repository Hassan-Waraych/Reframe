import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SignUpScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @Environment(\.dismiss) private var dismiss
    
    let isFromSettings: Bool
    
    @State private var isAnimating = false
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
                        Text("Welcome to Reframe")
                            .font(.custom("Quicksand-Bold", size: 28))
                            .foregroundColor(themeManager.colors.text)
                        
                        Text("Sign in to continue your journey to better mental clarity")
                            .font(.custom("Nunito-Regular", size: 16))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    
                    // Social Sign In Section
                    VStack(spacing: 24) {
                        // Error Message
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .font(.custom("Nunito-Regular", size: 14))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                        }
                        
                        // Social Sign In Buttons
                        VStack(spacing: 16) {
                            Text("Sign in with")
                                .font(.custom("Nunito-Regular", size: 16))
                                .foregroundColor(themeManager.colors.textLight)
                            
                            VStack(spacing: 12) {
                                Button(action: handleGoogleSignIn) {
                                    HStack {
                                        Image("google_logo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                        
                                        Text("Continue with Google")
                                            .font(.custom("Nunito-Medium", size: 16))
                                            .foregroundColor(themeManager.colors.text)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(themeManager.colors.surface)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(themeManager.colors.border, lineWidth: 1)
                                    )
                                }
                                .disabled(authService.isLoading)
                                
                                Button(action: handleAppleSignIn) {
                                    HStack {
                                        Image(systemName: "apple.logo")
                                            .font(.system(size: 20))
                                            .foregroundColor(themeManager.colors.text)
                                        
                                        Text("Continue with Apple")
                                            .font(.custom("Nunito-Medium", size: 16))
                                            .foregroundColor(themeManager.colors.text)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(themeManager.colors.surface)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(themeManager.colors.border, lineWidth: 1)
                                    )
                                }
                                .disabled(authService.isLoading)
                            }
                        }
                        
                        // Info Text
                        VStack(spacing: 8) {
                            Text("By continuing, you agree to our")
                                .font(.custom("Nunito-Regular", size: 12))
                                .foregroundColor(themeManager.colors.textLight)
                            
                            HStack(spacing: 4) {
                                Button("Terms of Service") {
                                    // Handle terms of service
                                }
                                .font(.custom("Nunito-Medium", size: 12))
                                .foregroundColor(themeManager.colors.primary)
                                
                                Text("and")
                                    .font(.custom("Nunito-Regular", size: 12))
                                    .foregroundColor(themeManager.colors.textLight)
                                
                                Button("Privacy Policy") {
                                    // Handle privacy policy
                                }
                                .font(.custom("Nunito-Medium", size: 12))
                                .foregroundColor(themeManager.colors.primary)
                            }
                        }
                    }
                    .padding(.horizontal)
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
    
    private func handleGoogleSignIn() {
        Task {
            do {
                try await authService.signInWithGoogle()
                
                // Store assigned coach in Firestore if available
                if let coach = coordinator.assignedCoach {
                    let db = Firestore.firestore()
                    if let userId = Auth.auth().currentUser?.uid {
                        try await db.collection("users").document(userId).setData([
                            "coachId": coach.id,
                            "coachAssignedAt": FieldValue.serverTimestamp()
                        ], merge: true)
                    }
                }
                
                if isFromSettings {
                    dismiss()
                } else {
                    coordinator.next()
                }
            } catch {
                // Error is handled by the authService
            }
        }
    }
    
    private func handleAppleSignIn() {
        Task {
            do {
                try await authService.signInWithApple()
                
                // Store assigned coach in Firestore if available
                if let coach = coordinator.assignedCoach {
                    let db = Firestore.firestore()
                    if let userId = Auth.auth().currentUser?.uid {
                        try await db.collection("users").document(userId).setData([
                            "coachId": coach.id,
                            "coachAssignedAt": FieldValue.serverTimestamp()
                        ], merge: true)
                    }
                }
                
                if isFromSettings {
                    dismiss()
                } else {
                    coordinator.next()
                }
            } catch {
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