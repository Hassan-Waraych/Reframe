import SwiftUI

struct RemindersScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int
    @State private var isRemindersEnabled = false
    @State private var selectedTime = Date()
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5] // Monday to Friday
    
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
                    
                    Text("Reminders")
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Reminders Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Daily Reminders")
                        .font(.custom("Quicksand-SemiBold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                    
                    // Toggle
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
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(themeManager.colors.background)
        .navigationBarHidden(true)
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

#Preview {
    RemindersScreen(selectedTab: .constant(2))
        .environmentObject(ThemeManager())
} 