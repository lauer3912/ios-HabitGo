import Foundation

// MARK: - Weekly Goal
struct WeeklyGoal: Identifiable, Codable, Equatable {
    var id: UUID
    var habitId: UUID
    var weekStartDate: Date // Monday of the week
    var targetCompletions: Int
    var actualCompletions: Int

    var weekKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-'W'ww"
        return formatter.string(from: weekStartDate)
    }

    var progress: Double {
        guard targetCompletions > 0 else { return 0 }
        return min(Double(actualCompletions) / Double(targetCompletions), 1.0)
    }

    var isCompleted: Bool {
        actualCompletions >= targetCompletions
    }

    static func weekStart(for date: Date = Date()) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = 2 // Monday
        return calendar.date(from: components) ?? date
    }
}

// MARK: - Habit Note
struct HabitNote: Identifiable, Codable, Equatable {
    var id: UUID
    var habitId: UUID
    var dateKey: String // "yyyy-MM-dd"
    var content: String
    var mood: Mood?
    var createdAt: Date

    init(habitId: UUID, dateKey: String, content: String, mood: Mood? = nil) {
        self.id = UUID()
        self.habitId = habitId
        self.dateKey = dateKey
        self.content = content
        self.mood = mood
        self.createdAt = Date()
    }
}

enum Mood: String, Codable, CaseIterable {
    case great = "great"
    case good = "good"
    case okay = "okay"
    case bad = "bad"

    var icon: String {
        switch self {
        case .great: return "face.smiling.fill"
        case .good: return "hand.thumbsup.fill"
        case .okay: return "minus.circle.fill"
        case .bad: return "hand.thumbsdown.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .great: return "#34C759"
        case .good: return "#007AFF"
        case .okay: return "#FF9500"
        case .bad: return "#FF3B30"
        }
    }
}
