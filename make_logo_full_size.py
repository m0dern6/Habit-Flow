#!/usr/bin/env python3
"""
Make the ChatGPT logo fill the entire icon space like the Internet app
Remove excess padding and scale up the design elements
"""

import os
from PIL import Image, ImageDraw
import math

def create_full_size_logo(size, output_path):
    """Create the ChatGPT logo design but scaled to fill the entire icon space"""
    
    # Create image with the gradient background filling everything
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    center = size // 2
    
    # Create the beautiful purple-to-blue gradient background (fills entire space)
    for y in range(size):
        ratio = y / size
        # Purple to blue gradient
        r = int(138 * (1 - ratio) + 99 * ratio)    # 138 -> 99
        g = int(119 * (1 - ratio) + 102 * ratio)   # 119 -> 102  
        b = int(255 * (1 - ratio) + 241 * ratio)   # 255 -> 241
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    # Create rounded corners (modern app icon style)
    corner_radius = size // 5  # Standard iOS/Android app corner radius
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, size, size], corner_radius, fill=255)
    
    # Apply rounded corners to the gradient
    final_image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    gradient_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    gradient_draw = ImageDraw.Draw(gradient_img)
    
    for y in range(size):
        ratio = y / size
        r = int(138 * (1 - ratio) + 99 * ratio)
        g = int(119 * (1 - ratio) + 102 * ratio)
        b = int(255 * (1 - ratio) + 241 * ratio)
        gradient_draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    final_image.paste(gradient_img, (0, 0), mask)
    
    # Now add the LARGE elements that fill most of the space
    draw = ImageDraw.Draw(final_image)
    
    # Colors
    white = (255, 255, 255, 255)
    
    # 1. MUCH LARGER CHECKMARK (fills about 40% of icon)
    check_size = int(size * 0.45)  # Much bigger!
    check_thickness = max(6, size // 15)  # Thicker stroke
    
    # Position checkmark in upper area but more centered
    check_center_x = center - size // 8
    check_center_y = center - size // 10
    
    # Create the checkmark path
    # First stroke (down-right)
    check_x1 = check_center_x - check_size // 3
    check_y1 = check_center_y - check_size // 6
    check_x2 = check_center_x - check_size // 10
    check_y2 = check_center_y + check_size // 4
    
    # Second stroke (up-right, longer)
    check_x3 = check_center_x + check_size // 2
    check_y3 = check_center_y - check_size // 2
    
    # Draw thick checkmark
    for i in range(check_thickness):
        offset = i - check_thickness // 2
        # First stroke
        draw.line([
            (check_x1, check_y1 + offset),
            (check_x2, check_y2 + offset)
        ], fill=white, width=2)
        # Second stroke  
        draw.line([
            (check_x2, check_y2 + offset),
            (check_x3, check_y3 + offset)
        ], fill=white, width=2)
    
    # 2. LARGER PROGRESS BARS (fill more of bottom area)
    bar_width = size // 8  # Wider bars
    bar_spacing = size // 15  # Less spacing
    bar_heights = [size // 5, size // 4, size // 3, int(size * 0.4)]  # Taller bars
    
    # Position bars closer to bottom edge
    bars_start_x = center - (len(bar_heights) * bar_width + (len(bar_heights) - 1) * bar_spacing) // 2
    bars_bottom_y = size - size // 8  # Closer to bottom
    
    for i, height in enumerate(bar_heights):
        bar_x = bars_start_x + i * (bar_width + bar_spacing)
        bar_y = bars_bottom_y - height
        
        # Draw progress bar with rounded corners
        bar_radius = bar_width // 4
        draw.rounded_rectangle(
            [bar_x, bar_y, bar_x + bar_width, bars_bottom_y],
            radius=bar_radius,
            fill=white
        )
    
    # 3. PROMINENT GROWTH CURVE (thicker and more visible)
    curve_thickness = max(5, size // 20)  # Much thicker curve
    
    # Create curve that flows better across the icon
    curve_start_x = check_center_x + check_size // 4
    curve_start_y = check_center_y + check_size // 6
    
    curve_end_x = bars_start_x + len(bar_heights) * (bar_width + bar_spacing) - bar_spacing
    curve_end_y = bars_bottom_y - bar_heights[-1] - size // 12
    
    # Draw smooth, thick curve
    num_points = 30
    curve_points = []
    
    for i in range(num_points + 1):
        t = i / num_points
        
        # Smooth curve with better control points
        control1_x = curve_start_x + (curve_end_x - curve_start_x) * 0.4
        control1_y = curve_start_y - size // 15  # Slight upward curve
        control2_x = curve_start_x + (curve_end_x - curve_start_x) * 0.6  
        control2_y = curve_end_y + size // 20
        
        # Cubic interpolation
        x = (1-t)**3 * curve_start_x + 3*(1-t)**2*t * control1_x + 3*(1-t)*t**2 * control2_x + t**3 * curve_end_x
        y = (1-t)**3 * curve_start_y + 3*(1-t)**2*t * control1_y + 3*(1-t)*t**2 * control2_y + t**3 * curve_end_y
        
        curve_points.append((int(x), int(y)))
    
    # Draw the thick curve
    for i in range(len(curve_points) - 1):
        for thickness_offset in range(curve_thickness):
            offset_y = thickness_offset - curve_thickness // 2
            draw.line([
                (curve_points[i][0], curve_points[i][1] + offset_y),
                (curve_points[i+1][0], curve_points[i+1][1] + offset_y)
            ], fill=white, width=2)
    
    # 4. ADD SUBTLE DEPTH ELEMENTS that don't take up space
    # Very subtle circle overlay for depth (like Internet app has subtle elements)
    circle_radius = size // 2
    circle_center_x = center + size // 6
    circle_center_y = center - size // 8
    
    # Very subtle circle overlay for depth
    overlay_color = (255, 255, 255, 15)  # Very subtle
    draw.ellipse([
        circle_center_x - circle_radius, circle_center_y - circle_radius,
        circle_center_x + circle_radius, circle_center_y + circle_radius
    ], fill=overlay_color)
    
    # Save the icon
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    final_image.save(output_path, 'PNG', quality=100, optimize=True)
    print(f"✅ Created FULL-SIZE icon: {output_path} ({size}x{size})")

def main():
    """Apply the ChatGPT logo design but scaled to fill the entire icon like Internet app"""
    base_path = "e:/flutter/demo_app"
    
    print("🎯 Making logo FILL THE ENTIRE ICON like Internet app...")
    print("📏 Scaling up all elements to remove excess padding")
    print("💫 Making it prominent and visible like other apps")
    print()
    
    # All required sizes and paths
    sizes_and_paths = [
        # Android
        (48, f"{base_path}/android/app/src/main/res/mipmap-mdpi/ic_launcher.png"),
        (72, f"{base_path}/android/app/src/main/res/mipmap-hdpi/ic_launcher.png"),
        (96, f"{base_path}/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"),
        (144, f"{base_path}/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"),
        (192, f"{base_path}/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"),
        
        # Web
        (16, f"{base_path}/web/favicon.png"),
        (192, f"{base_path}/web/icons/Icon-192.png"),
        (512, f"{base_path}/web/icons/Icon-512.png"),
        (192, f"{base_path}/web/icons/Icon-maskable-192.png"),
        (512, f"{base_path}/web/icons/Icon-maskable-512.png"),
        
        # iOS
        (180, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png"),
        (120, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png"),
        (180, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-180x180@3x.png"),
        (120, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-120x120@3x.png"),
        (76, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png"),
        (152, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png"),
        (40, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png"),
        (80, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png"),
        (120, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png"),
        (29, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png"),
        (58, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png"),
        (87, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png"),
        (20, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png"),
        (40, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png"),
        (60, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png"),
        (1024, f"{base_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"),
    ]
    
    # Generate all full-size icons
    for size, path in sizes_and_paths:
        create_full_size_logo(size, path)
    
    print()
    print("🎯 ✅ FULL-SIZE LOGO APPLIED!")
    print()
    print("📏 Changes made:")
    print("✅ Checkmark is 45% of icon size (was much smaller)")
    print("✅ Progress bars are taller and wider") 
    print("✅ Growth curve is thicker and more prominent")
    print("✅ Elements positioned closer to edges")
    print("✅ Fills the space like Internet app!")
    print()
    print("🚀 Your app icon will now be as prominent as other apps!")

if __name__ == "__main__":
    main()
