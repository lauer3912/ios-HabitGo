import XCTest

final class ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        // Launch in dark mode for professional appearance
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Screenshot Helper

    func ss(_ name: String) {
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "/tmp/\(name).png"))
    }

    // MARK: - iPhone Screenshots (6.1" - 1170×2532 for iPhone 16)

    func testiPhone_Home() throws {
        ss("iPhone_61_portrait_01_Home")
    }

    func testiPhone_AddHabit() throws {
        // Tap add button
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            usleep(1000000)
            ss("iPhone_61_portrait_02_AddHabit")
        }
    }

    func testiPhone_HabitForm() throws {
        // Navigate to add habit and fill form
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            usleep(1000000)
            
            // Type habit name
            let textField = app.textFields.firstMatch
            if textField.exists {
                textField.tap()
                textField.typeText("Morning Exercise")
                usleep(500000)
            }
            ss("iPhone_61_portrait_03_HabitForm")
        }
    }

    func testiPhone_History() throws {
        // Navigate to calendar/history
        if app.tabBars.buttons.element(boundBy: 1).exists {
            app.tabBars.buttons.element(boundBy: 1).tap()
            usleep(1000000)
            ss("iPhone_61_portrait_04_History")
        }
    }

    func testiPhone_Achievements() throws {
        // Navigate to achievements
        if app.tabBars.buttons.element(boundBy: 2).exists {
            app.tabBars.buttons.element(boundBy: 2).tap()
            usleep(1000000)
            ss("iPhone_61_portrait_05_Achievements")
        }
    }

    func testiPhone_Settings() throws {
        // Navigate to settings
        if app.tabBars.buttons.element(boundBy: 3).exists {
            app.tabBars.buttons.element(boundBy: 3).tap()
            usleep(1000000)
            ss("iPhone_61_portrait_06_Settings")
        }
    }

    // MARK: - iPad Screenshots (12.9" - 2048×2732 for iPad Pro 13")

    func testiPad_Dashboard() throws {
        ss("iPad_129_portrait_01_Dashboard")
    }

    func testiPad_AddHabit() throws {
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            usleep(1000000)
            ss("iPad_129_portrait_02_AddHabit")
        }
    }

    func testiPad_History() throws {
        // iPad might have different navigation
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
            usleep(1000000)
            ss("iPad_129_portrait_03_History")
        }
    }

    func testiPad_Achievements() throws {
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
            usleep(1000000)
            ss("iPad_129_portrait_04_Achievements")
        }
    }

    func testiPad_Settings() throws {
        if app.tabBars.buttons.count > 3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
            usleep(1000000)
            ss("iPad_129_portrait_05_Settings")
        }
    }
}
