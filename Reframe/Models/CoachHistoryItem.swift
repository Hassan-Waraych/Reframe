import Foundation
import FirebaseFirestore

struct CoachHistoryItem: Identifiable, Codable {
    let id: String
    let userId: String
    let coachId: String
    let userMessage: String
    let coachResponse: String
    let timestamp: Date
    var wasHelpful: Bool
    var isSavedToJournal: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case coachId
        case userMessage
        case coachResponse
        case timestamp
        case wasHelpful
        case isSavedToJournal
    }
}

// MARK: - Firestore Timestamp Conversion
extension CoachHistoryItem {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        coachId = try container.decode(String.self, forKey: .coachId)
        userMessage = try container.decode(String.self, forKey: .userMessage)
        coachResponse = try container.decode(String.self, forKey: .coachResponse)
        wasHelpful = try container.decode(Bool.self, forKey: .wasHelpful)
        isSavedToJournal = try container.decode(Bool.self, forKey: .isSavedToJournal)
        
        // Handle Firestore Timestamp
        let timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
        self.timestamp = timestamp.dateValue()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(coachId, forKey: .coachId)
        try container.encode(userMessage, forKey: .userMessage)
        try container.encode(coachResponse, forKey: .coachResponse)
        try container.encode(wasHelpful, forKey: .wasHelpful)
        try container.encode(isSavedToJournal, forKey: .isSavedToJournal)
        try container.encode(Timestamp(date: timestamp), forKey: .timestamp)
    }
} 