import SwiftUI

struct CalendarGridView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var calendarDataService = CalendarDataService.shared
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var showDayDetail = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.colors.primary)
                        .frame(width: 32, height: 32)
                        .background(themeManager.colors.surface)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.custom("Quicksand-Bold", size: 18))
                    .foregroundColor(themeManager.colors.text)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.colors.primary)
                        .frame(width: 32, height: 32)
                        .background(themeManager.colors.surface)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            VStack(spacing: 8) {
                // Day headers
                HStack(spacing: 0) {
                    ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, day in
                        Text(day)
                            .font(.custom("Nunito-Medium", size: 12))
                            .foregroundColor(themeManager.colors.textLight)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                if calendarDataService.isLoading {
                    // Loading state
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading calendar data...")
                            .font(.custom("Nunito-Regular", size: 14))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    .frame(height: 200)
                } else if let errorMessage = calendarDataService.errorMessage {
                    // Error state
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 24))
                            .foregroundColor(themeManager.colors.error)
                        Text("Error loading data")
                            .font(.custom("Nunito-Medium", size: 16))
                            .foregroundColor(themeManager.colors.text)
                        Text(errorMessage)
                            .font(.custom("Nunito-Regular", size: 14))
                            .foregroundColor(themeManager.colors.textLight)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task {
                                await calendarDataService.loadCalendarDataAsync()
                            }
                        }
                        .font(.custom("Nunito-SemiBold", size: 14))
                        .foregroundColor(themeManager.colors.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(themeManager.colors.primary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .frame(height: 200)
                } else {
                    // Calendar days
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(Array(calendarDays.enumerated()), id: \.offset) { index, date in
                            if let date = date {
                                CalendarDayView(
                                    date: date,
                                    isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate ?? Date()),
                                    hasEntries: hasEntries(for: date),
                                    entryTypes: entryTypes(for: date)
                                ) {
                                    selectedDate = date
                                    showDayDetail = true
                                }
                            } else {
                                Color.clear
                                    .frame(height: 32)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(themeManager.colors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .sheet(isPresented: $showDayDetail) {
            if let selectedDate = selectedDate {
                DayDetailView(date: selectedDate, entries: entries(for: selectedDate))
                    .environmentObject(themeManager)
            }
        }
        .task {
            await calendarDataService.loadCalendarDataAsync()
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private var calendarDays: [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days in the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasEntries(for date: Date) -> Bool {
        calendarDataService.hasEntriesForDate(date)
    }
    
    private func entryTypes(for date: Date) -> [EntryType] {
        calendarDataService.getEntryTypesForDate(date)
    }
    
    private func entries(for date: Date) -> [CalendarEntry] {
        calendarDataService.getEntriesForDate(date)
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
    }
}

struct CalendarDayView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let date: Date
    let isSelected: Bool
    let hasEntries: Bool
    let entryTypes: [EntryType]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.custom("Nunito-Medium", size: 14))
                    .foregroundColor(isToday ? themeManager.colors.primary : themeManager.colors.text)
                
                if hasEntries {
                    HStack(spacing: 1) {
                        ForEach(Array(entryTypes.prefix(3).enumerated()), id: \.offset) { index, type in
                            Circle()
                                .fill(colorForEntryType(type))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            .frame(height: 32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? themeManager.colors.primary.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private func colorForEntryType(_ type: EntryType) -> Color {
        switch type {
        case .reframe:
            return Color.orange
        case .reflection:
            return Color.purple
        case .coach:
            return Color.green
        case .guided:
            return Color.blue
        }
    }
}

struct DayDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    let date: Date
    let entries: [CalendarEntry]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text(dayString)
                    .font(.custom("Quicksand-Bold", size: 24))
                    .foregroundColor(themeManager.colors.text)
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .font(.custom("Nunito-SemiBold", size: 16))
                .foregroundColor(themeManager.colors.primary)
            }
            .padding(.horizontal)
            .padding(.top)
            
            if entries.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(themeManager.colors.textLight)
                    
                    Text("No entries for this day")
                        .font(.custom("Nunito-Medium", size: 18))
                        .foregroundColor(themeManager.colors.textLight)
                    
                    Text("Start your journey by adding a reframe or reflection")
                        .font(.custom("Nunito-Regular", size: 14))
                        .foregroundColor(themeManager.colors.textLight)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(entries, id: \.id) { entry in
                            EntryRowView(entry: entry)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .background(themeManager.colors.background.ignoresSafeArea())
    }
    
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
}

struct EntryRowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let entry: CalendarEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(colorForEntryType(entry.type))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.type.rawValue.capitalized)
                    .font(.custom("Nunito-SemiBold", size: 16))
                    .foregroundColor(themeManager.colors.text)
                
                Text(truncatedDescription)
                    .font(.custom("Nunito-Regular", size: 14))
                    .foregroundColor(themeManager.colors.textLight)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(timeString)
                .font(.custom("Nunito-Regular", size: 12))
                .foregroundColor(themeManager.colors.textLight)
        }
        .padding(16)
        .background(themeManager.colors.surface)
        .cornerRadius(12)
    }
    
    private var truncatedDescription: String {
        let maxLength = 60
        if entry.description.count > maxLength {
            return String(entry.description.prefix(maxLength)) + "..."
        }
        return entry.description
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: entry.date)
    }
    
    private func colorForEntryType(_ type: EntryType) -> Color {
        switch type {
        case .reframe:
            return Color.orange
        case .reflection:
            return Color.purple
        case .coach:
            return Color.green
        case .guided:
            return Color.blue
        }
    }
}



#Preview {
    CalendarGridView()
        .environmentObject(ThemeManager())
} 