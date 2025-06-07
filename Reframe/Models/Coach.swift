import Foundation
import FirebaseFirestore

struct Coach: Identifiable, Codable {
    let id: String
    let name: String
    let emoji: String
    let description: String
    let toneSummary: String
    let covers: [String]
    let background: String
    let specialties: [String]
    let approach: String
    let quote: String
    let introStyle: String
    let techniqueStyle: String
    let closingStyle: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, emoji, description, toneSummary, covers, background, specialties, approach, quote
        case introStyle, techniqueStyle, closingStyle
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
            covers: ["anxiety", "perfectionism", "stress"],
            background: "Theo brings a unique blend of mindfulness and practical wisdom to his coaching. With a background in meditation and cognitive behavioral therapy, he helps you find peace in chaos and clarity in confusion.",
            specialties: [
                "Mindfulness techniques",
                "Anxiety management",
                "Perfectionism reframing",
                "Stress reduction"
            ],
            approach: "Theo believes in meeting you where you are, using gentle guidance to help you find your own path to peace. He combines practical exercises with deep listening to help you build resilience and find balance.",
            quote: "Peace isn't the absence of chaos, but the ability to find calm within it.",
            introStyle: "Mindful acknowledgment of feelings, gentle invitation to explore",
            techniqueStyle: "Breathing exercises, mindfulness practices, present-moment awareness",
            closingStyle: "Encouraging finding peace in the present moment"
        ),
        Coach(
            id: "maya",
            name: "Maya",
            emoji: "🌷",
            description: "Warm and uplifting. Supports self-worth and confidence.",
            toneSummary: "Affirming, encouraging, validating tone.",
            covers: ["self-doubt", "self-worth"],
            background: "Maya specializes in helping people rediscover their inner strength and self-worth. Her approach combines positive psychology with practical exercises to build lasting confidence.",
            specialties: [
                "Self-worth building",
                "Confidence development",
                "Positive mindset",
                "Personal growth"
            ],
            approach: "Maya creates a safe, nurturing space where you can explore your feelings and build a stronger sense of self. She uses a combination of validation and gentle challenges to help you grow.",
            quote: "Your worth isn't determined by your achievements, but by your inherent value as a human being.",
            introStyle: "Warm validation of feelings, emphasis on self-worth",
            techniqueStyle: "Self-compassion exercises, perspective-shifting questions",
            closingStyle: "Affirming inherent worth and potential"
        ),
        Coach(
            id: "jordan",
            name: "Jordan",
            emoji: "🧭",
            description: "Empathetic and wise. Guides through relationships and change.",
            toneSummary: "Balanced, thoughtful, supportive.",
            covers: ["relationships", "change"],
            background: "Jordan brings years of experience in relationship counseling and life transitions. Their approach helps you navigate complex emotions and situations with clarity and confidence.",
            specialties: [
                "Relationship dynamics",
                "Life transitions",
                "Emotional intelligence",
                "Boundary setting"
            ],
            approach: "Jordan believes in empowering you to make your own decisions while providing the tools and perspective needed to navigate life's challenges. They combine empathy with practical guidance.",
            quote: "Change isn't something to fear, but an opportunity to grow and discover new strengths.",
            introStyle: "Empathetic acknowledgment, focus on growth potential",
            techniqueStyle: "Boundary-setting exercises, relationship navigation tools",
            closingStyle: "Encouraging growth through change"
        ),
        Coach(
            id: "alex",
            name: "Alex",
            emoji: "🧠",
            description: "Logical and clear-headed. Breaks down overthinking and stress.",
            toneSummary: "Rational, structured, calming.",
            covers: ["overthinking", "stress"],
            background: "Alex combines cognitive behavioral techniques with practical problem-solving strategies. Their analytical approach helps you break through mental blocks and find clarity.",
            specialties: [
                "Overthinking management",
                "Stress reduction",
                "Problem-solving",
                "Mental clarity"
            ],
            approach: "Alex helps you step back from overwhelming thoughts and see situations with fresh perspective. They use structured techniques to help you find practical solutions to complex problems.",
            quote: "Clarity comes not from having all the answers, but from asking the right questions.",
            introStyle: "Clear acknowledgment, focus on finding solutions",
            techniqueStyle: "Cognitive reframing, structured problem-solving",
            closingStyle: "Encouraging continued growth and learning"
        )
    ]
} 