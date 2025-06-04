import SwiftUI

struct DevSettingsScreen: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var loading = false
    @State private var testResults: TestResults?
    @State private var showOnboardingResetAlert = false
    @State private var showReframeLimitResetAlert = false
    @State private var showClearReframesAlert = false
    @State private var showClearJournalAlert = false
    
    struct TestResults {
        let connection: Bool
        let auth: Bool
        let firestore: Bool
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView
                firebaseTestsSection
                onboardingResetSection
                reframeLimitResetSection
                journalSection
            }
            .padding(.vertical)
        }
        .background(themeManager.colors.background)
        .alert("Reset Onboarding", isPresented: $showOnboardingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetOnboarding()
            }
        } message: {
            Text("This will reset the onboarding experience and sign you out. You'll need to go through the onboarding flow again.")
        }
        .alert("Reset Reframe Limit", isPresented: $showReframeLimitResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                ReframeService.shared.resetDailyCount()
            }
        } message: {
            Text("This will reset your daily reframe limit. You'll be able to create 5 new reframes today.")
        }
        .alert("Clear All Reframes", isPresented: $showClearReframesAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                clearAllReframes()
            }
        } message: {
            Text("This will permanently delete all your reframes. This action cannot be undone.")
        }
        .alert("Clear All Journal Entries", isPresented: $showClearJournalAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                clearAllJournalEntries()
            }
        } message: {
            Text("This will permanently delete all your journal entries. This action cannot be undone.")
        }
    }
    
    private var headerView: some View {
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
    }
    
    private var firebaseTestsSection: some View {
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
                testResultsView(results: results)
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
    }
    
    private func testResultsView(results: TestResults) -> some View {
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
    
    private var onboardingResetSection: some View {
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
    
    private var reframeLimitResetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reframe Limits")
                .font(.system(size: themeManager.typography.fontSize.h3, weight: .bold))
                .foregroundColor(themeManager.colors.text)
            
            Button(action: {
                showReframeLimitResetAlert = true
            }) {
                Text("Reset Daily Reframe Limit")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(themeManager.colors.secondary)
                    .cornerRadius(12)
            }
            
            Button(action: {
                showClearReframesAlert = true
            }) {
                Text("Clear All Reframes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(themeManager.colors.error)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
    
    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Journal")
                .font(.system(size: themeManager.typography.fontSize.h3, weight: .bold))
                .foregroundColor(themeManager.colors.text)
            
            Button(action: {
                showClearJournalAlert = true
            }) {
                Text("Clear All Journal Entries")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(themeManager.colors.error)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
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
    
    private func resetOnboarding() {
        // Reset onboarding state
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        // Sign out the user
        do {
            try AuthService.shared.signOut()
        } catch {
            // Error is handled by the authService
        }
        
        // Clear all reframes
        Task {
            do {
                try await ReframeService.shared.clearAllReframes()
            } catch {
                // Error is handled by the reframeService
            }
        }
    }
    
    private func clearAllReframes() {
        Task {
            do {
                try await ReframeService.shared.clearAllReframes()
            } catch {
                // Error is handled by the reframeService
            }
        }
    }
    
    private func clearAllJournalEntries() {
        Task {
            do {
                try await JournalService.shared.clearAllEntries()
            } catch {
                // Error is handled by the journalService
            }
        }
    }
}

#Preview {
    DevSettingsScreen()
        .environmentObject(ThemeManager())
} 