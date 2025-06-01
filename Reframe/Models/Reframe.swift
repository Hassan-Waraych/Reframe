import Foundation
import FirebaseFirestore

struct Reframe: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let originalThought: String
    let reframedThought: String
    let timestamp: Date
    let category: String?
    var helped: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case originalThought
        case reframedThought
        case timestamp
        case category
        case helped
    }
}

// MARK: - Firestore Timestamp Conversion
extension Reframe {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        originalThought = try container.decode(String.self, forKey: .originalThought)
        reframedThought = try container.decode(String.self, forKey: .reframedThought)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        helped = try container.decodeIfPresent(Bool.self, forKey: .helped)
        
        // Handle Firestore Timestamp
        let timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
        self.timestamp = timestamp.dateValue()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(originalThought, forKey: .originalThought)
        try container.encode(reframedThought, forKey: .reframedThought)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(helped, forKey: .helped)
        try container.encode(Timestamp(date: timestamp), forKey: .timestamp)
    }
} 