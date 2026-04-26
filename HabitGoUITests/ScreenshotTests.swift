import XCTest

final class ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        usleep(500000) // Wait for app to fully load
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

    // MARK: - Tab Navigation Helper

    private func navigateToTab(_ index: Int) {
        // Try tabBars.buttons first (works on iPhone and some iPad configs)
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            let buttons = tabBar.buttons
            if buttons.count > index {
                buttons.element(boundBy: index).tap()
                usleep(1200000)
                return
            }
        }

        // Fallback: coordinate-based tap at bottom of screen
        // Tab positions for 5 tabs: 10%, 30%, 50%, 70%, 90%
        let tabPositions: [CGFloat] = [0.1, 0.3, 0.5, 0.7, 0.9]
        if index < tabPositions.count {
            let window = app.windows.firstMatch
            let xRatio = tabPositions[index]
            // On iPhone use dy=0.97, on iPad use dy=0.96
            let coord = window.coordinate(withNormalizedOffset: CGVector(dx: xRatio, dy: 0.965))
            coord.tap()
            usleep(1200000)
        }
    }

    // MARK: - iPhone Screenshots (6.9" - 1320×2868 for iPhone 16 Pro Max)

    func testiPhone_Home() {
        capture("iPhone_61_portrait_01_Home")
    }

    func testiPhone_History() {
        navigateToTab(1) // History = index 1
        capture("iPhone_61_portrait_04_History")
    }

    func testiPhone_Achievements() {
        navigateToTab(3) // Badges = index 3
        capture("iPhone_61_portrait_05_Achievements")
    }

    func testiPhone_Settings() {
        navigateToTab(4) // Settings = index 4
        capture("iPhone_61_portrait_06_Settings")
    }

    // MARK: - iPad Screenshots (12.9" - 2064×2752 for iPad Pro 13-inch M4)

    func testiPad_Dashboard() {
        capture("iPad_129_portrait_01_Dashboard")
    }

    func testiPad_History() {
        navigateToTab(1) // History = index 1
        capture("iPad_129_portrait_03_History")
    }

    func testiPad_Achievements() {
        navigateToTab(3) // Badges = index 3
        capture("iPad_129_portrait_04_Achievements")
    }

    func testiPad_Settings() {
        navigateToTab(4) // Settings = index 4
        capture("iPad_129_portrait_05_Settings")
    }
}