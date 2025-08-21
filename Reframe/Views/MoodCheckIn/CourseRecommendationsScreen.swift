import SwiftUI

struct CourseRecommendationsScreen: View {
    @ObservedObject var coordinator: MoodCheckInCoordinator
    @EnvironmentObject var themeManager: ThemeManager
    
    private func getRecommendedCourses() -> [Course] {
        // Simple recommendation logic based on mood and emotions
        var recommendations: [Course] = []
        
        // Add stress-related courses if user selected negative emotions
        let negativeEmotions = coordinator.selectedEmotions.filter { $0.category == .negative }
        if !negativeEmotions.isEmpty || coordinator.selectedMood == .bad || coordinator.selectedMood == .terrible {
            recommendations.append(contentsOf: stressCourses.prefix(2))
        }
        
        // Add relationship courses if user selected relationship context
        let relationshipContext = coordinator.contextTags.contains { $0.name == "Relationships" }
        if relationshipContext {
            recommendations.append(contentsOf: relationshipCourses.prefix(2))
        }
        
        // Add general wellness courses
        recommendations.append(contentsOf: wellnessCourses.prefix(2))
        
        // Remove duplicates and limit to 4 courses
        return Array(Set(recommendations)).prefix(4).map { $0 }
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
                    
                    Text("6 of 6")
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
                        Text("Recommended for You")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(themeManager.colors.text)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .lineLimit(nil)
                        
                        Text("Based on your mood check-in")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    
                    // Course Recommendations
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "book.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.colors.primary)
                            
                            Text("Personalized Courses")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(themeManager.colors.text)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(getRecommendedCourses(), id: \.id) { course in
                                    CourseRecommendationCard(course: course)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Completion Message
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.green)
                            
                            Text("Check-in Complete!")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(themeManager.colors.text)
                        }
                        
                        Text("Great job taking time to reflect on your mood. Keep up the daily check-ins to build healthy habits!")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(themeManager.colors.textLight)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.green.opacity(0.1),
                                        Color.green.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                
                // Bottom Button
                VStack(spacing: 16) {
                    Button(action: {
                        coordinator.next()
                    }) {
                        HStack {
                            Text("Complete Check-in")
                                .font(.system(size: 18, weight: .semibold, design: .default))
                            
                            Image(systemName: "checkmark")
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

struct CourseRecommendationCard: View {
    let course: Course
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Course Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [themeManager.colors.primary.opacity(0.8), themeManager.colors.primaryDark.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 80)
                
                Image(systemName: course.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Course Info
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(themeManager.colors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(course.duration)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(themeManager.colors.textLight)
            }
        }
        .frame(width: 140)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.colors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    CourseRecommendationsScreen(coordinator: MoodCheckInCoordinator())
        .environmentObject(ThemeManager())
}
