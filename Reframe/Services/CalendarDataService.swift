import Foundation
import FirebaseAuth
import Combine

class CalendarDataService: ObservableObject {
    static let shared = CalendarDataService()
    
    @Published var calendarEntries: [CalendarEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let reframeService = ReframeService.shared
    private let journalService = JournalService.shared
    private let coachService = CoachService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupDataListeners()
    }
    
    private func setupDataListeners() {
        // Listen to auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if user != nil {
                self?.loadCalendarData()
            } else {
                self?.calendarEntries = []
            }
        }
        
        // Listen to changes in journal service
        journalService.$entries
            .sink { [weak self] _ in
                self?.loadCalendarData()
            }
            .store(in: &cancellables)
    }
    
    func loadCalendarData() {
        Task {
            await loadCalendarDataAsync()
        }
    }
    
    @MainActor
    func loadCalendarDataAsync() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get reframes from ReframeService
            let reframes = try await reframeService.getReframes()
            let reframeEntries = reframes.compactMap { reframe -> CalendarEntry? in
                // Handle different reframe categories
                switch reframe.category {
                case "Reflection":
                    return nil // Skip reflections from reframe service (get from journal)
                case "Positive Reflection":
                    return CalendarEntry(
                        date: reframe.timestamp,
                        type: .reflection, // Treat positive reflections as reflections
                        description: reframe.originalThought,
                        id: reframe.id ?? UUID().uuidString
                    )
                case "Nonsense":
                    return nil // Skip nonsense entries
                default:
                    // Regular reframes (category is nil or any other value)
                    return CalendarEntry(
                        date: reframe.timestamp,
                        type: .reframe,
                        description: reframe.originalThought,
                        id: reframe.id ?? UUID().uuidString
                    )
                }
            }
            
            // Get journal entries
            let journalEntries = journalService.entries.compactMap { entry -> CalendarEntry? in
                let entryType: EntryType
                switch entry.category {
                case "Reflection":
                    entryType = .reflection
                case "Guided Prompt":
                    entryType = .guided
                case "Coach":
                    entryType = .coach
                case "Reframe":
                    // Skip reframe entries from journal since we get them from reframeService
                    return nil
                default:
                    entryType = .reflection
                }
                
                return CalendarEntry(
                    date: entry.timestamp,
                    type: entryType,
                    description: entry.content,
                    id: entry.id ?? UUID().uuidString
                )
            }
            
            // Combine all entries and sort by date
            let allEntries = reframeEntries + journalEntries
            calendarEntries = allEntries.sorted { $0.date > $1.date }
            
            // Debug logging
            print("📅 Calendar Data Loaded:")
            print("   - Reframe entries: \(reframeEntries.count)")
            print("   - Journal entries: \(journalEntries.count)")
            print("   - Total entries: \(calendarEntries.count)")
            
            // Log entries by type for debugging
            let entriesByType = Dictionary(grouping: calendarEntries) { $0.type }
            for (type, entries) in entriesByType {
                print("   - \(type.rawValue): \(entries.count) entries")
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func getEntriesForDate(_ date: Date) -> [CalendarEntry] {
        let calendar = Calendar.current
        return calendarEntries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    func hasEntriesForDate(_ date: Date) -> Bool {
        !getEntriesForDate(date).isEmpty
    }
    
    func getEntryTypesForDate(_ date: Date) -> [EntryType] {
        // Get unique entry types for the date (no duplicates)
        let entries = getEntriesForDate(date)
        let types = entries.map { $0.type }
        let uniqueTypes = Array(Set(types)).sorted { type1, type2 in
            // Sort by priority: reframe, reflection, coach, guided
            let priority: [EntryType] = [.reframe, .reflection, .coach, .guided]
            let index1 = priority.firstIndex(of: type1) ?? 999
            let index2 = priority.firstIndex(of: type2) ?? 999
            return index1 < index2
        }
        
        // Debug logging for specific dates
        if !entries.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let dateString = formatter.string(from: date)
            print("📅 \(dateString): \(entries.count) entries, \(uniqueTypes.count) unique types: \(uniqueTypes.map { $0.rawValue })")
        }
        
        return uniqueTypes
    }
    
    func getEntriesForMonth(_ date: Date) -> [CalendarEntry] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end ?? date
        
        return calendarEntries.filter { entry in
            entry.date >= startOfMonth && entry.date < endOfMonth
        }
    }
}

// Updated CalendarEntry model to work with real data
struct CalendarEntry: Identifiable {
    let id: String
    let date: Date
    let type: EntryType
    let description: String
    
    init(date: Date, type: EntryType, description: String, id: String) {
        self.id = id
        self.date = date
        self.type = type
        self.description = description
    }
}

enum EntryType: String, CaseIterable, Hashable {
    case reframe = "reframe"
    case reflection = "reflection"
    case coach = "coach"
    case guided = "guided"
} 