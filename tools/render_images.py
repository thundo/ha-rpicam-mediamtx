#!/usr/bin/env python3
"""Render the add-on's store images (icon.png, logo.png) with Pillow.

Drawn at 8x and downsampled, since Pillow's primitives are not antialiased.
Run from the repo root: python3 tools/render_images.py
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ADDON = Path(__file__).resolve().parent.parent / "rpicam_mediamtx"
SCALE = 8

PCB = (38, 128, 72)
PCB_EDGE = (24, 92, 50)
GOLD = (214, 176, 92)
HOUSING = (28, 28, 30)
LENS_RING = (70, 72, 78)
GLASS = (22, 44, 86)
GLASS_INNER = (40, 78, 140)
HIGHLIGHT = (235, 242, 255)
RIBBON = (222, 196, 140)
TITLE = (46, 125, 79)
SUBTITLE = (128, 128, 128)
FONT_BOLD = "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf"
FONT_REGULAR = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"


def circle(d, cx, cy, r, fill):
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=fill)


def draw_module(d, size):
    """A camera module seen from the front: board, mounting holes, sensor housing, lens, ribbon."""
    u = size / 128
    # ribbon leaving the bottom edge, drawn first so the board covers its top
    d.rectangle((44 * u, 100 * u, 84 * u, 126 * u), fill=RIBBON)
    d.rounded_rectangle((8 * u, 8 * u, 120 * u, 108 * u), radius=10 * u, fill=PCB_EDGE)
    d.rounded_rectangle((11 * u, 11 * u, 117 * u, 105 * u), radius=8 * u, fill=PCB)
    for cx, cy in ((22, 22), (106, 22), (22, 94), (106, 94)):
        circle(d, cx * u, cy * u, 7 * u, GOLD)
        circle(d, cx * u, cy * u, 4 * u, PCB_EDGE)
    d.rounded_rectangle((36 * u, 30 * u, 92 * u, 86 * u), radius=5 * u, fill=HOUSING)
    circle(d, 64 * u, 58 * u, 22 * u, LENS_RING)
    circle(d, 64 * u, 58 * u, 17 * u, GLASS)
    circle(d, 64 * u, 58 * u, 10 * u, GLASS_INNER)
    circle(d, 57 * u, 51 * u, 4 * u, HIGHLIGHT)


def render_icon():
    size = 128 * SCALE
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw_module(ImageDraw.Draw(img), size)
    img.resize((128, 128), Image.LANCZOS).save(ADDON / "icon.png", optimize=True)


def render_logo():
    w, h = 250 * SCALE, 100 * SCALE
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    mark = Image.new("RGBA", (128 * SCALE, 128 * SCALE), (0, 0, 0, 0))
    draw_module(ImageDraw.Draw(mark), 128 * SCALE)
    mark = mark.resize((84 * SCALE, 84 * SCALE), Image.LANCZOS)
    img.alpha_composite(mark, (4 * SCALE, 8 * SCALE))
    d.text((96 * SCALE, 24 * SCALE), "Pi Camera", font=ImageFont.truetype(FONT_BOLD, 26 * SCALE), fill=TITLE)
    d.text((97 * SCALE, 60 * SCALE), "MediaMTX · RTSP", font=ImageFont.truetype(FONT_REGULAR, 14 * SCALE), fill=SUBTITLE)
    img.resize((250, 100), Image.LANCZOS).save(ADDON / "logo.png", optimize=True)


if __name__ == "__main__":
    render_icon()
    render_logo()
