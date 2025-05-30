import Foundation
import SwiftUI

struct JournalEntry: Identifiable {
    let id: String
    let date: Date
    let title: String
    let originalThought: String
    let reframe: String
    let mood: Mood
    
    enum Mood {
        case happy
        case neutral
        case productive
        case anxious
        
        var icon: String {
            switch self {
            case .happy: return "face.smiling.fill"
            case .neutral: return "face.neutral.fill"
            case .productive: return "bolt.fill"
            case .anxious: return "face.anxious.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .happy: return .yellow
            case .neutral: return .gray
            case .productive: return .blue
            case .anxious: return .orange
            }
        }
    }
    
    // Helper computed property for formatted date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
} 