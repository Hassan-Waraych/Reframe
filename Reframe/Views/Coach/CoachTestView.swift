import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CoachTestView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedNeeds: Set<String> = []
    @State private var assignedCoach: Coach?
    @State private var showResetAlert = false
    
    let emotionalNeeds = [
        EmotionalNeed(id: "overthinking", title: "Overthinking", description: "Help me break free from repetitive negative thoughts", icon: "brain"),
        EmotionalNeed(id: "self-doubt", title: "Self-Doubt", description: "Build confidence and trust in my abilities", icon: "shield"),
        EmotionalNeed(id: "anxiety", title: "Anxiety", description: "Find calm and perspective in stressful moments", icon: "leaf"),
        EmotionalNeed(id: "perfectionism", title: "Perfectionism", description: "Embrace progress over perfection", icon: "star"),
        EmotionalNeed(id: "relationships", title: "Relationships", description: "Navigate social situations with more clarity", icon: "person.2"),
        EmotionalNeed(id: "stress", title: "Stress Management", description: "Develop healthier coping mechanisms", icon: "figure.walk"),
        EmotionalNeed(id: "self-worth", title: "Self-Worth", description: "Build a stronger sense of self-value", icon: "heart"),
        EmotionalNeed(id: "change", title: "Life Changes", description: "Adapt to transitions and new situations", icon: "arrow.triangle.branch")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    needsGridView
                    assignButton
                    if let coach = assignedCoach {
                        coachCardView(coach: coach)
                    }
                    resetButton
                }
                .padding(24)
            }
            .background(themeManager.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(themeManager.colors.text)
                    }
                }
            }
            .alert("Reset Coach Usage", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetCoachUsage()
                }
            } message: {
                Text("This will reset your coach usage count. You'll be able to use the coach feature again.")
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Test Coach Assignment")
                .font(.system(size: themeManager.typography.fontSize.h2, weight: .bold))
                .foregroundColor(themeManager.colors.text)
            
            Text("Select emotional needs to test coach assignment")
                .font(.system(size: themeManager.typography.fontSize.body))
                .foregroundColor(themeManager.colors.textLight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var needsGridView: some View {
        LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
            ForEach(emotionalNeeds) { need in
                NeedCard(
                    need: need,
                    isSelected: selectedNeeds.contains(need.id),
                    action: {
                        if selectedNeeds.contains(need.id) {
                            selectedNeeds.remove(need.id)
                        } else {
                            selectedNeeds.insert(need.id)
                        }
                    }
                )
            }
        }
    }
    
    private var assignButton: some View {
        Button(action: {
            assignedCoach = CoachService.assignCoach(emotionalNeeds: Array(selectedNeeds))
        }) {
            Text("Assign Coach")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(themeManager.colors.primary)
                .cornerRadius(16)
        }
        .disabled(selectedNeeds.isEmpty)
        .opacity(selectedNeeds.isEmpty ? 0.5 : 1)
    }
    
    private func coachCardView(coach: Coach) -> some View {
        VStack(spacing: 24) {
            // Emoji and Name
            VStack(spacing: 16) {
                Text(coach.emoji)
                    .font(.system(size: 64))
                
                Text(coach.name)
                    .font(.system(size: themeManager.typography.fontSize.h2, weight: .bold))
                    .foregroundColor(themeManager.colors.text)
            }
            
            // Description
            Text(coach.description)
                .font(.system(size: themeManager.typography.fontSize.body))
                .foregroundColor(themeManager.colors.text)
                .multilineTextAlignment(.center)
            
            // Tone Summary
            VStack(spacing: 8) {
                Text("Their Approach")
                    .font(.system(size: themeManager.typography.fontSize.h3, weight: .semibold))
                    .foregroundColor(themeManager.colors.text)
                
                Text(coach.toneSummary)
                    .font(.system(size: themeManager.typography.fontSize.body))
                    .foregroundColor(themeManager.colors.textLight)
                    .multilineTextAlignment(.center)
            }
            
            // Covered Needs
            VStack(spacing: 8) {
                Text("Covers These Needs")
                    .font(.system(size: themeManager.typography.fontSize.h3, weight: .semibold))
                    .foregroundColor(themeManager.colors.text)
                
                ForEach(coach.covers, id: \.self) { need in
                    Text(need)
                        .font(.system(size: themeManager.typography.fontSize.body))
                        .foregroundColor(themeManager.colors.textLight)
                }
            }
        }
        .padding(24)
        .background(themeManager.colors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var resetButton: some View {
        Button(action: {
            showResetAlert = true
        }) {
            Text("Reset Coach Usage")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(themeManager.colors.secondary)
                .cornerRadius(16)
        }
    }
    
    private func resetCoachUsage() {
        if let userId = Auth.auth().currentUser?.uid {
            Task {
                do {
                    let db = Firestore.firestore()
                    let snapshot = try await db.collection("coachMessages")
                        .whereField("userId", isEqualTo: userId)
                        .getDocuments()
                    
                    for document in snapshot.documents {
                        try await document.reference.delete()
                    }
                } catch {
                    print("Error resetting coach usage: \(error)")
                }
            }
        }
    }
}

#Preview {
    CoachTestView()
        .environmentObject(ThemeManager())
} 