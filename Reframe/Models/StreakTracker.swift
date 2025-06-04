import Foundation
import FirebaseFirestore

struct StreakTracker: Codable {
    @DocumentID var id: String?
    let userId: String
    let count: Int
    let lastUpdated: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case count
        case lastUpdated
    }
}

// MARK: - Firestore Timestamp Conversion
extension StreakTracker {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        count = try container.decode(Int.self, forKey: .count)
        
        let lastUpdatedTimestamp = try container.decode(Timestamp.self, forKey: .lastUpdated)
        lastUpdated = lastUpdatedTimestamp.dateValue()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(count, forKey: .count)
        try container.encode(Timestamp(date: lastUpdated), forKey: .lastUpdated)
    }
} 