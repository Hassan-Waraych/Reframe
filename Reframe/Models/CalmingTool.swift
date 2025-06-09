import Foundation
import SwiftUI

struct CalmingTool: Identifiable {
    let id: String
    let title: String
    let description: String
    let category: ToolCategory
    let icon: String
    let type: ToolType
    
    static let tools: [CalmingTool] = [
        // Breathing Tools
        CalmingTool(
            id: "breath_1",
            title: "Box Breathing",
            description: "4-4-4-4 breathing pattern: inhale, hold, exhale, hold",
            category: .breathing,
            icon: "lungs.fill",
            type: .breathing(inhale: 4, hold: 4, exhale: 4, holdAfter: 4)
        ),
        CalmingTool(
            id: "breath_2",
            title: "Calming Breath",
            description: "4-7-8 breathing: inhale, hold, exhale",
            category: .breathing,
            icon: "wind",
            type: .breathing(inhale: 4, hold: 7, exhale: 8, holdAfter: 0)
        ),
        CalmingTool(
            id: "breath_3",
            title: "Deep Breathing",
            description: "5-2-7 breathing: inhale, hold, exhale",
            category: .breathing,
            icon: "leaf.fill",
            type: .breathing(inhale: 5, hold: 2, exhale: 7, holdAfter: 0)
        ),
        
        // Grounding Tools
        CalmingTool(
            id: "ground_1",
            title: "5-4-3-2-1",
            description: "Ground yourself by engaging your senses",
            category: .grounding,
            icon: "hand.raised.fill",
            type: .grounding
        ),
        CalmingTool(
            id: "ground_2",
            title: "Body Scan",
            description: "Progressive relaxation through body awareness",
            category: .grounding,
            icon: "figure.stand",
            type: .bodyScan
        ),
        
        // Mindfulness Tools
        CalmingTool(
            id: "mind_1",
            title: "Quick Meditation",
            description: "2-minute guided meditation",
            category: .mindfulness,
            icon: "brain.head.profile",
            type: .meditation
        ),
        CalmingTool(
            id: "mind_2",
            title: "Gratitude Moment",
            description: "Focus on three things you're grateful for",
            category: .mindfulness,
            icon: "heart.fill",
            type: .gratitude
        ),
        
        // Movement Tools
        CalmingTool(
            id: "move_1",
            title: "Quick Stretch",
            description: "Simple stretches to release tension",
            category: .movement,
            icon: "figure.walk",
            type: .stretch
        ),
        CalmingTool(
            id: "move_2",
            title: "Desk Yoga",
            description: "Gentle yoga poses you can do at your desk",
            category: .movement,
            icon: "figure.mind.and.body",
            type: .yoga
        )
    ]
}

enum ToolCategory: String, CaseIterable {
    case breathing = "Breathe"
    case grounding = "Ground"
    case mindfulness = "Mind"
    case movement = "Move"
    
    var color: Color {
        switch self {
        case .breathing: return .blue
        case .grounding: return .green
        case .mindfulness: return .purple
        case .movement: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .breathing: return "lungs.fill"
        case .grounding: return "hand.raised.fill"
        case .mindfulness: return "brain.head.profile"
        case .movement: return "figure.walk"
        }
    }
}

enum ToolType {
    case breathing(inhale: Int, hold: Int, exhale: Int, holdAfter: Int)
    case grounding
    case bodyScan
    case meditation
    case gratitude
    case stretch
    case yoga
} 