import Foundation
import FirebaseFirestore
import FirebaseAuth

class CoachService {
    static let shared = CoachService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Coach Assignment
    func getCurrentCoach(for userId: String) async throws -> Coach? {
        // Get user's assigned coach from Firestore
        let userDoc = try await db.collection("users").document(userId).getDocument()
        
        // Check for existing coach assignment
        if let coachId = userDoc.data()?["coachId"] as? String,
           let coach = Coach.coaches.first(where: { $0.id == coachId }) {
            return coach
        }
        
        return nil
    }
    
    func assignCoach(for userId: String) async throws -> Coach {
        // Get user's assigned coach from Firestore
        let userDoc = try await db.collection("users").document(userId).getDocument()
        
        // Check for existing coach assignment
        if let coachId = userDoc.data()?["coachId"] as? String,
           let coach = Coach.coaches.first(where: { $0.id == coachId }) {
            return coach
        }
        
        // Filter out premium coaches
        let availableCoaches = Coach.coaches.filter { !$0.isPremium }
        
        // If no coach is assigned, find the best match based on emotional needs
        if let emotionalNeeds = userDoc.data()?["emotionalNeeds"] as? [String] {
            // Find the coach with the most matching emotional needs
            var bestCoach: Coach? = nil
            var maxMatches = 0
            
            for coach in availableCoaches {
                let matches = Set(coach.covers).intersection(Set(emotionalNeeds)).count
                if matches > maxMatches {
                    maxMatches = matches
                    bestCoach = coach
                }
            }
            
            if let matchedCoach = bestCoach {
                // Save the assignment
                try await db.collection("users").document(userId).setData([
                    "coachId": matchedCoach.id,
                    "coachAssignedAt": FieldValue.serverTimestamp()
                ], merge: true)
                
                return matchedCoach
            }
        }
        
        // If no emotional needs or no good match, assign randomly from available coaches
        let randomCoach = availableCoaches.randomElement() ?? availableCoaches[0]
        
        // Save the assignment
        try await db.collection("users").document(userId).setData([
            "coachId": randomCoach.id,
            "coachAssignedAt": FieldValue.serverTimestamp()
        ], merge: true)
        
        return randomCoach
    }
    
    // MARK: - Message Management
    func getMessages() async throws -> [CoachMessage] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "CoachService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let snapshot = try await db.collection("coachMessages")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: false)
            .getDocuments()
        
        var messages: [CoachMessage] = []
        for document in snapshot.documents {
            do {
                var message = try document.data(as: CoachMessage.self)
                // Create a new message with the document ID
                message = CoachMessage(
                    id: document.documentID,
                    userId: message.userId,
                    coachId: message.coachId,
                    content: message.content,
                    timestamp: message.timestamp,
                    isFromUser: message.isFromUser
                )
                messages.append(message)
            } catch {
                print("Error decoding message: \(error)")
            }
        }
        
        return messages
    }
    
    func sendMessage(_ content: String, coachId: String) async throws -> CoachMessage {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "CoachService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Create user message
        let userMessageRef = try await db.collection("coachMessages").addDocument(data: [
            "userId": userId,
            "coachId": coachId,
            "content": content,
            "timestamp": Timestamp(date: Date()),
            "isFromUser": true
        ])
        
        // Get the coach's response
        let response = try await generateCoachResponse(content: content, coachId: coachId)
        
        // Save coach response
        _ = try await db.collection("coachMessages").addDocument(data: [
            "userId": userId,
            "coachId": coachId,
            "content": response,
            "timestamp": Timestamp(date: Date()),
            "isFromUser": false
        ])
        
        // Create history item
        _ = try await db.collection("coachHistory").addDocument(data: [
            "userId": userId,
            "coachId": coachId,
            "userMessage": content,
            "coachResponse": response,
            "timestamp": Timestamp(date: Date()),
            "wasHelpful": false,
            "isSavedToJournal": false
        ])
        
        // Create and return the user message with its document ID
        return CoachMessage(
            id: userMessageRef.documentID,
            userId: userId,
            coachId: coachId,
            content: content,
            timestamp: Date(),
            isFromUser: true
        )
    }
    
    // MARK: - History Management
    func getHistory() async throws -> [CoachHistoryItem] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "CoachService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let snapshot = try await db.collection("coachHistory")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 10)
            .getDocuments()
        
        var items: [CoachHistoryItem] = []
        for document in snapshot.documents {
            do {
                let data = document.data()
                let item = CoachHistoryItem(
                    id: document.documentID,
                    userId: data["userId"] as? String ?? "",
                    coachId: data["coachId"] as? String ?? "",
                    userMessage: data["userMessage"] as? String ?? "",
                    coachResponse: data["coachResponse"] as? String ?? "",
                    timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                    wasHelpful: data["wasHelpful"] as? Bool ?? false,
                    isSavedToJournal: data["isSavedToJournal"] as? Bool ?? false
                )
                items.append(item)
            } catch {
                print("Error decoding history item: \(error)")
            }
        }
        
        return items
    }
    
    func markHistoryItemAsHelpful(_ itemId: String) async throws {
        try await db.collection("coachHistory").document(itemId).updateData([
            "wasHelpful": true
        ])
    }
    
    func saveHistoryItemToJournal(_ itemId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "CoachService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Get the history item
        let item = try await db.collection("coachHistory").document(itemId).getDocument()
        guard let data = item.data() else {
            throw NSError(domain: "CoachService", code: -1, userInfo: [NSLocalizedDescriptionKey: "History item not found"])
        }
        
        // Create a journal entry
        try await db.collection("journal").addDocument(data: [
            "userId": userId,
            "content": data["userMessage"] as? String ?? "",
            "coachResponse": data["coachResponse"] as? String ?? "",
            "timestamp": data["timestamp"] as? Timestamp ?? Timestamp(date: Date()),
            "type": "coach"
        ])
        
        // Mark the history item as saved
        try await db.collection("coachHistory").document(itemId).updateData([
            "isSavedToJournal": true
        ])
    }
    
    // MARK: - Helper Methods
    private func generateCoachResponse(content: String, coachId: String) async throws -> String {
        guard let coach = Coach.coaches.first(where: { $0.id == coachId }) else {
            throw NSError(domain: "CoachService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Coach not found"])
        }
        
        return try await AIService.shared.generateCoachResponse(content: content, coach: coach)
    }
} 