import Foundation
import SwiftUI

@MainActor
class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []

    private let storageKey = "HabitGo_habits"

    init() {
        load()
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

    func addHabit(name: String, icon: String, colorHex: String, frequency: HabitFrequency) {
        let habit = Habit(name: name, icon: icon, colorHex: colorHex, frequency: frequency)
        habits.append(habit)
        save()
    }

    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        save()
    }

    func toggleHabit(_ habit: Habit) {
        guard let idx = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[idx].toggleToday()
        save()
    }

    func updateHabit(_ habit: Habit, name: String, icon: String, colorHex: String, frequency: HabitFrequency) {
        guard let idx = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[idx].name = name
        habits[idx].icon = icon
        habits[idx].colorHex = colorHex
        habits[idx].frequency = frequency
        save()
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
