import Foundation
import SwiftUI

struct JournalPrompt: Identifiable {
    let id: String
    let title: String
    let text: String
    let category: PromptCategory
    let icon: String
    
    static let prompts: [JournalPrompt] = [
        // Self-Reflection
        JournalPrompt(id: "reflection_1", title: "Handling Challenges", text: "What's one thing you handled well today?", category: .selfReflection, icon: "person.fill.checkmark"),
        JournalPrompt(id: "reflection_2", title: "Growth Through Challenge", text: "What's a challenge you faced today and how did you grow from it?", category: .selfReflection, icon: "person.fill.questionmark"),
        JournalPrompt(id: "reflection_3", title: "Proud Achievement", text: "What's something you're proud of accomplishing today?", category: .selfReflection, icon: "star.fill"),
        JournalPrompt(id: "reflection_4", title: "Areas for Improvement", text: "What's one thing you'd like to improve about today?", category: .selfReflection, icon: "arrow.up.circle.fill"),
        JournalPrompt(id: "reflection_5", title: "Grateful Moment", text: "What's a moment today that made you feel grateful?", category: .selfReflection, icon: "heart.circle.fill"),
        
        // Growth
        JournalPrompt(id: "growth_1", title: "New Perspective", text: "What's a new perspective you gained today?", category: .growth, icon: "lightbulb.fill"),
        JournalPrompt(id: "growth_2", title: "Self Discovery", text: "What's something you learned about yourself today?", category: .growth, icon: "brain.head.profile"),
        JournalPrompt(id: "growth_3", title: "Skill Development", text: "What's a skill you're developing that you're excited about?", category: .growth, icon: "figure.walk"),
        JournalPrompt(id: "growth_4", title: "Goal Progress", text: "What's a goal you're working towards and how did you progress today?", category: .growth, icon: "target"),
        JournalPrompt(id: "growth_5", title: "Habit Building", text: "What's a habit you're trying to build and how did it go today?", category: .growth, icon: "repeat"),
        
        // Relationships
        JournalPrompt(id: "relationships_1", title: "Meaningful Interaction", text: "What's a meaningful interaction you had today?", category: .relationships, icon: "bubble.left.and.bubble.right.fill"),
        JournalPrompt(id: "relationships_2", title: "Act of Kindness", text: "How did you show kindness to someone today?", category: .relationships, icon: "heart.fill"),
        JournalPrompt(id: "relationships_3", title: "Memorable Conversation", text: "What's a conversation that stuck with you today?", category: .relationships, icon: "message.fill"),
        JournalPrompt(id: "relationships_4", title: "Deep Connection", text: "How did you connect with someone important to you today?", category: .relationships, icon: "person.2.fill"),
        JournalPrompt(id: "relationships_5", title: "Supporting Others", text: "What's a way you supported someone today?", category: .relationships, icon: "hand.raised.fill"),
        
        // Well-being
        JournalPrompt(id: "wellbeing_1", title: "Joyful Moment", text: "What's something that brought you joy today?", category: .wellbeing, icon: "sun.max.fill"),
        JournalPrompt(id: "wellbeing_2", title: "Self Care", text: "How did you take care of yourself today?", category: .wellbeing, icon: "leaf.fill"),
        JournalPrompt(id: "wellbeing_3", title: "Peaceful Moment", text: "What's a moment of peace you experienced today?", category: .wellbeing, icon: "sparkles"),
        JournalPrompt(id: "wellbeing_4", title: "Energy Boost", text: "What's something that made you feel energized today?", category: .wellbeing, icon: "bolt.fill"),
        JournalPrompt(id: "wellbeing_5", title: "Self Compassion", text: "How did you practice self-compassion today?", category: .wellbeing, icon: "heart.circle.fill"),
        
        // Future
        JournalPrompt(id: "future_1", title: "Looking Forward", text: "What's something you're looking forward to tomorrow?", category: .future, icon: "calendar"),
        JournalPrompt(id: "future_2", title: "Next Steps", text: "What's a small step you can take tomorrow to move closer to your goals?", category: .future, icon: "arrow.up.forward"),
        JournalPrompt(id: "future_3", title: "Positive Change", text: "What's a positive change you want to make tomorrow?", category: .future, icon: "wand.and.stars"),
        JournalPrompt(id: "future_4", title: "Future Challenge", text: "What's a challenge you're ready to tackle tomorrow?", category: .future, icon: "figure.hiking"),
        JournalPrompt(id: "future_5", title: "Better Tomorrow", text: "What's a way you can make tomorrow even better than today?", category: .future, icon: "sunrise.fill"),
        
        // Gratitude
        JournalPrompt(id: "gratitude_1", title: "Simple Gratitude", text: "What's something simple you're grateful for today?", category: .gratitude, icon: "gift.fill"),
        JournalPrompt(id: "gratitude_2", title: "Positive Impact", text: "Who made a positive impact on your day and why?", category: .gratitude, icon: "person.fill.checkmark"),
        JournalPrompt(id: "gratitude_3", title: "Small Win", text: "What's a small win you're grateful for today?", category: .gratitude, icon: "trophy.fill"),
        JournalPrompt(id: "gratitude_4", title: "Beautiful Moment", text: "What's something beautiful you noticed today?", category: .gratitude, icon: "sparkles"),
        JournalPrompt(id: "gratitude_5", title: "Thankful Moment", text: "What's a moment today that you're thankful for?", category: .gratitude, icon: "heart.fill")
    ]
    
    static func getPromptForDate(_ date: Date = Date()) -> JournalPrompt {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        return prompts[(day - 1) % prompts.count]
    }
}

enum PromptCategory: String, CaseIterable {
    case selfReflection = "Self-Reflection"
    case growth = "Growth"
    case relationships = "Relationships"
    case wellbeing = "Well-being"
    case future = "Future"
    case gratitude = "Gratitude"
    
    var color: Color {
        switch self {
        case .selfReflection: return .blue
        case .growth: return .green
        case .relationships: return .purple
        case .wellbeing: return .orange
        case .future: return .indigo
        case .gratitude: return .pink
        }
    }
    
    var icon: String {
        switch self {
        case .selfReflection: return "person.fill.questionmark"
        case .growth: return "leaf.fill"
        case .relationships: return "heart.fill"
        case .wellbeing: return "sparkles"
        case .future: return "arrow.up.forward"
        case .gratitude: return "hand.thumbsup.fill"
        }
    }
} 