# HabitGo

AI-Adaptive Pomodoro & Focus Timer for iPhone

## Project Info

- **Bundle ID:** com.ggsheng.HabitGo
- **Version:** 1.0.0
- **iOS Target:** 16.0+
- **UI Framework:** SwiftUI

## Building

```bash
# Open in Xcode
open HabitGo.xcodeproj

# Build from command line
xcodebuild -project HabitGo.xcodeproj \
  -scheme HabitGo \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

## Project Structure

```
HabitGo/
├── App/
│   ├── HabitGoApp.swift       # App entry point
│   └── ContentView.swift       # Main TabView + Stats + Settings
├── Models/
│   └── Habit.swift             # Habit data model
├── ViewModels/
│   └── HabitViewModel.swift    # Business logic + persistence
├── Views/
│   ├── HabitListView.swift     # Main habit list
│   ├── HabitRowView.swift      # Individual habit row
│   └── AddHabitView.swift      # Add/edit habit sheet
└── Assets.xcassets/
    ├── AppIcon.appiconset/     # 15 icon sizes
    └── AccentColor.colorset/
```

## Features

- Track unlimited daily habits
- Single-tap completion
- Streak tracking (current + longest)
- Frequency options: daily, weekdays, weekends, weekly
- Beautiful icon + color picker
- Progress overview
- All-time statistics dashboard
- 100% local storage (no cloud, no account)
- No permissions required

## Screenshots

Use XCUITest to capture App Store screenshots. On MacinCloud VNC:

```bash
cd ~/Desktop/ios-HabitGo
git pull origin main
~/tools/xcodegen/bin/xcodegen generate

# Run screenshot tests
xcodebuild -project HabitGo.xcodeproj \
  -scheme HabitGo \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
  -test-target HabitGoUITests \
  -only-testing:HabitGoUITests/HabitGoUITests/testAllTabs \
  build

# Screenshots saved to: /tmp/HabitGoScreenshots/
ls /tmp/HabitGoScreenshots/
```

Required sizes: iPhone 6.7" (1290×2796), iPhone 6.5" (1242×2688), iPad 12.9" (2048×2732).

## App Store

See `AppStore/Listing.md` for App Store listing content.
See `AppStore/HOW-TO-AppStoreConnect.md` for submission guide.
