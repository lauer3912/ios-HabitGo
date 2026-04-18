import XCTest

final class HabitGoUITests: XCTestCase {

    private var app: XCUIApplication!
    private let screenshotDir = "/tmp/HabitGoScreenshots"

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        try? FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true)
        app.launchArguments = []
        app.launch()
        Thread.sleep(forTimeInterval: 3.0)
    }

    private func ss(_ name: String) {
        let window = app.windows.firstMatch
        let data = window.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "\(screenshotDir)/\(name).png"))
        print("Saved: \(name) (\(data.count) bytes)")
    }

    private func tapTab(_ iconName: String) {
        let tabBar = app.tabBars.firstMatch
        if tabBar.buttons[iconName].exists {
            tabBar.buttons[iconName].tap()
            Thread.sleep(forTimeInterval: 1.5)
            return
        }
        for btn in tabBar.buttons.allElementsBoundByIndex {
            if btn.label.lowercased().contains(iconName.lowercased()) {
                btn.tap()
                Thread.sleep(forTimeInterval: 1.5)
                return
            }
        }
        // Fallback: tap by index
        let allTabs = tabBar.buttons.allElementsBoundByIndex
        print("Available tab buttons: \(allTabs.count)")
    }

    func testAllTabs() {
        ss("01_Habits")
        tapTab("calendar")
        ss("02_History")
        tapTab("chart.bar")
        ss("03_Stats")
        tapTab("gearshape")
        ss("04_Settings")
        print("ALL TABS DONE")
    }

    func testAddHabitFlow() {
        ss("00_Habits_Before_Add")
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
        }
        print("TOGGLE DONE")
    }
}
