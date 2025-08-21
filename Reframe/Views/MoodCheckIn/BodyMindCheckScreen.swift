import SwiftUI

struct BodyMindCheckScreen: View {
    @ObservedObject var coordinator: MoodCheckInCoordinator
    @EnvironmentObject var themeManager: ThemeManager
    
    private func energyIcon(for level: BodyMindCheck.EnergyLevel) -> String {
        switch level {
        case .low: return "battery.25"
        case .medium: return "battery.50"
        case .high: return "battery.100"
        }
    }
    
    private func sleepIcon(for quality: BodyMindCheck.SleepQuality) -> String {
        switch quality {
        case .poor: return "bed.double"
        case .okay: return "bed.double.fill"
        case .restful: return "moon.stars.fill"
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            themeManager.customBackground()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: {
                        coordinator.previous()
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    
                    Spacer()
                    
                    Text("4 of 6")
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundColor(themeManager.colors.textLight)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(themeManager.colors.surface.opacity(0.8))
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // Main Content
                VStack(spacing: 24) {
                    // Title
                    VStack(spacing: 12) {
                        Text("How's your body feeling?")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(themeManager.colors.text)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .lineLimit(nil)
                        
                        Text("Connect your mental and physical health")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    
                    // Energy Level
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.colors.primary)
                            
                            Text("Energy Level")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(themeManager.colors.text)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            ForEach(BodyMindCheck.EnergyLevel.allCases, id: \.self) { level in
                                Button(action: {
                                    coordinator.bodyMindCheck.energyLevel = level
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: energyIcon(for: level))
                                            .font(.system(size: 20))
                                            .foregroundColor(coordinator.bodyMindCheck.energyLevel == level ? .white : themeManager.colors.text)
                                        
                                        Text(level.displayName)
                                            .font(.system(size: 14, weight: .medium, design: .default))
                                            .foregroundColor(coordinator.bodyMindCheck.energyLevel == level ? .white : themeManager.colors.text)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                coordinator.bodyMindCheck.energyLevel == level ?
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        themeManager.colors.primary,
                                                        themeManager.colors.primaryDark
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ) :
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        themeManager.colors.surface,
                                                        themeManager.colors.surface.opacity(0.8)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                coordinator.bodyMindCheck.energyLevel == level ? Color.clear : themeManager.colors.border,
                                                lineWidth: 1
                                            )
                                    )
                                    .shadow(
                                        color: coordinator.bodyMindCheck.energyLevel == level ? 
                                            themeManager.colors.primary.opacity(0.3) : 
                                            Color.black.opacity(0.05),
                                        radius: coordinator.bodyMindCheck.energyLevel == level ? 8 : 4,
                                        x: 0,
                                        y: coordinator.bodyMindCheck.energyLevel == level ? 4 : 2
                                    )
                                    .scaleEffect(coordinator.bodyMindCheck.energyLevel == level ? 1.02 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: coordinator.bodyMindCheck.energyLevel)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Sleep Quality
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "bed.double.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.colors.primary)
                            
                            Text("Sleep Quality")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(themeManager.colors.text)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            ForEach(BodyMindCheck.SleepQuality.allCases, id: \.self) { quality in
                                Button(action: {
                                    coordinator.bodyMindCheck.sleepQuality = quality
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: sleepIcon(for: quality))
                                            .font(.system(size: 20))
                                            .foregroundColor(coordinator.bodyMindCheck.sleepQuality == quality ? .white : themeManager.colors.text)
                                        
                                        Text(quality.displayName)
                                            .font(.system(size: 14, weight: .medium, design: .default))
                                            .foregroundColor(coordinator.bodyMindCheck.sleepQuality == quality ? .white : themeManager.colors.text)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                coordinator.bodyMindCheck.sleepQuality == quality ?
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        themeManager.colors.primary,
                                                        themeManager.colors.primaryDark
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ) :
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        themeManager.colors.surface,
                                                        themeManager.colors.surface.opacity(0.8)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                coordinator.bodyMindCheck.sleepQuality == quality ? Color.clear : themeManager.colors.border,
                                                lineWidth: 1
                                            )
                                    )
                                    .shadow(
                                        color: coordinator.bodyMindCheck.sleepQuality == quality ? 
                                            themeManager.colors.primary.opacity(0.3) : 
                                            Color.black.opacity(0.05),
                                        radius: coordinator.bodyMindCheck.sleepQuality == quality ? 8 : 4,
                                        x: 0,
                                        y: coordinator.bodyMindCheck.sleepQuality == quality ? 4 : 2
                                    )
                                    .scaleEffect(coordinator.bodyMindCheck.sleepQuality == quality ? 1.02 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: coordinator.bodyMindCheck.sleepQuality)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Stress Level Slider
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.colors.primary)
                            
                            Text("Stress Level")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(themeManager.colors.text)
                            
                            Spacer()
                            
                            Text("\(Int(coordinator.bodyMindCheck.stressLevel * 100))%")
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundColor(themeManager.colors.textLight)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            // Slider Labels
                            HStack {
                                VStack(spacing: 6) {
                                    Text("😌")
                                        .font(.system(size: 16))
                                    Text("Calm")
                                        .font(.system(size: 12, weight: .medium, design: .default))
                                        .foregroundColor(themeManager.colors.textLight)
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 6) {
                                    Text("😰")
                                        .font(.system(size: 16))
                                    Text("Overwhelmed")
                                        .font(.system(size: 12, weight: .medium, design: .default))
                                        .foregroundColor(themeManager.colors.textLight)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Custom Slider
                            ZStack {
                                // Track
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "4CAF50"), // Green for calm
                                                Color(hex: "FFC107"), // Amber for medium
                                                Color(hex: "F44336")  // Red for overwhelmed
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 8)
                                    .padding(.horizontal, 20)
                                
                                // Thumb
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    .offset(x: (coordinator.bodyMindCheck.stressLevel - 0.5) * (UIScreen.main.bounds.width - 40))
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newValue = (value.location.x + (UIScreen.main.bounds.width - 40) / 2) / (UIScreen.main.bounds.width - 40)
                                                coordinator.bodyMindCheck.stressLevel = max(0, min(1, newValue))
                                            }
                                    )
                            }
                        }
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
    }
}

#Preview {
    BodyMindCheckScreen(coordinator: MoodCheckInCoordinator())
        .environmentObject(ThemeManager())
}
