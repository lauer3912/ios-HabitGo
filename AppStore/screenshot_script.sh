#!/bin/bash
# HabitGo Screenshot Capture Script
# Run this on MacinCloud VNC after xcodegen generate

set -e

PROJECT_DIR="$HOME/Desktop/ios-HabitGo"
SCHEME="HabitGo"
CONFIG="Debug"

echo "=== HabitGo Screenshot Capture ==="
echo "Project: $PROJECT_DIR"
echo ""

# Step 1: Check if project exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: Project not found at $PROJECT_DIR"
    echo "Please clone the repo first:"
    echo "  git clone https://github.com/lauer3912/ios-HabitGo.git ~/Desktop/ios-HabitGo"
    exit 1
fi

# Step 2: Check if XcodeGen is needed
if [ ! -f "$PROJECT_DIR/HabitGo.xcodeproj/project.xcworkspace/contents.xcworkspacedata" ]; then
    echo "XcodeGen not yet run. Generating project..."
    cd "$PROJECT_DIR"
    if [ -f "$HOME/tools/xcodegen/bin/xcodegen" ]; then
        "$HOME/tools/xcodegen/bin/xcodegen" generate
    else
        echo "ERROR: XcodeGen not found. Please install from https://github.com/yonaskolb/XcodeGen"
        exit 1
    fi
fi

# Step 3: Run xcodebuild for UITests
# The UITests will save screenshots to /tmp/HabitGoScreenshots
SCREENSHOT_DIR="/tmp/HabitGoScreenshots"
rm -rf "$SCREENSHOT_DIR"
mkdir -p "$SCREENSHOT_DIR"

# iPhone 6.7" (iPhone 16 Pro Max or similar 6.7" simulator)
IPHONE_67="iPhone 16 Pro Max"

echo "--- Capturing iPhone 6.7\" screenshots ---"
xcodebuild -project "$PROJECT_DIR/HabitGo.xcodeproj" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -destination "platform=iOS Simulator,name=$IPHONE_67" \
  -test-target HabitGoUITests \
  -only-testing:HabitGoUITests/HabitGoUITests/testAllTabs \
  build 2>&1 | tail -5

echo ""
echo "--- Screenshots saved to $SCREENSHOT_DIR ---"
ls -la "$SCREENSHOT_DIR/" 2>/dev/null || echo "No screenshots found"

# Step 4: Copy screenshots to AppStore folder
DEST_DIR="$PROJECT_DIR/AppStore/Screenshots"
mkdir -p "$DEST_DIR"
cp "$SCREENSHOT_DIR"/*.png "$DEST_DIR/" 2>/dev/null

echo ""
echo "--- Copied to $DEST_DIR ---"
ls -la "$DEST_DIR/"

# Step 5: Report
echo ""
echo "=== Screenshot Summary ==="
for f in "$DEST_DIR"/*.png; do
    if [ -f "$f" ]; then
        SIZE=$(identify "$f" 2>/dev/null | awk '{print $3}' || echo "unknown")
        echo "  $(basename $f): $SIZE"
    fi
done

echo ""
echo "Done! Screenshots are in: $DEST_DIR"
