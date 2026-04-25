import XCTest

final class ScreenshotTests_iPhone16ProMax: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        usleep(2000000) // Wait for app to fully load
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    func ss(_ name: String) {
        // Capture the screenshot from the first window (main screen, not modals)
        let window = app.windows.element(boundBy: 0)
        if window.exists {
            let data = window.screenshot().pngRepresentation
            try? data.write(to: URL(fileURLWithPath: "/tmp/iPhone_69/\(name).png"))
        }
    }

    func testCaptureAll() throws {
        // Screen 1: Home
        ss("01_Home")
        
        // Dismiss any modals first
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
            usleep(500000)
        }
        
        // Screen 2: Add Habit
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            usleep(1500000)
            ss("02_AddHabit")
            
            // Screen 3: Fill form
            let textField = app.textFields.firstMatch
            if textField.exists {
                textField.tap()
                textField.typeText("Morning Exercise")
                usleep(500000)
            }
            ss("03_HabitForm")
            
            // Dismiss
            if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
                usleep(500000)
            }
        }
        
        // Screen 4: History
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
            usleep(1500000)
            ss("04_History")
        }
        
        // Screen 5: Achievements
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
            usleep(1500000)
            ss("05_Achievements")
        }
        
        // Screen 6: Settings
        if app.tabBars.buttons.count > 3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
            usleep(1500000)
            ss("06_Settings")
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
        usleep(2000000)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    func ss(_ name: String) {
        let window = app.windows.element(boundBy: 0)
        if window.exists {
            let data = window.screenshot().pngRepresentation
            try? data.write(to: URL(fileURLWithPath: "/tmp/iPhone_61/\(name).png"))
        }
    }

    func testCaptureAll() throws {
        ss("01_Home")
        
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
            usleep(500000)
        }
        
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            usleep(1500000)
            ss("02_AddHabit")
            
            let textField = app.textFields.firstMatch
            if textField.exists {
                textField.tap()
                textField.typeText("Evening Reading")
                usleep(500000)
            }
            ss("03_HabitForm")
            
            if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
                usleep(500000)
            }
        }
        
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
            usleep(1500000)
            ss("04_History")
        }
        
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
            usleep(1500000)
            ss("05_Achievements")
        }
    }
}

final class ScreenshotTests_iPhone16Plus: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        usleep(2000000)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    func ss(_ name: String) {
        let window = app.windows.element(boundBy: 0)
        if window.exists {
            let data = window.screenshot().pngRepresentation
            try? data.write(to: URL(fileURLWithPath: "/tmp/iPhone_67/\(name).png"))
        }
    }

    func testCaptureAll() throws {
        ss("01_Home")
        
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
            usleep(500000)
        }
        
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            usleep(1500000)
            ss("02_AddHabit")
            
            if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
                usleep(500000)
            }
        }
        
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
            usleep(1500000)
            ss("03_History")
        }
        
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
            usleep(1500000)
            ss("04_Achievements")
        }
        
        if app.tabBars.buttons.count > 3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
            usleep(1500000)
            ss("05_Settings")
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
        usleep(2000000)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    func ss(_ name: String) {
        let window = app.windows.element(boundBy: 0)
        if window.exists {
            let data = window.screenshot().pngRepresentation
            try? data.write(to: URL(fileURLWithPath: "/tmp/iPad_129/\(name).png"))
        }
    }

    func testCaptureAll() throws {
        ss("01_Dashboard")
        
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
            usleep(500000)
        }
        
        // iPad might use NavigationSplitView or different layout
        // Try to find add button in different ways
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            usleep(1500000)
            ss("02_AddHabit")
            
            if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
                usleep(500000)
            }
        }
        
        // iPad has more buttons in tab bar
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
            usleep(1500000)
            ss("03_History")
        }
        
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
            usleep(1500000)
            ss("04_Achievements")
        }
        
        if app.tabBars.buttons.count > 3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
            usleep(1500000)
            ss("05_Settings")
        }
    }
}
