#!/usr/bin/env python3
"""Generate Windows installer branding assets from the app icon.

Produces (committed to the repo so CI does not depend on Pillow):
  - windows/runner/resources/app_icon.ico   multi-resolution icon (16..256)
  - windows/packaging/wizard_large*.bmp      Inno Setup welcome/finish banner
  - windows/packaging/wizard_small*.bmp      Inno Setup top-right small image

Run locally after changing the source icon:
    python windows/packaging/gen_assets.py

Source icon: assets/icon/launcher_icon_v2.png (1024x1024)
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image

REPO_ROOT = Path(__file__).resolve().parents[2]
SOURCE_ICON = REPO_ROOT / "assets" / "icon" / "launcher_icon_v2.png"
ICO_OUT = REPO_ROOT / "windows" / "runner" / "resources" / "app_icon.ico"
PKG_DIR = REPO_ROOT / "windows" / "packaging"

# Inno Setup picks the best-fit variant from a comma-separated list by DPI.
# Base sizes are the 100% values; the rest cover 125/150/175/200%.
LARGE_SIZES = [(164, 314), (192, 386), (246, 459), (273, 556), (328, 628)]
SMALL_SIZES = [(55, 58), (64, 68), (83, 86), (92, 97), (110, 116), (119, 123), (138, 140)]

ICO_SIZES = [16, 24, 32, 48, 64, 128, 256]


def load_icon() -> Image.Image:
    if not SOURCE_ICON.exists():
        raise FileNotFoundError(f"Source icon not found: {SOURCE_ICON}")
    return Image.open(SOURCE_ICON).convert("RGBA")


def dominant_color(icon: Image.Image) -> tuple[int, int, int]:
    """Average color of the icon's opaque pixels, used to theme the banner."""
    small = icon.resize((64, 64))
    px = small.load()
    r = g = b = n = 0
    for y in range(64):
        for x in range(64):
            cr, cg, cb, ca = px[x, y]
            if ca < 32:
                continue
            r += cr
            g += cg
            b += cb
            n += 1
    if n == 0:
        return (60, 70, 110)
    return (r // n, g // n, b // n)


def shade(color: tuple[int, int, int], factor: float) -> tuple[int, int, int]:
    return tuple(max(0, min(255, int(c * factor))) for c in color)


def vertical_gradient(size: tuple[int, int], top: tuple[int, int, int],
                      bottom: tuple[int, int, int]) -> Image.Image:
    w, h = size
    grad = Image.new("RGB", size)
    px = grad.load()
    for y in range(h):
        t = y / max(1, h - 1)
        row = (
            int(top[0] + (bottom[0] - top[0]) * t),
            int(top[1] + (bottom[1] - top[1]) * t),
            int(top[2] + (bottom[2] - top[2]) * t),
        )
        for x in range(w):
            px[x, y] = row
    return grad


def make_large(icon: tuple, size: tuple[int, int], base: tuple[int, int, int]) -> Image.Image:
    src = icon  # RGBA source
    w, h = size
    bg = vertical_gradient(size, shade(base, 1.15), shade(base, 0.45))
    # Icon centered horizontally, in the upper third.
    icon_box = int(w * 0.62)
    ic = src.resize((icon_box, icon_box), Image.LANCZOS)
    ix = (w - icon_box) // 2
    iy = int(h * 0.16)
    bg.paste(ic, (ix, iy), ic)
    return bg


def make_small(icon: Image.Image, size: tuple[int, int], base: tuple[int, int, int]) -> Image.Image:
    w, h = size
    bg = vertical_gradient(size, shade(base, 1.1), shade(base, 0.55))
    pad = max(2, int(min(w, h) * 0.12))
    box = min(w, h) - 2 * pad
    ic = icon.resize((box, box), Image.LANCZOS)
    bg.paste(ic, ((w - box) // 2, (h - box) // 2), ic)
    return bg


def variant_name(stem: str, idx: int) -> str:
    # First (base/100%) file has no suffix; Inno orders by the list, not name.
    return f"{stem}.bmp" if idx == 0 else f"{stem}_{idx}.bmp"


def main() -> None:
    icon = load_icon()
    base = dominant_color(icon)
    print(f"Themed banner base color: {base}")

    # 1. Multi-resolution ICO
    ICO_OUT.parent.mkdir(parents=True, exist_ok=True)
    icon.save(ICO_OUT, format="ICO", sizes=[(s, s) for s in ICO_SIZES])
    print(f"Wrote {ICO_OUT.relative_to(REPO_ROOT)} ({ICO_SIZES})")

    PKG_DIR.mkdir(parents=True, exist_ok=True)

    # 2. Wizard large banner (24-bit BMP; Inno dislikes alpha BMPs)
    for i, size in enumerate(LARGE_SIZES):
        img = make_large(icon, size, base)
        out = PKG_DIR / variant_name("wizard_large", i)
        img.save(out, format="BMP")
        print(f"Wrote {out.relative_to(REPO_ROOT)} {size}")

    # 3. Wizard small image
    for i, size in enumerate(SMALL_SIZES):
        img = make_small(icon, size, base)
        out = PKG_DIR / variant_name("wizard_small", i)
        img.save(out, format="BMP")
        print(f"Wrote {out.relative_to(REPO_ROOT)} {size}")

    print("Done.")


if __name__ == "__main__":
    main()
