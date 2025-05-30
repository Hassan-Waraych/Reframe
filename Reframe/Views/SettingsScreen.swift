import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int
    @State private var showDevSettings = false
    @State private var selectedSection: String? = nil
    
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
                    HStack(spacing: 16) {
                        AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&h=200&fit=crop")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(themeManager.colors.primary, lineWidth: 2)
                        )
                        .shadow(color: themeManager.colors.primary.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("John Doe")
                                .font(.custom("Quicksand-SemiBold", size: 20))
                                .foregroundColor(themeManager.colors.text)
                            
                            Text("john.doe@example.com")
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
                            color: themeManager.colors.primary
                        )
                        
                        SupportButton(
                            icon: "questionmark.circle.fill",
                            title: "Help Center",
                            color: themeManager.colors.secondary
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
    }
}

struct SupportButton: View {
    let icon: String
    let title: String
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: {}) {
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

#Preview {
    SettingsScreen(selectedTab: .constant(3))
        .environmentObject(ThemeManager())
} 