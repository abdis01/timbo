#!/usr/bin/env python3
"""Generate empty_timbonce.png and premium_bg.png."""
from PIL import Image, ImageDraw, ImageFont
import os

SIZE_W, SIZE_H = 768, 1365  # ~9:16

def generate_empty_timbonce(path):
    img = Image.new("RGBA", (SIZE_W, SIZE_H), (5, 5, 10, 255))
    draw = ImageDraw.Draw(img)
    cx, cy = SIZE_W // 2, SIZE_H // 3
    # dark chart bars
    bar_colors = [(40, 45, 60), (30, 35, 50), (50, 55, 70), (35, 40, 55)]
    for i, c in enumerate(bar_colors):
        bw, bh = 60, 80 + i * 40
        bx = cx - 100 + i * 60
        by = cy + 80 - bh
        draw.rectangle([bx, by, bx + bw, by + bh], fill=c + (200,))
    # line chart dots and lines
    pts = [(cx - 80, cy + 40), (cx - 40, cy - 20), (cx, cy + 10), (cx + 40, cy - 40), (cx + 80, cy)]
    for x, y in pts:
        draw.ellipse([x-4, y-4, x+4, y+4], fill=(60, 65, 85, 220))
    for i in range(len(pts)-1):
        draw.line([pts[i], pts[i+1]], fill=(60, 65, 85, 150), width=2)
    # subtle floating particles
    import random
    for _ in range(30):
        x, y = random.randint(0, SIZE_W), random.randint(0, SIZE_H)
        r = random.randint(1, 3)
        a = random.randint(30, 80)
        draw.ellipse([x-r, y-r, x+r, y+r], fill=(255, 255, 255, a))
    img.save(path)
    print(f"Created {path}")

def generate_premium_bg(path):
    img = Image.new("RGBA", (SIZE_W, SIZE_H), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)
    import random
    random.seed(42)
    # very subtle gold veins
    for _ in range(12):
        x = random.randint(0, SIZE_W)
        y = random.randint(0, SIZE_H)
        pts = []
        for i in range(6):
            pts.append((x + random.randint(-80, 80), y + random.randint(-30, 30)))
            x, y = pts[-1]
        for i in range(len(pts)-1):
            alpha = random.randint(8, 20)
            draw.line([pts[i], pts[i+1]], fill=(184, 134, 11, alpha), width=1)
    # subtle radial glow
    for r in range(300, 0, -30):
        alpha = max(0, 3 - r // 100)
        draw.ellipse([SIZE_W//2-r, SIZE_H//2-r, SIZE_W//2+r, SIZE_H//2+r],
                     fill=(184, 134, 11, alpha))
    # tiny gold specks
    for _ in range(50):
        x, y = random.randint(0, SIZE_W), random.randint(0, SIZE_H)
        a = random.randint(5, 15)
        draw.ellipse([x-1, y-1, x+1, y+1], fill=(184, 134, 11, a))
    img.save(path)
    print(f"Created {path}")

generate_empty_timbonce("assets/images/empty_timbonce.png")
generate_premium_bg("assets/images/premium_bg.png")
