import XCTest

final class HabitGoUITests: XCTestCase {

    private var app: XCUIApplication!
    private let screenshotDir = "/tmp/HabitGoScreenshots"
    // iPhone 16 Pro Max UDID (6.7" display)
    private let deviceUDID = "59030A31-1FAA-43F2-96AC-B36521085127"

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        try? FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true)
        app.launchArguments = []
        app.launch()
        // Wait for SwiftUI to fully render
        Thread.sleep(forTimeInterval: 3.0)
    }

    /// Use xcrun simctl to capture iOS framebuffer (accurate, not affected by macOS Simulator window)
    private func ss(_ name: String) {
        let path = "\(screenshotDir)/\(name).png"
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        task.arguments = ["simctl", "io", deviceUDID, "screenshot", path]
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Screenshot failed: \(error)")
        }

        // Verify file was created
        if FileManager.default.fileExists(atPath: path) {
            if let attrs = try? FileManager.default.attributesOfItem(atPath: path),
               let size = attrs[.size] as? Int {
                print("Saved: \(name) (\(size) bytes)")
            }
        }
    }

    private func tapTab(_ iconName: String) {
        let tabBar = app.tabBars.firstMatch
        // Try by SF Symbol name
        if tabBar.buttons[iconName].exists {
            tabBar.buttons[iconName].tap()
            Thread.sleep(forTimeInterval: 1.5)
            return
        }
        // Fallback: tap by accessibility label
        for btn in tabBar.buttons.allElementsBoundByIndex {
            if btn.label.lowercased().contains(iconName.lowercased()) {
                btn.tap()
                Thread.sleep(forTimeInterval: 1.5)
                return
            }
        }
        // Fallback: tap tab by index
        let allTabs = tabBar.buttons.allElementsBoundByIndex
        print("Available tab buttons (\(allTabs.count)): \(allTabs.map { $0.label })")
    }

    // MARK: - Tests

    /// Test all 4 tabs: Habits, History, Stats, Settings
    func testAllTabs() {
        // Tab 1: Habits (default, no tap needed)
        ss("01_Habits")

        // Tab 2: History
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
            let navFrame = navBar.frame
            let window = app.windows.firstMatch
            let coord = window.coordinate(withNormalizedOffset: .zero).withOffset(
                CGVector(dx: navFrame.maxX - 30, dy: navFrame.midY)
            )
            coord.tap()
        }

        Thread.sleep(forTimeInterval: 2.0)
        ss("05_AddHabit_Sheet")

        let textField = app.textFields.firstMatch
        if textField.exists {
            textField.tap()
            textField.typeText("Morning Run")
        }
        Thread.sleep(forTimeInterval: 0.5)
        ss("06_AddHabit_NameFilled")

        for btn in app.buttons.allElementsBoundByIndex {
            if btn.label == "Add" && btn.isEnabled {
                btn.tap()
                break
            }
        }

        Thread.sleep(forTimeInterval: 2.0)
        ss("07_Habits_After_Add")

        print("ADD HABIT FLOW DONE")
    }

    /// Test: Toggle habit completion
    func testToggleHabit() {
        ss("00_Habits_Before_Toggle")

        let circles = app.buttons.allElementsBoundByIndex.filter { btn in
            btn.frame.width >= 28 && btn.frame.width <= 36 &&
            btn.frame.height >= 28 && btn.frame.height <= 36 &&
            btn.frame.origin.y > 100
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

        let navBar = app.navigationBars.firstMatch
        for btn in navBar.buttons.allElementsBoundByIndex {
            if btn.label.hasSuffix("chevron.right") {
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

        app.tables.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)
        ss("12_Settings_Scrolled")

        print("SETTINGS DONE")
    }
}
