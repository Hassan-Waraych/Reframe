import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int
    @State private var selectedOption: String = "Reframe"
    @State private var inputText: String = ""
    @State private var isAnimating = false
    @State private var showQuote = false
    @State private var currentQuote = "Your daily dose of wisdom will appear here..."
    
    let quotes = [
        "The only way to do great work is to love what you do.",
        "Life is what happens while you're busy making other plans.",
        "The future belongs to those who believe in the beauty of their dreams."
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Reframe")
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    
                    Spacer()
                    
                    NavigationLink(destination: SettingsScreen(selectedTab: $selectedTab)) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(themeManager.colors.primary)
                            .frame(width: 48, height: 48)
                            .background(themeManager.colors.surface)
                            .clipShape(Circle())
                            .shadow(color: themeManager.colors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal)
                
                // Quote Card
                QuoteCard(quote: currentQuote, isAnimating: $isAnimating)
                    .padding(.horizontal)
                
                // Option Buttons
                HStack(spacing: 16) {
                    OptionButton(
                        title: "Reframe",
                        icon: "arrow.triangle.2.circlepath",
                        isSelected: selectedOption == "Reframe",
                        action: { selectOption("Reframe") }
                    )
                    
                    OptionButton(
                        title: "Reflect",
                        icon: "book.fill",
                        isSelected: selectedOption == "Reflect",
                        action: { selectOption("Reflect") }
                    )
                }
                .padding(.horizontal)
                
                // Input Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's on your mind?")
                        .font(.custom("Quicksand-SemiBold", size: 18))
                        .foregroundColor(themeManager.colors.text)
                    
                    ZStack(alignment: .topLeading) {
                        if inputText.isEmpty {
                            Text("Type your thoughts here...")
                                .font(.custom("Nunito-Regular", size: 16))
                                .foregroundColor(themeManager.colors.textLight)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        
                        TextEditor(text: $inputText)
                            .font(.custom("Nunito-Regular", size: 16))
                            .foregroundColor(themeManager.colors.text)
                            .frame(minHeight: 120)
                            .padding(4)
                            .background(themeManager.colors.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.colors.border, lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        // Handle submission
                        withAnimation {
                            showQuote = true
                            currentQuote = quotes.randomElement() ?? quotes[0]
                            inputText = ""
                        }
                    }) {
                        HStack {
                            Text("Submit")
                                .font(.custom("Nunito-SemiBold", size: 16))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    themeManager.colors.primary,
                                    themeManager.colors.primaryDark
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: themeManager.colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(inputText.isEmpty)
                    .opacity(inputText.isEmpty ? 0.6 : 1)
                }
                .padding(.horizontal)
                
                // Progress Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Reflections Used")
                            .font(.custom("Quicksand-SemiBold", size: 16))
                            .foregroundColor(themeManager.colors.text)
                        
                        Spacer()
                        
                        Text("3/5")
                            .font(.custom("Nunito-Medium", size: 16))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(themeManager.colors.surface)
                                .frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            themeManager.colors.primary,
                                            themeManager.colors.primaryDark
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.6, height: 12)
                        }
                    }
                    .frame(height: 12)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(themeManager.colors.background)
        .navigationBarHidden(true)
    }
    
    private func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    private func selectOption(_ option: String) {
        withAnimation(.spring()) {
            selectedOption = option
        }
    }
}

struct QuoteCard: View {
    let quote: String
    @Binding var isAnimating: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.colors.primary)
                
                Text("Daily Quote")
                    .font(.custom("Quicksand-SemiBold", size: 20))
                    .foregroundColor(themeManager.colors.text)
            }
            
            Text(quote)
                .font(.custom("Nunito-Regular", size: 16))
                .foregroundColor(themeManager.colors.textLight)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.colors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
    }
}

struct OptionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var gradientColors: [Color] {
        if title == "Reframe" {
            return isSelected ? [
                themeManager.colors.primary,
                themeManager.colors.primaryDark
            ] : [
                themeManager.colors.surface,
                themeManager.colors.surface
            ]
        } else {
            return isSelected ? [
                themeManager.colors.secondary,
                Color(hex: "7B4B8E") // Darker purple
            ] : [
                themeManager.colors.surface,
                themeManager.colors.surface
            ]
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                
                Text(title)
                    .font(.custom("Nunito-SemiBold", size: 16))
            }
            .foregroundColor(isSelected ? .white : themeManager.colors.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: isSelected ? (title == "Reframe" ? themeManager.colors.primary : themeManager.colors.secondary).opacity(0.3) : Color.black.opacity(0.05),
                   radius: isSelected ? 8 : 4,
                   x: 0,
                   y: isSelected ? 4 : 2)
        }
    }
}

#Preview {
    HomeScreen(selectedTab: .constant(0))
        .environmentObject(ThemeManager())
} 