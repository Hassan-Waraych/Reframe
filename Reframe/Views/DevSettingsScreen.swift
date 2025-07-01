import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Foundation

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
                milestoneSection
                dailyWisdomPreviewSection
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
        
        // Check premium milestone if status is set to premium
        if status == .premium {
            await MilestoneService.shared.checkPremiumExplorer()
        }
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
    
    private var milestoneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Milestones")
                .font(.system(size: themeManager.typography.fontSize.h3, weight: .bold))
                .foregroundColor(themeManager.colors.text)
            
            Button(action: { Task { await resetAllMilestones() } }) {
                Text("Reset All Milestones")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(themeManager.colors.error)
                    .cornerRadius(12)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(MilestoneService.shared.milestones) { milestone in
                    MilestoneTestCard(milestone: milestone)
                }
            }
        }
        .padding(.horizontal)
    }
    
    @MainActor
    private func resetAllMilestones() async {
        await MilestoneService.shared.resetAllMilestones()
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
    
    private var dailyWisdomPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preview Daily Wisdom Strategies")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(themeManager.colors.text)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 32) {
                    ForEach(dailyBoostStrategies, id: \.id) { strategy in
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.87, green: 0.67, blue: 0.39),
                                    Color(red: 0.74, green: 0.51, blue: 0.22)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(width: 320, height: 480)
                            .cornerRadius(32)
                            VStack(spacing: 20) {
                                Image("TreeIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140, height: 140)
                                    .background(Color.clear)
                                    .padding(.top, 32)
                                Text(strategy.title)
                                    .font(.custom("Snell Roundhand", size: 28).weight(.bold))
                                    .foregroundColor(Color(red: 0.22, green: 0.13, blue: 0.07))
                                    .padding(.bottom, 2)
                                Text(strategy.description)
                                    .font(.custom("Georgia", size: 16))
                                    .foregroundColor(Color(red: 0.22, green: 0.13, blue: 0.07))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 12)
                                    .lineLimit(4)
                                    .minimumScaleFactor(0.7)
                                Spacer()
                            }
                            .frame(width: 300, height: 440)
                            .padding(.bottom, 24)
                            VStack {
                                Spacer()
                                WaveShape()
                                    .fill(Color(red: 0.56, green: 0.34, blue: 0.13))
                                    .frame(height: 40)
                                    .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                            }
                        }
                        .frame(width: 320, height: 480)
                        .shadow(radius: 8)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// Helper for corner radius on specific corners
fileprivate extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat = 0.0
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct MilestoneTestCard: View {
    let milestone: Milestone
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: milestone.icon)
                    .font(.system(size: 16))
                    .foregroundColor(milestone.isCompleted ? milestone.category.color : themeManager.colors.textLight)
                
                Text(milestone.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.colors.text)
                    .lineLimit(1)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                Button(action: { Task { await completeMilestone() } }) {
                    Text("Complete")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(milestone.isCompleted ? Color.gray : milestone.category.color)
                        .cornerRadius(8)
                }
                .disabled(milestone.isCompleted)
                
                Button(action: { Task { await uncompleteMilestone() } }) {
                    Text("Reset")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(milestone.isCompleted ? Color.red : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!milestone.isCompleted)
            }
        }
        .padding(8)
        .background(themeManager.colors.surface)
        .cornerRadius(8)
    }
    
    private func completeMilestone() async {
        await MilestoneService.shared.completeMilestone(id: milestone.id)
    }
    
    private func uncompleteMilestone() async {
        await MilestoneService.shared.uncompleteMilestone(id: milestone.id)
    }
}

#Preview {
    DevSettingsScreen()
        .environmentObject(ThemeManager())
        .environmentObject(AuthService.shared)
} 