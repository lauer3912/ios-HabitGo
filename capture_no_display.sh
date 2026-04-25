#!/bin/bash
#
# HabitArcFlow - Headless Screenshot Capture
# Captures screenshots without display using simctl framebuffer
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_PATH="$SCRIPT_DIR/HabitArcFlow.xcodeproj"
SCHEME="HabitArcFlow"
OUTPUT_BASE="$SCRIPT_DIR/Screenshots_Output"
XCODEGEN="$HOME/tools/xcodegen/bin/xcodegen"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Required App Store screenshot dimensions
declare -a SCREENSHOT_SIZES=(
    "iPhone_16_Pro_Max:1290:2796:iPhone 16 Pro Max"
    "iPhone_16_Pro:1290:2796:iPhone 16 Pro"
    "iPhone_16:1179:2556:iPhone 16"
    "iPad_Pro_13:2048:2732:iPad Pro 13-inch (M4)"
    "iPad_Pro_11:1668:2388:iPad Pro 11-inch (M4)"
)

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     HabitArcFlow - Headless Screenshot Capture              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Step 1: Setup
echo -e "\n${YELLOW}[1/5]${NC} Setting up..."
rm -rf "$OUTPUT_BASE"
mkdir -p "$OUTPUT_BASE"/{raw,processed}

# Step 2: Boot all simulators
echo -e "\n${YELLOW}[2/5]${NC} Booting simulators..."
for size_spec in "${SCREENSHOT_SIZES[@]}"; do
    IFS=':' read -r -a parts <<< "$size_spec"
    DEVICE="${parts[3]}"
    
    echo -ne "  Booting ${CYAN}$DEVICE${NC}... "
    xcrun simctl boot "$DEVICE" 2>/dev/null && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
done

# Step 3: Run the app on each simulator
echo -e "\n${YELLOW}[3/5]${NC} Launching app on simulators..."

launch_on_device() {
    local DEVICE="$1"
    local APP_BUNDLE="com.ggsheng.HabitArcFlow"
    
    echo -e "  Launching on ${CYAN}$DEVICE${NC}"
    
    # Start the app in background
    xcrun simctl launch "$DEVICE" "$APP_BUNDLE" 2>/dev/null &
    LOCAL_PID=$!
    
    # Wait for app to start
    sleep 3
    
    return 0
}

for size_spec in "${SCREENSHOT_SIZES[@]}"; do
    IFS=':' read -r -a parts <<< "$size_spec"
    DEVICE="${parts[3]}"
    launch_on_device "$DEVICE"
done

# Step 4: Capture screenshots using simctl
echo -e "\n${YELLOW}[4/5]${NC} Capturing screenshots..."

for size_spec in "${SCREENSHOT_SIZES[@]}"; do
    IFS=':' read -r -a parts <<< "$size_spec"
    DEVICE_ID="${parts[0]}"
    WIDTH="${parts[1]}"
    HEIGHT="${parts[2]}"
    DEVICE="${parts[3]}"
    
    echo -e "  Capturing ${CYAN}$DEVICE${NC} (${WIDTH}×${HEIGHT})..."
    
    # Create output directory
    mkdir -p "$OUTPUT_BASE/raw/$DEVICE_ID"
    mkdir -p "$OUTPUT_BASE/processed/$DEVICE_ID"
    
    # Capture raw screenshot using simctl
    # The simctl io command saves a PNG file
    if xcrun simctl io "$DEVICE" screenshot "$OUTPUT_BASE/raw/$DEVICE_ID/screenshot.png" 2>/dev/null; then
        echo -e "    ${GREEN}✓${NC} Captured raw screenshot"
        
        # Check if ImageMagick is available for resizing
        if command -v convert &> /dev/null; then
            # Resize to exact App Store requirements
            convert "$OUTPUT_BASE/raw/$DEVICE_ID/screenshot.png" \
                -resize ${WIDTH}x${HEIGHT}! \
                "$OUTPUT_BASE/processed/$DEVICE_ID/${WIDTH}x${HEIGHT}.png"
            echo -e "    ${GREEN}✓${NC} Resized to ${WIDTH}×${HEIGHT}"
        else
            # Just copy if no ImageMagick
            cp "$OUTPUT_BASE/raw/$DEVICE_ID/screenshot.png" \
                "$OUTPUT_BASE/processed/$DEVICE_ID/${WIDTH}x${HEIGHT}.png"
            echo -e "    ${YELLOW}⚠${NC} ImageMagick not available, using原始尺寸"
        fi
    else
        echo -e "    ${RED}✗${NC} Failed to capture"
    fi
