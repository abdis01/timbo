#!/usr/bin/env python3
"""Generate Timbo app icons per design spec."""
from PIL import Image, ImageDraw, ImageFont
import os

SIZE = 1024
CENTER = SIZE // 2
NAVY = (31, 41, 55, 255)       # #1F2937
WHITE = (255, 255, 255, 255)
GOLD = (245, 158, 11, 255)     # #F59E0B
TRANSPARENT = (0, 0, 0, 0)

RADIUS = int(SIZE * 0.42)  # Circle radius
FONT_SIZE = int(SIZE * 0.55)
BOLT_SIZE = int(SIZE * 0.18)

def load_font():
    """Try to load Sora font, fallback to default bold."""
    font_paths = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
    ]
    for path in font_paths:
        if os.path.exists(path):
            return ImageFont.truetype(path, FONT_SIZE)
    return ImageFont.load_default()

def draw_t_with_bolt(draw, font, offset_x=0, offset_y=0):
    """Draw centered 'T' with lightning bolt at bottom-right."""
    text = "T"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    x = CENTER - text_w // 2 + offset_x
    y = CENTER - text_h // 2 + offset_y
    draw.text((x, y), text, font=font, fill=WHITE)

    bolt_x = x + text_w - int(FONT_SIZE * 0.15)
    bolt_y = y + text_h - int(FONT_SIZE * 0.25)
    draw_lightning_bolt(draw, bolt_x, bolt_y)

def draw_lightning_bolt(draw, x, y):
    """Draw a gold lightning bolt."""
    size = BOLT_SIZE
    points = [
        (x + size * 0.5, y),
        (x + size * 0.15, y + size * 0.45),
        (x + size * 0.35, y + size * 0.45),
        (x, y + size),
        (x + size * 0.85, y + size * 0.55),
        (x + size * 0.65, y + size * 0.55),
        (x + size * 0.5, y),
    ]
    draw.polygon(points, fill=GOLD)

font = load_font()

# 1. Full app icon with navy background circle
img_full = Image.new("RGBA", (SIZE, SIZE), TRANSPARENT)
draw_full = ImageDraw.Draw(img_full)
draw_full.ellipse(
    [CENTER - RADIUS, CENTER - RADIUS, CENTER + RADIUS, CENTER + RADIUS],
    fill=NAVY
)
draw_t_with_bolt(draw_full, font)
img_full.save("assets/images/app_icon.png")
print("Created assets/images/app_icon.png")

# 2. Foreground only (transparent background)
img_fg = Image.new("RGBA", (SIZE, SIZE), TRANSPARENT)
draw_fg = ImageDraw.Draw(img_fg)
draw_t_with_bolt(draw_fg, font)
img_fg.save("assets/images/app_icon_foreground.png")
print("Created assets/images/app_icon_foreground.png")

print("\nDone! Now run:")
print("  flutter pub add --dev flutter_launcher_icons")
print("  dart run flutter_launcher_icons")