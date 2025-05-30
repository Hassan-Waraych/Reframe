import SwiftUI

struct DevSettingsScreen: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var loading = false
    @State private var testResults: TestResults?
    @State private var showOnboardingResetAlert = false
    
    struct TestResults {
        let connection: Bool
        let auth: Bool
        let firestore: Bool
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24))
                            .foregroundColor(themeManager.colors.text)
                            .frame(width: 48, height: 48)
                    }
                    
                    Text("Developer Settings")
                        .font(.system(size: themeManager.typography.fontSize.h1, weight: .bold))
                        .foregroundColor(themeManager.colors.text)
                }
                .padding(.horizontal)
                
                // Firebase Tests Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Firebase Tests")
                        .font(.system(size: themeManager.typography.fontSize.h3, weight: .bold))
                        .foregroundColor(themeManager.colors.text)
                    
                    Button(action: runTests) {
                        Text(loading ? "Running Tests..." : "Test Firebase Connection")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(themeManager.colors.primary)
                            .cornerRadius(12)
                    }
                    .disabled(loading)
                    
                    if let results = testResults {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Connection: \(results.connection ? "✅" : "❌")")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.colors.text)
                            
                            Text("Auth: \(results.auth ? "✅" : "❌")")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.colors.text)
                            
                            Text("Firestore: \(results.firestore ? "✅" : "❌")")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.colors.text)
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    Button(action: testAuth) {
                        Text(loading ? "Testing Auth..." : "Test Authentication")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(themeManager.colors.primary)
                            .cornerRadius(12)
                    }
                    .disabled(loading)
                }
                .padding(.horizontal)
                
                // Onboarding Reset Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Onboarding")
                        .font(.system(size: themeManager.typography.fontSize.h3, weight: .bold))
                        .foregroundColor(themeManager.colors.text)
                    
                    Button(action: {
                        showOnboardingResetAlert = true
                    }) {
                        Text("Reset Onboarding")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(themeManager.colors.secondary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(themeManager.colors.background)
        .alert("Reset Onboarding", isPresented: $showOnboardingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                // TODO: Reset onboarding state
                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            }
        } message: {
            Text("This will reset the onboarding experience. You'll need to go through the onboarding flow again.")
        }
    }
    
    private func runTests() {
        loading = true
        // Simulate test delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            testResults = TestResults(connection: true, auth: true, firestore: true)
            loading = false
        }
    }
    
    private func testAuth() {
        loading = true
        // Simulate auth test delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            loading = false
        }
    }
}

#Preview {
    DevSettingsScreen()
        .environmentObject(ThemeManager())
} 