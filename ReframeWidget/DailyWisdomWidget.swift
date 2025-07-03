import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DailyWisdomEntry {
        DailyWisdomEntry(date: Date(), strategy: dailyBoostStrategies[0], isPremium: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyWisdomEntry) -> ()) {
        let entry = getEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyWisdomEntry>) -> ()) {
        let entry = getEntry()
        let currentDate = Date()
        let midnight = Calendar.current.startOfDay(for: currentDate)
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }

    private func getEntry() -> DailyWisdomEntry {
        let isPremium = isPremiumUser()
        if isPremium {
            let strategy = getTodaysStrategy()
            return DailyWisdomEntry(date: Date(), strategy: strategy, isPremium: true)
        } else {
            return DailyWisdomEntry(date: Date(), strategy: nil, isPremium: false)
        }
    }

    private func isPremiumUser() -> Bool {
        let userDefaults = UserDefaults(suiteName: "group.com.reframeapp.shared")
        return userDefaults?.bool(forKey: "isPremiumUser") ?? false
    }

    private func getTodaysStrategy() -> DailyBoostStrategy {
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let dayOfCycle = (calendar.ordinality(of: .day, in: .year, for: today) ?? 1) % dailyBoostStrategies.count
        // Seed for deterministic shuffle: year * 100 + month
        var rng = SeededGenerator(seed: UInt64(year * 100 + month))
        let shuffled = dailyBoostStrategies.shuffled(using: &rng)
        return shuffled[dayOfCycle]
    }
}

struct DailyWisdomEntry: TimelineEntry {
    let date: Date
    let strategy: DailyBoostStrategy?
    let isPremium: Bool
}

struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addCurve(to: CGPoint(x: rect.width, y: 0),
                      control1: CGPoint(x: rect.width * 0.25, y: 40),
                      control2: CGPoint(x: rect.width * 0.75, y: -40))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct DailyWisdomWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if entry.isPremium, let strategy = entry.strategy {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.87, green: 0.67, blue: 0.39), // light brown
                        Color(red: 0.74, green: 0.51, blue: 0.22)  // medium brown
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                // Brown wave at the bottom (even smaller)
                VStack {
                    Spacer()
                    WaveShape()
                        .fill(Color(red: 0.56, green: 0.34, blue: 0.13))
                        .frame(height: 32)
                        .edgesIgnoringSafeArea(.bottom)
                }
                VStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Image("TreeIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 320, maxHeight: 280)
                        .background(Color.clear)
                        .padding(.bottom, -10)
                    Text(strategy.title)
                        .font(.custom("Snell Roundhand", size: 24).weight(.bold))
                        .foregroundColor(Color(red: 0.22, green: 0.13, blue: 0.07))
                        .padding(.bottom, 1)
                    Text(strategy.description)
                        .font(.custom("Georgia", size: 13))
                        .foregroundColor(Color(red: 0.22, green: 0.13, blue: 0.07))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .lineLimit(4)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 32)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(.fill, for: .widget)
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.87, green: 0.67, blue: 0.39),
                        Color(red: 0.74, green: 0.51, blue: 0.22)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack {
                    Spacer()
                    WaveShape()
                        .fill(Color(red: 0.56, green: 0.34, blue: 0.13))
                        .frame(height: 32)
                        .edgesIgnoringSafeArea(.bottom)
                }
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "lock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(Color(red: 0.22, green: 0.13, blue: 0.07))
                        .padding(.bottom, 8)
                    Text("Premium Required")
                        .font(.custom("Snell Roundhand", size: 22).weight(.bold))
                        .foregroundColor(Color(red: 0.22, green: 0.13, blue: 0.07))
                    Text("Go Premium to unlock Daily Wisdom on your home screen.")
                        .font(.custom("Georgia", size: 13))
                        .foregroundColor(Color(red: 0.22, green: 0.13, blue: 0.07))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 32)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(.fill, for: .widget)
        }
    }
}

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

struct DailyWisdomWidget: Widget {
    let kind: String = "DailyWisdomWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyWisdomWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Wisdom")
        .description("Get your daily wisdom strategy to support your mental wellness journey.")
        .supportedFamilies([.systemLarge])
        .contentMarginsDisabledIfAvailable()
    }
}

struct DailyWisdomWidget_Previews: PreviewProvider {
    static var previews: some View {
        DailyWisdomWidgetEntryView(entry: DailyWisdomEntry(date: Date(), strategy: dailyBoostStrategies[0], isPremium: true))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
} 