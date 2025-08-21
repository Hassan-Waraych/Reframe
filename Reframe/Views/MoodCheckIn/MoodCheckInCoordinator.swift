import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class MoodCheckInCoordinator: ObservableObject {
    @Published var currentStep: MoodCheckInStep = .moodSpectrum
    @Published var isActive = false
    
    // Data collected during the check-in flow
    @Published var selectedMood: MoodType = .okay
    @Published var selectedEmotions: [EmotionTag] = []
    @Published var customEmotions: [String] = []
    @Published var contextTags: [ContextTag] = []
    @Published var contextNotes: String = ""
    @Published var bodyMindCheck = BodyMindCheck()
    @Published var isPositiveFocus: Bool = true
    
    enum MoodCheckInStep {
        case moodSpectrum
        case emotionLayer
        case contextTriggers
        case bodyMindCheck
        case visualization
        case courseRecommendations
    }
    
    func next() {
        switch currentStep {
        case .moodSpectrum:
            currentStep = .emotionLayer
        case .emotionLayer:
            currentStep = .contextTriggers
        case .contextTriggers:
            currentStep = .bodyMindCheck
        case .bodyMindCheck:
            currentStep = .visualization
        case .visualization:
            currentStep = .courseRecommendations
        case .courseRecommendations:
            completeCheckIn()
        }
    }
    
    func previous() {
        switch currentStep {
        case .moodSpectrum:
            // Can't go back from first step
            break
        case .emotionLayer:
            currentStep = .moodSpectrum
        case .contextTriggers:
            currentStep = .emotionLayer
        case .bodyMindCheck:
            currentStep = .contextTriggers
        case .visualization:
            currentStep = .bodyMindCheck
        case .courseRecommendations:
            currentStep = .visualization
        }
    }
    
    func startCheckIn() {
        resetData()
        currentStep = .moodSpectrum
        isActive = true
    }
    
    func completeCheckIn() {
        Task {
            await saveMoodEntry()
            await MainActor.run {
                isActive = false
                resetData()
            }
        }
    }
    
    func cancelCheckIn() {
        isActive = false
        resetData()
    }
    
    private func resetData() {
        selectedMood = .okay
        selectedEmotions = []
        customEmotions = []
        contextTags = []
        contextNotes = ""
        bodyMindCheck = BodyMindCheck()
        isPositiveFocus = true
        currentStep = .moodSpectrum
    }
    
    private func saveMoodEntry() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let moodEntry = MoodEntry(
            userId: userId,
            date: Date(),
            mood: selectedMood,
            selectedEmotions: selectedEmotions,
            customEmotions: customEmotions,
            contextTags: contextTags,
            contextNotes: contextNotes.isEmpty ? nil : contextNotes,
            bodyMindCheck: bodyMindCheck,
            isPositiveFocus: isPositiveFocus
        )
        
        // Save to MoodService
        await MoodService.shared.saveMoodEntry(moodEntry)
        
        // Also save as a journal entry
        await saveAsJournalEntry(moodEntry)
    }
    
    private func saveAsJournalEntry(_ moodEntry: MoodEntry) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let journalService = JournalService.shared
        
        // Create a formatted content string for the journal entry
        var content = "Mood: \(moodEntry.mood.displayName) \(moodEntry.mood.emoji)\n\n"
        
        if !moodEntry.selectedEmotions.isEmpty {
            let emotionNames = moodEntry.selectedEmotions.map { $0.name }.joined(separator: ", ")
            content += "Emotions: \(emotionNames)\n\n"
        }
        
        if !moodEntry.customEmotions.isEmpty {
            let customEmotionNames = moodEntry.customEmotions.joined(separator: ", ")
            content += "Additional Emotions: \(customEmotionNames)\n\n"
        }
        
        if !moodEntry.contextTags.isEmpty {
            let contextNames = moodEntry.contextTags.map { $0.name }.joined(separator: ", ")
            content += "Context: \(contextNames)\n\n"
        }
        
        if let notes = moodEntry.contextNotes {
            content += "Notes: \(notes)\n\n"
        }
        
        content += "Energy Level: \(moodEntry.bodyMindCheck.energyLevel.displayName)\n"
        content += "Sleep Quality: \(moodEntry.bodyMindCheck.sleepQuality.displayName)\n"
        content += "Stress Level: \(Int(moodEntry.bodyMindCheck.stressLevel * 100))%\n\n"
        
        content += "Focus: \(moodEntry.isPositiveFocus ? "What's boosting your mood" : "What's draining your mood")"
        
        let journalEntry = JournalEntry(
            userId: userId,
            content: content,
            originalThought: nil,
            timestamp: moodEntry.timestamp,
            category: "Mood Check-in",
            reframeId: nil,
            isFavorite: false
        )
        
        try? await journalService.addEntry(
            content: content,
            originalThought: nil,
            category: "Mood Check-in",
            reframeId: nil,
            isFavorite: false
        )
    }
}

struct MoodCheckInView: View {
    @ObservedObject var coordinator: MoodCheckInCoordinator
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // Background
            themeManager.customBackground()
            

            
            if coordinator.isActive {
                switch coordinator.currentStep {
                case .moodSpectrum:
                    MoodSpectrumScreen(coordinator: coordinator)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                case .emotionLayer:
                    EmotionLayerScreen(coordinator: coordinator)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                case .contextTriggers:
                    ContextTriggersScreen(coordinator: coordinator)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                case .bodyMindCheck:
                    BodyMindCheckScreen(coordinator: coordinator)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                case .visualization:
                    VisualizationScreen(coordinator: coordinator)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                case .courseRecommendations:
                    CourseRecommendationsScreen(coordinator: coordinator)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                }
            }
        }
        .animation(.spring(), value: coordinator.currentStep)
    }
}

#Preview {
    MoodCheckInView(coordinator: MoodCheckInCoordinator())
        .environmentObject(ThemeManager())
}
