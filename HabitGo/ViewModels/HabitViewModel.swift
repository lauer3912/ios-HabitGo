import Foundation
import SwiftUI
import Combine

@MainActor
class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var notificationAuthGranted = false
    @Published var categories: [HabitCategory] = HabitCategory.defaultCategories
    @Published var achievements: [Achievement] = []
    @Published var weeklyGoals: [WeeklyGoal] = []
    @Published var habitNotes: [HabitNote] = []

    private let storageKey = "HabitGo_habits"
    private let categoriesKey = "HabitGo_categories"
    private let achievementsKey = "HabitGo_achievements"
    private let weeklyGoalsKey = "HabitGo_weeklyGoals"
    private let notesKey = "HabitGo_notes"
    private let appGroupId = "group.com.ggsheng.HabitGo"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    init() {
        load()
        checkNotificationAuth()
        checkAndUpdateAchievements()
    }

    // MARK: - Persistence

    func save() {
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: storageKey)
            sharedDefaults?.set(data, forKey: storageKey)
        }
    }

    func load() {
        if let data = sharedDefaults?.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        } else if let data = UserDefaults.standard.data(forKey: storageKey),
                  let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }

        if let data = UserDefaults.standard.data(forKey: categoriesKey),
           let decoded = try? JSONDecoder().decode([HabitCategory].self, from: data) {
            categories = decoded
        }

        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            achievements = AchievementType.allCases.map { Achievement(type: $0) }
        }

        if let data = UserDefaults.standard.data(forKey: weeklyGoalsKey),
           let decoded = try? JSONDecoder().decode([WeeklyGoal].self, from: data) {
            weeklyGoals = decoded
        }

        if let data = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([HabitNote].self, from: data) {
            habitNotes = decoded
        }
    }

    func saveCategories(_ cats: [HabitCategory]) {
        categories = cats
        if let data = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(data, forKey: categoriesKey)
        }
    }

    func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }

    func saveWeeklyGoals() {
        if let data = try? JSONEncoder().encode(weeklyGoals) {
            UserDefaults.standard.set(data, forKey: weeklyGoalsKey)
        }
    }

    func saveNotes() {
        if let data = try? JSONEncoder().encode(habitNotes) {
            UserDefaults.standard.set(data, forKey: notesKey)
        }
    }

    // MARK: - CRUD

    func addHabit(
        name: String,
        icon: String,
        colorHex: String,
        frequency: HabitFrequency,
        reminderHour: Int?,
        reminderMinute: Int?,
        reminderEnabled: Bool,
        categoryId: UUID? = nil,
        weeklyGoalTarget: Int? = nil
    ) {
        var habit = Habit(
            name: name,
            icon: icon,
            colorHex: colorHex,
            frequency: frequency,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute,
            reminderEnabled: reminderEnabled,
            categoryId: categoryId,
            weeklyGoalTarget: weeklyGoalTarget
        )

        if reminderEnabled, let h = habit.reminderHour, let m = habit.reminderMinute {
            NotificationManager.shared.scheduleDailyReminder(for: habit, at: h, minute: m)
        }

        habits.append(habit)
        save()
        checkAndUpdateAchievements()

        // Create weekly goal if target set
        if let target = weeklyGoalTarget {
            createWeeklyGoal(for: habit, target: target)
        }
    }

    func deleteHabit(_ habit: Habit) {
        NotificationManager.shared.cancelReminder(for: habit.id)
        habits.removeAll { $0.id == habit.id }
        weeklyGoals.removeAll { $0.habitId == habit.id }
        habitNotes.removeAll { $0.habitId == habit.id }
        save()
        saveWeeklyGoals()
        saveNotes()
    }

    func toggleHabit(_ habit: Habit) {
        guard let idx = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        let wasCompleted = habits[idx].isCompletedToday
        habits[idx].toggleToday()
        save()

        // Update weekly goal
        if let goalIdx = weeklyGoals.firstIndex(where: { $0.habitId == habit.id && $0.weekKey == WeeklyGoal.weekStart().description }) {
            let key = habit.todayKey
            if habits[idx].completions[key] == true {
                weeklyGoals[goalIdx].actualCompletions += 1
            } else {
                weeklyGoals[goalIdx].actualCompletions = max(0, weeklyGoals[goalIdx].actualCompletions - 1)
            }
            saveWeeklyGoals()
        }

        // Check achievements
        if !wasCompleted {
            checkAndUpdateAchievements()
        }
    }

    func updateHabit(
        _ habit: Habit,
        name: String,
        icon: String,
        colorHex: String,
        frequency: HabitFrequency,
        reminderHour: Int?,
        reminderMinute: Int?,
        reminderEnabled: Bool,
        categoryId: UUID?,
        weeklyGoalTarget: Int?
    ) {
        guard let idx = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[idx].name = name
        habits[idx].icon = icon
        habits[idx].colorHex = colorHex
        habits[idx].frequency = frequency
        habits[idx].reminderHour = reminderHour
        habits[idx].reminderMinute = reminderMinute
        habits[idx].reminderEnabled = reminderEnabled
        habits[idx].categoryId = categoryId
        habits[idx].weeklyGoalTarget = weeklyGoalTarget

        NotificationManager.shared.cancelReminder(for: habit.id)
        if reminderEnabled, let h = reminderHour, let m = reminderMinute {
            NotificationManager.shared.scheduleDailyReminder(for: habits[idx], at: h, minute: m)
        }

        save()

        // Update weekly goal
        if let target = weeklyGoalTarget {
            if let goalIdx = weeklyGoals.firstIndex(where: { $0.habitId == habit.id }) {
                weeklyGoals[goalIdx].targetCompletions = target
            } else {
                createWeeklyGoal(for: habits[idx], target: target)
            }
        }
        saveWeeklyGoals()
    }

    // MARK: - Notes

    func addNote(_ note: HabitNote) {
        habitNotes.append(note)
        saveNotes()
    }

    func notes(for habitId: UUID) -> [HabitNote] {
        habitNotes.filter { $0.habitId == habitId }.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Weekly Goals

    func createWeeklyGoal(for habit: Habit, target: Int) {
        let weekStart = WeeklyGoal.weekStart()
        let goal = WeeklyGoal(
            id: UUID(),
            habitId: habit.id,
            weekStartDate: weekStart,
            targetCompletions: target,
            actualCompletions: 0
        )
        weeklyGoals.append(goal)
        saveWeeklyGoals()
    }

    func weeklyGoal(for habit: Habit) -> WeeklyGoal? {
        let weekStart = WeeklyGoal.weekStart()
        return weeklyGoals.first { $0.habitId == habit.id && $0.weekStartDate == weekStart }
    }

    var habitsWithGoals: [Habit] {
        habits.filter { $0.weeklyGoalTarget != nil }
    }

    var completedThisWeek: Int {
        let weekStart = WeeklyGoal.weekStart()
        let calendar = Calendar.current
        var count = 0
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                let key = Habit.dayKey(from: date)
                count += habits.filter { $0.completions[key] == true }.count
            }
        }
        return count
    }

    var totalThisWeek: Int {
        habits.count * 7
    }

    var weeklyProgress: Double {
        guard totalThisWeek > 0 else { return 0 }
        return Double(completedThisWeek) / Double(totalThisWeek)
    }

    var weeklyTrendData: [WeeklyTrendData] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<4).reversed().compactMap { weekOffset in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today) else { return nil }
            let monday = WeeklyGoal.weekStart(for: weekStart)
            var total = 0
            for dayOffset in 0..<7 {
                if let day = calendar.date(byAdding: .day, value: dayOffset, to: monday) {
                    let key = Habit.dayKey(from: day)
                    total += habits.filter { $0.completions[key] == true }.count
                }
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return WeeklyTrendData(weekLabel: formatter.string(from: monday), completions: total)
        }
    }

    // MARK: - Achievements

    var allAchievements: [Achievement] {
        AchievementType.allCases.map { type in
            achievements.first { $0.type == type } ?? Achievement(type: type)
        }
    }

    func checkAndUpdateAchievements() {
        // First Step
        updateAchievement(.firstStep) { _ in
            self.habits.contains { $0.totalCompletions >= 1 }
        }

        // Week Streak
        updateAchievement(.weekStreak) { _ in
            self.habits.contains { $0.currentStreak >= 7 }
        }

        // Month Streak
        updateAchievement(.monthStreak) { _ in
            self.habits.contains { $0.currentStreak >= 30 }
        }

        // Century Streak
        updateAchievement(.centuryStreak) { _ in
            self.habits.contains { $0.currentStreak >= 100 }
        }

        // Perfect Day
        updateAchievement(.perfectDay) { _ in
            !self.habits.isEmpty && self.habits.allSatisfy { $0.isCompletedToday }
        }

        // Ten Habits
        updateAchievement(.tenHabits) { _ in
            self.habits.count >= 10
        }

        // Habit Master (500 completions)
        updateAchievement(.habitMaster) { _ in
            self.habits.reduce(0) { $0 + $1.totalCompletions } >= 500
        }

        saveAchievements()
    }

    private func updateAchievement(_ type: AchievementType, condition: @escaping (HabitViewModel) -> Bool) {
        if let idx = achievements.firstIndex(where: { $0.type == type }) {
            if !achievements[idx].isUnlocked && condition(self) {
                achievements[idx].isUnlocked = true
                achievements[idx].earnedDate = Date()
                achievements[idx].progress = 1.0
            } else if !achievements[idx].isUnlocked {
                achievements[idx].progress = min(achievements[idx].progress + 0.1, 0.9)
            }
        } else {
            var achievement = Achievement(type: type)
            if condition(self) {
                achievement.isUnlocked = true
                achievement.earnedDate = Date()
                achievement.progress = 1.0
            }
            achievements.append(achievement)
        }
    }

    // MARK: - Focus Mode

    func setFocusMode(enabled: Bool, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, days: Set<Int>) {
        let defaults = UserDefaults.standard
        defaults.set(enabled, forKey: "HabitArcFlow_focusEnabled")
        defaults.set(startHour, forKey: "HabitArcFlow_focusStartHour")
        defaults.set(startMinute, forKey: "HabitArcFlow_focusStartMinute")
        defaults.set(endHour, forKey: "HabitArcFlow_focusEndHour")
        defaults.set(endMinute, forKey: "HabitArcFlow_focusEndMinute")
        defaults.set(Array(days), forKey: "HabitArcFlow_focusDays")

        if enabled {
            NotificationManager.shared.scheduleFocusModeNotifications(
                startHour: startHour, startMinute: startMinute,
                endHour: endHour, endMinute: endMinute,
                days: days
            )
        } else {
            NotificationManager.shared.cancelFocusMode()
        }
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
