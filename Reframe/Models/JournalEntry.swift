import Foundation
import FirebaseFirestore

struct JournalEntry: Identifiable, Codable {
    var id: String?
    let userId: String
    let content: String
    let originalThought: String?
    let timestamp: Date
    let category: String
    let reframeId: String?
    let isFavorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case content
        case originalThought
        case timestamp
        case category
        case reframeId
        case isFavorite
    }
    
    init(userId: String, content: String, originalThought: String? = nil, timestamp: Date, category: String, reframeId: String? = nil, isFavorite: Bool = false) {
        self.id = nil
        self.userId = userId
        self.content = content
        self.originalThought = originalThought
        self.timestamp = timestamp
        self.category = category
        self.reframeId = reframeId
        self.isFavorite = isFavorite
    }
} 