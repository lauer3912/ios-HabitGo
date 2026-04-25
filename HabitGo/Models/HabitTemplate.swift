import Foundation

// MARK: - Habit Template
struct HabitTemplate: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var frequency: HabitFrequency
    var category: String
    var description: String
    var suggestedReminderHour: Int?
    var suggestedReminderMinute: Int?

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        frequency: HabitFrequency = .daily,
        category: String,
        description: String,
        suggestedReminderHour: Int? = nil,
        suggestedReminderMinute: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.frequency = frequency
        self.category = category
        self.description = description
        self.suggestedReminderHour = suggestedReminderHour
        self.suggestedReminderMinute = suggestedReminderMinute
    }

    func toHabit() -> Habit {
        Habit(
            name: name,
            icon: icon,
            colorHex: colorHex,
            frequency: frequency,
            reminderHour: suggestedReminderHour,
            reminderMinute: suggestedReminderMinute,
            reminderEnabled: suggestedReminderHour != nil
        )
    }

    static let templates: [HabitTemplate] = [
        // Health
        HabitTemplate(name: "Drink Water", icon: "drop.fill", colorHex: "#007AFF", frequency: .daily, category: "Health", description: "Drink 8 glasses of water daily", suggestedReminderHour: 9, suggestedReminderMinute: 0),
        HabitTemplate(name: "Take Vitamins", icon: "pill.fill", colorHex: "#FF9500", frequency: .daily, category: "Health", description: "Take your daily vitamins", suggestedReminderHour: 8, suggestedReminderMinute: 0),
        HabitTemplate(name: "Meditate", icon: "brain.head.profile", colorHex: "#AF52DE", frequency: .daily, category: "Mindfulness", description: "10 minutes of meditation", suggestedReminderHour: 7, suggestedReminderMinute: 0),
        HabitTemplate(name: " journal", icon: "book.fill", colorHex: "#34C759", frequency: .daily, category: "Mindfulness", description: "Write in your journal", suggestedReminderHour: 21, suggestedReminderMinute: 0),

        // Fitness
        HabitTemplate(name: "Morning Workout", icon: "figure.run", colorHex: "#FF3B30", frequency: .daily, category: "Fitness", description: "30 min morning exercise", suggestedReminderHour: 7, suggestedReminderMinute: 0),
        HabitTemplate(name: "Stretch", icon: "figure.yoga", colorHex: "#00C7BE", frequency: .daily, category: "Fitness", description: "15 min stretching routine", suggestedReminderHour: 8, suggestedReminderMinute: 30),
        HabitTemplate(name: "Walk 10K Steps", icon: "figure.walk", colorHex: "#30D158", frequency: .daily, category: "Fitness", description: "Reach 10,000 steps today", suggestedReminderHour: 18, suggestedReminderMinute: 0),

        // Productivity
        HabitTemplate(name: "Read 30 Minutes", icon: "book.fill", colorHex: "#007AFF", frequency: .daily, category: "Learning", description: "Read for at least 30 minutes", suggestedReminderHour: 21, suggestedReminderMinute: 0),
        HabitTemplate(name: "Learn Language", icon: "globe", colorHex: "#5856D6", frequency: .daily, category: "Learning", description: "Practice a new language", suggestedReminderHour: 12, suggestedReminderMinute: 0),
        HabitTemplate(name: "No Social Media", icon: "iphone.slash", colorHex: "#FF2D55", frequency: .daily, category: "Productivity", description: "Avoid social media for the entire day", suggestedReminderHour: 9, suggestedReminderMinute: 0),
        HabitTemplate(name: "Inbox Zero", icon: "envelope.fill", colorHex: "#007AFF", frequency: .daily, category: "Productivity", description: "Clear your email inbox", suggestedReminderHour: 10, suggestedReminderMinute: 0),
        HabitTemplate(name: "Plan Tomorrow", icon: "checklist", colorHex: "#34C759", frequency: .daily, category: "Productivity", description: "Plan your next day in advance", suggestedReminderHour: 21, suggestedReminderMinute: 0),

        // Sleep
        HabitTemplate(name: "Early Sleep", icon: "bed.double.fill", colorHex: "#5856D6", frequency: .daily, category: "Sleep", description: "Be in bed by 10 PM", suggestedReminderHour: 22, suggestedReminderMinute: 0),
        HabitTemplate(name: "No Screens Before Bed", icon: "moon.fill", colorHex: "#AF52DE", frequency: .daily, category: "Sleep", description: "No screens 1 hour before bed", suggestedReminderHour: 21, suggestedReminderMinute: 0),

        // Lifestyle
        HabitTemplate(name: "Gratitude", icon: "heart.fill", colorHex: "#FF2D55", frequency: .daily, category: "Mindfulness", description: "Write 3 things you're grateful for", suggestedReminderHour: 21, suggestedReminderMinute: 0),
        HabitTemplate(name: "Cold Shower", icon: "snowflake", colorHex: "#64D2FF", frequency: .daily, category: "Health", description: "Take a cold shower", suggestedReminderHour: 7, suggestedReminderMinute: 30),
        HabitTemplate(name: "No Alcohol", icon: "xmark.circle.fill", colorHex: "#8E8E93", frequency: .daily, category: "Health", description: "Avoid alcohol today", suggestedReminderHour: 18, suggestedReminderMinute: 0)
    ]
}
