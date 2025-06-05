import SwiftUI

struct CoachHistoryCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let historyItem: CoachHistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(historyItem.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: themeManager.typography.fontSize.small))
                    .foregroundColor(themeManager.colors.textLight)
                
                Spacer()
                
                if historyItem.wasHelpful {
                    Image(systemName: "heart.fill")
                        .foregroundColor(themeManager.colors.primary)
                }
                
                if historyItem.isSavedToJournal {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(themeManager.colors.secondary)
                }
            }
            
            // User Message
            Text(historyItem.userMessage)
                .font(.system(size: themeManager.typography.fontSize.body))
                .foregroundColor(themeManager.colors.text)
                .lineLimit(2)
            
            // Coach Response
            Text(historyItem.coachResponse)
                .font(.system(size: themeManager.typography.fontSize.body))
                .foregroundColor(themeManager.colors.textLight)
                .lineLimit(2)
        }
        .padding(16)
        .background(themeManager.colors.surface)
        .cornerRadius(12)
    }
}

#Preview {
    CoachHistoryCard(historyItem: CoachHistoryItem(
        id: "1",
        userId: "user1",
        coachId: "coach1",
        userMessage: "I've been feeling lost lately.",
        coachResponse: "Let's unpack that feeling together. What do you think might be causing this sense of being lost?",
        timestamp: Date(),
        wasHelpful: true,
        isSavedToJournal: false
    ))
    .environmentObject(ThemeManager())
} 