import Foundation
import FirebaseFirestore

struct Coach: Identifiable, Codable {
    let id: String
    let name: String
    let emoji: String
    let description: String
    let toneSummary: String
    let covers: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, name, emoji, description, toneSummary, covers
    }
}

// MARK: - Coach Constants
extension Coach {
    static let coaches: [Coach] = [
        Coach(
            id: "theo",
            name: "Theo",
            emoji: "🍃",
            description: "Grounded and calm. Helps manage anxiety and perfectionism.",
            toneSummary: "Soothing, mindful, realistic reassurance.",
            covers: ["anxiety", "perfectionism", "stress"]
        ),
        Coach(
            id: "maya",
            name: "Maya",
            emoji: "🌷",
            description: "Warm and uplifting. Supports self-worth and confidence.",
            toneSummary: "Affirming, encouraging, validating tone.",
            covers: ["self-doubt", "self-worth"]
        ),
        Coach(
            id: "jordan",
            name: "Jordan",
            emoji: "🧭",
            description: "Empathetic and wise. Guides through relationships and change.",
            toneSummary: "Balanced, thoughtful, supportive.",
            covers: ["relationships", "change"]
        ),
        Coach(
            id: "alex",
            name: "Alex",
            emoji: "🧠",
            description: "Logical and clear-headed. Breaks down overthinking and stress.",
            toneSummary: "Rational, structured, calming.",
            covers: ["overthinking", "stress"]
        )
    ]
} 