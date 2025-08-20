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

struct MoodEntry: Identifiable, Codable {
    var id: String?
    let userId: String
    let date: Date
    let mood: MoodType
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case date
        case mood
        case timestamp
    }
    
    init(userId: String, date: Date, mood: MoodType, timestamp: Date = Date()) {
        self.id = nil
        self.userId = userId
        self.date = date
        self.mood = mood
        self.timestamp = timestamp
    }
}
