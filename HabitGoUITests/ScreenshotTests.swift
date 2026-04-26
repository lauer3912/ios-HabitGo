import XCTest

final class ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        usleep(800000) // Wait for app to fully settle
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
        // Use tabBars.buttons for iPhone (this works reliably)
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

    func testiPad_Dashboard() {
        capture("iPad_129_portrait_01_Dashboard")
    }

    func testiPad_History() {
        // Coordinate-based tap: 5 tabs at 10%, 30%, 50%, 70%, 90% of screen width
        // History = index 1 = 30%
        let coord = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.965))
        coord.tap()
        usleep(1500000)
        capture("iPad_129_portrait_03_History")
    }

    func testiPad_Achievements() {
        // Badges = index 3 = 70%
        let coord = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.965))
        coord.tap()
        usleep(1500000)
        capture("iPad_129_portrait_04_Achievements")
    }

    func testiPad_Settings() {
        // Settings = index 4 = 90%
        let coord = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.965))
        coord.tap()
        usleep(1500000)
        capture("iPad_129_portrait_05_Settings")
    }
}