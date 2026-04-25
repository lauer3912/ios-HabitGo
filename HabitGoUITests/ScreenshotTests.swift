import XCTest

class ScreenshotTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        // Launch with dark mode
        app = XCUIApplication()
        app.launchArguments = [
            "--uitesting",
            "--reset-state"
        ]
        app.launchEnvironment = [
            "UITESTING": "true",
            "NSInterfaceStyle": "Dark"
        ]
        app.launch()
        
        // Ensure dark mode is enabled
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    override func tearDown() {
        app.terminate()
        super.tearDown()
    }
    
    // MARK: - Screenshot Capture Methods
    
    func captureScreenshot(named name: String, for device: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "\(device)_\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Test Cases
    
    func testScreenshotHomeScreen() throws {
        Thread.sleep(forTimeInterval: 2.0)
        captureScreenshot(named: "Home", for: "iPhone")
    }
    
    func testScreenshotAddHabit() throws {
        Thread.sleep(forTimeInterval: 2.0)
        
        // Tap add button
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            captureScreenshot(named: "AddHabit", for: "iPhone")
        }
    }
    
    func testScreenshotHabitList() throws {
        Thread.sleep(forTimeInterval: 2.0)
        
        // Scroll or interact
        if app.collectionViews.firstMatch.exists {
            captureScreenshot(named: "HabitList", for: "iPhone")
        }
    }
    
    func testScreenshotHistory() throws {
        Thread.sleep(forTimeInterval: 2.0)
        
        // Navigate to history
        if app.tabBars.buttons["calendar"].exists {
            app.tabBars.buttons["calendar"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            captureScreenshot(named: "History", for: "iPhone")
        }
    }
    
    func testScreenshotAchievements() throws {
        Thread.sleep(forTimeInterval: 2.0)
        
        if app.tabBars.buttons["star.fill"].exists {
            app.tabBars.buttons["star.fill"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            captureScreenshot(named: "Achievements", for: "iPhone")
        }
    }
    
    func testScreenshotSettings() throws {
        Thread.sleep(forTimeInterval: 2.0)
        
        if app.tabBars.buttons["gearshape.fill"].exists {
            app.tabBars.buttons["gearshape.fill"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            captureScreenshot(named: "Settings", for: "iPhone")
        }
    }
    
    // MARK: - iPad Screenshots
    
    func testScreenshotiPadHome() throws {
        Thread.sleep(forTimeInterval: 2.0)
        captureScreenshot(named: "Home", for: "iPad")
    }
    
    func testScreenshotiPadHabitDetail() throws {
        Thread.sleep(forTimeInterval: 2.0)
        
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            captureScreenshot(named: "AddHabit", for: "iPad")
        }
    }
}
