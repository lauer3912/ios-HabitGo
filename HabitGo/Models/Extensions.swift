import Foundation
import CoreLocation

// MARK: - Habit Stacking
struct HabitChain: Identifiable, Codable {
    let id: UUID
    var anchorHabitId: UUID
    var linkedHabitId: UUID
    var isEnabled: Bool

    init(anchorHabitId: UUID, linkedHabitId: UUID) {
        self.id = UUID()
        self.anchorHabitId = anchorHabitId
        self.linkedHabitId = linkedHabitId
        self.isEnabled = true
    }
}

struct HabitSuggestion: Identifiable, Codable {
    let id: UUID
    let habitId: UUID
    let suggestedTime: Date
    let reason: String
    var isAccepted: Bool

    init(habitId: UUID, suggestedTime: Date, reason: String) {
        self.id = UUID()
        self.habitId = habitId
        self.suggestedTime = suggestedTime
        self.reason = reason
        self.isAccepted = false
    }
}

// MARK: - Progress Photos
struct ProgressPhoto: Identifiable, Codable {
    let id: UUID
    let habitId: UUID
    let imageData: Data
    let caption: String?
    let createdAt: Date

    init(habitId: UUID, imageData: Data, caption: String? = nil) {
        self.id = UUID()
        self.habitId = habitId
        self.imageData = imageData
        self.caption = caption
        self.createdAt = Date()
    }
}

// MARK: - Energy Level
enum EnergyLevel: String, Codable, CaseIterable {
    case high = "High Energy"
    case medium = "Medium Energy"
    case low = "Low Energy"

    var icon: String {
        switch self {
        case .high: return "bolt.fill"
        case .medium: return "battery.50"
        case .low: return "battery.25"
        }
    }

    var color: String {
        switch self {
        case .high: return "#FF9500"
        case .medium: return "#34C759"
        case .low: return "#8E8E93"
        }
    }
}

// MARK: - Location Reminders
struct LocationReminder: Identifiable, Codable {
    let id: UUID
    var habitId: UUID
    var locationName: String
    var latitude: Double
    var longitude: Double
    var radius: Double // meters
    var isEnabled: Bool

    init(habitId: UUID, locationName: String, latitude: Double, longitude: Double, radius: Double = 100) {
        self.id = UUID()
        self.habitId = habitId
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.isEnabled = true
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Heat Map Data
struct HeatMapDay: Identifiable {
    let id: String // "yyyy-MM-dd"
    let date: Date
    let completionCount: Int
    let totalHabits: Int

    var intensity: Double {
        guard totalHabits > 0 else { return 0 }
        return Double(completionCount) / Double(totalHabits)
    }

    var color: Color {
        switch intensity {
        case 0: return Color.gray.opacity(0.1)
        case 0..<0.25: return Color(hex: "0E4429")
        case 0.25..<0.5: return Color(hex: "006D32")
        case 0.5..<0.75: return Color(hex: "26A641")
        case 0.75..<1.0: return Color(hex: "39D353")
        default: return Color(hex: "006D32")
        }
    }
}

// MARK: - Weekly Review
struct WeeklyReview: Identifiable, Codable {
    let id: UUID
    let weekStartDate: Date
    let totalCompletions: Int
    let targetCompletions: Int
    let completionRate: Double
    let bestHabit: String?
    let mostImprovedHabit: String?
    let insights: [String]
    let habitsData: [String: Int]

    init(weekStartDate: Date, totalCompletions: Int, targetCompletions: Int, completionRate: Double, bestHabit: String?, mostImprovedHabit: String?, insights: [String], habitsData: [String: Int]) {
        self.id = UUID()
        self.weekStartDate = weekStartDate
        self.totalCompletions = totalCompletions
        self.targetCompletions = targetCompletions
        self.completionRate = completionRate
        self.bestHabit = bestHabit
        self.mostImprovedHabit = mostImprovedHabit
        self.insights = insights
        self.habitsData = habitsData
    }

    var weekLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: weekStartDate)
        let end = formatter.string(from: Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate) ?? weekStartDate)
        return "\(start) - \(end)"
    }
}

// MARK: - Sound Effect
enum HabitSoundEffect: String, CaseIterable {
    case none = "None"
    case click = "Click"
    case pop = "Pop"
    case celebration = "Celebration"
    case chime = "Chime"
    case success = "Success"

    var systemSoundName: String {
        switch self {
        case .click: return "tock"
        case .pop: return "pop"
        case .celebration: return "celebration"
        case .chime: return "chime"
        case .success: return "success"
        case .none: return ""
        }
    }
}

// MARK: - Haptic Feedback
enum HabitHaptic: String, CaseIterable {
    case none = "None"
    case light = "Light"
    case medium = "Medium"
    case heavy = "Heavy"
    case success = "Success"
    case warning = "Warning"
}

// MARK: - Achievement Categories
enum AchievementCategory: String, Codable, CaseIterable {
    case streak = "Streak"
    case milestone = "Milestone"
    case consistency = "Consistency"
    case special = "Special"

    var icon: String {
        switch self {
        case .streak: return "flame.fill"
        case .milestone: return "flag.fill"
        case .consistency: return "chart.bar.fill"
        case .special: return "star.fill"
        }
    }
}

// MARK: - Habit Note Extension
struct HabitNote: Identifiable, Codable {
    let id: UUID
    let habitId: UUID
    let content: String
    let createdAt: Date

    init(habitId: UUID, content: String) {
        self.id = UUID()
        self.habitId = habitId
        self.content = content
        self.createdAt = Date()
    }
}

// MARK: - Weekly Goal Extension
struct WeeklyGoal: Identifiable, Codable {
    let id: UUID
    let habitId: UUID
    let weekStartDate: Date
    var targetCompletions: Int
    var actualCompletions: Int

    init(id: UUID = UUID(), habitId: UUID, weekStartDate: Date, targetCompletions: Int, actualCompletions: Int = 0) {
        self.id = id
        self.habitId = habitId
        self.weekStartDate = weekStartDate
        self.targetCompletions = targetCompletions
        self.actualCompletions = actualCompletions
    }

    var progress: Double {
        guard targetCompletions > 0 else { return 0 }
        return min(Double(actualCompletions) / Double(targetCompletions), 1.0)
    }

    static func weekStart(from date: Date = Date()) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
}

// MARK: - Weekly Trend Data
struct WeeklyTrendData: Identifiable {
    let id = UUID()
    let weekLabel: String
    let completions: Int
}

// MARK: - Data Export Manager
struct DataExportManager {
    static func exportToJSON(habits: [Habit]) -> Data? {
        try? JSONEncoder().encode(ExportData(habits: habits, exportDate: Date(), version: "3.0"))
    }

    static func exportToCSV(habits: [Habit]) -> String {
        var csv = "Habit Name,Icon,Color,Frequency,Created Date,Total Completions,Current Streak,Longest Streak\n"
        for habit in habits {
            csv += "\"\(habit.name)\",\"\(habit.icon)\",\"\(habit.colorHex)\",\"\(habit.frequency.rawValue)\",\"\(habit.createdAt)\",\(habit.totalCompletions),\(habit.currentStreak),\(habit.longestStreak)\n"
        }
        return csv
    }

    static func importFromJSON(_ data: Data) -> [Habit]? {
        guard let exportData = try? JSONDecoder().decode(ExportData.self, from: data) else {
            return nil
        }
        return exportData.habits
    }
}

struct ExportData: Codable {
    let habits: [Habit]
    let exportDate: Date
    let version: String
}