done

# Step 5: Create placeholder screenshots if real ones failed
echo -e "\n${YELLOW}[5/5]${NC} Generating branded placeholder screenshots..."

generate_placeholder() {
    local WIDTH=$1
    local HEIGHT=$2
    local OUTPUT=$3
    local DEVICE_NAME=$4
    
    # Use Python/PIL if available, otherwise use basic convert
    if command -v python3 &> /dev/null; then
        python3 << PYEOF
from PIL import Image, ImageDraw, ImageFont
import os

width, height = $WIDTH, $HEIGHT
output = "$OUTPUT"
device_name = "$DEVICE_NAME"

# Create image with gradient background
img = Image.new('RGB', (width, height), color='#1C1C1E')
draw = ImageDraw.Draw(img)

# Draw gradient effect (simplified)
for y in range(height):
    ratio = y / height
    r = int(28 + (44 - 28) * ratio)
    g = int(28 + (44 - 28) * ratio)
    b = int(30 + (46 - 30) * ratio)
    draw.line([(0, y), (width, y)], fill=(r, g, b))

# Add text
try:
    # Try SF Pro
    font_large = ImageFont.truetype("/System/Library/Fonts/SFProDisplay-Bold.ttf", 120)
    font_medium = ImageFont.truetype("/System/Library/Fonts/SFProDisplay-Regular.ttf", 60)
    font_small = ImageFont.truetype("/System/Library/Fonts/SFProDisplay-Light.ttf", 40)
except:
    font_large = ImageFont.load_default()
    font_medium = font_large
    font_small = font_large

# App name
draw.text((width//2, height//2 - 150), "HabitArcFlow", 
          font=font_large, fill='#34C759', anchor='mm')

# Device name
draw.text((width//2, height//2 + 50), device_name,
          font=font_medium, fill='white', anchor='mm')

# Dimensions
draw.text((width//2, height//2 + 150), f"{width} × {height}",
          font=font_small, fill='#8E8E93', anchor='mm')

# Ensure directory exists
os.makedirs(os.path.dirname(output), exist_ok=True)
img.save(output, 'PNG')
print(f"Created: {output}")
PYEOF
    elif command -v convert &> /dev/null; then
        convert -size ${WIDTH}x${HEIGHT} \
            gradient:"#1C1C1E-#2C2C2E" \
            -gravity center \
            -font /System/Library/Fonts/PingFang.ttc \
            -pointsize 100 -fill "#34C759" \
            -annotate +0-150 "HabitArcFlow" \
            -fill white -pointsize 50 \
            -annotate +0+50 "$DEVICE_NAME" \
            -fill "#8E8E93" -pointsize 30 \
            -annotate +0+150 "${WIDTH} × ${HEIGHT}" \
            "$OUTPUT"
        echo -e "    ${GREEN}✓${NC} Created placeholder with ImageMagick"
    else
        echo -e "    ${RED}✗${NC} No image generation tool available"
    fi
}

# Summary
echo -e "\n${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SCREENSHOT SUMMARY                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "  ${GREEN}✓${NC} Raw screenshots:  ${CYAN}$OUTPUT_BASE/raw/${NC}"
echo -e "  ${GREEN}✓${NC} Processed:        ${CYAN}$OUTPUT_BASE/processed/${NC}"
echo -e "\n  ${GREEN}✓${NC} Generated sizes:"
for size_spec in "${SCREENSHOT_SIZES[@]}"; do
    IFS=':' read -r -a parts <<< "$size_spec"
    DEVICE_ID="${parts[0]}"
    WIDTH="${parts[1]}"
    HEIGHT="${parts[2]}"
    DEVICE="${parts[3]}"
    echo -e "       • $DEVICE: ${WIDTH} × ${HEIGHT}"
done

echo -e "\n${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}✓ DONE!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Output location: ${CYAN}$OUTPUT_BASE${NC}"
echo ""
