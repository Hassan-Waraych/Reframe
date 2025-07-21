import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authService: AuthService
    @StateObject private var coordinator = OnboardingCoordinator()
    @StateObject private var milestoneService = MilestoneService.shared
    @State private var selectedTab = 0
    
    init() {
        // Configure navigation bar appearance globally
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundColor = .clear
        navAppearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        // Configure tab bar appearance globally
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = .clear
        tabBarAppearance.shadowColor = .clear
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    var body: some View {
        Group {
            if !authService.isAuthenticated {
                // Show mandatory signup screen when not authenticated
                SignUpScreen(isFromSettings: false, isMandatory: true)
                    .environmentObject(themeManager)
                    .environmentObject(authService)
                    .environmentObject(coordinator)
            } else if !coordinator.hasCompletedOnboarding {
                OnboardingView()
            } else {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        HomeScreen(selectedTab: $selectedTab)
                    }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                    
                    NavigationStack {
                        JournalScreen(selectedTab: $selectedTab)
                    }
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("Journal")
                    }
                    .tag(1)
                    
                    NavigationStack {
                        CoachHomeView(selectedTab: $selectedTab)
                    }
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("Coach")
                    }
                    .tag(2)
                    
                    /*
                    NavigationStack {
                        InsightsScreen(selectedTab: $selectedTab)
                    }
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Insights")
                    }
                    .tag(3)
                    */
                    
                    NavigationStack {
                        SettingsScreen(selectedTab: $selectedTab)
                    }
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .tag(4)
                }
                .accentColor(themeManager.colors.primary)
            }
        }
        .environmentObject(themeManager)
        .environmentObject(coordinator)
        .environmentObject(milestoneService)
        .overlay(
            Group {
                if milestoneService.showMilestoneNotification {
                    MilestoneNotificationView(
                        milestone: milestoneService.completedMilestone ?? Milestone(
                            id: "",
                            title: "",
                            subtitle: "",
                            icon: "",
                            category: .beginner,
                            isCompleted: false
                        ),
                        isPresented: $milestoneService.showMilestoneNotification
                    )
                    .zIndex(9999)
                    .allowsHitTesting(true)
                }
            }
        )
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = UIColor(themeManager.colors.textLight.opacity(0.7))
            UITabBar.appearance().backgroundColor = .clear
            UITabBar.appearance().isTranslucent = true
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
        .environmentObject(AuthService.shared)
} 