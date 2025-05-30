import Foundation
import SwiftUI

struct JournalEntry: Identifiable, Equatable {
    let id: String
    let date: Date
    let title: String
    let originalThought: String
    let reframe: String
    let mood: Mood
    
    // New UI enhancement properties
    var interactionState: InteractionState = .default
    
    enum InteractionState: Equatable {
        case `default`
        case expanded
        case minimized
        case swiping(offset: CGFloat)
    }
    
    enum Mood: Equatable {
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
        
        // New animation properties
        var iconAnimation: Animation {
            switch self {
            case .happy: return .spring(response: 0.3, dampingFraction: 0.6)
            case .neutral: return .easeInOut(duration: 0.2)
            case .productive: return .spring(response: 0.4, dampingFraction: 0.7)
            case .anxious: return .easeInOut(duration: 0.3)
            }
        }
        
        var iconScale: CGFloat {
            switch self {
            case .happy: return 1.1
            case .neutral: return 1.0
            case .productive: return 1.15
            case .anxious: return 0.95
            }
        }
    }
    
    // Enhanced date formatting with animation support
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Animation timing based on entry age
    var animationDelay: Double {
        return Date().timeIntervalSince(date) * 0.1
    }
    
    // Implement Equatable
    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        lhs.id == rhs.id &&
        lhs.date == rhs.date &&
        lhs.title == rhs.title &&
        lhs.originalThought == rhs.originalThought &&
        lhs.reframe == rhs.reframe &&
        lhs.mood == rhs.mood &&
        lhs.interactionState == rhs.interactionState
    }
} 