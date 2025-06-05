import SwiftUI

struct MessageBubble: View {
    @EnvironmentObject var themeManager: ThemeManager
    let message: CoachMessage
    let coach: Coach
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                if !message.isFromUser {
                    HStack(spacing: 4) {
                        Text(coach.emoji)
                            .font(.system(size: 16))
                        Text(coach.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                }
                
                Text(message.content)
                    .font(.system(size: 16))
                    .foregroundColor(message.isFromUser ? .white : themeManager.colors.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(message.isFromUser ? 
                                themeManager.colors.primary : 
                                themeManager.colors.surface)
                    )
                
                Text(formatTimestamp(message.timestamp))
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.colors.textLight)
            }
            
            if !message.isFromUser {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 