import SwiftUI

struct MoodSpectrumScreen: View {
    @ObservedObject var coordinator: MoodCheckInCoordinator
    @EnvironmentObject var themeManager: ThemeManager
    @State private var sliderValue: Double = 0.5 // 0.0 = terrible, 1.0 = great
    
    private var currentMood: MoodType {
        if sliderValue <= 0.2 {
            return .terrible
        } else if sliderValue <= 0.4 {
            return .bad
        } else if sliderValue <= 0.6 {
            return .okay
        } else if sliderValue <= 0.8 {
            return .good
        } else {
            return .great
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            themeManager.customBackground()
            
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Button(action: {
                            coordinator.cancelCheckIn()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(themeManager.colors.textLight)
                        }
                        
                        Spacer()
                        
                        Text("1 of 6")
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(themeManager.colors.textLight)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeManager.colors.surface.opacity(0.8))
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                
                // Main Content
                VStack(spacing: 32) {
                    // Title and Emoji
                    VStack(spacing: 20) {
                        Text("How are you feeling right now?")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(themeManager.colors.text)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .lineLimit(nil)
                        
                        // Large Emoji Display
                        Text(currentMood.emoji)
                            .font(.system(size: 100))
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentMood)
                    }
                    
                    // Mood Spectrum Slider
                    VStack(spacing: 20) {
                        // Slider Labels
                        HStack {
                            VStack(spacing: 6) {
                                Text("😢")
                                    .font(.system(size: 20))
                                Text("Terrible")
                                    .font(.system(size: 12, weight: .medium, design: .default))
                                    .foregroundColor(themeManager.colors.textLight)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 6) {
                                Text("😊")
                                    .font(.system(size: 20))
                                Text("Great")
                                    .font(.system(size: 12, weight: .medium, design: .default))
                                    .foregroundColor(themeManager.colors.textLight)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Custom Slider
                        ZStack {
                            // Track
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "F44336"), // Red for terrible
                                            Color(hex: "FF9800"), // Orange for bad
                                            Color(hex: "FFC107"), // Amber for okay
                                            Color(hex: "8BC34A"), // Light green for good
                                            Color(hex: "4CAF50")  // Green for great
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 12)
                                .padding(.horizontal, 24)
                            
                            // Thumb
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                .offset(x: (sliderValue - 0.5) * (UIScreen.main.bounds.width - 64))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let newValue = (value.location.x + (UIScreen.main.bounds.width - 64) / 2) / (UIScreen.main.bounds.width - 64)
                                            sliderValue = max(0, min(1, newValue))
                                            coordinator.selectedMood = currentMood
                                        }
                                )
                        }
                        
                        // Current Mood Label
                        Text(currentMood.displayName)
                            .font(.system(size: 20, weight: .semibold, design: .default))
                            .foregroundColor(themeManager.colors.text)
                            .padding(.top, 12)
                    }
                    
                    Spacer()
                }
                
                // Bottom Button
                VStack(spacing: 16) {
                    Button(action: {
                        coordinator.selectedMood = currentMood
                        coordinator.next()
                    }) {
                        HStack {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold, design: .default))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
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
                        .cornerRadius(16)
                        .shadow(color: themeManager.colors.primary.opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal, 32)
                    
                    Text("Slide to adjust your mood")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(themeManager.colors.textLight)
                }
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            // Set initial mood
            coordinator.selectedMood = currentMood
        }
    }
}

#Preview {
    MoodSpectrumScreen(coordinator: MoodCheckInCoordinator())
        .environmentObject(ThemeManager())
}
