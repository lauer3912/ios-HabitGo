#!/usr/bin/env python3
"""
HabitArcFlow - Professional Screenshot Placeholder Generator
Generates App Store ready screenshots with professional dark theme design
"""

import os
import sys
from PIL import Image, ImageDraw, ImageFont
import argparse

# App Store required sizes
SCREENSHOT_SIZES = {
    "iPhone_16_Pro_Max": {"width": 1290, "height": 2796, "device": "iPhone 16 Pro Max", "family": "iPhone"},
    "iPhone_16_Pro": {"width": 1290, "height": 2796, "device": "iPhone 16 Pro", "family": "iPhone"},
    "iPhone_16": {"width": 1179, "height": 2556, "device": "iPhone 16", "family": "iPhone"},
    "iPhone_15_Pro_Max": {"width": 1290, "height": 2796, "device": "iPhone 15 Pro Max", "family": "iPhone"},
    "iPhone_14_Pro_Max": {"width": 1290, "height": 2796, "device": "iPhone 14 Pro Max", "family": "iPhone"},
    "iPad_Pro_13": {"width": 2048, "height": 2732, "device": "iPad Pro 13\"", "family": "iPad"},
    "iPad_Pro_11": {"width": 1668, "height": 2388, "device": "iPad Pro 11\"", "family": "iPad"},
    "iPad_Pro_12_9": {"width": 2048, "height": 2732, "device": "iPad Pro 12.9\"", "family": "iPad"},
}

# Color palette - Dark theme
COLORS = {
    "background": "#1C1C1E",
    "background_secondary": "#2C2C2E",
    "primary": "#34C759",
    "primary_dark": "#248A3D",
    "text_primary": "#FFFFFF",
    "text_secondary": "#8E8E93",
    "text_tertiary": "#636366",
    "card": "#3A3A3C",
    "separator": "#38383A",
    "accent": "#007AFF",
}

