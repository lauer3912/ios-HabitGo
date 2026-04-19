#!/bin/bash
# HabitArcFlow - Re-record Screenshots for App Store (Simulator)
# Run on MacinCloud VNC

cd ~/Desktop/ios-HabitGo

# Build and install to simulator
xcodebuild -project HabitGo.xcodeproj -scheme HabitArcFlow \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build 2>&1 | tail -5

echo ""
echo "=== Build complete ==="
echo "Now record the screen:"
echo "1. Press Cmd+Shift+5 (macOS screenshot toolbar)"
echo "2. Click 'Options' → Save to: /tmp"
echo "3. Check 'Record Entire Screen' or select simulator window"
echo "4. Press 'Record'"
echo ""
echo "While recording, interact with the app:"
echo "  - View habit list (Tab 1)"
echo "  - Tap + to add a habit"
echo "  - Complete a habit"
echo "  - View Stats (Tab 2)"
echo "  - View History calendar (Tab 3)"
echo "  - View Settings (Tab 4)"
echo ""
echo "Press Cmd+Shift+5 again to stop recording"
echo "Video saves to /tmp/"
