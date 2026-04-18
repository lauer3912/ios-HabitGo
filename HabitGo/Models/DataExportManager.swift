import Foundation

struct ExportedHabit: Codable {
    let id: String
    let name: String
    let icon: String
    let colorHex: String
    let frequency: String
    let createdAt: String
    let completions: [String: Bool]
    let reminderHour: Int?
    let reminderMinute: Int?
    let reminderEnabled: Bool
}

struct ExportData: Codable {
    let version: Int
    let exportedAt: String
    let habits: [ExportedHabit]
}

class DataExportManager {
    static let shared = DataExportManager()
    private init() {}

    func exportToJSON(habits: [Habit]) -> Data? {
        let exported = habits.map { habit in
            ExportedHabit(
                id: habit.id.uuidString,
                name: habit.name,
                icon: habit.icon,
                colorHex: habit.colorHex,
                frequency: habit.frequency.rawValue,
                createdAt: ISO8601DateFormatter().string(from: habit.createdAt),
                completions: habit.completions,
                reminderHour: habit.reminderHour,
                reminderMinute: habit.reminderMinute,
                reminderEnabled: habit.reminderEnabled
            )
        }

        let exportData = ExportData(
            version: 1,
            exportedAt: ISO8601DateFormatter().string(from: Date()),
            habits: exported
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(exportData)
    }

    func importFromJSON(_ data: Data) -> [Habit]? {
        guard let exportData = try? JSONDecoder().decode(ExportData.self, from: data) else {
            return nil
        }

        return exportData.habits.compactMap { exported -> Habit? in
            guard let uuid = UUID(uuidString: exported.id),
                  let frequency = HabitFrequency(rawValue: exported.frequency),
                  let createdAt = ISO8601DateFormatter().date(from: exported.createdAt) else {
                return nil
            }

            var habit = Habit(
                id: uuid,
                name: exported.name,
                icon: exported.icon,
                colorHex: exported.colorHex,
                frequency: frequency,
                reminderHour: exported.reminderHour,
                reminderMinute: exported.reminderMinute,
                reminderEnabled: exported.reminderEnabled
            )
            habit.createdAt = createdAt
            habit.completions = exported.completions
            return habit
        }
    }

    func exportToCSV(habits: [Habit]) -> String {
        var csv = "Habit Name,Icon,Color,Frequency,Created At,Total Completions,Current Streak,Longest Streak\n"
        for habit in habits {
            let row = [
                habit.name,
                habit.icon,
                habit.colorHex,
                habit.frequency.rawValue,
                ISO8601DateFormatter().string(from: habit.createdAt),
                String(habit.totalCompletions),
                String(habit.currentStreak),
                String(habit.longestStreak)
            ].map { "\"\($0)\"" }.joined(separator: ",")
            csv += row + "\n"
        }
        return csv
    }
}
