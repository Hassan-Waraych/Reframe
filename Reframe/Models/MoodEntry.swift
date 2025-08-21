import Foundation
import FirebaseFirestore

enum MoodType: String, CaseIterable, Codable {
    case great = "great"
    case good = "good"
    case okay = "okay"
    case bad = "bad"
    case terrible = "terrible"
    case none = "none"
    
    var emoji: String {
        switch self {
        case .great: return "😊"
        case .good: return "🙂"
        case .okay: return "😐"
        case .bad: return "😔"
        case .terrible: return "😢"
        case .none: return "○"
        }
    }
    
    var displayName: String {
        switch self {
        case .great: return "Great"
        case .good: return "Good"
        case .okay: return "Okay"
        case .bad: return "Bad"
        case .terrible: return "Terrible"
        case .none: return "Not Set"
        }
    }
    
    var color: String {
        switch self {
        case .great: return "4CAF50" // Green
        case .good: return "8BC34A" // Light Green
        case .okay: return "FFC107" // Amber
        case .bad: return "FF9800" // Orange
        case .terrible: return "F44336" // Red
        case .none: return "E0E0E0" // Light Gray
        }
    }
}

// Predefined emotions for the emotion layer
struct EmotionTag: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let category: EmotionCategory
    var isSelected: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case name, category, isSelected
    }
    
    enum EmotionCategory: String, CaseIterable, Codable {
        case positive = "positive"
        case negative = "negative"
        case neutral = "neutral"
    }
}

// Context categories for triggers
struct ContextTag: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    var isSelected: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case name, isSelected
    }
}

// Body and mind check data
struct BodyMindCheck: Codable {
    var energyLevel: EnergyLevel = .medium
    var sleepQuality: SleepQuality = .okay
    var stressLevel: Double = 0.5 // 0.0 = Calm, 1.0 = Overwhelmed
    
    enum EnergyLevel: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        
        var displayName: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
    }
    
    enum SleepQuality: String, CaseIterable, Codable {
        case poor = "poor"
        case okay = "okay"
        case restful = "restful"
        
        var displayName: String {
            switch self {
            case .poor: return "Poor"
            case .okay: return "Okay"
            case .restful: return "Restful"
            }
        }
    }
}

struct MoodEntry: Identifiable, Codable {
    var id: String?
    let userId: String
    let date: Date
    let mood: MoodType
    let timestamp: Date
    
    // New comprehensive fields
    let selectedEmotions: [EmotionTag]
    let customEmotions: [String]
    let contextTags: [ContextTag]
    let contextNotes: String?
    let bodyMindCheck: BodyMindCheck
    let isPositiveFocus: Bool // true = "What's boosting your mood?", false = "What's draining it?"
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case date
        case mood
        case timestamp
        case selectedEmotions
        case customEmotions
        case contextTags
        case contextNotes
        case bodyMindCheck
        case isPositiveFocus
    }
    
    init(userId: String, date: Date, mood: MoodType, selectedEmotions: [EmotionTag] = [], customEmotions: [String] = [], contextTags: [ContextTag] = [], contextNotes: String? = nil, bodyMindCheck: BodyMindCheck = BodyMindCheck(), isPositiveFocus: Bool = true, timestamp: Date = Date()) {
        self.id = nil
        self.userId = userId
        self.date = date
        self.mood = mood
        self.selectedEmotions = selectedEmotions
        self.customEmotions = customEmotions
        self.contextTags = contextTags
        self.contextNotes = contextNotes
        self.bodyMindCheck = bodyMindCheck
        self.isPositiveFocus = isPositiveFocus
        self.timestamp = timestamp
    }
}

// Predefined data for the check-in flow
struct MoodCheckInData {
    static let predefinedEmotions: [EmotionTag] = [
        // Positive emotions
        EmotionTag(name: "Calm", category: .positive),
        EmotionTag(name: "Grateful", category: .positive),
        EmotionTag(name: "Hopeful", category: .positive),
        EmotionTag(name: "Motivated", category: .positive),
        EmotionTag(name: "Excited", category: .positive),
        EmotionTag(name: "Proud", category: .positive),
        EmotionTag(name: "Loved", category: .positive),
        EmotionTag(name: "Inspired", category: .positive),
        
        // Negative emotions
        EmotionTag(name: "Stressed", category: .negative),
        EmotionTag(name: "Lonely", category: .negative),
        EmotionTag(name: "Angry", category: .negative),
        EmotionTag(name: "Anxious", category: .negative),
        EmotionTag(name: "Sad", category: .negative),
        EmotionTag(name: "Frustrated", category: .negative),
        EmotionTag(name: "Overwhelmed", category: .negative),
        EmotionTag(name: "Tired", category: .negative),
        
        // Neutral emotions
        EmotionTag(name: "Focused", category: .neutral),
        EmotionTag(name: "Curious", category: .neutral),
        EmotionTag(name: "Reflective", category: .neutral),
        EmotionTag(name: "Balanced", category: .neutral),
        EmotionTag(name: "Content", category: .neutral)
    ]
    
    static let contextCategories: [ContextTag] = [
        ContextTag(name: "Work"),
        ContextTag(name: "School"),
        ContextTag(name: "Relationships"),
        ContextTag(name: "Health"),
        ContextTag(name: "Money"),
        ContextTag(name: "Family"),
        ContextTag(name: "Social Life"),
        ContextTag(name: "Personal Goals"),
        ContextTag(name: "Weather"),
        ContextTag(name: "News/Media")
    ]
}
