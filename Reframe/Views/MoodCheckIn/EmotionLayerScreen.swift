import SwiftUI

struct EmotionLayerScreen: View {
    @ObservedObject var coordinator: MoodCheckInCoordinator
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var emotionPositions: [(x: CGFloat, y: CGFloat)] = []
    
    private func getEmotionPosition(index: Int, total: Int) -> (x: CGFloat, y: CGFloat) {
        if emotionPositions.indices.contains(index) {
            return emotionPositions[index]
        }
        
        // Use a strict grid layout to prevent overlapping
        let containerWidth: CGFloat = 360 // Match the container width
        let containerHeight: CGFloat = 480 // Use full height
        
        // 3 columns with proper spacing
        let columns = 3
        let rows = (total + columns - 1) / columns
        
        let row = index / columns
        let col = index % columns
        
        // Fixed spacing - no randomness to prevent overlap
        let spacingX: CGFloat = 120 // Adjusted for better centering
        let spacingY: CGFloat = 85 // Reduced vertical spacing
        
        // Calculate exact grid positions - pushed down and centered
        let x = CGFloat(col) * spacingX - (CGFloat(columns - 1) * spacingX) / 2
        let y = CGFloat(row) * spacingY - (CGFloat(rows - 1) * spacingY) / 2 + 60 // Push down by 60px
        
        return (x: x, y: y)
    }
    
    @State private var floatingOffsets: [CGFloat] = []
    
    private func getFloatingOffset(for index: Int) -> CGFloat {
        if floatingOffsets.indices.contains(index) {
            return floatingOffsets[index]
        }
        return 0
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
                    
                    Text("2 of 6")
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
                        Text("What emotions are you feeling?")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(themeManager.colors.text)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .lineLimit(nil)
                        
                        Text("Select all that apply")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    
                                                // Emotion Selection
                            VStack(spacing: 20) {
                                // Predefined Emotions
                                VStack(alignment: .leading, spacing: 12) {
                            
                            // Floating cloud layout for emotions
                            ZStack {
                                // Center the entire grid
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        ZStack {
                                            ForEach(MoodCheckInData.predefinedEmotions.indices, id: \.self) { index in
                                    let emotion = MoodCheckInData.predefinedEmotions[index]
                                    let isSelected = coordinator.selectedEmotions.contains { $0.name == emotion.name }
                                    let position = getEmotionPosition(index: index, total: MoodCheckInData.predefinedEmotions.count)
                                    
                                    Button(action: {
                                        if isSelected {
                                            coordinator.selectedEmotions.removeAll { $0.name == emotion.name }
                                        } else {
                                            var updatedEmotion = emotion
                                            updatedEmotion.isSelected = true
                                            coordinator.selectedEmotions.append(updatedEmotion)
                                        }
                                    }) {
                                        Text(emotion.name)
                                            .font(.system(size: 14, weight: .medium, design: .default))
                                            .foregroundColor(isSelected ? .white : themeManager.colors.text)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(
                                                        isSelected ?
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
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(
                                                        isSelected ? Color.clear : themeManager.colors.border,
                                                        lineWidth: 1
                                                    )
                                            )
                                            .shadow(
                                                color: isSelected ?
                                                    themeManager.colors.primary.opacity(0.3) :
                                                    Color.black.opacity(0.05),
                                                radius: isSelected ? 8 : 4,
                                                x: 0,
                                                y: isSelected ? 4 : 2
                                            )
                                            .scaleEffect(isSelected ? 1.05 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .offset(x: position.x, y: position.y + getFloatingOffset(for: index))
                                    .animation(.easeInOut(duration: 2.0 + Double(index % 3) * 0.5).repeatForever(autoreverses: true), value: getFloatingOffset(for: index))
                                            }
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                            .frame(height: 420)
                            .padding(.horizontal, 20)
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
        .onAppear {
            // Initialize positions once to prevent glitching
            if emotionPositions.isEmpty {
                emotionPositions = (0..<MoodCheckInData.predefinedEmotions.count).map { index in
                    getEmotionPosition(index: index, total: MoodCheckInData.predefinedEmotions.count)
                }
            }
            
            // Initialize floating offsets for bubble effect
            floatingOffsets = Array(repeating: 0, count: MoodCheckInData.predefinedEmotions.count)
            
            // Start floating animations with different patterns
            for i in 0..<MoodCheckInData.predefinedEmotions.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    floatingOffsets[i] = CGFloat.random(in: -10...10)
                }
            }
        }
    }
}

#Preview {
    EmotionLayerScreen(coordinator: MoodCheckInCoordinator())
        .environmentObject(ThemeManager())
}
