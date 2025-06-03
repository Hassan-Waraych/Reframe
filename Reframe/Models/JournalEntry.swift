import Foundation
import FirebaseFirestore

struct JournalEntry: Identifiable, Codable {
    var id: String?
    let userId: String
    let content: String
    let timestamp: Date
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case content
        case timestamp
        case category
    }
} 