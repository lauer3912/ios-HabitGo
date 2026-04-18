import XCTest

final class HabitGoUITests: XCTestCase {

    private var app: XCUIApplication!
    private let screenshotDir = "/tmp/HabitGoScreenshots"
    private let simulatorScale: CGFloat = 3.0  // Retina scaling

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        try? FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true)
        app.launchArguments = []
        app.launch()
        sleep(3)  // Wait for SwiftUI to render
    }

    private func ss(_ name: String) {
        let window = app.windows.firstMatch
        let data = window.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "\(screenshotDir)/\(name).png"))
        let w = window.frame.width
        let h = window.frame.height
        print("Saved: \(name) @ \(Int(w))x\(Int(h)) (\(data.count) bytes)")
    }

    private func dismissSheet() {
        // Try to find Done button in navigation bar first
        var doneFound = false
        for _ in 0..<30 {
            let btns = app.buttons.allElementsBoundByIndex
            for btn in btns {
                if btn.label == "Done" && btn.exists && btn.isHittable {
                    btn.tap()
                    doneFound = true
                    break
                }
            }
            if doneFound { break }
            Thread.sleep(forTimeInterval: 0.2)
        }

        if !doneFound {
            app.windows.firstMatch.swipeDown()
        }
        Thread.sleep(forTimeInterval: 1.5)
    }

    // Navigate to a specific tab by SF Symbol name
    private func tapTab(_ iconName: String) {
        // Tab bar icons use accessibilityIdentifier or we find by icon
        // SwiftUI TabView icons are accessible via .tabItem labels
        let tabBar = app.tabBars.firstMatch
        if tabBar.buttons[iconName].exists {
            tabBar.buttons[iconName].tap()
        } else {
            // Try matching by label or icon
            for btn in tabBar.buttons.allElementsBoundByIndex {
                if btn.label.lowercased().contains(iconName.lowercased()) {
                    btn.tap()
                    return
                }
            }
            // Fallback: tap by index
            let allTabs = tabBar.buttons.allElementsBoundByIndex
            print("Available tab buttons: \(allTabs.count)")
        }
        sleep(1.5)
    }

    // MARK: - Tests

    /// Test all 4 tabs: Habits, History, Stats, Settings
    func testAllTabs() {
        // Tab 1: Habits (default, no tap needed)
        ss("01_Habits")

        // Tab 2: History (calendar icon)
        tapTab("calendar")
        ss("02_History")

        // Tab 3: Stats
        tapTab("chart.bar")
        ss("03_Stats")

        // Tab 4: Settings
        tapTab("gearshape")
        ss("04_Settings")

        print("ALL TABS DONE")
    }

    /// Test: Add new habit flow
    func testAddHabitFlow() {
        ss("00_Habits_Before_Add")

        // Tap + button in nav bar
        let navBar = app.navigationBars.firstMatch
        var addButton: XCUIElement?

        for btn in navBar.buttons.allElementsBoundByIndex {
            if btn.label == "Add" || btn.label.contains("plus") || btn.label == "+" {
                addButton = btn
                break
            }
        }

        // Also try otherElements (toolbar buttons)
        if addButton == nil {
            for el in navBar.otherElements.allElementsBoundByIndex {
                if el.label == "Add" || el.label == "+" {
                    addButton = el
                    break
                }
            }
        }

        if let btn = addButton {
            btn.tap()
        } else {
            // Fallback: use coordinate at top-right of nav bar
            let navFrame = navBar.frame
            let window = app.windows.firstMatch
            let coord = window.coordinate(withNormalizedOffset: .zero).withOffset(
                CGVector(dx: navFrame.maxX - 30, dy: navFrame.midY)
            )
            coord.tap()
        }

        Thread.sleep(forTimeInterval: 2.0)
        ss("05_AddHabit_Sheet")

        // Fill in habit name
        let textField = app.textFields.firstMatch
        if textField.exists {
            textField.tap()
            textField.typeText("Morning Run")
        }
        Thread.sleep(forTimeInterval: 0.5)
        ss("06_AddHabit_NameFilled")

        // Tap Add button to confirm
        let addBtn = app.buttons["Add"]
        if addBtn.exists && addBtn.isEnabled {
            addBtn.tap()
        } else {
            // Try first enabled button in toolbar
            for btn in app.buttons.allElementsBoundByIndex {
                if btn.label == "Add" && btn.isEnabled {
                    btn.tap()
                    break
                }
            }
        }

        Thread.sleep(forTimeInterval: 2.0)
        ss("07_Habits_After_Add")

        print("ADD HABIT FLOW DONE")
    }

    /// Test: Toggle habit completion
    func testToggleHabit() {
        ss("00_Habits_Before_Toggle")

        // The first toggle circle should be tappable
        // Look for circles in the list
        let circles = app.buttons.allElementsBoundByIndex.filter { btn in
            btn.frame.width >= 28 && btn.frame.width <= 36 &&
            btn.frame.height >= 28 && btn.frame.height <= 36 &&
            btn.frame.origin.y > 100  // Below nav bar
        }

        if let firstCircle = circles.first {
            firstCircle.tap()
            Thread.sleep(forTimeInterval: 1.0)
            ss("08_Habits_After_Toggle")
            print("Tapped toggle at (\(firstCircle.frame.origin.x), \(firstCircle.frame.origin.y))")
        } else {
            print("No toggle button found, skipping toggle test")
        }

        print("TOGGLE DONE")
    }

    /// Test: History tab - calendar navigation
    func testHistoryCalendar() {
        tapTab("calendar")
        Thread.sleep(forTimeInterval: 1.0)
        ss("09_History_Calendar")

        // Tap next month chevron
        let navBar = app.navigationBars.firstMatch
        for btn in navBar.buttons.allElementsBoundByIndex {
            if btn.label == " chevron.right" || btn.label == "Chevron Right" || btn.label.hasSuffix("chevron.right") {
                btn.tap()
                Thread.sleep(forTimeInterval: 1.0)
                ss("10_History_NextMonth")
                break
            }
        }

        print("HISTORY CALENDAR DONE")
    }

    /// Test: Settings export/import options
    func testSettings() {
        tapTab("gearshape")
        Thread.sleep(forTimeInterval: 1.0)
        ss("11_Settings")

        // Scroll down to see all options
        app.tables.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)
        ss("12_Settings_Scrolled")

        print("SETTINGS DONE")
    }
}
