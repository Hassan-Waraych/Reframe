import SwiftUI

struct CoachInputSheet: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CoachHomeViewModel
    
    @State private var messageText = ""
    @State private var selectedEmotion: Emotion?
    
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
    
    init() {
        _viewModel = StateObject(wrappedValue: CoachHomeViewModel())
    }
    
    var body: some View {
        NavigationView {
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
                    
                    TextEditor(text: $messageText)
                        .font(.system(size: themeManager.typography.fontSize.body))
                        .foregroundColor(themeManager.colors.text)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(themeManager.colors.surface)
                        .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding(24)
            .background(themeManager.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        Task {
                            await viewModel.submitMessage(messageText)
                            dismiss()
                        }
                    }
                    .disabled(messageText.isEmpty)
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
            .background(isSelected ? themeManager.colors.primary : themeManager.colors.surface)
            .cornerRadius(12)
        }
    }
}

#Preview {
    CoachInputSheet()
        .environmentObject(ThemeManager())
} 