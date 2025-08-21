import SwiftUI

struct CoursesScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authService: AuthService
    @State private var searchText = ""
    @State private var showPaywall = false
    @State private var showCourseViewer = false
    @State private var selectedCourse: Course?
    
    var filteredCategories: [CourseCategory] {
        if searchText.isEmpty {
            return allCategories
        } else {
            return allCategories.compactMap { category in
                let filteredCourses = category.courses.filter { course in
                    course.title.localizedCaseInsensitiveContains(searchText)
                }
                if filteredCourses.isEmpty {
                    return nil
                } else {
                    return CourseCategory(
                        title: category.title,
                        courses: filteredCourses,
                        color: category.color,
                        isPremium: category.isPremium
                    )
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(themeManager.colors.textLight)
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("Search courses...", text: $searchText)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(themeManager.colors.text)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(themeManager.colors.surface)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    
                           
                           // Course Categories
                           LazyVStack(spacing: 32) {
                               ForEach(filteredCategories, id: \.title) { category in
                                   CourseCategoryView(
                                       title: category.title,
                                       courses: category.courses,
                                       categoryColor: category.color,
                                       isPremium: category.isPremium,
                                                                          onCourseSelected: { course in
                                       print("Main screen received course: \(course.title)")
                                       selectedCourse = course
                                       showCourseViewer = true
                                   }
                                   )
                               }
                           }
                }
                .padding(.vertical, 24)
            }
            .background(themeManager.colors.background)
            .navigationTitle("Courses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(themeManager.colors.text.opacity(0.7))
                            .font(.system(size: 24))
                    }
                }
            }
            .preferredColorScheme(themeManager.selectedTheme == .dark || themeManager.selectedTheme == .midnightGold ? .dark : .light)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PremiumModalScreen()
        }
        .sheet(isPresented: $showCourseViewer) {
            if let course = selectedCourse {
                CourseViewerScreen(course: course)
            }
        }
    }
}

struct CourseCategoryView: View {
    let title: String
    let courses: [Course]
    let categoryColor: Color
    let isPremium: Bool
    let onCourseSelected: (Course) -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authService: AuthService
    @State private var showPaywall = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category Title
            HStack {
                Text(title)
                    .font(.system(size: 22, weight: .semibold, design: .default))
                    .foregroundColor(themeManager.colors.text)
                
                Spacer()
                
                if isPremium && !authService.isPremiumUser() {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal)
            
            // Course Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(courses) { course in
                        CourseCard(
                            course: course,
                            categoryColor: categoryColor,
                            isPremium: isPremium
                        ) {
                            if isPremium && !authService.isPremiumUser() {
                                showPaywall = true
                            } else {
                                // Launch course viewer
                                print("Course selected: \(course.title)")
                                onCourseSelected(course)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PremiumModalScreen()
        }
    }
}

struct CourseCard: View {
    let course: Course
    let categoryColor: Color
    let isPremium: Bool
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Course Image
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [categoryColor.opacity(0.8), categoryColor.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 160, height: 100)
                    
