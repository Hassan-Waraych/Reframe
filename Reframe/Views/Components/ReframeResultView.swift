import SwiftUI

/// A view component that displays the result of a reframe operation
struct ReframeResultView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let reframe: Reframe
    let viewModel: ReframeViewModel
    let onDismiss: () -> Void
    
    @State private var animateIn = false
    @State private var showConfetti = false
    @State private var isMarkedAsHelpful = false
    
    var isPositive: Bool {
        reframe.category == "Positive Reflection"
    }
    
    var isReflection: Bool {
        reframe.category == "Reflection"
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 14) {
                // Header
                HStack {
                    Text(isReflection ? "Your Reflection" : "Your Reframe")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.colors.text)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                }
                .padding(.top, 8)
                
                // Confetti overlay
                if isPositive {
                    IOSConfettiView(trigger: showConfetti, colors: [themeManager.colors.primary, .yellow, .red, .blue, .green, .purple], count: 150)
                        .frame(maxWidth: .infinity, maxHeight: 0)
                }
                
                if isReflection {
                    // Reflection View
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Reflection")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(themeManager.colors.secondary)
                        Text(reframe.originalThought)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(themeManager.colors.text)
                            .padding(12)
                            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeManager.colors.secondary.opacity(0.07))
                                    .shadow(color: themeManager.colors.secondary.opacity(0.08), radius: 6, x: 0, y: 2)
                            )
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 15)
                    .animation(.easeOut(duration: 0.35).delay(0.13), value: animateIn)
                } else {
                    // Original Thought
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Original Thought")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(themeManager.colors.textLight)
                        Text(reframe.originalThought)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(themeManager.colors.text)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(themeManager.colors.surface)
                            )
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 10)
                    .animation(.easeOut(duration: 0.3).delay(0.08), value: animateIn)
                    
                    // Reframed Thought
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reframe")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(themeManager.colors.primary)
                        Text(reframe.reframedThought)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(themeManager.colors.text)
                            .padding(12)
                            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeManager.colors.primary.opacity(0.07))
                                    .shadow(color: themeManager.colors.primary.opacity(0.08), radius: 6, x: 0, y: 2)
                            )
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 15)
                    .animation(.easeOut(duration: 0.35).delay(0.13), value: animateIn)
                }
                
                // Soft nudge for positive reflections
                if reframe.category == "Positive Reflection" {
                    VStack(spacing: 4) {
                        Text("This is a positive thought! ✨")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(themeManager.colors.primary)
                        Text("You can save your daily reframe limit by using the Reflect tab instead – it's perfect for capturing and celebrating these moments.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(themeManager.colors.textLight)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 2)
                    .opacity(animateIn ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(0.18), value: animateIn)
                }
                
                // Friendly message for nonsense inputs
                if reframe.category == "Nonsense" {
                    VStack(spacing: 4) {
                        Text("Hmm...")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(themeManager.colors.textLight)
                        Text("I'm not quite sure how to reflect on that. Try sharing something that's been on your mind, or use the Reflect tab for positive moments!")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(themeManager.colors.textLight)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 2)
                    .opacity(animateIn ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(0.18), value: animateIn)
                }
                
                // Action Buttons
                VStack(spacing: 10) {
                    if !isReflection {
                        Button {
                            Task {
                                await viewModel.markAsHelpful()
                                isMarkedAsHelpful = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: isMarkedAsHelpful ? "checkmark.circle.fill" : "heart.fill")
                                Text(isMarkedAsHelpful ? "Marked as Helpful" : "That Helped")
                            }
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        isMarkedAsHelpful ? themeManager.colors.secondary : themeManager.colors.primary,
                                        isMarkedAsHelpful ? Color(hex: "7B4B8E") : themeManager.colors.primaryDark
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                            .shadow(color: (isMarkedAsHelpful ? themeManager.colors.secondary : themeManager.colors.primary).opacity(0.13), radius: 5, x: 0, y: 2)
                        }
                        .disabled(isMarkedAsHelpful)
                        
                        Button {
                            Task {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.isCurrentReframeLogged = true
                                }
                                await viewModel.logToJournal()
                            }
                        } label: {
                            HStack {
                                Image(systemName: viewModel.isCurrentReframeLogged ? "checkmark.circle.fill" : "book.fill")
                                Text(viewModel.isCurrentReframeLogged ? "Saved to Journal" : "Add to Journal")
                            }
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(viewModel.isCurrentReframeLogged ? themeManager.colors.textLight : themeManager.colors.text)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(viewModel.isCurrentReframeLogged ? themeManager.colors.surface.opacity(0.5) : themeManager.colors.surface)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                        }
                        .disabled(viewModel.isCurrentReframeLogged)
                    }
                    
                    Button {
                        onDismiss()
                    } label: {
                        HStack {
                            Image(systemName: isReflection ? "plus" : "arrow.triangle.2.circlepath")
                            Text(isReflection ? "Add Another" : "Try Another")
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(themeManager.colors.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(themeManager.colors.surface)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                    }
                }
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 10)
                .animation(.easeOut(duration: 0.3).delay(0.22), value: animateIn)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 22)
            .frame(width: 360)
            .frame(minHeight: 420)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(themeManager.colors.background)
                    .shadow(color: Color.black.opacity(0.18), radius: 24, x: 0, y: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(isReflection ? themeManager.colors.secondary.opacity(0.10) : themeManager.colors.primary.opacity(0.10), lineWidth: 1)
                    )
            )
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            withAnimation {
                animateIn = true
            }
            if isPositive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    showConfetti = true
                }
            }
        }
    }
}

#Preview {
    ReframeResultView(
        reframe: Reframe(
            id: "1",
            userId: "preview",
            originalThought: "I'm feeling anxious about my presentation tomorrow.",
            reframedThought: "I'm prepared and ready to share my knowledge with others.",
            timestamp: Date(),
            category: "Reflection",
            helped: false
        ),
        viewModel: ReframeViewModel(),
        onDismiss: {}
    )
    .environmentObject(ThemeManager())
} 