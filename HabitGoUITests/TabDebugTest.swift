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
        
        // Check buttons by label
        NSLog("Buttons['History'].exists: %d", app.buttons["History"].exists ? 1 : 0);
        NSLog("Buttons['Stats'].exists: %d", app.buttons["Stats"].exists ? 1 : 0);
        NSLog("Buttons['Achievements'].exists: %d", app.buttons["Achievements"].exists ? 1 : 0);
        NSLog("Buttons['Settings'].exists: %d", app.buttons["Settings"].exists ? 1 : 0);
        NSLog("Buttons['Home'].exists: %d", app.buttons["Home"].exists ? 1 : 0);
        
        // Try tapping Achievements by label
        if app.buttons["Achievements"].firstMatch.exists {
            app.buttons["Achievements"].firstMatch.tap();
            usleep(1500000);
            NSLog("Tapped Achievements - success");
        } else {
            NSLog("Achievements button NOT FOUND");
        }
        
        // Check static texts
        NSLog("StaticTexts['Achievements'].exists: %d", app.staticTexts["Achievements"].exists ? 1 : 0);
        NSLog("StaticTexts['Badges'].exists: %d", app.staticTexts["Badges"].exists ? 1 : 0);
    }
}
