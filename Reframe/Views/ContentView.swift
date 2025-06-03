import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authService: AuthService
    @StateObject private var coordinator = OnboardingCoordinator()
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
            if !coordinator.hasCompletedOnboarding {
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
                        RemindersScreen(selectedTab: $selectedTab)
                    }
                    .tabItem {
                        Image(systemName: "bell.fill")
                        Text("Reminders")
                    }
                    .tag(2)
                    
                    NavigationStack {
                        SettingsScreen(selectedTab: $selectedTab)
                    }
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .tag(3)
                }
                .accentColor(themeManager.colors.primary)
            }
        }
        .environmentObject(themeManager)
        .environmentObject(coordinator)
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