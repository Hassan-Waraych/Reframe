import SwiftUI

struct VisualizationScreen: View {
    @ObservedObject var coordinator: MoodCheckInCoordinator
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showMoodSummary = false
    @State private var showEmotionsSummary = false
    @State private var showStreakInfo = false
    
    var body: some View {
        ZStack {
            // Background
            themeManager.customBackground()
            
            VStack(spacing: 24) {
                                                                // Header
                        HStack {
                            // No back button on page 5 to prevent data issues
                            Spacer()
                            
                            Text("5 of 6")
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(themeManager.colors.textLight)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(themeManager.colors.surface.opacity(0.8))
                                )
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                
                // Main Content
                VStack(spacing: 24) {
                    // Title
                    VStack(spacing: 12) {
                        Text("Your Mood Summary")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(themeManager.colors.text)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .lineLimit(nil)
                        
                        Text("See your patterns and insights")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    
                    // Mood Summary Card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.colors.primary)
                            
                            Text("Today's Mood")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(themeManager.colors.text)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            // Main Mood Display
                            HStack {
                                Text(coordinator.selectedMood.emoji)
                                    .font(.system(size: 48))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(coordinator.selectedMood.displayName)
                                        .font(.system(size: 20, weight: .bold, design: .default))
                                        .foregroundColor(themeManager.colors.text)
                                    
                                    Text("How you're feeling")
                                        .font(.system(size: 14, weight: .regular, design: .default))
                                        .foregroundColor(themeManager.colors.textLight)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: coordinator.selectedMood.color).opacity(0.1),
                                                Color(hex: coordinator.selectedMood.color).opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: coordinator.selectedMood.color).opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                        }
                        .opacity(showMoodSummary ? 1.0 : 0.0)
                        .offset(y: showMoodSummary ? 0 : 30)
                        .scaleEffect(showMoodSummary ? 1.0 : 0.9)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showMoodSummary)
                    }
                    
                    // Emotions Summary
                    if !coordinator.selectedEmotions.isEmpty {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.colors.primary)
                                
                                Text("Your Emotions")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(themeManager.colors.text)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(coordinator.selectedEmotions, id: \.id) { emotion in
                                        Text(emotion.name)
                                            .font(.system(size: 14, weight: .medium, design: .default))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
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
                                            )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .opacity(showEmotionsSummary ? 1.0 : 0.0)
                            .offset(y: showEmotionsSummary ? 0 : 30)
                            .scaleEffect(showEmotionsSummary ? 1.0 : 0.9)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: showEmotionsSummary)
                        }
                    }
                    
                    // Streak Information
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.colors.primary)
                            
                            Text("Your Streak")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(themeManager.colors.text)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        HStack {
                            VStack(spacing: 8) {
                                Text("🔥")
                                    .font(.system(size: 32))
                                
                                Text("3 Days")
                                    .font(.system(size: 18, weight: .bold, design: .default))
                                    .foregroundColor(themeManager.colors.text)
                                
                                Text("Mood Check-in Streak")
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .foregroundColor(themeManager.colors.textLight)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.orange.opacity(0.1),
                                                Color.orange.opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                            
                            VStack(spacing: 8) {
                                Text("📊")
                                    .font(.system(size: 32))
                                
                                Text("7")
                                    .font(.system(size: 18, weight: .bold, design: .default))
                                    .foregroundColor(themeManager.colors.text)
                                
                                Text("Total Check-ins")
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .foregroundColor(themeManager.colors.textLight)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                themeManager.colors.primary.opacity(0.1),
                                                themeManager.colors.primary.opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.colors.primary.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        .opacity(showStreakInfo ? 1.0 : 0.0)
                        .offset(y: showStreakInfo ? 0 : 30)
                        .scaleEffect(showStreakInfo ? 1.0 : 0.9)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: showStreakInfo)
                    }
                    
                    Spacer()
                }
                
                // Bottom Button
                VStack(spacing: 16) {
                    Button(action: {
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
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            // Trigger animations in sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showMoodSummary = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showEmotionsSummary = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                showStreakInfo = true
            }
        }
    }
}

#Preview {
    VisualizationScreen(coordinator: MoodCheckInCoordinator())
        .environmentObject(ThemeManager())
}
