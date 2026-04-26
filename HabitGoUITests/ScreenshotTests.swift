import XCTest

final class ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        usleep(1000000)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Screenshot Helper

    func capture(_ name: String) {
        let path = "/tmp/\(name).png"
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: path))
    }

    // MARK: - iPhone Screenshots (6.9" - 1320×2868 for iPhone 16 Pro Max)

    func testiPhone_Home() {
        capture("iPhone_61_portrait_01_Home")
    }

    func testiPhone_History() {
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
            usleep(1500000)
        }
        capture("iPhone_61_portrait_04_History")
    }

    func testiPhone_Achievements() {
        if app.tabBars.buttons.count > 3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
            usleep(1500000)
        }
        capture("iPhone_61_portrait_05_Achievements")
    }

    func testiPhone_Settings() {
        if app.tabBars.buttons.count > 4 {
            app.tabBars.buttons.element(boundBy: 4).tap()
            usleep(1500000)
        }
        capture("iPhone_61_portrait_06_Settings")
    }

    // MARK: - iPad Screenshots (12.9" - 2064×2752 for iPad Pro 13-inch M4)
    // iPad may use NavigationSplitView or custom layout - use swipe gestures

    func testiPad_Dashboard() {
        capture("iPad_129_portrait_01_Dashboard")
    }

    func testiPad_History() {
        // Swipe left on main content area to switch to History tab (index 1)
        let window = app.windows.firstMatch
        window.swipeLeft()
        usleep(1500000)
        capture("iPad_129_portrait_03_History")
    }

    func testiPad_Achievements() {
        // Swipe left 3 times to get to Badges tab (index 3)
        let window = app.windows.firstMatch
        window.swipeLeft()
        usleep(800000)
        window.swipeLeft()
        usleep(800000)
        window.swipeLeft()
        usleep(1500000)
        capture("iPad_129_portrait_04_Achievements")
    }

    func testiPad_Settings() {
        // Swipe left 4 times to get to Settings tab (index 4)
        let window = app.windows.firstMatch
        window.swipeLeft()
        usleep(800000)
        window.swipeLeft()
        usleep(800000)
        window.swipeLeft()
        usleep(800000)
        window.swipeLeft()
        usleep(1500000)
        capture("iPad_129_portrait_05_Settings")
    }
}