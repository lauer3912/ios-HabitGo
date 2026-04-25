import Foundation

struct Habit: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var frequency: HabitFrequency
    var createdAt: Date
    var completions: [String: Bool]
    var reminderHour: Int?
    var reminderMinute: Int?
    var reminderEnabled: Bool
    var categoryId: UUID?
    var weeklyGoalTarget: Int?

    // NEW: Energy Level
    var energyLevel: EnergyLevel?

    // NEW: Habit Stacking
    var stackedHabitId: UUID?
    var isStackedFrom: Bool

    // NEW: Smart Notifications
    var smartSuggestionEnabled: Bool
    var typicalCompletionTime: Date?

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String = "#34C759",
        frequency: HabitFrequency = .daily,
        reminderHour: Int? = nil,
        reminderMinute: Int? = nil,
        reminderEnabled: Bool = false,
        categoryId: UUID? = nil,
        weeklyGoalTarget: Int? = nil,
        energyLevel: EnergyLevel? = nil,
        stackedHabitId: UUID? = nil,
        isStackedFrom: Bool = false,
        smartSuggestionEnabled: Bool = false,
        typicalCompletionTime: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.frequency = frequency
        self.createdAt = Date()
        self.completions = [:]
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.reminderEnabled = reminderEnabled
        self.categoryId = categoryId
        self.weeklyGoalTarget = weeklyGoalTarget
        self.energyLevel = energyLevel
        self.stackedHabitId = stackedHabitId
        self.isStackedFrom = isStackedFrom
        self.smartSuggestionEnabled = smartSuggestionEnabled
        self.typicalCompletionTime = typicalCompletionTime
    }

    var todayKey: String {
        Self.dayKey(from: Date())
    }

    var isCompletedToday: Bool {
        completions[todayKey] == true
    }

    var currentStreak: Int {
        var streak = 0
        var date = Date()
        while true {
            let key = Self.dayKey(from: date)
            if completions[key] == true {
                streak += 1
                date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
            } else {
                break
            }
        }
        return streak
    }

    var longestStreak: Int {
        guard !completions.isEmpty else { return 0 }
        let sortedDays = completions.keys.sorted()
        var maxStreak = 0
        var current = 0
        var prevDate: Date?
        for dayStr in sortedDays {
            guard completions[dayStr] == true else { continue }
            let date = Self.dateFromKey(dayStr)
            if let prev = prevDate,
               let diff = Calendar.current.dateComponents([.day], from: prev, to: date).day,
               diff == 1 {
                current += 1
            } else {
                current = 1
            }
            maxStreak = max(maxStreak, current)
            prevDate = date
        }
        return maxStreak
    }

    var totalCompletions: Int {
        completions.values.filter { $0 }.count
    }

    var streakFireEmoji: String {
        switch currentStreak {
        case 7...: return "🔥🔥"
        case 30...: return "🔥🔥🔥"
        case 100...: return "⭐🔥🔥🔥"
        default: return currentStreak > 0 ? "🔥" : ""
        }
    }

    mutating func toggleToday() {
        let key = todayKey
        completions[key] = !(completions[key] ?? false)
    }

    static func dayKey(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    static func dateFromKey(_ key: String) -> Date {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: key) ?? Date()
    }
}

enum HabitFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekdays = "Weekdays"
    case weekends = "Weekends"
    case weekly = "Weekly"

    var shouldCompleteToday: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        switch self {
        case .daily: return true
        case .weekdays: return weekday >= 2 && weekday <= 6
        case .weekends: return weekday == 1 || weekday == 7
        case .weekly: return true
        }
    }
}