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

    // MARK: - iPhone 6.9" (1320×2868 - iPhone 16 Pro Max)

    func testiPhone_69_01_Home() {
        // Reset to Home tab
        if app.tabBars.buttons.count > 0 {
            app.tabBars.buttons.element(boundBy: 0).tap()
            usleep(1500000)
        }
        capture("iPhone_69_portrait_01_Home")
    }

    func testiPhone_69_02_History() {
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
        } else if app.buttons["History"].exists {
            app.buttons["History"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPhone_69_portrait_02_History")
    }

    func testiPhone_69_03_Stats() {
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
        } else if app.buttons["Stats"].exists {
            app.buttons["Stats"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPhone_69_portrait_03_Stats")
    }

    func testiPhone_69_04_Achievements() {
        if app.tabBars.buttons.count > 3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
        } else if app.buttons["Achievements"].exists {
            app.buttons["Achievements"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPhone_69_portrait_04_Achievements")
    }

    func testiPhone_69_05_Settings() {
        if app.tabBars.buttons.count > 4 {
            app.tabBars.buttons.element(boundBy: 4).tap()
        } else if app.buttons["Settings"].exists {
            app.buttons["Settings"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPhone_69_portrait_05_Settings")
    }

    // MARK: - iPhone 6.5" (1284×2778 - iPhone 14 Plus)

    func testiPhone_65_01_Home() {
        if app.tabBars.buttons.count > 0 {
            app.tabBars.buttons.element(boundBy: 0).tap()
            usleep(1500000)
        }
        capture("iPhone_65_portrait_01_Home")
    }

    func testiPhone_65_02_History() {
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
        } else if app.buttons["History"].exists {
            app.buttons["History"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPhone_65_portrait_02_History")
    }

    func testiPhone_65_03_Stats() {
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
        } else if app.buttons["Stats"].exists {
            app.buttons["Stats"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPhone_65_portrait_03_Stats")
    }

    func testiPhone_65_04_Achievements() {
        if app.tabBars.buttons.count > 3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
        } else if app.buttons["Achievements"].exists {
            app.buttons["Achievements"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPhone_65_portrait_04_Achievements")
    }

    func testiPhone_65_05_Settings() {
        if app.tabBars.buttons.count > 4 {
            app.tabBars.buttons.element(boundBy: 4).tap()
        } else if app.buttons["Settings"].exists {
            app.buttons["Settings"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPhone_65_portrait_05_Settings")
    }

    // MARK: - iPhone 6.3" (1206×2622 - iPhone 16 Pro)

    func testiPhone_63_01_Home() {
        if app.tabBars.buttons.count > 0 {
            app.tabBars.buttons.element(boundBy: 0).tap()
            usleep(1500000)
        }
        capture("iPhone_63_portrait_01_Home")
    }

    func testiPhone_63_02_History() {
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
        } else if app.buttons["History"].exists {
            app.buttons["History"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPhone_63_portrait_02_History")
    }

    func testiPhone_63_03_Stats() {
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
        } else if app.buttons["Stats"].exists {
            app.buttons["Stats"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPhone_63_portrait_03_Stats")
    }

    func testiPhone_63_04_Achievements() {
        if app.tabBars.buttons.count > 3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
        } else if app.buttons["Achievements"].exists {
            app.buttons["Achievements"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPhone_63_portrait_04_Achievements")
    }

    func testiPhone_63_05_Settings() {
        if app.tabBars.buttons.count > 4 {
            app.tabBars.buttons.element(boundBy: 4).tap()
        } else if app.buttons["Settings"].exists {
            app.buttons["Settings"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPhone_63_portrait_05_Settings")
    }

    // MARK: - iPad 13" (2048×2732 - iPad Pro 13" M4)

    func testiPad_13_01_Home() {
        if app.tabBars.buttons.count > 0 {
            app.tabBars.buttons.element(boundBy: 0).tap()
        } else if app.buttons["Home"].exists {
            app.buttons["Home"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPad_13_portrait_01_Home")
    }

    func testiPad_13_02_History() {
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
        } else if app.buttons["History"].exists {
            app.buttons["History"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPad_13_portrait_02_History")
    }

    func testiPad_13_03_Stats() {
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
        } else if app.buttons["Stats"].exists {
            app.buttons["Stats"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPad_13_portrait_03_Stats")
    }

    func testiPad_13_04_Achievements() {
        if app.tabBars.buttons.count > 3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
        } else if app.buttons["Achievements"].exists {
            app.buttons["Achievements"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPad_13_portrait_04_Achievements")
    }

    func testiPad_13_05_Settings() {
        if app.tabBars.buttons.count > 4 {
            app.tabBars.buttons.element(boundBy: 4).tap()
        } else if app.buttons["Settings"].exists {
            app.buttons["Settings"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPad_13_portrait_05_Settings")
    }

    // MARK: - iPad 11" (1668×2388 - iPad Pro 11" M4)

    func testiPad_11_01_Home() {
        if app.tabBars.buttons.count > 0 {
            app.tabBars.buttons.element(boundBy: 0).tap()
        } else if app.buttons["Home"].exists {
            app.buttons["Home"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPad_11_portrait_01_Home")
    }

    func testiPad_11_02_History() {
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
        } else if app.buttons["History"].exists {
            app.buttons["History"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPad_11_portrait_02_History")
    }

    func testiPad_11_03_Stats() {
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
        } else if app.buttons["Stats"].exists {
            app.buttons["Stats"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPad_11_portrait_03_Stats")
    }

    func testiPad_11_04_Achievements() {
        if app.tabBars.buttons.count > 3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
        } else if app.buttons["Achievements"].exists {
            app.buttons["Achievements"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPad_11_portrait_04_Achievements")
    }

    func testiPad_11_05_Settings() {
        if app.tabBars.buttons.count > 4 {
            app.tabBars.buttons.element(boundBy: 4).tap()
        } else if app.buttons["Settings"].exists {
            app.buttons["Settings"].firstMatch.tap()
        }
        usleep(1500000)
        capture("iPad_11_portrait_05_Settings")
    }
}
