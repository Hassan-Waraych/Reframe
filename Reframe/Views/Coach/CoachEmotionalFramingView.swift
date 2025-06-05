import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CoachEmotionalFramingView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CoachHomeViewModel
    @State private var selectedNeeds: Set<String> = []
    @State private var isAssigning = false
    @State private var showError = false
    @State private var errorMessage: String?
    
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
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose Your Coach")
                        .font(.system(size: themeManager.typography.fontSize.h2, weight: .bold))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text("Select the areas you'd like to work on to find your perfect coach")
                        .font(.system(size: themeManager.typography.fontSize.body))
                        .foregroundColor(themeManager.colors.textLight)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Needs Grid
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
                
                // Assign Coach Button
                Button(action: {
                    Task {
                        await assignCoach()
                    }
                }) {
                    HStack {
                        if isAssigning {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                            Text("Finding your coach...")
                        } else {
                            Text("Find My Coach")
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(themeManager.colors.primary)
                    .cornerRadius(16)
                }
                .disabled(selectedNeeds.isEmpty || isAssigning)
                .opacity((selectedNeeds.isEmpty || isAssigning) ? 0.5 : 1)
            }
            .padding(24)
        }
        .background(themeManager.colors.background)
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
    }
    
    private func assignCoach() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isAssigning = true
        defer { isAssigning = false }
        
        do {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userId)
            
            // First, ensure the user document exists
            try await userRef.setData([
                "emotionalNeeds": Array(selectedNeeds),
                "coachId": FieldValue.delete(),
                "createdAt": FieldValue.serverTimestamp()
            ], merge: true)
            
            // Find the best matching coach
            var bestCoach: Coach? = nil
            var maxMatches = 0
            
            for coach in Coach.coaches {
                let matches = Set(coach.covers).intersection(selectedNeeds).count
                if matches > maxMatches {
                    maxMatches = matches
                    bestCoach = coach
                }
            }
            
            // If we found a good match, assign that coach
            if let matchedCoach = bestCoach {
                try await userRef.updateData([
                    "coachId": matchedCoach.id,
                    "coachAssignedAt": FieldValue.serverTimestamp()
                ])
            } else {
                // If no good match, assign randomly
                let randomCoach = Coach.coaches.randomElement() ?? Coach.coaches[0]
                try await userRef.updateData([
                    "coachId": randomCoach.id,
                    "coachAssignedAt": FieldValue.serverTimestamp()
                ])
            }
            
            // Reload the view model to get the new coach
            await viewModel.loadData()
            
            // Only dismiss after everything is complete
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    CoachEmotionalFramingView(viewModel: CoachHomeViewModel())
        .environmentObject(ThemeManager())
} 