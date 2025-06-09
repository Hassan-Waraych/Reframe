import SwiftUI

struct GuidedJournalScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedPrompt: JournalPrompt?
    @State private var journalEntry: String = ""
    @State private var isShowingNewPrompt = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(PromptCategory.allCases, id: \.self) { category in
                        CategoryPromptSection(category: category) { prompt in
                            selectedPrompt = prompt
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Guided Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Guided Journal")
                        .font(.custom("Poppins-Bold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.colors.text)
                    }
                }
            }
            .background(themeManager.colors.background)
        }
        .sheet(item: $selectedPrompt) { prompt in
            JournalEntryModal(prompt: prompt, journalEntry: $journalEntry) {
                selectedPrompt = nil
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(themeManager.colors.background)
        }
    }
}

struct CategoryPromptSection: View {
    let category: PromptCategory
    let onSelectPrompt: (JournalPrompt) -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var prompts: [JournalPrompt] {
        JournalPrompt.prompts.filter { $0.category == category }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(category.rawValue)
                .font(.custom("Poppins-Bold", size: 22))
                .foregroundColor(themeManager.colors.text)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(prompts) { prompt in
                        VStack(spacing: 8) {
                            PromptCard(prompt: prompt) {
                                onSelectPrompt(prompt)
                            }
                            
                            Text(prompt.title)
                                .font(.custom("Poppins-Bold", size: 13))
                                .foregroundColor(themeManager.colors.text)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(width: 120, height: 32)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct PromptCard: View {
    let prompt: JournalPrompt
    let onSelect: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onSelect) {
            ZStack {
                Circle()
                    .fill(prompt.category.color.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: prompt.icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(prompt.category.color)
            }
            .frame(width: 120, height: 120)
            .background(themeManager.colors.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct JournalEntryModal: View {
    let prompt: JournalPrompt
    @Binding var journalEntry: String
    let onDismiss: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: prompt.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(prompt.category.color)
                        
                        Text(prompt.title)
                            .font(.custom("Poppins-Bold", size: 20))
                            .foregroundColor(themeManager.colors.text)
                    }
                    
                    Text(prompt.text)
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(themeManager.colors.text)
                        .padding(.leading, 4)
                }
                .padding()
                .background(themeManager.colors.surface)
                .cornerRadius(16)
                
                ZStack {
                    themeManager.colors.surface
                        .cornerRadius(16)
                    
                    TextEditor(text: $journalEntry)
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(themeManager.colors.text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .focused($isFocused)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(themeManager.colors.text)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: Implement save functionality
                        onDismiss()
                    }
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(prompt.category.color)
                }
            }
            .background(themeManager.colors.background)
        }
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    GuidedJournalScreen()
        .environmentObject(ThemeManager())
} 