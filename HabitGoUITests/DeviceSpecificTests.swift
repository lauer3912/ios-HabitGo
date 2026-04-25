import XCTest

final class ScreenshotTests_iPhone16ProMax: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        usleep(2000000)
        
        // Ensure we're on the main screen by dismissing any overlay
        dismissAnyOverlay()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func dismissAnyOverlay() {
        // Press Escape or tap outside to dismiss any modal
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
            usleep(500000)
        }
        if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
            usleep(500000)
        }
        // Swipe down to dismiss any sheet
        app.swipeDown()
        usleep(300000)
    }

    func ss(_ name: String) {
        // Wait a moment for any animations to settle
        usleep(500000)
        
        // Capture from the main application window
        if let window = app.windows.firstMatch as XCUIElement? {
            if window.exists {
                let data = window.screenshot().pngRepresentation
                try? data.write(to: URL(fileURLWithPath: "/tmp/iPhone_69/\(name).png"))
            }
        }
    }

    func testCaptureAll() throws {
        // Screen 1: Home - make sure we're on the main tab
        ss("01_Home")
        
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
        
        // Screen 4: History (tab index 1)
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
            usleep(1500000)
            ss("04_History")
        }
        
        // Screen 5: Achievements (tab index 2)
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
            usleep(1500000)
            ss("05_Achievements")
        }
        
        // Screen 6: Settings (tab index 3)
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
        dismissAnyOverlay()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func dismissAnyOverlay() {
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
            usleep(500000)
        }
        if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
            usleep(500000)
        }
        app.swipeDown()
        usleep(300000)
    }

    func ss(_ name: String) {
        usleep(500000)
        if let window = app.windows.firstMatch as XCUIElement? {
            if window.exists {
                let data = window.screenshot().pngRepresentation
                try? data.write(to: URL(fileURLWithPath: "/tmp/iPhone_61/\(name).png"))
            }
        }
    }

    func testCaptureAll() throws {
        ss("01_Home")
        
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
        
        if app.tabBars.buttons.count > 3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
            usleep(1500000)
            ss("06_Settings")
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
        dismissAnyOverlay()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func dismissAnyOverlay() {
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
            usleep(500000)
        }
        if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
            usleep(500000)
        }
        app.swipeDown()
        usleep(300000)
    }

    func ss(_ name: String) {
        usleep(500000)
        if let window = app.windows.firstMatch as XCUIElement? {
            if window.exists {
                let data = window.screenshot().pngRepresentation
                try? data.write(to: URL(fileURLWithPath: "/tmp/iPhone_67/\(name).png"))
            }
        }
    }

    func testCaptureAll() throws {
        ss("01_Home")
        
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
        dismissAnyOverlay()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func dismissAnyOverlay() {
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
            usleep(500000)
        }
        if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
            usleep(500000)
        }
        app.swipeDown()
        usleep(300000)
    }

    func ss(_ name: String) {
        usleep(500000)
        // iPad may have split view, so capture the first window
        if let window = app.windows.element(boundBy: 0) as XCUIElement? {
            if window.exists {
                let data = window.screenshot().pngRepresentation
                try? data.write(to: URL(fileURLWithPath: "/tmp/iPad_129/\(name).png"))
            }
        }
    }

    func testCaptureAll() throws {
        ss("01_Dashboard")
        
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            usleep(1500000)
            ss("02_AddHabit")
            
            if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
                usleep(500000)
            }
        }
        
        // Try different tab bar indices
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
        
        // If no tabs work, try navigating differently
        if app.tabBars.buttons.count == 0 {
            // Try scroll views or other navigation
            app.swipeLeft()
            usleep(1000000)
            ss("03_NextView")
        }
    }
}
