import XCTest

final class HabitGoUITests: XCTestCase {

    private var app: XCUIApplication!
    private let ssDir = "/tmp/HabitGoScreenshots"
    // Tab bar button labels match the tabItem Label text
    private let tabLabels = ["Habits", "History", "Stats", "Settings"]
    private let tabNames = ["01_Habits", "02_History", "03_Stats", "04_Settings"]

    override func setUp() {
        super.setUp()
        continueAfterFailure = true
        app = XCUIApplication()
        try? FileManager.default.createDirectory(atPath: ssDir, withIntermediateDirectories: true)
        app.launchArguments = []
        app.launch()
        Thread.sleep(forTimeInterval: 4.0)
    }

    override func tearDown() {
        super.tearDown()
    }

    private func ss(_ name: String) {
        let window = app.windows.firstMatch
        let data = window.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "\(ssDir)/\(name).png"))
        print("Screenshot: \(name) (\(data.count) bytes)")
    }

    func testAppStoreScreenshots() {
        // Tab 0: Habits (default after launch)
        ss(tabNames[0])

        // Tabs 1-3: tap by button label (more reliable than index on iPad)
        for i in 1..<tabLabels.count {
            let btn = app.buttons[tabLabels[i]].firstMatch
            if btn.exists && btn.isHittable {
                btn.tap()
                Thread.sleep(forTimeInterval: 2)
                print("Tapped '\(tabLabels[i])' at (\(btn.frame.midX), \(btn.frame.midY))")
            } else {
                print("Button '\(tabLabels[i])' not hittable, trying coordinate tap")
                // Coordinate fallback based on window size
                let win = app.windows.firstMatch
                let frame = win.frame
                let tabBarH: CGFloat = 83
                let yCenter = frame.height - tabBarH / 2
                let tabW = frame.width / 4
                let xCenter = tabW * (CGFloat(i) + 0.5)
                let coord = win.coordinate(withNormalizedOffset: .zero)
                    .withOffset(CGVector(dx: xCenter, dy: yCenter))
                coord.tap()
                Thread.sleep(forTimeInterval: 2)
            }
            ss(tabNames[i])
        }

        print("All screenshots captured to \(ssDir)")
    }
}
