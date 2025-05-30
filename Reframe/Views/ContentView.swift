import SwiftUI

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedTab = 0
    
    var body: some View {
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
        .environmentObject(themeManager)
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = UIColor(themeManager.colors.textLight.opacity(0.7))
            UITabBar.appearance().backgroundColor = .clear
            UITabBar.appearance().isTranslucent = true
        }
    }
}

#Preview {
    ContentView()
} 