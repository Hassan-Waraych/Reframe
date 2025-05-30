import SwiftUI

struct JournalListView: View {
    let entries: [JournalEntry]
    @State private var selectedEntry: JournalEntry?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(entries) { entry in
                    JournalEntryCard(entry: entry)
                        .padding(.horizontal)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            .padding(.vertical)
        }
        .animation(.spring(), value: entries)
    }
}

#Preview {
    JournalListView(
        entries: [
            JournalEntry(
                id: "1",
                date: Date(),
                title: "First Entry",
                originalThought: "I'm feeling overwhelmed with work.",
                reframe: "I'm capable of handling challenges one step at a time.",
                mood: .anxious
            ),
            JournalEntry(
                id: "2",
                date: Date().addingTimeInterval(-86400),
                title: "Second Entry",
                originalThought: "I accomplished a lot today!",
                reframe: "I'm proud of my productivity and progress.",
                mood: .productive
            )
        ]
    )
} 