                    Image(systemName: course.icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                    
                    // Lock icon for premium courses
                    if isPremium && !authService.isPremiumUser() {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        .frame(width: 160, height: 100)
                    }
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
            .frame(width: 160)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Data Models

struct Course: Identifiable, Hashable {
    let id: String
    let title: String
    let duration: String
    let icon: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CourseCategory {
    let title: String
    let courses: [Course]
    let color: Color
    let isPremium: Bool
}

// MARK: - Sample Data

let stressCourses: [Course] = [
    Course(id: "understanding_stress", title: "Understanding Stress", duration: "3 min", icon: "brain.head.profile"),
    Course(id: "stress_response", title: "Stress Response", duration: "2 min", icon: "heart.fill"),
    Course(id: "managing_anxiety", title: "Managing Anxiety", duration: "4 min", icon: "lungs.fill"),
    Course(id: "calm_your_mind", title: "Calm Your Mind", duration: "3 min", icon: "leaf.fill"),
    Course(id: "stress_relief", title: "Stress Relief", duration: "2 min", icon: "wind")
]

let relationshipCourses: [Course] = [
    Course(id: "healthy_boundaries", title: "Healthy Boundaries", duration: "4 min", icon: "person.2.fill"),
    Course(id: "communication_skills", title: "Communication Skills", duration: "3 min", icon: "bubble.left.and.bubble.right.fill"),
    Course(id: "conflict_resolution", title: "Conflict Resolution", duration: "5 min", icon: "hand.raised.fill"),
    Course(id: "building_trust", title: "Building Trust", duration: "3 min", icon: "heart.circle.fill"),
    Course(id: "emotional_support", title: "Emotional Support", duration: "2 min", icon: "person.fill.checkmark")
]

let cognitiveCourses: [Course] = [
    Course(id: "cognitive_distortions", title: "Cognitive Distortions", duration: "4 min", icon: "brain"),
    Course(id: "all_or_nothing_thinking", title: "All-or-Nothing Thinking", duration: "3 min", icon: "arrow.left.and.right"),
    Course(id: "challenging_thoughts", title: "Challenging Your Thoughts", duration: "5 min", icon: "lightbulb.fill"),
    Course(id: "mental_filters", title: "Mental Filters", duration: "3 min", icon: "camera.filters"),
    Course(id: "overgeneralization", title: "Overgeneralization", duration: "2 min", icon: "arrow.triangle.branch")
]

let mindfulnessCourses: [Course] = [
    Course(id: "present_moment", title: "Present Moment", duration: "3 min", icon: "clock.fill"),
    Course(id: "body_awareness", title: "Body Awareness", duration: "4 min", icon: "figure.mind.and.body"),
    Course(id: "breathing_techniques", title: "Breathing Techniques", duration: "2 min", icon: "wind"),
    Course(id: "mindful_walking", title: "Mindful Walking", duration: "3 min", icon: "figure.walk"),
    Course(id: "meditation_basics", title: "Meditation Basics", duration: "5 min", icon: "sparkles")
]

let growthCourses: [Course] = [
    Course(id: "self_compassion", title: "Self-Compassion", duration: "4 min", icon: "heart.fill"),
    Course(id: "goal_setting", title: "Goal Setting", duration: "3 min", icon: "target"),
    Course(id: "building_confidence", title: "Building Confidence", duration: "4 min", icon: "star.fill"),
    Course(id: "overcoming_fear", title: "Overcoming Fear", duration: "3 min", icon: "shield.fill"),
    Course(id: "personal_values", title: "Personal Values", duration: "2 min", icon: "diamond.fill")
]

// Additional Categories
let sleepCourses: [Course] = [
    Course(id: "sleep_hygiene", title: "Sleep Hygiene", duration: "3 min", icon: "bed.double.fill"),
    Course(id: "relaxation_techniques", title: "Relaxation Techniques", duration: "4 min", icon: "moon.stars.fill"),
    Course(id: "mindful_sleep", title: "Mindful Sleep", duration: "2 min", icon: "zzz"),
    Course(id: "sleep_anxiety", title: "Sleep Anxiety", duration: "3 min", icon: "brain.head.profile"),
    Course(id: "evening_routine", title: "Evening Routine", duration: "4 min", icon: "sunset.fill")
]

let emotionCourses: [Course] = [
    Course(id: "emotional_awareness", title: "Emotional Awareness", duration: "3 min", icon: "heart.circle.fill"),
    Course(id: "managing_anger", title: "Managing Anger", duration: "4 min", icon: "flame.fill"),
    Course(id: "dealing_with_sadness", title: "Dealing with Sadness", duration: "3 min", icon: "cloud.rain.fill"),
    Course(id: "joy_happiness", title: "Joy & Happiness", duration: "2 min", icon: "sun.max.fill"),
    Course(id: "emotional_balance", title: "Emotional Balance", duration: "4 min", icon: "scalemass.fill")
]

let workCourses: [Course] = [
    Course(id: "work_life_balance", title: "Work-Life Balance", duration: "4 min", icon: "briefcase.fill"),
    Course(id: "dealing_with_burnout", title: "Dealing with Burnout", duration: "3 min", icon: "exclamationmark.triangle.fill"),
    Course(id: "productivity_tips", title: "Productivity Tips", duration: "3 min", icon: "bolt.fill"),
    Course(id: "workplace_stress", title: "Workplace Stress", duration: "4 min", icon: "building.2.fill"),
    Course(id: "career_growth", title: "Career Growth", duration: "3 min", icon: "chart.line.uptrend.xyaxis")
]

let socialCourses: [Course] = [
    Course(id: "social_anxiety", title: "Social Anxiety", duration: "4 min", icon: "person.3.fill"),
    Course(id: "making_friends", title: "Making Friends", duration: "3 min", icon: "person.badge.plus.fill"),
    Course(id: "public_speaking", title: "Public Speaking", duration: "5 min", icon: "megaphone.fill"),
    Course(id: "social_confidence", title: "Social Confidence", duration: "3 min", icon: "person.fill.checkmark"),
    Course(id: "group_dynamics", title: "Group Dynamics", duration: "4 min", icon: "person.2.circle.fill")
]

let habitCourses: [Course] = [
    Course(id: "building_good_habits", title: "Building Good Habits", duration: "4 min", icon: "checkmark.circle.fill"),
    Course(id: "breaking_bad_habits", title: "Breaking Bad Habits", duration: "3 min", icon: "xmark.circle.fill"),
    Course(id: "habit_tracking", title: "Habit Tracking", duration: "2 min", icon: "chart.bar.fill"),
    Course(id: "morning_routines", title: "Morning Routines", duration: "3 min", icon: "sunrise.fill"),
    Course(id: "consistency", title: "Consistency", duration: "4 min", icon: "repeat.circle.fill")
]

let wellnessCourses: [Course] = [
    Course(id: "daily_wellness", title: "Daily Wellness", duration: "3 min", icon: "heart.fill"),
    Course(id: "mindful_living", title: "Mindful Living", duration: "4 min", icon: "leaf.fill"),
    Course(id: "self_care_basics", title: "Self-Care Basics", duration: "3 min", icon: "sparkles"),
    Course(id: "positive_mindset", title: "Positive Mindset", duration: "2 min", icon: "sun.max.fill"),
    Course(id: "gratitude_practice", title: "Gratitude Practice", duration: "3 min", icon: "hand.raised.fill")
]

let selfCareCourses: [Course] = [
    Course(id: "self_care_basics", title: "Self-Care Basics", duration: "3 min", icon: "heart.fill"),
    Course(id: "physical_wellness", title: "Physical Wellness", duration: "4 min", icon: "figure.walk"),
    Course(id: "mental_health", title: "Mental Health", duration: "3 min", icon: "brain.head.profile"),
    Course(id: "spiritual_growth", title: "Spiritual Growth", duration: "4 min", icon: "sparkles"),
    Course(id: "creative_expression", title: "Creative Expression", duration: "3 min", icon: "paintbrush.fill")
]

// All Categories Array
let allCategories: [CourseCategory] = [
    CourseCategory(title: "Understanding Stress", courses: stressCourses, color: Color.orange, isPremium: false),
    CourseCategory(title: "Relationships", courses: relationshipCourses, color: Color.pink, isPremium: false),
    CourseCategory(title: "Sleep & Rest", courses: sleepCourses, color: Color.indigo, isPremium: false),
    CourseCategory(title: "Emotional Health", courses: emotionCourses, color: Color.red, isPremium: true),
    CourseCategory(title: "Work & Career", courses: workCourses, color: Color.teal, isPremium: true),
    CourseCategory(title: "Social Skills", courses: socialCourses, color: Color.cyan, isPremium: true),
    CourseCategory(title: "Habits & Routines", courses: habitCourses, color: Color.mint, isPremium: true),
    CourseCategory(title: "Self-Care", courses: selfCareCourses, color: Color.yellow, isPremium: true),
    CourseCategory(title: "Cognitive Patterns", courses: cognitiveCourses, color: Color.purple, isPremium: true),
    CourseCategory(title: "Mindfulness", courses: mindfulnessCourses, color: Color.green, isPremium: true),
    CourseCategory(title: "Personal Growth", courses: growthCourses, color: Color.blue, isPremium: true)
]

#Preview {
    CoursesScreen()
        .environmentObject(ThemeManager())
        .environmentObject(AuthService.shared)
} 