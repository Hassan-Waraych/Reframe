import Foundation
import FirebaseFirestore
import FirebaseAuth

class StreakService {
    static let shared = StreakService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func updateStreak() async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let streakRef = db.collection("streaks").document(userId)
        
        do {
            let document = try await streakRef.getDocument()
            let today = Calendar.current.startOfDay(for: Date())
            
            if document.exists {
                let streak = try document.data(as: StreakTracker.self)
                let lastUpdated = Calendar.current.startOfDay(for: streak.lastUpdated)
                
                if today == lastUpdated {
                    // Already updated today, do nothing
                    return
                } else if let daysBetween = Calendar.current.dateComponents([.day], from: lastUpdated, to: today).day,
                          daysBetween == 1 {
                    // Consecutive day, increment streak
                    try await streakRef.updateData([
                        "count": streak.count + 1,
                        "lastUpdated": Timestamp(date: Date())
                    ])
                    
                    // Check streak milestones
                    await MilestoneService.shared.checkStreakMilestones()
                } else {
                    // Streak broken, reset to 1
                    try await streakRef.updateData([
                        "count": 1,
                        "lastUpdated": Timestamp(date: Date())
                    ])
                }
            } else {
                // First streak
                let newStreak = StreakTracker(
                    userId: userId,
                    count: 1,
                    lastUpdated: Date()
                )
                try await streakRef.setData(from: newStreak)
                
                // Check streak milestones
                await MilestoneService.shared.checkStreakMilestones()
            }
        } catch {
            throw error
        }
    }
    
    func getCurrentStreak() async throws -> Int {
        guard let userId = Auth.auth().currentUser?.uid else { return 0 }
        
        let document = try await db.collection("streaks").document(userId).getDocument()
        
        if document.exists {
            let streak = try document.data(as: StreakTracker.self)
            let lastUpdated = Calendar.current.startOfDay(for: streak.lastUpdated)
            let today = Calendar.current.startOfDay(for: Date())
            
            // If last update was today or yesterday, return current streak
            if let daysBetween = Calendar.current.dateComponents([.day], from: lastUpdated, to: today).day,
               daysBetween <= 1 {
                return streak.count
            }
        }
        
        return 0
    }
} 