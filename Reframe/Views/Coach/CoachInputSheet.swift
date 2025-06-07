import SwiftUI

struct CoachInputSheet: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CoachHomeViewModel
    
    @State private var messageText = ""
    @State private var selectedEmotion: Emotion?
    @State private var isSending = false
    @State private var showResponse = false
    @State private var coachResponse = ""
    
    private let emotions: [Emotion] = [
        Emotion(emoji: "😊", name: "Happy"),
        Emotion(emoji: "😔", name: "Sad"),
        Emotion(emoji: "😡", name: "Angry"),
        Emotion(emoji: "😰", name: "Anxious"),
        Emotion(emoji: "😴", name: "Tired"),
        Emotion(emoji: "😌", name: "Calm"),
        Emotion(emoji: "🤔", name: "Confused"),
        Emotion(emoji: "😤", name: "Frustrated")
    ]
    
    init(viewModel: CoachHomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if !showResponse {
                        // Input Section
                        VStack(spacing: 24) {
                            // Emotion Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("How are you feeling?")
                                    .font(.system(size: themeManager.typography.fontSize.body, weight: .medium))
                                    .foregroundColor(themeManager.colors.text)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(emotions) { emotion in
                                            EmotionButton(
                                                emotion: emotion,
                                                isSelected: selectedEmotion?.id == emotion.id,
                                                action: { selectedEmotion = emotion }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            
                            // Message Input
                            VStack(alignment: .leading, spacing: 12) {
                                Text("What's on your mind?")
                                    .font(.system(size: themeManager.typography.fontSize.body, weight: .medium))
                                    .foregroundColor(themeManager.colors.text)
                                
                                ZStack {
                                    TextEditor(text: $messageText)
                                        .font(.system(size: themeManager.typography.fontSize.body))
                                        .foregroundColor(themeManager.colors.text)
                                        .frame(minHeight: 120)
                                        .scrollContentBackground(.hidden)
                                }
                                .background(themeManager.colors.surface)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                                .padding(0)
                            }
                        }
                    } else {
                        // Response Section
                        VStack(spacing: 24) {
                            // Coach Response Card
                            VStack(alignment: .leading, spacing: 16) {
                                // Coach Header
                                HStack(spacing: 12) {
                                    if let coach = viewModel.currentCoach {
                                        Text(coach.emoji)
                                            .font(.system(size: 32))
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(coach.name)
                                                .font(.system(size: themeManager.typography.fontSize.body, weight: .semibold))
                                                .foregroundColor(themeManager.colors.text)
                                            Text("Coach's Response")
                                                .font(.system(size: themeManager.typography.fontSize.small))
                                                .foregroundColor(themeManager.colors.text.opacity(0.6))
                                        }
                                    }
                                }
                                
                                // Response Text
                                Text(coachResponse)
                                    .font(.system(size: themeManager.typography.fontSize.body))
                                    .foregroundColor(themeManager.colors.text)
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(themeManager.colors.surface)
                                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                                    )
                            }
                            
                            // Action Buttons
                            VStack(spacing: 12) {
                                Button(action: {
                                    // Mark as helpful
                                    Task {
                                        if let lastItem = viewModel.historyItems.first {
                                            await viewModel.markAsHelpful(lastItem)
                                        }
                                        dismiss()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "heart.fill")
                                        Text("That Helped")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(themeManager.colors.primary)
                                            .shadow(color: themeManager.colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                }
                                
                                Button(action: {
                                    // Save to journal
                                    Task {
                                        if let lastItem = viewModel.historyItems.first {
                                            await viewModel.saveToJournal(lastItem)
                                        }
                                        dismiss()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "book.fill")
                                        Text("Save Entry")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(themeManager.colors.secondary)
                                            .shadow(color: themeManager.colors.secondary.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                }
                                
                                Button(action: {
                                    // Reset for follow-up
                                    showResponse = false
                                    messageText = ""
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Ask More")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(themeManager.colors.text)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(themeManager.colors.surface)
                                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(themeManager.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showResponse {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Send") {
                            Task {
                                isSending = true
                                await viewModel.submitMessage(messageText)
                                // Get the response from the first history item
                                if let response = viewModel.historyItems.first?.coachResponse {
                                    coachResponse = response
                                    showResponse = true
                                }
                                isSending = false
                            }
                        }
                        .disabled(messageText.isEmpty || isSending)
                    }
                }
            }
            .overlay {
                if isSending {
                    VStack(spacing: 24) {
                        if let coach = viewModel.currentCoach {
                            Text(coach.emoji)
                                .font(.system(size: 64))
                        }
                        VStack(spacing: 16) {
                            Text("Thinking...")
                                .font(.system(size: themeManager.typography.fontSize.body, weight: .medium))
                                .foregroundColor(themeManager.colors.text)
                            HStack(spacing: 4) {
                                ForEach(0..<3) { i in
                                    Circle()
                                        .fill(themeManager.colors.primary)
                                        .frame(width: 8, height: 8)
                                        .opacity(0.5)
                                        .animation(
                                            Animation.easeInOut(duration: 0.5)
                                                .repeatForever()
                                                .delay(0.2 * Double(i)),
                                            value: isSending
                                        )
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        themeManager.colors.background
                            .opacity(0.9)
                            .blur(radius: 2)
                    )
                }
            }
        }
    }
}

// MARK: - Emotion Model
struct Emotion: Identifiable {
    let id = UUID()
    let emoji: String
    let name: String
}

// MARK: - Emotion Button
struct EmotionButton: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let emotion: Emotion
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emotion.emoji)
                    .font(.system(size: 32))
                
                Text(emotion.name)
                    .font(.system(size: themeManager.typography.fontSize.small))
                    .foregroundColor(isSelected ? .white : themeManager.colors.text)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? themeManager.colors.primary : themeManager.colors.surface)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
    }
}

#Preview {
    CoachInputSheet(viewModel: CoachHomeViewModel())
        .environmentObject(ThemeManager())
} 