def create_gradient_background(width, height):
    """Create a professional gradient background"""
    img = Image.new('RGB', (width, height), color=COLORS["background"])
    draw = ImageDraw.Draw(img)
    
    # Subtle gradient from top to bottom
    for y in range(height):
        ratio = y / height
        # Gradient from background to background_secondary
        r = int(28 + (44 - 28) * ratio)
        g = int(28 + (44 - 28) * ratio)
        b = int(30 + (46 - 30) * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    return img, draw

def get_font(size, bold=False):
    """Get system font"""
    if sys.platform == "darwin":
        if bold:
            font_paths = [
                "/System/Library/Fonts/SFProDisplay-Bold.otf",
                "/System/Library/Fonts/Helvetica.ttc",
                "/Library/Fonts/Arial.ttf",
            ]
        else:
            font_paths = [
                "/System/Library/Fonts/SFProDisplay-Regular.otf",
                "/System/Library/Fonts/Helvetica.ttc",
                "/Library/Fonts/Arial.ttf",
            ]
        for path in font_paths:
            if os.path.exists(path):
                try:
                    return ImageFont.truetype(path, size)
                except:
                    pass
    return ImageFont.load_default()

def draw_centered_text(draw, text, y, font, color, width):
    """Draw text centered horizontally"""
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    x = (width - text_width) // 2
    draw.text((x, y), text, font=font, fill=color)

def create_mockup_screenshot(size_key, output_path, screen_type="Home"):
    """Create a professional mockup screenshot"""
    config = SCREENSHOT_SIZES[size_key]
    width = config["width"]
    height = config["height"]
    device = config["device"]
    family = config["family"]
    
    # Create background
    img, draw = create_gradient_background(width, height)
    
    # Get fonts
    font_large = get_font(int(width * 0.06), bold=True)
    font_medium = get_font(int(width * 0.035))
    font_small = get_font(int(width * 0.025))
    font_tiny = get_font(int(width * 0.018))
    
    # Calculate responsive sizes
    padding = width * 0.08
    content_top = height * 0.15
    content_bottom = height * 0.85
    
    # Draw mock phone frame for iPhone
    if family == "iPhone":
        frame_top = height * 0.08
        frame_bottom = height * 0.12
        frame_left = width * 0.05
        frame_right = width * 0.95
        
        # Phone bezel (subtle)
        draw.rounded_rectangle(
            [frame_left, frame_top, frame_right, height - frame_bottom],
            radius=int(width * 0.08),
            outline=COLORS["card"],
            width=3
        )
        
        # Dynamic Island / Notch indicator
        island_width = width * 0.25
        island_height = height * 0.015
        island_top = frame_top + height * 0.01
        draw.rounded_rectangle(
            [(width - island_width)//2, island_top,
             (width + island_width)//2, island_top + island_height],
            radius=island_height//2,
            fill=COLORS["card"]
        )
        
        # Home indicator
        indicator_width = width * 0.3
        indicator_height = height * 0.008
        indicator_bottom = height - frame_bottom - height * 0.015
        draw.rounded_rectangle(
            [(width - indicator_width)//2, indicator_bottom,
             (width + indicator_width)//2, indicator_bottom + indicator_height],
            radius=indicator_height//2,
            fill=COLORS["text_tertiary"]
        )
    
    # Draw mock UI elements
    
    # Navigation bar area
    nav_height = height * 0.08
    draw.rectangle([0, content_top, width, content_top + nav_height], fill=COLORS["card"])
    
    # App title
    draw_centered_text(draw, "HabitArcFlow", content_top + nav_height * 0.4,
                       font_medium, COLORS["primary"], width)
    
    # Mock content cards
    card_top = content_top + nav_height + height * 0.05
    card_height = height * 0.12
    card_margin = width * 0.08
    card_spacing = card_height * 0.2
    
    for i in range(3):
        card_y = card_top + i * (card_height + card_spacing)
        
        # Card background
        draw.rounded_rectangle(
            [card_margin, card_y, width - card_margin, card_y + card_height],
            radius=width * 0.03,
            fill=COLORS["card"]
        )
        
        # Card icon circle
        icon_size = card_height * 0.5
        icon_x = card_margin + card_height * 0.25
        icon_y = card_y + card_height * 0.25
        draw.ellipse(
            [icon_x, icon_y, icon_x + icon_size, icon_y + icon_size],
            fill=COLORS["primary"]
        )
        
        # Card title
        title_x = icon_x + icon_size + card_height * 0.2
        title_y = card_y + card_height * 0.25
        draw.text((title_x, title_y), f"Habit {i+1}", font=font_small, fill=COLORS["text_primary"])
        
        # Card subtitle
        subtitle_y = title_y + card_height * 0.25
        draw.text((title_x, subtitle_y), "Daily • Streak: 5", font=font_tiny, fill=COLORS["text_secondary"])
    
    # Tab bar
    tab_height = height * 0.08
    tab_bottom = content_bottom
    draw.rectangle([0, tab_bottom - tab_height, width, tab_bottom], fill=COLORS["card"])
    
    # Tab icons
    tab_icons = ["habit", "calendar", "chart", "star", "gear"]
    tab_icon_width = width / 5
    
    for i, icon_name in enumerate(tab_icons):
        icon_x = tab_icon_width * i + tab_icon_width * 0.5
        icon_y = tab_bottom - tab_height * 0.5
        color = COLORS["primary"] if i == 0 else COLORS["text_tertiary"]
        
        # Simple circle indicator
        circle_size = tab_height * 0.3
        draw.ellipse(
            [icon_x - circle_size/2, icon_y - circle_size/2,
             icon_x + circle_size/2, icon_y + circle_size/2],
            fill=color
        )
    
    # Footer text
    footer_y = content_bottom + height * 0.02
    size_text = f"{width} × {height}"
    draw_centered_text(draw, size_text, footer_y, font_tiny, COLORS["text_tertiary"], width)
    
    # Ensure output directory exists
    os.makedirs(os.path.dirname(output_path) if os.path.dirname(output_path) else ".", exist_ok=True)
    
    # Save
    img.save(output_path, "PNG", quality=95)
    print(f"Created: {output_path} ({width} × {height})")
    
    return output_path

def main():
    parser = argparse.ArgumentParser(description="Generate App Store screenshots")
    parser.add_argument("--output", "-o", default="./AppStoreScreenshots",
                        help="Output directory")
    parser.add_argument("--size", "-s", choices=list(SCREENSHOT_SIZES.keys()) + ["all"],
                        default="all", help="Screenshot size to generate")
    parser.add_argument("--type", "-t", default="Home",
                        help="Screen type (Home, Detail, Settings, etc.)")
    
    args = parser.parse_args()
    
    output_dir = args.output
    os.makedirs(output_dir, exist_ok=True)
    
    if args.size == "all":
        sizes = SCREENSHOT_SIZES.keys()
    else:
        sizes = [args.size]
    
    print(f"\nGenerating App Store screenshots...")
    print(f"Output directory: {output_dir}\n")
    
    for size_key in sizes:
        config = SCREENSHOT_SIZES[size_key]
        output_path = os.path.join(output_dir, size_key, f"{args.type}.png")
        create_mockup_screenshot(size_key, output_path, args.type)
    
    print(f"\n✓ Generated {len(list(sizes))} screenshot(s)")
    print(f"\nNext steps:")
    print(f"  1. Replace placeholder images with real screenshots")
    print(f"  2. Upload to App Store Connect")
    print(f"  3. Use Transporter or App Store Connect website")

if __name__ == "__main__":
    main()
