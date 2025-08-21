import SwiftUI

struct ContextTriggersScreen: View {
    @ObservedObject var coordinator: MoodCheckInCoordinator
    @EnvironmentObject var themeManager: ThemeManager
    @FocusState private var isNotesFocused: Bool
    
    @State private var contextPositions: [(x: CGFloat, y: CGFloat)] = []
    
    private func getContextPosition(index: Int, total: Int) -> (x: CGFloat, y: CGFloat) {
        if contextPositions.indices.contains(index) {
            return contextPositions[index]
        }
        
        // Use a strict grid layout to prevent overlapping
        let containerWidth: CGFloat = 340
        let containerHeight: CGFloat = 360
        
        // 2 columns with proper spacing - no same line
        let columns = 2
        let rows = (total + columns - 1) / columns
        
        let row = index / columns
        let col = index % columns
        
        // Fixed spacing - no randomness to prevent overlap
        let spacingX: CGFloat = 150
        let spacingY: CGFloat = 90 // Reduced vertical spacing
        
        // Calculate exact grid positions - pushed down
        let x = CGFloat(col) * spacingX - (CGFloat(columns - 1) * spacingX) / 2
        let y = CGFloat(row) * spacingY - (CGFloat(rows - 1) * spacingY) / 2 + 35 // Push down by 35px
        
        return (x: x, y: y)
    }
    
    @State private var contextFloatingOffsets: [CGFloat] = []
    
    private func getContextFloatingOffset(for index: Int) -> CGFloat {
        if contextFloatingOffsets.indices.contains(index) {
            return contextFloatingOffsets[index]
        }
        return 0
    }
    
    var body: some View {
        ZStack {
            // Background
            themeManager.customBackground()
            
            // Tap to dismiss keyboard
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isNotesFocused = false
                }
            
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
                    
                    Text("3 of 6")
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
                        Text("What's affecting your mood?")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(themeManager.colors.text)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .lineLimit(nil)
                        
                        Text("Select categories and add notes")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    
                    // Context Categories
                    VStack(spacing: 16) {
                        

                    
                        // Floating cloud layout for context categories
                        ZStack {
                            ForEach(MoodCheckInData.contextCategories.indices, id: \.self) { index in
                                let context = MoodCheckInData.contextCategories[index]
                                let isSelected = coordinator.contextTags.contains { $0.name == context.name }
                                let position = getContextPosition(index: index, total: MoodCheckInData.contextCategories.count)
                                
                                Button(action: {
                                    if isSelected {
                                        coordinator.contextTags.removeAll { $0.name == context.name }
                                    } else {
                                        var updatedContext = context
                                        updatedContext.isSelected = true
                                        coordinator.contextTags.append(updatedContext)
                                    }
                                }) {
                                    Text(context.name)
                                        .font(.system(size: 15, weight: .medium, design: .default))
                                        .foregroundColor(isSelected ? .white : themeManager.colors.text)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
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
                                            RoundedRectangle(cornerRadius: 18)
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
                                .offset(x: position.x, y: position.y + getContextFloatingOffset(for: index))
                                .animation(.easeInOut(duration: 2.5 + Double(index % 4) * 0.3).repeatForever(autoreverses: true), value: getContextFloatingOffset(for: index))
                            }
                        }
                            .frame(height: 320)
                        .padding(.horizontal, 20)
                    }
                    
                    // Notes Section - pushed down
                    VStack(spacing: 12) {
                        Spacer(minLength: 20) // Add extra space above notes
                        HStack {
                            Image(systemName: "note.text")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.colors.primary)
                            
                            Text("Additional Notes")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(themeManager.colors.text)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        TextField("Optional: Add more details...", text: $coordinator.contextNotes, axis: .vertical)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(themeManager.colors.text)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeManager.colors.surface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.colors.border, lineWidth: 1)
                            )
                            .lineLimit(3...6)
                            .focused($isNotesFocused)
                            .padding(.horizontal, 20)
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
            if contextPositions.isEmpty {
                contextPositions = (0..<MoodCheckInData.contextCategories.count).map { index in
                    getContextPosition(index: index, total: MoodCheckInData.contextCategories.count)
                }
            }
            
            // Initialize floating offsets for bubble effect
            contextFloatingOffsets = Array(repeating: 0, count: MoodCheckInData.contextCategories.count)
            
            // Start floating animations with different patterns
            for i in 0..<MoodCheckInData.contextCategories.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                    contextFloatingOffsets[i] = CGFloat.random(in: -8...8)
                }
            }
        }
    }
}

#Preview {
    ContextTriggersScreen(coordinator: MoodCheckInCoordinator())
        .environmentObject(ThemeManager())
}
