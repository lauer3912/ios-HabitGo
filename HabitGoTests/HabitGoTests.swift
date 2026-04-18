import XCTest
@testable import HabitGo

final class HabitGoTests: XCTestCase {

    func testHabitCreation() throws {
        let habit = Habit(name: "Test Habit", icon: "checkmark", colorHex: "#34C759")
        XCTAssertEqual(habit.name, "Test Habit")
        XCTAssertEqual(habit.icon, "checkmark")
        XCTAssertFalse(habit.isCompletedToday)
        XCTAssertEqual(habit.currentStreak, 0)
    }

    func testHabitToggle() throws {
        var habit = Habit(name: "Test", icon: "star", colorHex: "#FF9500")
        XCTAssertFalse(habit.isCompletedToday)
        habit.toggleToday()
        XCTAssertTrue(habit.isCompletedToday)
        habit.toggleToday()
        XCTAssertFalse(habit.isCompletedToday)
    }

    func testHabitStreakCalculation() throws {
        var habit = Habit(name: "Streak Test", icon: "flame", colorHex: "#FF3B30")
        // Toggle today
        habit.toggleToday()
        XCTAssertEqual(habit.currentStreak, 1)
    }

    func testColorFromHex() throws {
        let color = Color(hex: "#34C759")
        XCTAssertNotNil(color)
    }
}
