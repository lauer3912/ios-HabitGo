import XCTest

final class HabitGoUITests: XCTestCase {

    private var app: XCUIApplication!
    private let ssDir = "/tmp/HabitGoScreenshots"

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        try? FileManager.default.createDirectory(atPath: ssDir, withIntermediateDirectories: true)
        app.launchArguments = []
        app.launch()
        Thread.sleep(forTimeInterval: 4.0)
    }

    override func tearDown() {
        super.tearDown()
    }

    private func ss(_ name: String) {
        // Capture via CATARACT/Screenshot framework - more reliable than window.screenshot()
        let window = app.windows.firstMatch
        let data = window.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "\(ssDir)/\(name).png"))
        print("Screenshot: \(name) (\(data.count) bytes)")
    }

    private func navigateToTab(_ iconSubstring: String) {
        let tabBar = app.tabBars.firstMatch
        // Try icon-based first
        let matchingButtons = tabBar.buttons.allElementsBoundByIndex.filter {
            $0.label.lowercased().contains(iconSubstring.lowercased()) ||
            $0.label.lowercased().contains("tab")
        }
        for btn in matchingButtons {
            btn.tap()
            Thread.sleep(forTimeInterval: 1.5)
            return
        }
        // Fallback: tap by index
        let allBtns = tabBar.buttons.allElementsBoundByIndex
        if allBtns.count >= 4 {
            allBtns[0].tap()
            Thread.sleep(forTimeInterval: 1.5)
            if iconSubstring == "tab1" || iconSubstring == "calendar" || iconSubstring == "history" {
                allBtns[1].tap()
                Thread.sleep(forTimeInterval: 1.5)
            } else if iconSubstring == "tab2" || iconSubstring == "chart" || iconSubstring == "stats" {
                allBtns[2].tap()
                Thread.sleep(forTimeInterval: 1.5)
            } else if iconSubstring == "tab3" || iconSubstring == "gear" || iconSubstring == "settings" {
                allBtns[3].tap()
                Thread.sleep(forTimeInterval: 1.5)
            }
        }
    }

    func testAppStoreScreenshots() {
        // Tab 0: Habits (default after launch)
        ss("01_Habits")
        Thread.sleep(forTimeInterval: 1.0)

        // Tab 1: History
        navigateToTab("calendar")
        ss("02_History")
        Thread.sleep(forTimeInterval: 1.0)

        // Tab 2: Stats
        navigateToTab("chart")
        ss("03_Stats")
        Thread.sleep(forTimeInterval: 1.0)

        // Tab 3: Settings
        navigateToTab("gear")
        ss("04_Settings")

        print("All screenshots captured to \(ssDir)")
    }
}
