import SwiftUI

struct CoachTestView: View {
    @StateObject private var coachService = CoachService.shared
    @State private var selectedNeeds: [String] = []
    @State private var assignedCoach: Coach?
    
    let emotionalNeeds = [
        "anxiety", "perfectionism", "stress",
        "self-doubt", "self-worth",
        "relationships", "change",
        "overthinking"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Coach Assignment Test")
                .font(.title)
                .padding()
            
            Text("Select Emotional Needs:")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(emotionalNeeds, id: \.self) { need in
                        Button(action: {
                            if selectedNeeds.contains(need) {
                                selectedNeeds.removeAll { $0 == need }
                            } else {
                                selectedNeeds.append(need)
                            }
                        }) {
                            Text(need)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    selectedNeeds.contains(need) ?
                                    Color.blue : Color.gray.opacity(0.2)
                                )
                                .foregroundColor(
                                    selectedNeeds.contains(need) ?
                                    .white : .primary
                                )
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Button("Assign Coach") {
                assignedCoach = coachService.assignCoach(emotionalNeeds: selectedNeeds)
            }
            .disabled(selectedNeeds.isEmpty)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            if let coach = assignedCoach {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Assigned Coach: \(coach.name) \(coach.emoji)")
                        .font(.headline)
                    Text(coach.description)
                    Text("Tone: \(coach.toneSummary)")
                    Text("Covers: \(coach.covers.joined(separator: ", "))")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
            }
            
            Text("Coach Usage Status: \(coachService.hasUsedCoach ? "Used" : "Available")")
                .padding()
        }
    }
}

#Preview {
    CoachTestView()
} 