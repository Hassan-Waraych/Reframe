import SwiftUI

struct Achievement: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let progress: Double // 0.0 to 1.0
    let isLocked: Bool
    let category: AchievementCategory
    let dateEarned: Date?
    
    static let mockAchievements: [Achievement] = [
        Achievement(
            id: "first_reframe",
            title: "First Reframe",
            subtitle: "You've taken your first step towards positive thinking!",
            icon: "sparkles",
            progress: 1.0,
            isLocked: false,
            category: .beginner,
            dateEarned: Date().addingTimeInterval(-86400 * 5)
        ),
        Achievement(
            id: "three_day_streak",
            title: "3-Day Streak",
            subtitle: "You've maintained your practice for 3 consecutive days!",
            icon: "flame.fill",
            progress: 1.0,
            isLocked: false,
            category: .consistency,
            dateEarned: Date().addingTimeInterval(-86400 * 2)
        ),
        Achievement(
            id: "ten_day_streak",
            title: "10-Day Streak",
            subtitle: "Incredible consistency! You're building a strong habit.",
            icon: "flame.fill",
            progress: 0.7,
            isLocked: true,
            category: .consistency,
            dateEarned: nil
        ),
        Achievement(
            id: "first_insight",
            title: "First Insight",
            subtitle: "You've gained your first deep insight through reflection.",
            icon: "lightbulb.fill",
            progress: 1.0,
            isLocked: false,
            category: .insight,
            dateEarned: Date().addingTimeInterval(-86400 * 7)
        ),
        Achievement(
            id: "five_insights",
            title: "Insightful Mind",
            subtitle: "You've gained 5 deep insights through reflection.",
            icon: "brain.head.profile",
            progress: 0.6,
            isLocked: true,
            category: .insight,
            dateEarned: nil
        ),
        Achievement(
            id: "first_calm",
            title: "First Calm",
            subtitle: "You've used Quick Calm for the first time.",
            icon: "heart.fill",
            progress: 1.0,
            isLocked: false,
            category: .wellness,
            dateEarned: Date().addingTimeInterval(-86400 * 3)
        ),
        Achievement(
            id: "five_calms",
            title: "Calm Master",
            subtitle: "You've used Quick Calm 5 times.",
            icon: "heart.circle.fill",
            progress: 0.4,
            isLocked: true,
            category: .wellness,
            dateEarned: nil
        ),
        Achievement(
            id: "first_wisdom",
            title: "First Wisdom",
            subtitle: "You've read your first Daily Wisdom.",
            icon: "book.fill",
            progress: 1.0,
            isLocked: false,
            category: .wisdom,
            dateEarned: Date().addingTimeInterval(-86400 * 4)
        ),
        Achievement(
            id: "five_wisdoms",
            title: "Wisdom Seeker",
            subtitle: "You've read 5 Daily Wisdoms.",
            icon: "book.circle.fill",
            progress: 0.8,
            isLocked: true,
            category: .wisdom,
            dateEarned: nil
        ),
        Achievement(
            id: "first_milestone",
            title: "First Milestone",
            subtitle: "You've reached your first milestone!",
            icon: "trophy.fill",
            progress: 1.0,
            isLocked: false,
            category: .milestone,
            dateEarned: Date().addingTimeInterval(-86400 * 6)
        )
    ]
}

enum AchievementCategory: String, CaseIterable {
    case beginner = "Beginner"
    case consistency = "Consistency"
    case insight = "Insight"
    case wellness = "Wellness"
    case wisdom = "Wisdom"
    case milestone = "Milestone"
    
    var color: Color {
        switch self {
        case .beginner: return .blue
        case .consistency: return .orange
        case .insight: return .purple
        case .wellness: return .green
        case .wisdom: return .indigo
        case .milestone: return .yellow
        }
    }
} 