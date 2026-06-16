#!/usr/bin/env python3
"""Generate the branded macOS DMG background and volume icon.

Outputs (committed to the repo so CI does not depend on Pillow):
  - macos/packaging/dmg/background.png      680x420  (1x)
  - macos/packaging/dmg/background@2x.png   1360x840 (retina)
  - macos/packaging/dmg/volume.icns         DMG mount volume icon

appdmg picks up background@2x.png automatically for retina (it builds the
HiDPI .tiff internally), so build_dmg.sh just references background.png.

The geometry here MUST stay in sync with macos/packaging/dmg/appdmg.json:
  window 680x420, icon size 116, app icon at (175,175),
  Applications at (505,175), install note at (340,350)

Run locally after changing the source icon or layout:
    python3 macos/packaging/dmg/gen_background.py
"""
from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

REPO_ROOT = Path(__file__).resolve().parents[3]
SOURCE_ICON = REPO_ROOT / "assets" / "icon" / "launcher_icon_v2.png"
OUT_DIR = Path(__file__).resolve().parent

# 1x layout (must match appdmg.json geometry in build_dmg.sh)
W, H = 680, 420
ICON_Y = 175          # vertical center of the app / Applications row
APP_X = 175           # app (.app) icon center x
APPLICATIONS_X = 505  # Applications drop link center x
NOTE_Y = 350          # install-note icon center (bottom, centered)

# Warm palette derived from the app's brand orange.
BG_TOP = (255, 249, 243)
BG_BOTTOM = (255, 237, 220)
ACCENT = (234, 138, 51)
TEXT_DARK = (60, 50, 44)
TEXT_MUTED = (140, 120, 108)

FONT_CANDIDATES = [
    "/System/Library/Fonts/PingFang.ttc",
    "/System/Library/Fonts/STHeiti Medium.ttc",
    "/System/Library/Fonts/Hiragino Sans GB.ttc",
    "/Library/Fonts/Arial Unicode.ttf",
]


def load_font(size: int) -> ImageFont.FreeTypeFont:
    for path in FONT_CANDIDATES:
        if Path(path).exists():
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                continue
    return ImageFont.load_default()


def vertical_gradient(w: int, h: int, top, bottom) -> Image.Image:
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        t = y / max(1, h - 1)
        row = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        for x in range(w):
            px[x, y] = row
    return img


def draw_arrow(d: ImageDraw.ImageDraw, scale: int) -> None:
    """Right-pointing arrow between the app icon and Applications."""
    cy = ICON_Y * scale
    x0 = (APP_X + 70) * scale          # tail (right of app icon)
    x1 = (APPLICATIONS_X - 70) * scale  # tip (left of Applications)
    shaft_h = 12 * scale
    head_w = 34 * scale
    head_h = 40 * scale
    # shaft
    d.rounded_rectangle(
        [x0, cy - shaft_h // 2, x1 - head_w, cy + shaft_h // 2],
        radius=shaft_h // 2, fill=ACCENT,
    )
    # head
    d.polygon(
        [(x1 - head_w, cy - head_h // 2), (x1, cy), (x1 - head_w, cy + head_h // 2)],
        fill=ACCENT,
    )


def centered_text(d, cx, y, text, font, fill):
    bbox = d.textbbox((0, 0), text, font=font)
    w = bbox[2] - bbox[0]
    d.text((cx - w / 2, y), text, font=font, fill=fill)


def render(scale: int) -> Image.Image:
    w, h = W * scale, H * scale
    img = vertical_gradient(w, h, BG_TOP, BG_BOTTOM)
    d = ImageDraw.Draw(img)

    title_font = load_font(34 * scale)
    sub_font = load_font(16 * scale)

    centered_text(d, w / 2, 40 * scale, "i_iwara", title_font, TEXT_DARK)
    centered_text(d, w / 2, 86 * scale,
                  "将 i_iwara 拖入 Applications 文件夹完成安装",
                  sub_font, TEXT_MUTED)

    draw_arrow(d, scale)

    # Note: Finder renders each icon's own name label beneath it, so we do not
    # bake "i_iwara"/"Applications" captions here (they would double up).
    # The install-note icon sits centered at NOTE_Y; add a short hint above it.
    centered_text(d, w / 2, (NOTE_Y - 78) * scale,
                  "首次打开请右键点按图标 → 打开 · First launch: right-click → Open",
                  load_font(13 * scale), TEXT_MUTED)
    return img


def make_volume_icns() -> None:
    if not SOURCE_ICON.exists():
        print(f"  (skip volume.icns: {SOURCE_ICON} missing)")
        return
    src = Image.open(SOURCE_ICON).convert("RGBA")
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    with tempfile.TemporaryDirectory() as tmp:
        iconset = Path(tmp) / "icon.iconset"
        iconset.mkdir()
        for s in sizes:
            src.resize((s, s), Image.LANCZOS).save(iconset / f"icon_{s}x{s}.png")
            if s <= 512:
                src.resize((s * 2, s * 2), Image.LANCZOS).save(
                    iconset / f"icon_{s}x{s}@2x.png")
        out = OUT_DIR / "volume.icns"
        subprocess.run(["iconutil", "-c", "icns", str(iconset), "-o", str(out)],
                       check=True)
        print(f"Wrote {out.relative_to(REPO_ROOT)}")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    render(1).save(OUT_DIR / "background.png")
    print(f"Wrote {(OUT_DIR / 'background.png').relative_to(REPO_ROOT)} {W}x{H}")

    render(2).save(OUT_DIR / "background@2x.png")
    print(f"Wrote {(OUT_DIR / 'background@2x.png').relative_to(REPO_ROOT)} {W*2}x{H*2}")

    make_volume_icns()
    print("Done.")


if __name__ == "__main__":
    main()
