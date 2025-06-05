import Foundation
import FirebaseFirestore

struct CoachMessage: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    let coachId: String
    let content: String
    let timestamp: Date
    let isFromUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId
        case coachId
        case content
        case timestamp
        case isFromUser
    }
    
    static func == (lhs: CoachMessage, rhs: CoachMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.userId == rhs.userId &&
        lhs.coachId == rhs.coachId &&
        lhs.content == rhs.content &&
        lhs.timestamp == rhs.timestamp &&
        lhs.isFromUser == rhs.isFromUser
    }
}

// MARK: - Firestore Timestamp Conversion
extension CoachMessage {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // The ID will be set after decoding
        id = ""
        userId = try container.decode(String.self, forKey: .userId)
        coachId = try container.decode(String.self, forKey: .coachId)
        content = try container.decode(String.self, forKey: .content)
        isFromUser = try container.decode(Bool.self, forKey: .isFromUser)
        
        // Handle Firestore Timestamp
        let timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
        self.timestamp = timestamp.dateValue()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(coachId, forKey: .coachId)
        try container.encode(content, forKey: .content)
        try container.encode(isFromUser, forKey: .isFromUser)
        try container.encode(Timestamp(date: timestamp), forKey: .timestamp)
    }
}

// MARK: - Document ID Coding Key
extension CodingUserInfoKey {
    static let documentID = CodingUserInfoKey(rawValue: "documentID")!
} 