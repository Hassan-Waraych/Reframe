import SwiftUI

struct WeeklyMoodView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedDay: Date?
    @State private var showMoodPicker = false
    let onTodayTapped: (() -> Void)?
    
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.colors.primary)
                
                Text("Weekly Mood")
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundColor(themeManager.colors.text)
                
                Spacer()
            }
            
            HStack {
                ForEach(0..<7, id: \.self) { index in
                    let dayDate = getDateForWeekDay(index)
                    let isToday = Calendar.current.isDateInToday(dayDate)
                    let mood = getMoodForDate(dayDate) // Placeholder - will be connected to service later
                    
                    VStack(spacing: 6) {
                        Button(action: {
                            // Only allow selection for today
                            if isToday {
                                onTodayTapped?()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        mood == .none ? 
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                themeManager.colors.surface,
                                                themeManager.colors.surface.opacity(0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: mood.color),
                                                Color(hex: mood.color).opacity(0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                isToday ? 
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        themeManager.colors.primary,
                                                        themeManager.colors.primary.opacity(0.6)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        themeManager.colors.border,
                                                        themeManager.colors.border.opacity(0.3)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: isToday ? 3 : 1
                                            )
                                    )
                                    .shadow(
                                        color: mood == .none ? 
                                        Color.black.opacity(0.05) : 
                                        Color(hex: mood.color).opacity(0.3),
                                        radius: mood == .none ? 5 : 8,
                                        x: 0,
                                        y: mood == .none ? 2 : 4
                                    )
                                
                                Text(mood.emoji)
                                    .font(.system(size: 20))
                                    .opacity(mood == .none ? 0.3 : 1.0)
                            }
                        }
                        .scaleEffect(isToday ? 1.1 : 1.0)
                        .opacity(isToday ? 1.0 : 0.7)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isToday)
                        
                        Text(weekDays[index])
                            .font(.system(size: 10, weight: .medium, design: .default))
                            .foregroundColor(isToday ? themeManager.colors.primary : themeManager.colors.textLight)
                    }
                    
                    if index < 6 {
                        Spacer(minLength: 8)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            themeManager.selectedTheme == .sunsetSerenity ?
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.98),
                    Color(hex: "FFF0E6").opacity(0.95),
                    Color(hex: "FFE8D6").opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) : LinearGradient(
                gradient: Gradient(colors: [
                    themeManager.colors.surface,
                    themeManager.colors.surface
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            Group {
                if themeManager.selectedTheme == .sunsetSerenity {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FF6B35").opacity(0.4),
                                    Color(hex: "9B5DE5").opacity(0.3),
                                    Color(hex: "FF6B35").opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            }
        )
        .cornerRadius(20)
        .shadow(color: themeManager.selectedTheme == .sunsetSerenity ? Color(hex: "FF6B35").opacity(0.15) : Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        // New mood check-in flow will be triggered here
    }
    
    private func getDateForWeekDay(_ weekDayIndex: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let currentWeekDay = calendar.component(.weekday, from: today) - 1 // 0 = Sunday
        let daysToSubtract = currentWeekDay - weekDayIndex
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: today) ?? today
    }
    
    private func getMoodForDate(_ date: Date) -> MoodType {
        // Placeholder - will be connected to MoodService later
        return .none
    }
}

struct MoodPickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedMood: MoodType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How are you feeling?")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(themeManager.colors.text)
                    .padding(.top, 20)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(MoodType.allCases.filter { $0 != .none }, id: \.self) { mood in
                        Button(action: {
                            selectedMood = mood
                            dismiss()
                        }) {
                            VStack(spacing: 12) {
                                Text(mood.emoji)
                                    .font(.system(size: 48))
                                
                                Text(mood.displayName)
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(themeManager.colors.text)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: mood.color).opacity(0.1),
                                                Color(hex: mood.color).opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                Color(hex: mood.color).opacity(0.3),
                                                lineWidth: 1
                                            )
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(themeManager.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.colors.primary)
                }
            }
        }
    }
}

#Preview {
    WeeklyMoodView(onTodayTapped: nil)
        .environmentObject(ThemeManager())
}
