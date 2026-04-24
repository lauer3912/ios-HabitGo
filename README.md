# HabitArcFlow

**Build Habits · Track Progress · Stay Consistent**

A beautiful, privacy-first habit tracking app for iPhone and iPad.

## Project Info

- **Bundle ID:** com.ggsheng.HabitGo
- **Version:** 1.0.0
- **iOS Target:** 17.0+
- **UI Framework:** SwiftUI
- **Scheme:** HabitArcFlow
- **Main Target:** HabitArcFlow
- **Widget Target:** HabitArcFlowWidget

## Building

```bash
# Pull latest code
git fetch origin && git reset --hard origin/main

# Generate Xcode project
~/tools/xcodegen/bin/xcodegen generate

# Archive for App Store (requires signing)
xcodebuild archive -project HabitArcFlow.xcodeproj \
  -scheme HabitArcFlow \
  -configuration Release \
  CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  DEVELOPMENT_TEAM=9L6N2ZF26B
```

## Project Structure

```
ios-HabitGo/
├── HabitGo/                      # Main app source
│   ├── HabitGoApp.swift          # App entry point
│   ├── ContentView.swift          # Main TabView (Habits/History/Stats/Settings)
│   ├── Models/Habit.swift        # Habit data model (SwiftData)
│   ├── ViewModels/HabitViewModel.swift  # Business logic + persistence
│   └── Assets.xcassets/
│       ├── AppIcon.appiconset/   # 19 icon sizes (standard format)
│       └── AccentColor.colorset/
├── HabitGoWidget/                # Widget extension
├── HabitGoTests/                 # Unit tests
├── HabitGoUITests/               # UI tests (App Store screenshot capture)
├── AppStore/                     # App Store assets
│   ├── Screenshots/
│   │   ├── iPhone/               # 4x 1290x2796 (iPhone 6.5")
│   │   └── iPad/                  # 4x 2064x2752 (iPad 12.9")
│   ├── Listing.md               # App Store listing content
│   ├── AppStoreReviewResponse.md # Review response
│   └── PrivacyPolicy.html        # Privacy policy
└── project.yml                   # XcodeGen configuration
```

## App Store Screenshots

Screenshots are captured automatically using XCUITest on MacinCloud:

```bash
# Capture iPhone screenshots (1290x2796)
xcodebuild test -scheme HabitArcFlow \
  -destination 'id=2FA15CF7-8D04-4C43-927F-D28A907C8417' \
  -derivedDataPath /tmp/HabitGoUITest \
  CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  DEVELOPMENT_TEAM=9L6N2ZF26B

# Screenshots saved to: /tmp/HabitGoScreenshots/
# iPhone: 4x 1290x2796 (iPhone 6.5" - iPhone 16 Plus)
# iPad:   4x 2064x2752 (iPad Pro 13" M4)
```

Required sizes:
- iPhone 6.5" → **1290×2796** (portrait)
- iPad 12.9" → **2064×2752** (portrait)

## App Store

See `AppStore/Listing.md` for full listing content.
See `AppStore/AppStoreReviewResponse.md` for review response.
