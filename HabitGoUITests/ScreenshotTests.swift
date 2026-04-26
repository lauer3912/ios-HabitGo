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
    // Simulator: iPhone 16 Pro Max (59030A31-1FAA-43F2-96AC-B36521085127)

    func testiPhone_Home() {
        capture("iPhone_61_portrait_01_Home")
    }

    func testiPhone_History() {
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
            usleep(1500000)
        }
        capture("iPhone_61_portrait_02_History")
    }

    func testiPhone_Stats() {
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
            usleep(1500000)
        }
        capture("iPhone_61_portrait_03_Stats")
    }

    func testiPhone_Achievements() {
        if app.tabBars.buttons.count > 3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
            usleep(1500000)
        }
        capture("iPhone_61_portrait_04_Achievements")
    }

    func testiPhone_Settings() {
        if app.tabBars.buttons.count > 4 {
            app.tabBars.buttons.element(boundBy: 4).tap()
            usleep(1500000)
        }
        capture("iPhone_61_portrait_05_Settings")
    }

    // MARK: - iPad Screenshots (12.9" - 2064×2752 for iPad Pro 13-inch M4)
    // Simulator: iPad Pro 13-inch (M4) (E09FB483-2200-41F3-B597-A32B3AA5F4C0)

    func testiPad_Home() {
        capture("iPad_129_portrait_01_Home")
    }

    func testiPad_History() {
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists && tabBar.buttons.count > 1 {
            tabBar.buttons.element(boundBy: 1).tap()
            usleep(1500000)
        } else if app.buttons["History"].exists {
            app.buttons["History"].firstMatch.tap()
            usleep(1500000)
        }
        capture("iPad_129_portrait_02_History")
    }

    func testiPad_Stats() {
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists && tabBar.buttons.count > 2 {
            tabBar.buttons.element(boundBy: 2).tap()
            usleep(1500000)
        } else if app.buttons["Stats"].exists {
            app.buttons["Stats"].firstMatch.tap()
            usleep(1500000)
        }
        capture("iPad_129_portrait_03_Stats")
    }

    func testiPad_Achievements() {
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists && tabBar.buttons.count > 3 {
            tabBar.buttons.element(boundBy: 3).tap()
            usleep(1500000)
        } else if app.buttons["Badges"].exists {
            app.buttons["Badges"].firstMatch.tap()
            usleep(1500000)
        }
        capture("iPad_129_portrait_04_Achievements")
    }

    func testiPad_Settings() {
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists && tabBar.buttons.count > 4 {
            tabBar.buttons.element(boundBy: 4).tap()
            usleep(1500000)
        } else if app.buttons["Settings"].exists {
            app.buttons["Settings"].firstMatch.tap()
            usleep(1500000)
        }
        capture("iPad_129_portrait_05_Settings")
    }
}