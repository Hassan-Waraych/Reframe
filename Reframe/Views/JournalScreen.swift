import SwiftUI

struct JournalScreen: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var journalService = JournalService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            if journalService.entries.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 60))
                        .foregroundColor(themeManager.colors.primary)
                    
                    Text("No Entries Yet")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.colors.text)
                    
                    Text("Your reflections will appear here. Start by adding a reflection from the home screen!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(themeManager.colors.textLight)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(journalService.entries) { entry in
                            JournalEntryView(entry: entry)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .background(themeManager.colors.background)
        .navigationTitle("Journal")
    }
}

struct JournalEntryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.category)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(themeManager.colors.secondary)
                
                Spacer()
                
                Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(themeManager.colors.textLight)
            }
            
            Text(entry.content)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(themeManager.colors.text)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.colors.secondary.opacity(0.07))
                        .shadow(color: themeManager.colors.secondary.opacity(0.08), radius: 6, x: 0, y: 2)
                )
        }
    }
}

#Preview {
    JournalScreen(selectedTab: .constant(1))
        .environmentObject(ThemeManager())
} 