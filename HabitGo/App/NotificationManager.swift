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
        content.title = "HabitGo Reminder"
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
}
