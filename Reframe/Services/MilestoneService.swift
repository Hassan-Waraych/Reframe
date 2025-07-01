import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class MilestoneService: ObservableObject {
    static let shared = MilestoneService()
    private let db = Firestore.firestore()
    
    @Published var milestones: [Milestone] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showMilestoneNotification = false
    @Published var completedMilestone: Milestone?
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let userId = user?.uid {
                Task {
                    await self?.loadMilestones(userId: userId)
                }
            } else {
                DispatchQueue.main.async {
                    self?.milestones = []
                }
            }
        }
    }
    
    @MainActor
    func loadMilestones(userId: String) async {
        isLoading = true
        
        do {
            let document = try await db.collection("milestones").document(userId).getDocument()
            
            if document.exists {
                let milestoneData = try document.data(as: MilestoneData.self)
                self.milestones = milestoneData.milestones
            } else {
                // Initialize with default milestones
                self.milestones = Milestone.defaultMilestones
                try await saveMilestones(userId: userId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func saveMilestones(userId: String) async throws {
        let milestoneData = MilestoneData(userId: userId, milestones: milestones)
        try await db.collection("milestones").document(userId).setData(from: milestoneData)
    }
    
    // MARK: - Milestone Checking Methods
    
    func checkFirstReframe() async {
        await checkMilestone(id: "first_reframe") { [weak self] in
            await self?.hasCompletedFirstReframe() ?? false
        }
    }
    
    func checkFirstReflection() async {
        await checkMilestone(id: "first_reflection") { [weak self] in
            await self?.hasCompletedFirstReflection() ?? false
        }
    }
    
    func checkFirstGuidedJournal() async {
        await checkMilestone(id: "first_guided_journal") { [weak self] in
            await self?.hasCompletedFirstGuidedJournal() ?? false
        }
    }
    
    func checkFirstBreathing() async {
        await checkMilestone(id: "first_breathing") { [weak self] in
            await self?.hasCompletedFirstBreathing() ?? false
        }
    }
    
    func checkFirstCoach() async {
        await checkMilestone(id: "first_coach") { [weak self] in
            await self?.hasCompletedFirstCoach() ?? false
        }
    }
    
    func checkPremiumExplorer() async {
        await checkMilestone(id: "premium_explorer") { [weak self] in
            await self?.isPremiumUser() ?? false
        }
    }
    
    func checkStreakMilestones() async {
        let currentStreak = await getCurrentStreak()
        
        await checkMilestone(id: "three_day_streak") { currentStreak >= 3 }
        await checkMilestone(id: "seven_day_streak") { currentStreak >= 7 }
        await checkMilestone(id: "thirty_day_streak") { currentStreak >= 30 }
    }
    
    func checkReframeCountMilestones() async {
        let reframeCount = await getReframeCount()
        
        await checkMilestone(id: "five_reframes") { reframeCount >= 5 }
        await checkMilestone(id: "fifty_reframes") { reframeCount >= 50 }
    }
    
    func checkReflectionCountMilestones() async {
        let reflectionCount = await getReflectionCount()
        
        await checkMilestone(id: "ten_reflections") { reflectionCount >= 10 }
        await checkMilestone(id: "hundred_reflections") { reflectionCount >= 100 }
    }
    
    // MARK: - Helper Methods
    
    private func checkMilestone(id: String, condition: @escaping () async -> Bool) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let index = milestones.firstIndex(where: { $0.id == id }) {
            let milestone = milestones[index]
            
            if !milestone.isCompleted {
                let shouldComplete = await condition()
                
                if shouldComplete {
                    await MainActor.run {
                        milestones[index].isCompleted = true
                        milestones[index].dateCompleted = Date()
                        
                        // Trigger notification
                        completedMilestone = milestones[index]
                        showMilestoneNotification = true
                        
                        print("🎉 Milestone unlocked: \(milestone.title)")
                    }
                    
                    try? await saveMilestones(userId: userId)
                }
            }
        }
    }
    
    private func hasCompletedFirstReframe() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        
        do {
            let snapshot = try await db.collection("reframes")
                .whereField("userId", isEqualTo: userId)
                .whereField("category", isNotEqualTo: "Reflection")
                .limit(to: 10) // Get a few documents to filter in memory
                .getDocuments()
            
            // Filter out Nonsense category in memory
            let validReframes = snapshot.documents.filter { document in
                if let category = document.data()["category"] as? String {
                    return category != "Nonsense"
                }
                return false
            }
            
            let hasReframe = !validReframes.isEmpty
            print("🔍 Checking first reframe: \(hasReframe ? "Found" : "Not found")")
            return hasReframe
        } catch {
            print("❌ Error checking first reframe: \(error)")
            return false
        }
    }
    
    private func hasCompletedFirstReflection() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        
        do {
            let snapshot = try await db.collection("reframes")
                .whereField("userId", isEqualTo: userId)
                .whereField("category", isEqualTo: "Reflection")
                .limit(to: 1)
                .getDocuments()
            
            return !snapshot.documents.isEmpty
        } catch {
            return false
        }
    }
    
    private func hasCompletedFirstGuidedJournal() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        
        do {
            let snapshot = try await db.collection("journal_entries")
                .whereField("userId", isEqualTo: userId)
                .whereField("category", isEqualTo: "Guided Prompt")
                .limit(to: 1)
                .getDocuments()
            
            return !snapshot.documents.isEmpty
        } catch {
            return false
        }
    }
    
    private func hasCompletedFirstBreathing() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        
        do {
            let snapshot = try await db.collection("calming_tool_usage")
                .whereField("userId", isEqualTo: userId)
                .whereField("toolType", isEqualTo: "breathing")
                .limit(to: 1)
                .getDocuments()
            
            return !snapshot.documents.isEmpty
        } catch {
            return false
        }
    }
    
    private func hasCompletedFirstCoach() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        
        do {
            let snapshot = try await db.collection("coachHistory")
                .whereField("userId", isEqualTo: userId)
                .limit(to: 1)
                .getDocuments()
            
            let hasCoach = !snapshot.documents.isEmpty
            print("🔍 Checking first coach: \(hasCoach ? "Found" : "Not found")")
            return hasCoach
        } catch {
            print("❌ Error checking first coach: \(error)")
            return false
        }
    }
    
    private func isPremiumUser() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let data = document.data(), let userStatus = data["userStatus"] as? String {
                return userStatus == "premium"
            }
            return false
        } catch {
            return false
        }
    }
    
    private func getCurrentStreak() async -> Int {
        guard let userId = Auth.auth().currentUser?.uid else { return 0 }
        
        do {
            let document = try await db.collection("streaks").document(userId).getDocument()
            if document.exists {
                let streak = try document.data(as: StreakTracker.self)
                let lastUpdated = Calendar.current.startOfDay(for: streak.lastUpdated)
                let today = Calendar.current.startOfDay(for: Date())
                
                if let daysBetween = Calendar.current.dateComponents([.day], from: lastUpdated, to: today).day,
                   daysBetween <= 1 {
                    return streak.count
                }
            }
            return 0
        } catch {
            return 0
        }
    }
    
    private func getReframeCount() async -> Int {
        guard let userId = Auth.auth().currentUser?.uid else { return 0 }
        
        do {
            let snapshot = try await db.collection("reframes")
                .whereField("userId", isEqualTo: userId)
                .whereField("category", isNotEqualTo: "Reflection")
                .getDocuments()
            
            // Filter out Nonsense category in memory
            let validReframes = snapshot.documents.filter { document in
                if let category = document.data()["category"] as? String {
                    return category != "Nonsense"
                }
                return false
            }
            
            let count = validReframes.count
            print("🔍 Reframe count: \(count)")
            return count
        } catch {
            print("❌ Error getting reframe count: \(error)")
            return 0
        }
    }
    
    private func getReflectionCount() async -> Int {
        guard let userId = Auth.auth().currentUser?.uid else { return 0 }
        
        do {
            let snapshot = try await db.collection("reframes")
                .whereField("userId", isEqualTo: userId)
                .whereField("category", isEqualTo: "Reflection")
                .getDocuments()
            
            return snapshot.documents.count
        } catch {
            return 0
        }
    }
    
    // MARK: - Dev Testing Methods
    
    @MainActor
    func resetAllMilestones() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        milestones = Milestone.defaultMilestones
        try? await saveMilestones(userId: userId)
    }
    
    @MainActor
    func completeMilestone(id: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let index = milestones.firstIndex(where: { $0.id == id }) {
            milestones[index].isCompleted = true
            milestones[index].dateCompleted = Date()
            try? await saveMilestones(userId: userId)
        }
    }
    
    @MainActor
    func uncompleteMilestone(id: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let index = milestones.firstIndex(where: { $0.id == id }) {
            milestones[index].isCompleted = false
            milestones[index].dateCompleted = nil
            try? await saveMilestones(userId: userId)
        }
    }
    
    // MARK: - Batch Checking
    
    func checkAllMilestones() async {
        await checkFirstReframe()
        await checkFirstReflection()
        await checkFirstGuidedJournal()
        await checkFirstBreathing()
        await checkFirstCoach()
        await checkPremiumExplorer()
        await checkStreakMilestones()
        await checkReframeCountMilestones()
        await checkReflectionCountMilestones()
    }
    
    // MARK: - Debug Methods
    
    @MainActor
    func forceCheckMilestones() async {
        print("🔍 Force checking all milestones...")
        await checkAllMilestones()
    }
    
    @MainActor
    func testNotification() {
        if let firstMilestone = milestones.first {
            completedMilestone = firstMilestone
            showMilestoneNotification = true
            print("🧪 Test notification triggered")
        }
    }
    
    func trackBreathingExercise() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Create usage record
        let usageData: [String: Any] = [
            "userId": userId,
            "toolType": "breathing",
            "timestamp": Timestamp(date: Date())
        ]
        
        do {
            try await db.collection("calming_tool_usage").addDocument(data: usageData)
        } catch {
            print("Error tracking breathing exercise: \(error)")
        }
    }
}

