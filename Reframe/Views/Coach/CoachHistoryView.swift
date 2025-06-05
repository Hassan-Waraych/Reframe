import SwiftUI

struct CoachHistoryView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CoachHomeViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.historyItems) { item in
                        NavigationLink(destination: CoachConversationDetailView(item: item)) {
                            ConversationCard(item: item)
                        }
                    }
                }
                .padding(16)
            }
            .background(themeManager.colors.background)
            .navigationTitle("Past Conversations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Past Conversations")
                        .font(.custom("Quicksand-Bold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CoachConversationDetailView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let item: CoachHistoryItem
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // User Message Card
                MessageCard(
                    content: item.userMessage,
                    isFromUser: true,
                    timestamp: item.timestamp
                )
                
                // Coach Response Card
                MessageCard(
                    content: item.coachResponse,
                    isFromUser: false,
                    timestamp: item.timestamp,
                    coach: Coach.coaches.first(where: { $0.id == item.coachId })
                )
            }
            .padding(16)
        }
        .background(themeManager.colors.background)
        .navigationTitle("Conversation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Conversation")
                    .font(.custom("Quicksand-Bold", size: 20))
                    .foregroundColor(themeManager.colors.text)
            }
        }
    }
}

struct MessageCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    var coach: Coach?
    
    var body: some View {
        VStack(alignment: isFromUser ? .trailing : .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                if !isFromUser, let coach = coach {
                    Text(coach.emoji)
                        .font(.system(size: 24))
                    Text(coach.name)
                        .font(.system(size: themeManager.typography.fontSize.body, weight: .semibold))
                        .foregroundColor(themeManager.colors.text)
                } else {
                    Text("You")
                        .font(.system(size: themeManager.typography.fontSize.body, weight: .semibold))
                        .foregroundColor(themeManager.colors.text)
                }
                
                Spacer()
                
                Text(timestamp.formatted(.relative(presentation: .named)))
                    .font(.system(size: themeManager.typography.fontSize.small))
                    .foregroundColor(themeManager.colors.text.opacity(0.6))
            }
            
            // Message Content
            Text(content)
                .font(.system(size: themeManager.typography.fontSize.body))
                .foregroundColor(isFromUser ? .white : themeManager.colors.text)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: isFromUser ? .trailing : .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isFromUser ? themeManager.colors.primary : themeManager.colors.surface)
                )
        }
        .padding(.horizontal, 4)
    }
}

struct ConversationCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let item: CoachHistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                if let coach = Coach.coaches.first(where: { $0.id == item.coachId }) {
                    Text(coach.emoji)
                        .font(.system(size: 32))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(coach.name)
                            .font(.system(size: themeManager.typography.fontSize.body, weight: .semibold))
                            .foregroundColor(themeManager.colors.text)
                        Text(item.timestamp.formatted(.relative(presentation: .named)))
                            .font(.system(size: themeManager.typography.fontSize.small))
                            .foregroundColor(themeManager.colors.text.opacity(0.6))
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.colors.text.opacity(0.4))
            }
            
            // Preview Content
            VStack(alignment: .leading, spacing: 12) {
                // User Message Preview
                Text(item.userMessage)
                    .font(.system(size: themeManager.typography.fontSize.body))
                    .foregroundColor(themeManager.colors.text)
                    .lineLimit(2)
                
                // Coach Response Preview
                Text(item.coachResponse)
                    .font(.system(size: themeManager.typography.fontSize.body))
                    .foregroundColor(themeManager.colors.text.opacity(0.8))
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.colors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    CoachHistoryView(viewModel: CoachHomeViewModel())
        .environmentObject(ThemeManager())
} 