import Foundation
import FirebaseFirestore

struct NonsenseTracker: Codable {
    @DocumentID var id: String?
    let userId: String
    let count: Int
    let lastNonsenseDate: Date
    let cooldownEndDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case count
        case lastNonsenseDate
        case cooldownEndDate
    }
}

// MARK: - Firestore Timestamp Conversion
extension NonsenseTracker {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        count = try container.decode(Int.self, forKey: .count)
        
        let lastNonsenseTimestamp = try container.decode(Timestamp.self, forKey: .lastNonsenseDate)
        lastNonsenseDate = lastNonsenseTimestamp.dateValue()
        
        if let cooldownTimestamp = try container.decodeIfPresent(Timestamp.self, forKey: .cooldownEndDate) {
            cooldownEndDate = cooldownTimestamp.dateValue()
        } else {
            cooldownEndDate = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(count, forKey: .count)
        try container.encode(Timestamp(date: lastNonsenseDate), forKey: .lastNonsenseDate)
        if let cooldownEndDate = cooldownEndDate {
            try container.encode(Timestamp(date: cooldownEndDate), forKey: .cooldownEndDate)
        }
    }
} 