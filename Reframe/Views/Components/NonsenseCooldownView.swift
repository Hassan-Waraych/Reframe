import SwiftUI

struct NonsenseCooldownView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let cooldownEndDate: Date
    let onDismiss: () -> Void
    
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Take a Break")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.colors.text)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                }
                
                // Message
                VStack(spacing: 12) {
                    Text("You've reached the limit for unclear thoughts")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(themeManager.colors.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Please try again tomorrow with more specific thoughts. This helps us provide better reframes!")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(themeManager.colors.textLight)
                        .multilineTextAlignment(.center)
                }
                
                // Timer
                VStack(spacing: 8) {
                    Text("Time Remaining")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(themeManager.colors.textLight)
                    
                    Text(formatTimeRemaining(timeRemaining))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.colors.primary)
                }
                .padding(.vertical, 8)
                
                // Dismiss Button
                Button(action: onDismiss) {
                    Text("Got it")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
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
                }
            }
            .padding(24)
            .frame(width: 320)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(themeManager.colors.background)
                    .shadow(color: Color.black.opacity(0.18), radius: 24, x: 0, y: 10)
            )
        }
        .onAppear {
            updateTimeRemaining()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        timeRemaining = max(0, cooldownEndDate.timeIntervalSince(Date()))
        if timeRemaining <= 0 {
            timer?.invalidate()
            onDismiss()
        }
    }
    
    private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    NonsenseCooldownView(
        cooldownEndDate: Date().addingTimeInterval(3600),
        onDismiss: {}
    )
    .environmentObject(ThemeManager())
} 