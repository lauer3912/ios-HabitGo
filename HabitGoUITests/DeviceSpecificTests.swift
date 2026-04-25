import XCTest

final class ScreenshotTests_iPhone16ProMax: XCTestCase {
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

    func ss(_ name: String) {
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "/tmp/iPhone_69/\(name).png"))
    }

    func testCaptureAll() throws {
        // Home
        ss("01_Home")
        
        // Navigate and capture more screens
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            usleep(1000000)
            ss("02_AddHabit")
            
            // Fill form
            let textField = app.textFields.firstMatch
            if textField.exists {
                textField.tap()
                textField.typeText("Morning Exercise")
                usleep(500000)
            }
            ss("03_HabitForm")
        }
        
        // History
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
            usleep(1000000)
            ss("04_History")
        }
        
        // Achievements  
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
            usleep(1000000)
            ss("05_Achievements")
        }
    }
}

final class ScreenshotTests_iPhone16: XCTestCase {
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

    func ss(_ name: String) {
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "/tmp/iPhone_61/\(name).png"))
    }

    func testCaptureAll() throws {
        ss("01_Home")
        
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            usleep(1000000)
            ss("02_AddHabit")
        }
        
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
            usleep(1000000)
            ss("03_History")
        }
        
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
            usleep(1000000)
            ss("04_Achievements")
        }
    }
}

final class ScreenshotTests_iPadPro13: XCTestCase {
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

    func ss(_ name: String) {
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "/tmp/iPad_129/\(name).png"))
    }

    func testCaptureAll() throws {
        ss("01_Dashboard")
        
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            usleep(1000000)
            ss("02_AddHabit")
        }
        
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
            usleep(1000000)
            ss("03_History")
        }
        
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
            usleep(1000000)
            ss("04_Achievements")
        }
    }
}
