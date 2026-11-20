#!/usr/bin/env python3
"""Render the burned-in text overlays for the GTA 6 Trailer 1 vertical clip.

Every overlay is a transparent 1080x1920 PNG. build_clip.sh composites each
one over the segment(s) it belongs to. Style: heavy bold font, white text
with a thick black stroke, accent colour for the money lines, and a soft
dark band behind the smaller captions so they read on any footage.
"""
import os
from PIL import Image, ImageDraw, ImageFont

W, H = 1080, 1920
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "work", "overlays")
os.makedirs(OUT, exist_ok=True)

WHITE = (255, 255, 255, 255)
ACCENT = (255, 176, 58, 255)      # warm Vice amber for the money lines
PINK = (255, 77, 141, 255)        # Vice pink for the hook payoff
BLACK = (0, 0, 0, 255)

FONT_CANDIDATES = [
    "/usr/share/fonts/truetype/noto/NotoSansDisplay-Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
]


def font_path():
    for p in FONT_CANDIDATES:
        if os.path.exists(p):
            return p
    raise SystemExit("no bold font found")


FONT = font_path()


def fit_font(text, max_size, max_width=1000):
    """Largest font size <= max_size whose render of text fits max_width."""
    size = max_size
    while size > 20:
        f = ImageFont.truetype(FONT, size)
        if f.getlength(text) <= max_width:
            return f
        size -= 4
    return ImageFont.truetype(FONT, size)


def draw_centered(draw, text, y, max_size, fill, stroke_w=None, max_width=1000):
    f = fit_font(text, max_size, max_width)
    sw = stroke_w if stroke_w is not None else max(4, f.size // 11)
    x = (W - f.getlength(text)) / 2
    draw.text((x, y), text, font=f, fill=fill, stroke_width=sw, stroke_fill=BLACK)
    return f.size


def band(draw, y_top, height, alpha=110):
    draw.rounded_rectangle([40, y_top, W - 40, y_top + height], radius=28,
                           fill=(0, 0, 0, alpha))


def save(img, name):
    img.save(os.path.join(OUT, name))
    print("overlay:", name)


def blank():
    return Image.new("RGBA", (W, H), (0, 0, 0, 0))


# --- Hook (segment 1, top of frame, over the emerald-water boat shot) ---
img = blank()
d = ImageDraw.Draw(img)
draw_centered(d, "THIS IS NOT A MOVIE.", 150, 92, WHITE)
draw_centered(d, "IT'S GTA 6.", 268, 128, PINK)
save(img, "ov_hook.png")

# --- Bottom captions, one per montage segment ---
CAPTIONS = {
    "ov_cap_highway.png": "WELCOME TO LEONIDA",
    "ov_cap_convertible.png": "VICE CITY AFTER DARK",
    "ov_cap_keys.png": "THE LEONIDA KEYS",
    "ov_cap_gator.png": "ONLY IN LEONIDA...",
    "ov_cap_lucia.png": "LUCIA IS BACK",
    "ov_cap_hammer.png": "LEONIDA IS UNHINGED",
    "ov_cap_meet.png": "VICE CITY CHAOS",
}
for name, text in CAPTIONS.items():
    img = blank()
    d = ImageDraw.Draw(img)
    band(d, 1560, 120)
    draw_centered(d, text, 1582, 76, WHITE)
    save(img, name)

# --- Mid-clip pitch band (spans the Lucia + red-car segments) ---
img = blank()
d = ImageDraw.Draw(img)
band(d, 1330, 215, alpha=150)
draw_centered(d, "AN AI AGENT MADE THIS CLIP", 1352, 68, WHITE)
draw_centered(d, "FOR A $500 BOUNTY", 1448, 68, ACCENT)
save(img, "ov_midpitch.png")

# --- End card lines (staggered appearance over the trailer's VI logo card) ---
img = blank()
d = ImageDraw.Draw(img)
draw_centered(d, "MAKE CLIPS LIKE THIS WITH AI", 1210, 72, WHITE)
save(img, "ov_end1.png")

img = blank()
d = ImageDraw.Draw(img)
draw_centered(d, "EARN MONEY ON make.fun", 1395, 92, ACCENT)
save(img, "ov_end2.png")

img = blank()
d = ImageDraw.Draw(img)
draw_centered(d, "make.fun/bounty/gta6-clipper-01", 1565, 56, WHITE, max_width=1020)
save(img, "ov_end3.png")

print("done ->", OUT)
