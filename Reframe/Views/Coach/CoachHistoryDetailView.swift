import SwiftUI

struct CoachHistoryDetailView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CoachHomeViewModel
    let historyItem: CoachHistoryItem
    
    init(historyItem: CoachHistoryItem) {
        self.historyItem = historyItem
        _viewModel = StateObject(wrappedValue: CoachHomeViewModel())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // User Message Card
                    messageCard(
                        content: historyItem.userMessage,
                        isFromUser: true
                    )
                    
                    // Coach Response Card
                    messageCard(
                        content: historyItem.coachResponse,
                        isFromUser: false
                    )
                    
                    // Action Buttons
                    actionButtons
                }
                .padding(24)
            }
            .background(themeManager.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func messageCard(content: String, isFromUser: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(isFromUser ? "You" : "Coach")
                    .font(.system(size: themeManager.typography.fontSize.small, weight: .medium))
                    .foregroundColor(themeManager.colors.textLight)
                
                Spacer()
                
                Text(historyItem.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: themeManager.typography.fontSize.small))
                    .foregroundColor(themeManager.colors.textLight)
            }
            
            // Message
            Text(content)
                .font(.system(size: themeManager.typography.fontSize.body))
                .foregroundColor(themeManager.colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(themeManager.colors.surface)
        .cornerRadius(12)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // That Helped Button
            Button(action: {
                Task {
                    await viewModel.markAsHelpful(historyItem)
                }
            }) {
                HStack {
                    Image(systemName: historyItem.wasHelpful ? "heart.fill" : "heart")
                    Text(historyItem.wasHelpful ? "Helped" : "That Helped")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(historyItem.wasHelpful ? .white : themeManager.colors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(historyItem.wasHelpful ? themeManager.colors.primary : themeManager.colors.primary.opacity(0.1))
                .cornerRadius(12)
            }
            .disabled(historyItem.wasHelpful)
            
            // Save to Journal Button
            Button(action: {
                Task {
                    await viewModel.saveToJournal(historyItem)
                }
            }) {
                HStack {
                    Image(systemName: historyItem.isSavedToJournal ? "bookmark.fill" : "bookmark")
                    Text(historyItem.isSavedToJournal ? "Saved" : "Save to Journal")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(historyItem.isSavedToJournal ? .white : themeManager.colors.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(historyItem.isSavedToJournal ? themeManager.colors.secondary : themeManager.colors.secondary.opacity(0.1))
                .cornerRadius(12)
            }
            .disabled(historyItem.isSavedToJournal)
        }
    }
}

#Preview {
    CoachHistoryDetailView(historyItem: CoachHistoryItem(
        id: "1",
        userId: "user1",
        coachId: "coach1",
        userMessage: "I've been feeling lost lately.",
        coachResponse: "Let's unpack that feeling together. What do you think might be causing this sense of being lost?",
        timestamp: Date(),
        wasHelpful: false,
        isSavedToJournal: false
    ))
    .environmentObject(ThemeManager())
} 