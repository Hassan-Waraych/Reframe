import SwiftUI

struct MilestoneNotificationView: View {
    let milestone: Milestone
    @Binding var isPresented: Bool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var slideOffset: CGFloat = -300
    @State private var opacity: Double = 0
    @State private var backgroundOpacity: Double = 0
    
    var body: some View {
        if isPresented {
            ZStack {
                // Background overlay for better contrast
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .opacity(backgroundOpacity)
                
                VStack {
                    // Main notification card
                    HStack(spacing: 16) {
                        // Icon with gradient background
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            milestone.category.color.opacity(0.8),
                                            milestone.category.color.opacity(0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .shadow(color: milestone.category.color.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: milestone.icon)
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("🎉 Milestone Unlocked!")
                                    .font(.custom("Quicksand-Bold", size: 13))
                                    .foregroundColor(milestone.category.color)
                                
                                Spacer()
                                
                                // Close button
                                Button(action: {
                                    dismissNotification()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(themeManager.colors.textLight)
                                }
                            }
                            
                            Text(milestone.title)
                                .font(.custom("Quicksand-SemiBold", size: 17))
                                .foregroundColor(themeManager.colors.text)
                                .lineLimit(1)
                            
                            Text(milestone.subtitle)
                                .font(.custom("Nunito-Regular", size: 13))
                                .foregroundColor(themeManager.colors.textLight)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(themeManager.colors.surface)
                            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 60) // Account for status bar
                    .offset(y: slideOffset)
                    .opacity(opacity)
                    
                    Spacer()
                }
            }
            .zIndex(9999) // Ensure this appears above all other content
            .onAppear {
                showNotification()
            }
        }
    }
    
    private func showNotification() {
        // Start with notification off-screen
        slideOffset = -300
        opacity = 0
        backgroundOpacity = 0
        
        // Animate in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            slideOffset = 0
            opacity = 1
            backgroundOpacity = 1
        }
        
        // Auto-dismiss after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            dismissNotification()
        }
    }
    
    private func dismissNotification() {
        // Animate out
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            slideOffset = -300
            opacity = 0
            backgroundOpacity = 0
        }
        
        // Wait for animation to complete before hiding
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPresented = false
        }
    }
}

#Preview {
    MilestoneNotificationView(
        milestone: Milestone(
            id: "test",
            title: "First Reframe",
            subtitle: "You've taken your first step towards positive thinking!",
            icon: "sparkles",
            category: .beginner,
            isCompleted: true,
            dateCompleted: Date()
        ),
        isPresented: .constant(true)
    )
    .environmentObject(ThemeManager())
} 