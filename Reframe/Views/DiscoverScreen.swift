import SwiftUI

struct DiscoverScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int
    @State private var showAchievements = false
    @State private var showGuidedJournal = false
    @State private var showQuickCalm = false
    @State private var showDailyBoost = false
    @State private var showCourses = false
    @State private var animateCards = false
    @StateObject private var favoritesService = CourseFavoritesService.shared
    @State private var showCourseViewer = false
    @State private var selectedCourse: Course?
    
    var body: some View {
        ZStack {
            // Special effects for Sunset Serenity theme
            themeManager.sunsetParticles()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Discover")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(themeManager.colors.text)
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Featured Section
                    VStack(alignment: .leading, spacing: 16) {
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            // Existing features moved from home
                            DiscoverCard(
                                title: "Milestones",
                                subtitle: "Track your progress",
                                icon: "trophy.fill",
                                gradient: [Color.orange, Color.yellow],
                                delay: 0.1
                            ) {
                                showAchievements = true
                            }
                            
                            DiscoverCard(
                                title: "Guided Prompts",
                                subtitle: "Deep reflection",
                                icon: "text.bubble.fill",
                                gradient: [Color.blue, Color.purple],
                                delay: 0.2
                            ) {
                                showGuidedJournal = true
                            }
                            
                            DiscoverCard(
                                title: "Quick Calm",
                                subtitle: "Find peace now",
                                icon: "heart.fill",
                                gradient: [Color.pink, Color.red],
                                delay: 0.3
                            ) {
                                showQuickCalm = true
                            }
                            
                            DiscoverCard(
                                title: "Daily Wisdom",
                                subtitle: "Today's insight",
                                icon: "leaf.fill",
                                gradient: [Color.green, Color.mint],
                                delay: 0.4
                            ) {
                                showDailyBoost = true
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Additional Features Section
                    VStack(alignment: .leading, spacing: 16) {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            DiscoverCard(
                                title: "Courses",
                                subtitle: "Learn & grow",
                                icon: "book.closed.fill",
                                gradient: [Color.purple, Color.indigo],
                                delay: 0.5
                            ) {
                                showCourses = true
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Favorites Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Favorites")
                            .font(.system(size: 22, weight: .semibold, design: .default))
                            .foregroundColor(themeManager.colors.text)
                            .padding(.horizontal)
                        
                        let favoriteCourses = favoritesService.getFavoriteCourses()
                        if favoriteCourses.isEmpty {
                            // Empty state
                            VStack(spacing: 16) {
                                Image(systemName: "heart")
                                    .font(.system(size: 40))
                                    .foregroundColor(themeManager.colors.textLight)
                                
                                Text("No favorite courses yet")
                                    .font(.system(size: 18, weight: .medium, design: .default))
                                    .foregroundColor(themeManager.colors.text)
                                
                                Text("Complete courses and tap the heart to add them to your favorites")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(themeManager.colors.textLight)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(themeManager.colors.surface)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        } else {
                            // Favorites list
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(favoriteCourses) { courseContent in
                                        let course = Course(
                                            id: courseContent.courseId,
                                            title: courseContent.title,
                                            duration: courseContent.duration,
                                            icon: courseContent.icon
                                        )
                                        
                                        CourseCard(
                                            course: course,
                                            categoryColor: .orange, // Default color for favorites
                                            isPremium: courseContent.isPremium
                                        ) {
                                            selectedCourse = course
                                            showCourseViewer = true
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical, 24)
            }
            .background(themeManager.customBackground())
            .navigationBarHidden(true)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(0.1)) {
                animateCards = true
            }
        }
        .sheet(isPresented: $showAchievements) {
            NavigationView {
                AchievementsScreen()
            }
        }
        .sheet(isPresented: $showGuidedJournal) {
            GuidedJournalScreen()
        }
        .sheet(isPresented: $showQuickCalm) {
            QuickCalmScreen()
        }
        .sheet(isPresented: $showCourses) {
            CoursesScreen()
        }
        .sheet(isPresented: $showCourseViewer) {
            if let course = selectedCourse {
                CourseViewerScreen(course: course)
            }
        }
        .fullScreenCover(isPresented: $showDailyBoost) {
            // Deterministic shuffle based on month/year, then pick for the day
            let calendar = Calendar.current
            let today = Date()
            let year = calendar.component(.year, from: today)
            let month = calendar.component(.month, from: today)
            let dayOfCycle = (calendar.ordinality(of: .day, in: .year, for: today) ?? 1) % dailyBoostStrategies.count
            // Seed for deterministic shuffle: year * 100 + month
            var rng = SeededGenerator(seed: UInt64(year * 100 + month))
            let shuffled = dailyBoostStrategies.shuffled(using: &rng)
            
            // Apply offset from DevSettings (only in DEBUG builds)
            #if DEBUG
            let userDefaults = UserDefaults(suiteName: "group.com.reframeapp.shared")
            let offset = userDefaults?.integer(forKey: "dailyWisdomOffset") ?? 0
            let adjustedDayOfCycle = (dayOfCycle + offset + dailyBoostStrategies.count) % dailyBoostStrategies.count
            let strategy = shuffled[adjustedDayOfCycle]
            #else
            let strategy = shuffled[dayOfCycle]
            #endif
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.87, green: 0.67, blue: 0.39), // light brown
                        Color(red: 0.74, green: 0.51, blue: 0.22)  // medium brown
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                // Brown wave at the bottom
                VStack {
                    Spacer()
                    WaveShape()
                        .fill(Color(red: 0.56, green: 0.34, blue: 0.13))
                        .frame(height: 80)
                        .edgesIgnoringSafeArea(.bottom)
                }
                VStack(spacing: 24) {
                    Spacer()
                    Image("TreeIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 340, maxHeight: 320)
                        .background(Color.clear)
                        .padding(.bottom, 8)
                    Text(strategy.title)
                        .font(.custom("Snell Roundhand", size: 36).weight(.bold))
                        .foregroundColor(Color(red: 0.22, green: 0.13, blue: 0.07))
                        .padding(.bottom, 2)
                    Text(strategy.description)
                        .font(.custom("Georgia", size: 18))
                        .foregroundColor(Color(red: 0.22, green: 0.13, blue: 0.07))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .lineLimit(4)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    Button(action: { showDailyBoost = false }) {
                        Text("Close")
                            .font(.custom("Georgia", size: 20).weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 0.22, green: 0.13, blue: 0.07))
                            .cornerRadius(16)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

struct DiscoverCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let delay: Double
    let isComingSoon: Bool
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isPressed = false
    
    init(title: String, subtitle: String, icon: String, gradient: [Color], delay: Double, isComingSoon: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.gradient = gradient
        self.delay = delay
        self.isComingSoon = isComingSoon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 60, height: 60)
                        .shadow(color: gradient[0].opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(themeManager.colors.text)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundColor(themeManager.colors.textLight)
                        .multilineTextAlignment(.center)
                    
                    if isComingSoon {
                        Text("Coming Soon")
                            .font(.system(size: 10, weight: .medium, design: .default))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(8)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(themeManager.colors.surface)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(DiscoverCardButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

struct DiscoverCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}



#Preview {
    DiscoverScreen(selectedTab: .constant(1))
        .environmentObject(ThemeManager())
} 