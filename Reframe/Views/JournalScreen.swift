import SwiftUI

struct JournalScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Journal")
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedTab = 0
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(themeManager.colors.primary)
                            .frame(width: 48, height: 48)
                            .background(themeManager.colors.surface)
                            .clipShape(Circle())
                            .shadow(color: themeManager.colors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal)
                
                // Journal Entries
                LazyVStack(spacing: 16) {
                    ForEach(sampleEntries) { entry in
                        JournalEntryCard(entry: entry)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(themeManager.colors.background)
        .navigationBarHidden(true)
    }
    
    // Sample data
    let sampleEntries = [
        JournalEntry(
            id: "1",
            date: Date(),
            title: "Morning Reflection",
            originalThought: "I'm feeling overwhelmed with my tasks today.",
            reframe: "I have the opportunity to prioritize and tackle my tasks one at a time.",
            mood: .productive
        ),
        JournalEntry(
            id: "2",
            date: Date().addingTimeInterval(-86400),
            title: "Evening Thoughts",
            originalThought: "I didn't accomplish everything I wanted today.",
            reframe: "I made progress on important tasks and can continue tomorrow.",
            mood: .neutral
        ),
        JournalEntry(
            id: "3",
            date: Date().addingTimeInterval(-172800),
            title: "Weekly Review",
            originalThought: "This week was challenging because of unexpected changes.",
            reframe: "I'm learning to adapt and grow through these challenges.",
            mood: .happy
        )
    ]
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.custom("Quicksand-SemiBold", size: 18))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text(entry.date, style: .date)
                        .font(.custom("Nunito-Regular", size: 14))
                        .foregroundColor(themeManager.colors.textLight)
                }
                
                Spacer()
                
                Image(systemName: entry.mood.icon)
                    .font(.system(size: 24))
                    .foregroundColor(entry.mood.color)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Original Thought")
                            .font(.custom("Quicksand-SemiBold", size: 16))
                            .foregroundColor(themeManager.colors.primary)
                        
                        Text(entry.originalThought)
                            .font(.custom("Nunito-Regular", size: 16))
                            .foregroundColor(themeManager.colors.text)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reframe")
                            .font(.custom("Quicksand-SemiBold", size: 16))
                            .foregroundColor(themeManager.colors.secondary)
                        
                        Text(entry.reframe)
                            .font(.custom("Nunito-Regular", size: 16))
                            .foregroundColor(themeManager.colors.text)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(themeManager.colors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
}

#Preview {
    JournalScreen(selectedTab: .constant(1))
        .environmentObject(ThemeManager())
} 