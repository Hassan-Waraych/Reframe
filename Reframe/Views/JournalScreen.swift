import SwiftUI

struct JournalScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header with greeting
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Journal")
                        .font(.custom("Quicksand-Regular", size: 20))
                        .foregroundColor(themeManager.colors.textLight)
                    
                    Text("Reflections")
                        .font(.custom("Quicksand-Bold", size: 36))
                        .foregroundColor(themeManager.colors.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Journal Entries
                LazyVStack(spacing: 20) {
                    ForEach(sampleEntries) { entry in
                        JournalEntryCard(entry: entry)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 32)
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
    @State private var dragOffset: CGFloat = 0
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.title)
                        .font(.custom("Quicksand-SemiBold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text(entry.date, style: .date)
                        .font(.custom("Nunito-Regular", size: 15))
                        .foregroundColor(themeManager.colors.textLight)
                }
                
                Spacer()
                
                Image(systemName: entry.mood.icon)
                    .font(.system(size: 28))
                    .foregroundColor(entry.mood.color)
                    .scaleEffect(entry.mood.iconScale)
                    .animation(entry.mood.iconAnimation, value: entry.mood)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Original Thought")
                            .font(.custom("Quicksand-SemiBold", size: 18))
                            .foregroundColor(themeManager.colors.primary)
                        
                        Text(entry.originalThought)
                            .font(.custom("Nunito-Regular", size: 17))
                            .foregroundColor(themeManager.colors.text)
                            .lineSpacing(4)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reframe")
                            .font(.custom("Quicksand-SemiBold", size: 18))
                            .foregroundColor(themeManager.colors.secondary)
                        
                        Text(entry.reframe)
                            .font(.custom("Nunito-Regular", size: 17))
                            .foregroundColor(themeManager.colors.text)
                            .lineSpacing(4)
                    }
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .background(themeManager.colors.surface)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(isHovered ? 0.12 : 0.06), radius: isHovered ? 20 : 12, x: 0, y: isHovered ? 10 : 6)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    withAnimation(.spring()) {
                        dragOffset = 0
                    }
                }
        )
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    JournalScreen(selectedTab: .constant(1))
        .environmentObject(ThemeManager())
} 