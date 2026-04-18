import WidgetKit
import SwiftUI

// MARK: - Shared Models (must match main app)

struct HabitEntry: Identifiable, Codable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var isCompletedToday: Bool
}

struct HabitEntryData: Codable {
    var habits: [HabitEntry]
    var updatedAt: Date?
}

struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let habits: [HabitEntry]
    let habitName: String
}

struct HabitWidgetProvider: TimelineProvider {
    private let appGroupId = "group.com.ggsheng.HabitGo"

    func placeholder(in context: Context) -> HabitWidgetEntry {
        HabitWidgetEntry(
            date: Date(),
            habits: [
                HabitEntry(id: UUID(), name: "Exercise", icon: "figure.walk", colorHex: "#34C759", isCompletedToday: true),
                HabitEntry(id: UUID(), name: "Read", icon: "book.fill", colorHex: "#007AFF", isCompletedToday: false),
                HabitEntry(id: UUID(), name: "Meditate", icon: "brain.head.profile", colorHex: "#FF9500", isCompletedToday: false),
            ],
            habitName: "Today's Habits"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
        let entry = loadEntry()

        // Refresh at the top of each hour
        let calendar = Calendar.current
        let nextHour = calendar.date(byAdding: .hour, value: 1, to: Date())!
        let roundedNext = calendar.date(bySetting: .minute, value: 0, of: nextHour)!
        let roundedSecond = calendar.date(bySetting: .second, value: 0, of: roundedNext)!

        let timeline = Timeline(entries: [entry], policy: .after(roundedSecond))
        completion(timeline)
    }

    private func loadEntry() -> HabitWidgetEntry {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupId),
              let data = sharedDefaults.data(forKey: "HabitGo_habits"),
              let decoded = try? JSONDecoder().decode([HabitEntry].self, from: data) else {
            return HabitWidgetEntry(date: Date(), habits: [], habitName: "Today's Habits")
        }
        return HabitWidgetEntry(date: Date(), habits: decoded, habitName: "Today's Habits")
    }
}

// MARK: - Widget View

struct HabitGoWidgetEntryView: View {
    var entry: HabitWidgetProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .systemLarge:
            largeView
        default:
            smallView
        }
    }

    private var smallView: some View {
        let completed = entry.habits.filter { $0.isCompletedToday }.count
        let total = entry.habits.count
        let progress = total > 0 ? Double(completed) / Double(total) : 0

        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: 56, height: 56)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color(hex: "#34C759"), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
                Text("\(completed)")
                    .font(.title.bold())
                    .foregroundStyle(Color(hex: "#34C759"))
            }

            Text("\(total) habits")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .containerBackground(Color(.systemBackground), for: .widget)
    }

    private var mediumView: some View {
        let completed = entry.habits.filter { $0.isCompletedToday }.count
        let total = entry.habits.count

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("HabitGo")
                    .font(.headline)
                    .foregroundStyle(Color(hex: "#34C759"))
                Spacer()
                Text("\(completed)/\(total)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if entry.habits.isEmpty {
                Spacer()
                Text("No habits yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ForEach(Array(entry.habits.prefix(3))) { habit in
                    habitRow(habit)
                }
            }
        }
        .padding(.vertical, 4)
        .containerBackground(Color(.systemBackground), for: .widget)
    }

    private var largeView: some View {
        let completed = entry.habits.filter { $0.isCompletedToday }.count
        let total = entry.habits.count
        let progress = total > 0 ? Double(completed) / Double(total) : 0

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("HabitGo")
                    .font(.headline)
                    .foregroundStyle(Color(hex: "#34C759"))
                Spacer()
                Text(formatDate(entry.date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(completed)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color(hex: "#34C759"))
                    Text("of \(total) completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 64, height: 64)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color(hex: "#34C759"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(progress * 100))%")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(hex: "#34C759"))
                }
            }

            Divider()

            if entry.habits.isEmpty {
                Spacer()
                Text("No habits yet. Open the app to add your first habit.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ForEach(Array(entry.habits.prefix(5))) { habit in
                    habitRow(habit)
                }
                if entry.habits.count > 5 {
                    Text("+\(entry.habits.count - 5) more")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .containerBackground(Color(.systemBackground), for: .widget)
    }

    private func habitRow(_ habit: HabitEntry) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: habit.colorHex).opacity(0.15))
                    .frame(width: 28, height: 28)
                Text(habit.icon)
                    .font(.caption)
            }

            Text(habit.name)
                .font(.caption)
                .lineLimit(1)

            Spacer()

            if habit.isCompletedToday {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(Color(hex: habit.colorHex))
            } else {
                Image(systemName: "circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Color extension for widget

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
}

// MARK: - Widget config

struct HabitGoWidget: Widget {
    let kind: String = "HabitGoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetProvider()) { entry in
            HabitGoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Habits")
        .description("Track your daily habits at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
