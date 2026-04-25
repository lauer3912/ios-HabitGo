#!/bin/bash
#
# HabitArcFlow - Automated Screenshot Generation
# Generates all required App Store screenshots using UITests
#
# Required sizes for App Store:
# - iPhone 6.9" (16 Pro Max): 1290 × 2796 px (portrait)
# - iPhone 6.7" (16 Pro): 1290 × 2796 px (portrait)
# - iPhone 6.5" (11 Pro Max): 1242 × 2688 px (portrait)
# - iPad Pro 12.9": 2048 × 2732 px (portrait)
# - iPad Pro 11": 1668 × 2388 px (portrait)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_PATH="$SCRIPT_DIR/HabitArcFlow.xcodeproj"
SCHEME="HabitArcFlow"
OUTPUT_BASE="$SCRIPT_DIR/AppStoreScreenshots"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Device configurations: name, ID, screenshot path, width, height
declare -a DEVICES=(
    "iPhone_16_Pro_Max:iPhone 16 Pro Max:1290:2796"
    "iPhone_16_Pro:iPhone 16 Pro:1290:2796"
    "iPhone_16:iPhone 16:1179:2556"
    "iPad_Pro_13:iPad Pro 13-inch (M4):2048:2732"
    "iPad_Pro_11:iPad Pro 11-inch (M4):1668:2388"
)

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║       HabitArcFlow - App Store Screenshot Automation         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Step 1: Clean and prepare
echo -e "\n${YELLOW}▓${NC} Step 1/6: Preparing environment..."

rm -rf "$OUTPUT_BASE"
mkdir -p "$OUTPUT_BASE"

# Step 2: List available simulators
echo -e "\n${YELLOW}▓${NC} Step 2/6: Checking available simulators..."
xcrun simctl list devices available | grep -E "iPhone|iPad" | head -10

# Step 3: Boot simulators
echo -e "\n${YELLOW}▓${NC} Step 3/6: Booting simulators..."
for device_config in "${DEVICES[@]}"; do
    IFS=':' read -r -a config <<< "$device_config"
    DEVICE_NAME="${config[1]}"
    
    echo -ne "  Booting ${CYAN}$DEVICE_NAME${NC}... "
    xcrun simctl boot "$DEVICE_NAME" 2>/dev/null && \
        echo -e "${GREEN}✓${NC}" || \
        echo -e "${YELLOW}⚠${NC} (may already be booted)"
done

# Step 4: Wait for simulators to be ready
echo -e "\n${YELLOW}▓${NC} Step 4/6: Waiting for simulators to be ready..."
sleep 3

# Step 5: Run tests and capture screenshots
echo -e "\n${YELLOW}▓${NC} Step 5/6: Running screenshot tests..."

run_screenshot_test() {
    local DEVICE_NAME="$1"
    local OUTPUT_DIR="$2"
    
    echo -e "\n  ${CYAN}→${NC} Testing on ${GREEN}$DEVICE_NAME${NC}"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Run xcodebuild test
    xcodebuild test \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,name=$DEVICE_NAME" \
        -only-testing:ScreenshotTests \
        CODE_SIGNING_ALLOWED=NO \
        2>&1 | grep -E "(Screenshots|Test Suite|passed|failed|PASS|FAIL)" || true
    
    echo -e "  ${GREEN}✓${NC} Completed $DEVICE_NAME"
}

# Run for each device
for device_config in "${DEVICES[@]}"; do
    IFS=':' read -r -a config <<< "$device_config"
    DEVICE_ID="${config[0]}"
    DEVICE_NAME="${config[1]}"
    OUTPUT_DIR="$OUTPUT_BASE/$DEVICE_ID"
    
    run_screenshot_test "$DEVICE_NAME" "$OUTPUT_DIR"
done

# Step 6: Process and organize screenshots
echo -e "\n${YELLOW}▓${NC} Step 6/6: Organizing screenshots..."

# Move screenshots from DerivedData to output
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
find "$DERIVED_DATA" -name "*.png" -path "*Screenshots*" 2>/dev/null | while read -r png; do
    basename "$png" | xargs -I{} mv "$png" "$OUTPUT_BASE/"
done

# Final summary
echo -e "\n${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SCREENSHOT SUMMARY                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "  ${GREEN}✓${NC} Output directory: ${CYAN}$OUTPUT_BASE${NC}"
echo -e "\n  ${GREEN}✓${NC} Device screenshots:"
for device_config in "${DEVICES[@]}"; do
    IFS=':' read -r -a config <<< "$device_config"
    DEVICE_ID="${config[0]}"
    WIDTH="${config[2]}"
    HEIGHT="${config[3]}"
    echo -e "       • $DEVICE_ID: ${WIDTH} × ${HEIGHT} px"
done

echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════╗"
echo -e "║                    DONE!                                      ║"
echo -e "╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "  1. Check screenshots in: open $OUTPUT_BASE"
echo "  2. Review and replace any placeholder images"
echo "  3. Upload to App Store Connect"
echo ""
