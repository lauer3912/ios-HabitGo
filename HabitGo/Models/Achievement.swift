import Foundation

// MARK: - Achievement
struct Achievement: Identifiable, Codable, Equatable {
    var id: UUID
    var type: AchievementType
    var habitId: UUID?
    var earnedDate: Date?
    var progress: Double // 0.0 to 1.0
    var isUnlocked: Bool

    init(type: AchievementType, habitId: UUID? = nil, earnedDate: Date? = nil, progress: Double = 0, isUnlocked: Bool = false) {
        self.id = UUID()
        self.type = type
        self.habitId = habitId
        self.earnedDate = earnedDate
        self.progress = progress
        self.isUnlocked = isUnlocked
    }

    var title: String { type.title }
    var description: String { type.description }
    var icon: String { type.icon }
    var colorHex: String { type.colorHex }
}

enum AchievementType: String, Codable, CaseIterable {
    case firstStep = "first_step"
    case weekStreak = "week_streak"
    case monthStreak = "month_streak"
    case centuryStreak = "century_streak"
    case perfectDay = "perfect_day"
    case earlyBird = "early_bird"
    case habitMaster = "habit_master"
    case consistencyKing = "consistency_king"
    case tenHabits = "ten_habits"
    case comebackKid = "comeback_kid"

    var title: String {
        switch self {
        case .firstStep: return "First Step"
        case .weekStreak: return "Week Warrior"
        case .monthStreak: return "Month Master"
        case .centuryStreak: return "Century Club"
        case .perfectDay: return "Perfect Day"
        case .earlyBird: return "Early Bird"
        case .habitMaster: return "Habit Master"
        case .consistencyKing: return "Consistency King"
        case .tenHabits: return "Habit Collector"
        case .comebackKid: return "Comeback Kid"
        }
    }

    var description: String {
        switch self {
        case .firstStep: return "Complete your first habit"
        case .weekStreak: return "7-day streak on any habit"
        case .monthStreak: return "30-day streak on any habit"
        case .centuryStreak: return "100-day streak on any habit"
        case .perfectDay: return "Complete all habits in one day"
        case .earlyBird: return "Complete a habit before 7 AM"
        case .habitMaster: return "Complete 500 total habit check-ins"
        case .consistencyKing: return "Maintain 90% weekly completion for 4 weeks"
        case .tenHabits: return "Create 10 different habits"
        case .comebackKid: return "Resume a habit after a 7+ day break"
        }
    }

    var icon: String {
        switch self {
        case .firstStep: return "flag.fill"
        case .weekStreak: return "flame.fill"
        case .monthStreak: return "flame.fill"
        case .centuryStreak: return "star.fill"
        case .perfectDay: return "checkmark.seal.fill"
        case .earlyBird: return "sunrise.fill"
        case .habitMaster: return "crown.fill"
        case .consistencyKing: return "chart.bar.fill"
        case .tenHabits: return "square.stack.fill"
        case .comebackKid: return "arrow.uturn.backward.circle.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .firstStep: return "#34C759"
        case .weekStreak: return "#FF9500"
        case .monthStreak: return "#FF3B30"
        case .centuryStreak: return "#FFD700"
        case .perfectDay: return "#007AFF"
        case .earlyBird: return "#FFD60A"
        case .habitMaster: return "#AF52DE"
        case .consistencyKing: return "#00C7BE"
        case .tenHabits: return "#5856D6"
        case .comebackKid: return "#30D158"
        }
    }
}