// MARK: - Data Models

struct MilestoneData: Codable {
    let userId: String
    var milestones: [Milestone]
    
    enum CodingKeys: String, CodingKey {
        case userId
        case milestones
    }
}

struct Milestone: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let category: MilestoneCategory
    var isCompleted: Bool
    var dateCompleted: Date?
    
    static let defaultMilestones: [Milestone] = [
        Milestone(id: "first_reframe", title: "First Reframe", subtitle: "You've taken your first step towards positive thinking!", icon: "sparkles", category: .beginner, isCompleted: false),
        Milestone(id: "first_reflection", title: "First Reflection", subtitle: "You've completed your first reflection session", icon: "brain.head.profile", category: .beginner, isCompleted: false),
        Milestone(id: "first_guided_journal", title: "First Guided Journal", subtitle: "You've completed your first guided journal prompt", icon: "text.bubble.fill", category: .beginner, isCompleted: false),
        Milestone(id: "first_breathing", title: "First Breathing Exercise", subtitle: "You've completed your first breathing exercise", icon: "lungs.fill", category: .wellness, isCompleted: false),
        Milestone(id: "first_coach", title: "First Coach Conversation", subtitle: "You've had your first conversation with an AI coach", icon: "person.fill.questionmark", category: .coaching, isCompleted: false),
        Milestone(id: "premium_explorer", title: "Premium Explorer", subtitle: "You've upgraded to premium!", icon: "crown.fill", category: .premium, isCompleted: false),
        Milestone(id: "three_day_streak", title: "3-Day Streak", subtitle: "You've maintained your practice for 3 consecutive days!", icon: "flame.fill", category: .consistency, isCompleted: false),
        Milestone(id: "seven_day_streak", title: "7-Day Streak", subtitle: "A full week of consistent practice!", icon: "flame.fill", category: .consistency, isCompleted: false),
        Milestone(id: "thirty_day_streak", title: "30-Day Streak", subtitle: "Incredible! You've built a strong habit over a month", icon: "flame.fill", category: .consistency, isCompleted: false),
        Milestone(id: "five_reframes", title: "5 Reframes", subtitle: "You've created 5 reframes", icon: "arrow.triangle.2.circlepath", category: .reframe, isCompleted: false),
        Milestone(id: "fifty_reframes", title: "50 Reframes", subtitle: "You've created 50 reframes - you're becoming a pro!", icon: "arrow.triangle.2.circlepath", category: .reframe, isCompleted: false),
        Milestone(id: "ten_reflections", title: "10 Reflections", subtitle: "You've completed 10 reflection sessions", icon: "brain.head.profile", category: .reflection, isCompleted: false),
        Milestone(id: "hundred_reflections", title: "100 Reflections", subtitle: "You've completed 100 reflection sessions - amazing depth!", icon: "brain.head.profile", category: .reflection, isCompleted: false)
    ]
}

enum MilestoneCategory: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case consistency = "Consistency"
    case reframe = "Reframe"
    case reflection = "Reflection"
    case wellness = "Wellness"
    case coaching = "Coaching"
    case premium = "Premium"
    
    var color: Color {
        switch self {
        case .beginner: return .blue
        case .consistency: return .orange
        case .reframe: return .purple
        case .reflection: return .indigo
        case .wellness: return .green
        case .coaching: return .pink
        case .premium: return .yellow
        }
    }
} 