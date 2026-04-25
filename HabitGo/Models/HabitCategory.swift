import Foundation

// MARK: - Habit Category
struct HabitCategory: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var sortOrder: Int

    init(id: UUID = UUID(), name: String, icon: String, colorHex: String, sortOrder: Int = 0) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.sortOrder = sortOrder
    }

    static let defaultCategories: [HabitCategory] = [
        HabitCategory(name: "Health", icon: "heart.fill", colorHex: "#FF3B30", sortOrder: 0),
        HabitCategory(name: "Fitness", icon: "dumbbell.fill", colorHex: "#FF9500", sortOrder: 1),
        HabitCategory(name: "Productivity", icon: "bolt.fill", colorHex: "#34C759", sortOrder: 2),
        HabitCategory(name: "Learning", icon: "book.fill", colorHex: "#007AFF", sortOrder: 3),
        HabitCategory(name: "Mindfulness", icon: "brain.head.profile", colorHex: "#AF52DE", sortOrder: 4),
        HabitCategory(name: "Sleep", icon: "moon.fill", colorHex: "#5856D6", sortOrder: 5)
    ]
}
