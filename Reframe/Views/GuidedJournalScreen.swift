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
    @StateObject private var journalService = JournalService.shared
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccessAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
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
                        .disabled(isSaving)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            Task {
                                await saveEntry()
                            }
                        }
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(journalEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? themeManager.colors.textLight : prompt.category.color)
                        .disabled(journalEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                    }
                }
                .background(themeManager.colors.background)
                .alert("Error", isPresented: $showError) {
                    Button("OK") { }
                } message: {
                    Text(errorMessage)
                }
                
                // Success Animation Overlay
                if showSuccessAnimation {
                    SuccessAnimationView(prompt: prompt)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
    
    private func saveEntry() async {
        let trimmedEntry = journalEntry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEntry.isEmpty else { return }
        
        isSaving = true
        
        do {
            try await journalService.logGuidedPromptToJournal(prompt: prompt, response: trimmedEntry)
            await MainActor.run {
                journalEntry = ""
                showSuccessAnimation = true
                
                // Hide success animation after 2 seconds and dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSuccessAnimation = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        
        await MainActor.run {
            isSaving = false
        }
    }
}

struct SuccessAnimationView: View {
    let prompt: JournalPrompt
    @EnvironmentObject var themeManager: ThemeManager
    @State private var animateCheckmark = false
    @State private var animateText = false
    @State private var animateIcon = false
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Animated icon
                ZStack {
                    Circle()
                        .fill(prompt.category.color.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .scaleEffect(animateIcon ? 1.1 : 0.8)
                        .animation(.easeInOut(duration: 0.6).repeatCount(1, autoreverses: true), value: animateIcon)
                    
                    Image(systemName: prompt.icon)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(prompt.category.color)
                        .scaleEffect(animateIcon ? 1.2 : 0.9)
                        .animation(.easeInOut(duration: 0.6).repeatCount(1, autoreverses: true), value: animateIcon)
                }
                
                // Success checkmark
                ZStack {
                    Circle()
                        .fill(prompt.category.color)
                        .frame(width: 60, height: 60)
                        .scaleEffect(animateCheckmark ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateCheckmark)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(animateCheckmark ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: animateCheckmark)
                }
                
                // Success text
                VStack(spacing: 8) {
                    Text("Saved to Journal")
                        .font(.custom("Poppins-Bold", size: 24))
                        .foregroundColor(themeManager.colors.text)
                        .opacity(animateText ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateText)
                    
                    Text(prompt.title)
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(themeManager.colors.textLight)
                        .opacity(animateText ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5).delay(0.6), value: animateText)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(themeManager.colors.background)
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(animateText ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateText)
        }
        .onAppear {
            animateIcon = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateCheckmark = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                animateText = true
            }
        }
    }
}

#Preview {
    GuidedJournalScreen()
        .environmentObject(ThemeManager())
} 