import Foundation

struct Quote: Codable, Identifiable {
    let id: String
    let text: String
    let author: String
    let category: String
    let mood: String?
}

struct QuoteData: Codable {
    let quotes: [Quote]
} 