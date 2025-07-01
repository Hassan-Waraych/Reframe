import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authService: AuthService
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showDevSettings = false
    @State private var showSignInSheet = false
    @State private var showAccountOptions = false
    @State private var showFeedbackEmail = false
    @State private var isRemindersEnabled = false
    @State private var selectedTime = Date()
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5] // Monday to Friday
    @State private var showHelpCenter = false
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: {
                        selectedTab = 0
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(themeManager.colors.primary)
                            .frame(width: 48, height: 48)
                            .background(themeManager.colors.surface)
                            .clipShape(Circle())
                            .shadow(color: themeManager.colors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    
                    Text("Settings")
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Account Section
                VStack {
                    Button(action: {
                        if authService.isAuthenticated {
                            showAccountOptions = true
                        } else {
                            showSignInSheet = true
                        }
                    }) {
                        HStack(spacing: 16) {
                            UserAvatar(size: 70, email: authService.getUserEmail())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if authService.isAuthenticated {
                                    Text(authService.getUserEmail() ?? "User")
                                        .font(.custom("Quicksand-SemiBold", size: 20))
                                        .foregroundColor(themeManager.colors.text)
                                } else {
                                    Text("Sign In")
                                        .font(.custom("Quicksand-SemiBold", size: 20))
                                        .foregroundColor(themeManager.colors.primary)
                                }
                                
                                Text(authService.isAuthenticated ? "Tap to manage account" : "Create an account or sign in")
                                    .font(.custom("Nunito-Regular", size: 16))
                                    .foregroundColor(themeManager.colors.textLight)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(themeManager.colors.textLight)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(20)
                        .background(themeManager.colors.surface)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal)
                
                // Preferences Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Preferences")
                        .font(.custom("Quicksand-SemiBold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                        .padding(.horizontal)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            themeManager.toggleTheme()
                        }
                    }) {
                        HStack {
                            Image(systemName: themeManager.isDark ? "moon.fill" : "sun.max.fill")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.colors.primary)
                                .frame(width: 32)
                            
                            Text("Dark Mode")
                                .font(.custom("Nunito-Medium", size: 16))
                                .foregroundColor(themeManager.colors.text)
                            
                            Spacer()
                            
                            // Custom Toggle
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.isDark ? themeManager.colors.primary : themeManager.colors.border)
                                    .frame(width: 50, height: 28)
                                
                                Circle()
                                    .fill(themeManager.colors.background)
                                    .frame(width: 24, height: 24)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    .offset(x: themeManager.isDark ? 11 : -11)
                            }
                        }
                        .padding(20)
                        .background(themeManager.colors.surface)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal)
                
                // Reminders Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Reminders")
                        .font(.custom("Quicksand-SemiBold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        // Enable Reminders Toggle
                        Button(action: {
                            withAnimation(.spring()) {
                                isRemindersEnabled.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(themeManager.colors.primary)
                                    .frame(width: 32)
                                
                                Text("Enable Reminders")
                                    .font(.custom("Nunito-Medium", size: 16))
                                    .foregroundColor(themeManager.colors.text)
                                
                                Spacer()
                                
                                // Custom Toggle
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(isRemindersEnabled ? themeManager.colors.primary : themeManager.colors.border)
                                        .frame(width: 50, height: 28)
                                    
                                    Circle()
                                        .fill(themeManager.colors.background)
                                        .frame(width: 24, height: 24)
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                        .offset(x: isRemindersEnabled ? 11 : -11)
                                }
                            }
                            .padding(20)
                            .background(themeManager.colors.surface)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        }
                        
                        if isRemindersEnabled {
                            // Time Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Reminder Time")
                                    .font(.custom("Quicksand-SemiBold", size: 18))
                                    .foregroundColor(themeManager.colors.text)
                                
                                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(themeManager.colors.surface)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            }
                            
                            // Days Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Repeat on")
                                    .font(.custom("Quicksand-SemiBold", size: 18))
                                    .foregroundColor(themeManager.colors.text)
                                
                                HStack(spacing: 8) {
                                    ForEach(0..<7) { index in
                                        DayButton(
                                            day: days[index],
                                            isSelected: selectedDays.contains(index),
                                            action: {
                                                withAnimation(.spring()) {
                                                    if selectedDays.contains(index) {
                                                        selectedDays.remove(index)
                                                    } else {
                                                        selectedDays.insert(index)
                                                    }
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                            
                            // Categories Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Categories")
                                    .font(.custom("Quicksand-SemiBold", size: 18))
                                    .foregroundColor(themeManager.colors.text)
                                
                                VStack(spacing: 12) {
                                    CategoryToggle(title: "Personal", isEnabled: true)
                                    CategoryToggle(title: "Work", isEnabled: true)
                                    CategoryToggle(title: "Health", isEnabled: false)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Support Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Support")
                        .font(.custom("Quicksand-SemiBold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        SupportButton(
                            icon: "envelope.fill",
                            title: "Send Feedback",
                            color: themeManager.colors.primary,
                            action: {
                                showFeedbackEmail = true
                            }
                        )
                        
                        SupportButton(
                            icon: "questionmark.circle.fill",
                            title: "Help Center",
                            color: themeManager.colors.secondary,
                            action: {
                                showHelpCenter = true
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                // Development Section
                #if DEBUG
                VStack(alignment: .leading, spacing: 16) {
                    Text("Development")
                        .font(.custom("Quicksand-SemiBold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                        .padding(.horizontal)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            showDevSettings = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "hammer.fill")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.colors.accent)
                                .frame(width: 32)
                            
                            Text("Development Settings")
                                .font(.custom("Nunito-Medium", size: 16))
                                .foregroundColor(themeManager.colors.text)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(themeManager.colors.textLight)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(20)
                        .background(themeManager.colors.surface)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal)
                #endif
            }
            .padding(.vertical)
        }
        .background(themeManager.colors.background)
        .navigationBarHidden(true)
        .sheet(isPresented: $showDevSettings) {
            DevSettingsScreen()
        }
        .sheet(isPresented: $showSignInSheet) {
            SignUpScreen(isFromSettings: true)
                .environmentObject(themeManager)
                .environmentObject(authService)
        }
        .sheet(isPresented: $showFeedbackEmail) {
            FeedbackEmailView()
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showHelpCenter) {
            HelpCenterView()
                .environmentObject(themeManager)
        }
        .confirmationDialog("Account Options", isPresented: $showAccountOptions) {
            Button("Sign Out", role: .destructive) {
                do {
                    try authService.signOut()
                } catch {
                    // Error is handled by the authService
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct SupportButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 32)
                
                Text(title)
                    .font(.custom("Nunito-Medium", size: 16))
                    .foregroundColor(themeManager.colors.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.colors.textLight)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(20)
            .background(themeManager.colors.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
}

struct DayButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(.custom("Nunito-Medium", size: 14))
                .foregroundColor(isSelected ? .white : themeManager.colors.text)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: isSelected ? [
                            themeManager.colors.primary,
                            themeManager.colors.primaryDark
                        ] : [
                            themeManager.colors.surface,
                            themeManager.colors.surface
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: isSelected ? themeManager.colors.primary.opacity(0.3) : Color.black.opacity(0.05),
                       radius: isSelected ? 4 : 2,
                       x: 0,
                       y: isSelected ? 2 : 1)
        }
    }
}

struct CategoryToggle: View {
    let title: String
    @State var isEnabled: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isEnabled.toggle()
            }
        }) {
            HStack {
                Text(title)
                    .font(.custom("Nunito-Medium", size: 16))
                    .foregroundColor(themeManager.colors.text)
                
                Spacer()
                
                // Custom Toggle
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isEnabled ? themeManager.colors.primary : themeManager.colors.border)
                        .frame(width: 50, height: 28)
                    
                    Circle()
                        .fill(themeManager.colors.background)
                        .frame(width: 24, height: 24)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .offset(x: isEnabled ? 11 : -11)
                }
            }
            .padding(20)
            .background(themeManager.colors.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    SettingsScreen(selectedTab: .constant(3))
        .environmentObject(ThemeManager())
        .environmentObject(AuthService.shared)
} 