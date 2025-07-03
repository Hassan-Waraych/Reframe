import Foundation
import FirebaseFirestore
import FirebaseAuth

struct MoodScoreBreakdown: Codable {
    var emotion: MoodEmotionBreakdown?
    var reflections: Int
    var reframesPositive: Int
    var reframesNegative: Int
    var coachPositive: Int
    var coachNegative: Int
    var guidedPrompts: [MoodPromptBreakdown]
    var featureUses: Int
}

struct MoodEmotionBreakdown: Codable {
    var label: String
    var value: Int
}

struct MoodPromptBreakdown: Codable {
    var id: String
    var category: String // "happy" or "sad"
}

struct MoodScore: Codable, Identifiable {
    var id: String { dateString }
    let userId: String
    let dateString: String // yyyy-MM-dd
    var score: Double
    var breakdown: MoodScoreBreakdown
}

class MoodScoreService: ObservableObject {
    static let shared = MoodScoreService()
    private let db = Firestore.firestore()
    private init() {}

    // MARK: - Public Methods
    func updateTodayMoodScore(update: (inout MoodScoreBreakdown) -> Void, recalculate: Bool = true) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let dateString = Self.todayString()
        let docRef = db.collection("mood_scores").document("\(userId)_\(dateString)")

        do {
            let doc = try await docRef.getDocument()
            var moodScore: MoodScore
            if let data = doc.data() {
                moodScore = try Firestore.Decoder().decode(MoodScore.self, from: data)
            } else {
                moodScore = MoodScore(
                    userId: userId,
                    dateString: dateString,
                    score: 0,
                    breakdown: MoodScoreBreakdown(
                        emotion: nil,
                        reflections: 0,
                        reframesPositive: 0,
                        reframesNegative: 0,
                        coachPositive: 0,
                        coachNegative: 0,
                        guidedPrompts: [],
                        featureUses: 0
                    )
                )
            }
            // Apply update
            update(&moodScore.breakdown)
            // Recalculate score if needed
            if recalculate {
                moodScore.score = Self.calculateScore(from: moodScore.breakdown)
            }
            try await docRef.setData(from: moodScore)
        } catch {
            print("Error updating mood score: \(error)")
        }
    }

    func fetchMoodScores(forLastNDays n: Int = 7) async -> [MoodScore] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dates = (0..<n).map { calendar.date(byAdding: .day, value: -$0, to: today)! }
        let dateStrings = dates.map { Self.string(from: $0) }
        do {
            let snapshot = try await db.collection("mood_scores")
                .whereField("userId", isEqualTo: userId)
                .whereField("dateString", in: dateStrings)
                .getDocuments()
            let scores = try snapshot.documents.compactMap { doc in
                try? doc.data(as: MoodScore.self)
            }
            // Return in chronological order
            return dateStrings.reversed().compactMap { ds in scores.first(where: { $0.dateString == ds }) }
        } catch {
            print("Error fetching mood scores: \(error)")
            return []
        }
    }

    // MARK: - Helpers
    static func todayString() -> String {
        string(from: Date())
    }
    static func string(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func calculateScore(from breakdown: MoodScoreBreakdown) -> Double {
        // 1. Emotion (main weight)
        var score = 0.0
        if let emotion = breakdown.emotion {
            score += Double(emotion.value)
        }
        // 2. Reflections
        score += Double(breakdown.reflections) * 0.25
        // 3. Reframes/Coach Sentiment
        score += Double(breakdown.reframesPositive) * 0.2
        score -= Double(breakdown.reframesNegative) * 0.2
        score += Double(breakdown.coachPositive) * 0.2
        score -= Double(breakdown.coachNegative) * 0.2
        // 4. Guided Prompts
        for prompt in breakdown.guidedPrompts {
            score += (prompt.category == "happy") ? 0.3 : -0.2
        }
        // 5. Feature Uses
        score += min(Double(breakdown.featureUses) * 0.05, 0.5)
        // Clamp to 1...10
        return max(1.0, min(score, 10.0))
    }
} 