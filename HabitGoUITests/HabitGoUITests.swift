import XCTest

final class HabitGoUITests: XCTestCase {

    private var app: XCUIApplication!
    private let ssDir = "/tmp/HabitGoScreenshots"

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

    private func tapTabBarButton(index: Int) {
        let tabBar = app.tabBars.firstMatch
        let btns = tabBar.buttons.allElementsBoundByIndex
        if index < btns.count {
            btns[index].tap()
            Thread.sleep(forTimeInterval: 2)
            print("Tapped tab[\(index)]")
        } else {
            // Fallback: try coordinate-based tap at estimated tab position
            let win = app.windows.firstMatch
            let frame = win.frame
            // On iPhone (430x932): tab bar at bottom ~83pts, y_center = 889
            // On iPad (1032x1376): tab bar at bottom ~83pts, y_center = 1334.5
            let tabBarH: CGFloat = 83
            let yCenter = frame.height - tabBarH / 2
            let tabW = frame.width / CGFloat(btns.count > 0 ? btns.count : 5)
            let xCenter = tabW * (CGFloat(index) + 0.5)
            let coord = win.coordinate(withNormalizedOffset: .zero)
                .withOffset(CGVector(dx: xCenter, dy: yCenter))
            coord.tap()
            Thread.sleep(forTimeInterval: 2)
            print("Coordinate tapped tab[\(index)] at (\(xCenter), \(yCenter))")
        }
    }

    func testAppStoreScreenshots() {
        // Tab 0: Habits (default after launch)
        ss("01_Habits")
        Thread.sleep(forTimeInterval: 1.0)

        // Tab 1: History
        tapTabBarButton(index: 1)
        ss("02_History")
        Thread.sleep(forTimeInterval: 1.0)

        // Tab 2: Stats
        tapTabBarButton(index: 2)
        ss("03_Stats")
        Thread.sleep(forTimeInterval: 1.0)

        // Tab 3: Settings
        tapTabBarButton(index: 3)
        ss("04_Settings")

        print("All screenshots captured to \(ssDir)")
    }
}
