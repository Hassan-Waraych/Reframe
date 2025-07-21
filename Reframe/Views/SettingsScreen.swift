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
    @State private var showPremiumModal = false
    @State private var showDeleteAccountConfirmation = false
    @State private var isDeletingAccount = false
    @State private var showDeleteError = false
    @State private var deleteErrorMessage = ""
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
                    
                    // Theme Selection
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(spacing: 8) {
                            ForEach(ThemeType.allCases, id: \.self) { theme in
                                ThemeOptionButton(
                                    theme: theme,
                                    isSelected: themeManager.selectedTheme == theme,
                                    isPremiumUser: authService.isPremiumUser(),
                                    action: {
                                        if themeManager.canSelectTheme(theme, isPremiumUser: authService.isPremiumUser()) {
                                            themeManager.setTheme(theme)
                                        } else {
                                            showPremiumModal = true
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Reminders Section - Commented out for future implementation
                /*
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
                */
                
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
                        
                        // Subscription Management (only show for premium users)
                        if authService.isPremiumUser() {
                            SupportButton(
                                icon: "creditcard.fill",
                                title: "Manage Subscription",
                                color: .orange,
                                action: {
                                    StoreKitService.shared.manageSubscriptions()
                                }
                            )
                        }
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
        .background(themeManager.customBackground())
        .navigationBarHidden(true)
        .sheet(isPresented: $showDevSettings) {
            DevSettingsScreen()
        }
        .sheet(isPresented: $showSignInSheet) {
            SignUpScreen(isFromSettings: true, isMandatory: false)
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
        .sheet(isPresented: $showPremiumModal) {
            PremiumModalScreen()
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
            Button("Delete My Account", role: .destructive) {
                showDeleteAccountConfirmation = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Delete Account", isPresented: $showDeleteAccountConfirmation) {
            if isDeletingAccount {
                Button("Deleting Account...", role: .destructive) {
                    // Disabled while deleting
                }
                .disabled(true)
            } else {
                Button("Delete My Account", role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                // Only allow cancel if not currently deleting
            }
            .disabled(isDeletingAccount)
        } message: {
            if isDeletingAccount {
                Text("Please complete the re-authentication process to delete your account.")
            } else {
                Text("Are you sure? This will permanently delete your account and all data.")
            }
        }
        .alert("Delete Account Error", isPresented: $showDeleteError) {
            Button("OK") {
                showDeleteError = false
            }
        } message: {
            Text(deleteErrorMessage)
        }
    }
    
    private func deleteAccount() async {
        isDeletingAccount = true
        
        do {
            try await authService.deleteAccount()
            // Account deletion successful, user will be signed out automatically
        } catch {
            // Show error message with better formatting
            let errorMessage = error.localizedDescription
            print("Delete account error in UI: \(errorMessage)")
            await MainActor.run {
                deleteErrorMessage = errorMessage
                showDeleteError = true
            }
        }
        
        isDeletingAccount = false
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

struct ThemeOptionButton: View {
    let theme: ThemeType
    let isSelected: Bool
    let isPremiumUser: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @State private var animateGradient = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: theme.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : themeManager.colors.primary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(theme.displayName)
                            .font(.custom("Nunito-Medium", size: 16))
                            .foregroundColor(isSelected ? .white : themeManager.colors.text)
                        
                        if theme.isPremium && !isPremiumUser {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    if theme.isPremium && !isPremiumUser {
                        Text("Premium")
                            .font(.custom("Nunito-Regular", size: 11))
                            .foregroundColor(isSelected ? .white.opacity(0.8) : themeManager.colors.textLight)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                } else if theme.isPremium && !isPremiumUser {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.colors.textLight)
                }
            }
            .padding(20)
            .background(
                Group {
                    if isSelected {
                        if theme == .sunsetSerenity {
                            LinearGradient.sunsetGradient()
                        } else {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    themeManager.colors.primary,
                                    themeManager.colors.primaryDark
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    } else {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                themeManager.colors.surface,
                                themeManager.colors.surface
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(16)
            .shadow(color: isSelected ? themeManager.colors.primary.opacity(0.3) : Color.black.opacity(0.05), 
                   radius: isSelected ? 8 : 5, 
                   x: 0, 
                   y: isSelected ? 4 : 2)
            .opacity(theme.isPremium && !isPremiumUser ? 0.7 : 1.0)
            .overlay(
                // Special sunset effect for Sunset Serenity theme
                Group {
                    if theme == .sunsetSerenity && isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "FF6B35").opacity(0.6),
                                        Color(hex: "9B5DE5").opacity(0.6),
                                        Color(hex: "FF6B35").opacity(0.6)
                                    ]),
                                    startPoint: animateGradient ? .topLeading : .bottomTrailing,
                                    endPoint: animateGradient ? .bottomTrailing : .topLeading
                                ),
                                lineWidth: 2
                            )
                            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGradient)
                    }
                }
            )
            .onAppear {
                if theme == .sunsetSerenity {
                    animateGradient = true
                }
            }
        }
    }
}

#Preview {
    SettingsScreen(selectedTab: .constant(3))
        .environmentObject(ThemeManager())
        .environmentObject(AuthService.shared)
} 