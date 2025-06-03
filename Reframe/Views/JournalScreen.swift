import SwiftUI

struct JournalScreen: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var journalService = JournalService.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: {
                        selectedTab = 0
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(themeManager.colors.primary)
                            .frame(width: 48, height: 48)
                            .background(themeManager.colors.surface)
                            .clipShape(Circle())
                            .shadow(color: themeManager.colors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    
                    Text("Journal")
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
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
                    LazyVStack(spacing: 24) {
                        ForEach(journalService.entries) { entry in
                            JournalEntryView(entry: entry)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .padding(.vertical)
        }
        .background(themeManager.colors.background)
        .navigationBarHidden(true)
    }
}

struct JournalEntryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let entry: JournalEntry
    @State private var isExpanded = false
    
    private var isReframe: Bool {
        entry.category == "Reframe"
    }
    
    private var entryColor: Color {
        isReframe ? Color(hex: "FF7F6B") : themeManager.colors.secondary
    }
    
    private var contentParts: (original: String, reframed: String)? {
        guard isReframe else { return nil }
        let components = entry.content.components(separatedBy: "\n\n")
        guard components.count >= 2 else { return nil }
        return (components[0].replacingOccurrences(of: "Original Thought: ", with: ""),
                components[1].replacingOccurrences(of: "Reframed Thought: ", with: ""))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card Header
            HStack {
                Text(entry.category)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(entryColor)
                
                Spacer()
                
                Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(themeManager.colors.textLight)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Card Content
            VStack(alignment: .leading, spacing: 12) {
                if let parts = contentParts {
                    // Reframe Entry
                    VStack(alignment: .leading, spacing: 12) {
                        Text(parts.original)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(themeManager.colors.text.opacity(0.8))
                            .padding(.horizontal, 16)
                        
                        if isExpanded {
                            Text(parts.reframed)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(themeManager.colors.text)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(entryColor.opacity(0.1))
                                )
                                .padding(.horizontal, 16)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        HStack {
                            Spacer()
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(entryColor)
                                .padding(.trailing, 16)
                                .padding(.bottom, 8)
                        }
                    }
                } else {
                    // Reflection Entry
                    Text(entry.content)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(themeManager.colors.text)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.colors.background)
                .shadow(color: entryColor.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(entryColor.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture {
            if isReframe {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    JournalScreen(selectedTab: .constant(1))
        .environmentObject(ThemeManager())
} 