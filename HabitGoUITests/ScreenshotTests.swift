import XCTest

final class ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
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
        let buttons = app.buttons
        if buttons.count > 1 {
            buttons.element(boundBy: 1).tap()
            usleep(1000000)
        }
        capture("iPhone_61_portrait_04_History")
    }

    func testiPhone_Achievements() {
        let buttons = app.buttons
        if buttons.count > 2 {
            buttons.element(boundBy: 2).tap()
            usleep(1000000)
        }
        capture("iPhone_61_portrait_05_Achievements")
    }

    func testiPhone_Settings() {
        let buttons = app.buttons
        if buttons.count > 3 {
            buttons.element(boundBy: 3).tap()
            usleep(1000000)
        }
        capture("iPhone_61_portrait_06_Settings")
    }

    // MARK: - iPad Screenshots (12.9" - 2064×2752 for iPad Pro 13-inch M4)

    func testiPad_Dashboard() {
        capture("iPad_129_portrait_01_Dashboard")
    }

    func testiPad_History() {
        // Use coordinate tap for iPad tab bar navigation
        // iPad portrait: 2064x2732, tab bar ~80pt from bottom
        let window = app.windows.firstMatch
        let tabBarY = window.frame.height - 100
        let historyX = window.frame.width * 0.35
        let coord = XCUICoordinate(screen: window, x: historyX, y: tabBarY)
        coord.tap()
        usleep(1000000)
        capture("iPad_129_portrait_03_History")
    }

    func testiPad_Achievements() {
        let window = app.windows.firstMatch
        let tabBarY = window.frame.height - 100
        let badgesX = window.frame.width * 0.55
        let coord = XCUICoordinate(screen: window, x: badgesX, y: tabBarY)
        coord.tap()
        usleep(1000000)
        capture("iPad_129_portrait_04_Achievements")
    }

    func testiPad_Settings() {
        let window = app.windows.firstMatch
        let tabBarY = window.frame.height - 100
        let settingsX = window.frame.width * 0.75
        let coord = XCUICoordinate(screen: window, x: settingsX, y: tabBarY)
        coord.tap()
        usleep(1000000)
        capture("iPad_129_portrait_05_Settings")
    }
}
