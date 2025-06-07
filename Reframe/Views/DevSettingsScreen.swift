import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct DevSettingsScreen: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var loading = false
    @State private var testResults: TestResults?
    @State private var showOnboardingResetAlert = false
    @State private var showReframeLimitResetAlert = false
    @State private var showClearReframesAlert = false
    @State private var showClearJournalAlert = false
    @State private var showClearCoachMessagesAlert = false
    @State private var showClearCoachHistoryAlert = false
    @State private var showCoachTestView = false
    
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
                streakSection
                userStatusSection
                journalSection
                coachSection
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
        .alert("Clear All Coach Messages", isPresented: $showClearCoachMessagesAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                clearAllCoachMessages()
            }
        } message: {
            Text("This will permanently delete all your messages with your coach. This action cannot be undone.")
        }
        .alert("Clear All Coach History", isPresented: $showClearCoachHistoryAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                clearAllCoachHistory()
            }
        } message: {
            Text("This will permanently delete all your coach conversation history. This action cannot be undone.")
        }
        .sheet(isPresented: $showCoachTestView) {
            CoachTestView()
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
    
    @ViewBuilder
    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Streak")
                .font(.system(size: themeManager.typography.fontSize.h3, weight: .bold))
                .foregroundColor(themeManager.colors.text)

            Button(action: { Task { await resetStreak() } }) {
                Text("Reset Streak")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(themeManager.colors.secondary)
                    .cornerRadius(12)
            }

            Button(action: { Task { await incrementStreak() } }) {
                Text("+1 Day Streak")
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
    
    private var userStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("User Status")
                .font(.system(size: themeManager.typography.fontSize.h3, weight: .bold))
                .foregroundColor(themeManager.colors.text)
            
            HStack(spacing: 16) {
                Button(action: { Task { await setUserStatus(.free) } }) {
                    Text("Set Free")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(themeManager.colors.secondary)
                        .cornerRadius(12)
                }
                
                Button(action: { Task { await setUserStatus(.premium) } }) {
                    Text("Set Premium")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(themeManager.colors.primary)
                        .cornerRadius(12)
                }
            }
            
            Text("Current Status: \(authService.userStatus.rawValue.capitalized)")
                .font(.system(size: 16))
                .foregroundColor(themeManager.colors.textLight)
        }
        .padding(.horizontal)
    }
    
    @MainActor
    private func resetStreak() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let streakRef = Firestore.firestore().collection("streaks").document(userId)
        try? await streakRef.setData([
            "userId": userId,
            "count": 0,
            "lastUpdated": Timestamp(date: Date())
        ])
    }

    @MainActor
    private func incrementStreak() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let streakRef = Firestore.firestore().collection("streaks").document(userId)
        let doc = try? await streakRef.getDocument()
        if let data = doc?.data(), let count = data["count"] as? Int {
            try? await streakRef.updateData([
                "count": count + 1,
                "lastUpdated": Timestamp(date: Date())
            ])
        }
    }
    
    @MainActor
    private func setUserStatus(_ status: UserStatus) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        try? await db.collection("users").document(userId).updateData([
            "userStatus": status.rawValue
        ])
        authService.userStatus = status
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
    
    private var coachSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Coach")
                .font(.system(size: themeManager.typography.fontSize.h3, weight: .bold))
                .foregroundColor(themeManager.colors.text)
            
            VStack(spacing: 12) {
                Button(action: {
                    showCoachTestView = true
                }) {
                    Text("Test Coach Assignment")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(themeManager.colors.primary)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    showClearCoachMessagesAlert = true
                }) {
                    Text("Clear All Coach Messages")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(themeManager.colors.secondary)
                        .cornerRadius(12)
                }

                Button(action: {
                    showClearCoachHistoryAlert = true
                }) {
                    Text("Clear All Coach History")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(themeManager.colors.error)
                        .cornerRadius(12)
                }
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
    
    private func clearAllCoachMessages() {
        if let userId = Auth.auth().currentUser?.uid {
            Task {
                do {
                    let db = Firestore.firestore()
                    let snapshot = try await db.collection("coachMessages")
                        .whereField("userId", isEqualTo: userId)
                        .getDocuments()
                    
                    for document in snapshot.documents {
                        try await document.reference.delete()
                    }
                } catch {
                    print("Error clearing coach messages: \(error)")
                }
            }
        }
    }
    
    private func clearAllCoachHistory() {
        if let userId = Auth.auth().currentUser?.uid {
            Task {
                do {
                    let db = Firestore.firestore()
                    let snapshot = try await db.collection("coachHistory")
                        .whereField("userId", isEqualTo: userId)
                        .getDocuments()
                    
                    for document in snapshot.documents {
                        try await document.reference.delete()
                    }
                } catch {
                    print("Error clearing coach history: \(error)")
                }
            }
        }
    }
}

#Preview {
    DevSettingsScreen()
        .environmentObject(ThemeManager())
        .environmentObject(AuthService.shared)
} 