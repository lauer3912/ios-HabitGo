import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var notificationAuthGranted = false

    private let storageKey = "HabitGo_habits"

    init() {
        load()
        checkNotificationAuth()
    }

    // MARK: - Persistence

    func save() {
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Habit].self, from: data) else {
            return
        }
        habits = decoded
    }

    // MARK: - CRUD

    func addHabit(
        name: String,
        icon: String,
        colorHex: String,
        frequency: HabitFrequency,
        reminderHour: Int?,
        reminderMinute: Int?,
        reminderEnabled: Bool
    ) {
        var habit = Habit(
            name: name,
            icon: icon,
            colorHex: colorHex,
            frequency: frequency,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute,
            reminderEnabled: reminderEnabled
        )

        if reminderEnabled, let h = habit.reminderHour, let m = habit.reminderMinute {
            NotificationManager.shared.scheduleDailyReminder(for: habit, at: h, minute: m)
        }

        habits.append(habit)
        save()
    }

    func deleteHabit(_ habit: Habit) {
        NotificationManager.shared.cancelReminder(for: habit.id)
        habits.removeAll { $0.id == habit.id }
        save()
    }

    func toggleHabit(_ habit: Habit) {
        guard let idx = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[idx].toggleToday()
        save()
    }

    func updateHabit(
        _ habit: Habit,
        name: String,
        icon: String,
        colorHex: String,
        frequency: HabitFrequency,
        reminderHour: Int?,
        reminderMinute: Int?,
        reminderEnabled: Bool
    ) {
        guard let idx = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[idx].name = name
        habits[idx].icon = icon
        habits[idx].colorHex = colorHex
        habits[idx].frequency = frequency
        habits[idx].reminderHour = reminderHour
        habits[idx].reminderMinute = reminderMinute
        habits[idx].reminderEnabled = reminderEnabled

        NotificationManager.shared.cancelReminder(for: habit.id)
        if reminderEnabled, let h = reminderHour, let m = reminderMinute {
            NotificationManager.shared.scheduleDailyReminder(for: habits[idx], at: h, minute: m)
        }

        save()
    }

    // MARK: - Notifications

    func checkNotificationAuth() {
        NotificationManager.shared.checkAuthorizationStatus { [weak self] granted in
            self?.notificationAuthGranted = granted
        }
    }

    func requestNotificationAuth(completion: @escaping (Bool) -> Void) {
        NotificationManager.shared.requestAuthorization { [weak self] granted in
            self?.notificationAuthGranted = granted
            completion(granted)
        }
    }

    func rescheduleAllNotifications() {
        NotificationManager.shared.clearAll()
        for habit in habits where habit.reminderEnabled {
            if let h = habit.reminderHour, let m = habit.reminderMinute {
                NotificationManager.shared.scheduleDailyReminder(for: habit, at: h, minute: m)
            }
        }
    }

    // MARK: - Stats

    var completedToday: Int {
        habits.filter { $0.isCompletedToday }.count
    }

    var totalToday: Int {
        habits.count
    }

    var todayProgress: Double {
        guard totalToday > 0 else { return 0 }
        return Double(completedToday) / Double(totalToday)
    }

    var overallStreak: Int {
        habits.map { $0.currentStreak }.max() ?? 0
    }

    var totalCompletions: Int {
        habits.reduce(0) { $0 + $1.totalCompletions }
    }

    // MARK: - Calendar History

    func completionsForMonth(year: Int, month: Int) -> [String: Bool] {
        var result: [String: Bool] = [:]
        let calendar = Calendar.current

        for habit in habits {
            for (dayKey, completed) in habit.completions {
                if completed {
                    let parts = dayKey.split(separator: "-").compactMap { Int($0) }
                    if parts.count == 3, parts[0] == year, parts[1] == month {
                        result[dayKey] = true
                    }
                }
            }
        }
        return result
    }

    func habitCompletionForMonth(habitId: UUID, year: Int, month: Int) -> [String: Bool] {
        guard let habit = habits.first(where: { $0.id == habitId }) else { return [:] }
        var result: [String: Bool] = [:]
        for (dayKey, completed) in habit.completions {
            if completed {
                let parts = dayKey.split(separator: "-").compactMap { Int($0) }
                if parts.count == 3, parts[0] == year, parts[1] == month {
                    result[dayKey] = true
                }
            }
        }
        return result
    }

    // MARK: - Export / Import

    func exportJSON() -> Data? {
        DataExportManager.shared.exportToJSON(habits: habits)
    }

    func exportCSV() -> String {
        DataExportManager.shared.exportToCSV(habits: habits)
    }

    func importJSON(from data: Data) -> Bool {
        guard let imported = DataExportManager.shared.importFromJSON(data) else { return false }
        habits = imported
        save()
        rescheduleAllNotifications()
        return true
    }
}

// MARK: - Color helpers

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 3:
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6:
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
