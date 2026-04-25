import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func scheduleDailyReminder(for habit: Habit, at hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()

        // Remove existing notifications for this habit
        center.removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])

        guard habit.frequency.shouldCompleteToday else { return }

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "HabitArcFlow Reminder"
        content.body = "Don't forget: \(habit.name)"
        content.sound = .default
        content.badge = 1

        let request = UNNotificationRequest(
            identifier: habit.id.uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    func scheduleAllReminders(for habits: [Habit]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        for habit in habits {
            scheduleDailyReminder(for: habit, at: 9, minute: 0)
        }
    }

    func cancelReminder(for habitId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habitId.uuidString])
    }

    func clearAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    func scheduleFocusModeNotifications(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, days: Set<Int>) {
        cancelFocusMode()
        let center = UNUserNotificationCenter.current()

        for day in days {
            var dateComponents = DateComponents()
            dateComponents.hour = startHour
            dateComponents.minute = startMinute
            dateComponents.weekday = day

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            let content = UNMutableNotificationContent()
            content.title = "Focus Mode Active"
            content.body = "Habit reminders are silenced until \(String(format: "%02d:%02d", endHour, endMinute))"
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: "focus_mode_start_\(day)",
                content: content,
                trigger: trigger
            )

            center.add(request)

            // End focus mode notification
            var endComponents = DateComponents()
            endComponents.hour = endHour
            endComponents.minute = endMinute
            endComponents.weekday = day

            let endTrigger = UNCalendarNotificationTrigger(dateMatching: endComponents, repeats: true)

            let endContent = UNMutableNotificationContent()
            endContent.title = "Focus Mode Ended"
            endContent.body = "Habit reminders are now active again"
            endContent.sound = .default

            let endRequest = UNNotificationRequest(
                identifier: "focus_mode_end_\(day)",
                content: endContent,
                trigger: endTrigger
            )

            center.add(endRequest)
        }
    }

    func cancelFocusMode() {
        let center = UNUserNotificationCenter.current()
        let identifiers = (1...7).flatMap { day in ["focus_mode_start_\(day)", "focus_mode_end_\(day)"] }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
