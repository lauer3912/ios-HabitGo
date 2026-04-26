import XCTest

final class TabDebugTest: XCTestCase {
    func testDebug() {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        usleep(2000000)
        
        NSLog("=== TAB DEBUG ===");
        NSLog("TabBars.count: %d", app.tabBars.count);
        
        if app.tabBars.count > 0 {
            let tabBar = app.tabBars.firstMatch;
            NSLog("TabBar.buttons.count: %d", tabBar.buttons.count);
            for i in 0..<tabBar.buttons.count {
                let btn = tabBar.buttons.element(boundBy: i);
                NSLog("Button[%d]: '%@' exists=%d", i, btn.label, btn.exists ? 1 : 0);
            }
        }
        
        NSLog("Buttons 'History': %d", app.buttons["History"].count);
        NSLog("Buttons 'Stats': %d", app.buttons["Stats"].count);
        NSLog("Buttons 'Achievements': %d", app.buttons["Achievements"].count);
        NSLog("Buttons 'Settings': %d", app.buttons["Settings"].count);
        NSLog("Buttons 'Home': %d", app.buttons["Home"].count);
        
        // Try tapping by label
        if app.buttons["Achievements"].exists {
            app.buttons["Achievements"].firstMatch.tap();
            usleep(1500000);
            NSLog("Tapped Achievements button - success");
        } else {
            NSLog("Achievements button NOT FOUND");
        }
        
        // Check static texts
        NSLog("StaticTexts 'Achievements': %d", app.staticTexts["Achievements"].count);
        NSLog("StaticTexts 'Badges': %d", app.staticTexts["Badges"].count);
    }
}
