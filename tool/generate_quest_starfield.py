#!/usr/bin/env python3
"""Bake the Quest sky once; no noise generation or star simulation runs on-device.

Requires numpy and Pillow. Run without arguments to reproduce the bundled sky.
--source-hyg imports the magnitude <= 6.5 subset of the HYG v4.0 CSV (.gz).
HYG-derived data and star imagery: CC BY-SA 4.0, see the adjacent NOTICE.
The Milky Way is an artistic, restrained dust model, not survey photography.
"""

import argparse
import csv
import gzip
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "tool/data/quest_starfield/hyg_bright.csv"
OUTPUT = ROOT / "android/app/src/quest/assets/environments/deep_space.png"
WIDTH, HEIGHT = 4096, 2048

# IAU ICRS -> Galactic rotation. HYG right ascension is in hours, declination in degrees.
ICRS_TO_GALACTIC = np.array([
    [-0.0548755604, -0.8734370902, -0.4838350155],
    [0.4941094279, -0.4448296300, 0.7469822445],
    [-0.8676661490, -0.1980763734, 0.4559837762],
])
# One fixed orientation for the whole sky: no head-locked rotation or animated drift.
CORE = np.array([0.68, 0.38, 0.63])
CORE /= np.linalg.norm(CORE)
POLE = np.array([-0.58, 0.79, 0.08])
POLE -= CORE * np.dot(CORE, POLE)
POLE /= np.linalg.norm(POLE)
GALACTIC_TO_WORLD = np.column_stack([CORE, np.cross(POLE, CORE), POLE])


def import_catalog(source):
    opener = gzip.open if str(source).endswith(".gz") else open
    CATALOG.parent.mkdir(parents=True, exist_ok=True)
    with opener(source, "rt", newline="") as stream, CATALOG.open("w", newline="") as out:
        writer = csv.writer(out, lineterminator="\n")
        writer.writerow(["ra_hours", "dec_degrees", "magnitude", "bv"])
        for row in csv.DictReader(stream):
            if row["id"] == "0" or not row["mag"] or float(row["mag"]) > 6.5:
                continue  # The Sun is not part of the night sky.
            writer.writerow([row["ra"], row["dec"], row["mag"], row["ci"] or "0.65"])


def noise(p):
    """Seeded 3-D value noise; evaluating directions avoids a panorama seam/pole singularity."""
    cell = np.floor(p).astype(np.int32)
    f = p - cell
    f = f * f * (3 - 2 * f)
    result = np.zeros(p.shape[:-1], dtype=np.float32)
    for x in range(2):
        for y in range(2):
            for z in range(2):
                q = cell + [x, y, z]
                h = (q[..., 0].astype(np.uint32) * np.uint32(73856093)
                     ^ q[..., 1].astype(np.uint32) * np.uint32(19349663)
                     ^ q[..., 2].astype(np.uint32) * np.uint32(83492791))
                h = (h ^ (h >> 13)) * np.uint32(1274126177)
                v = (h ^ (h >> 16)).astype(np.float64) / 4294967295
                weight = ((f[..., 0] if x else 1 - f[..., 0])
                          * (f[..., 1] if y else 1 - f[..., 1])
                          * (f[..., 2] if z else 1 - f[..., 2]))
                result += v * weight
    return result


def dust(p):
    value = np.zeros(p.shape[:-1], dtype=np.float32)
    weight = 0.54
    for _ in range(5):
        value += weight * noise(p)
        p = p * 2.03 + np.array([3.7, -7.1, 4.3])
        weight *= 0.46
    return value


def sky_background():
    sky = np.zeros((HEIGHT, WIDTH, 3), dtype=np.float32)
    longitude = (np.arange(WIDTH) + 0.5) / WIDTH * (2 * np.pi) - np.pi
    for start in range(0, HEIGHT, 128):
        latitude = np.pi / 2 - (np.arange(start, min(start + 128, HEIGHT)) + 0.5) / HEIGHT * np.pi
        lon, lat = np.meshgrid(longitude, latitude)
        world = np.stack([np.sin(lon) * np.cos(lat), np.sin(lat), np.cos(lon) * np.cos(lat)], -1)
        galactic = world @ GALACTIC_TO_WORLD
        l = np.arctan2(galactic[..., 1], galactic[..., 0])
        b = np.arcsin(np.clip(galactic[..., 2], -1, 1))
        clouds = dust(galactic * 9)
        fine = noise(galactic * 67)
        band = np.exp(-((b / 0.115) ** 2))
        halo = np.exp(-((b / 0.26) ** 2))
        core = np.exp(-((l / 0.66) ** 2) - ((b / 0.19) ** 2))
        lane_center = 0.019 * np.sin(l * 3.2) + (clouds - 0.45) * 0.10
        lanes = np.exp(-(((b - lane_center) / 0.033) ** 2)) * (0.65 + 0.35 * fine)
        body = (0.0020 * halo + 0.020 * band * (0.20 + 1.5 * clouds ** 2)) * (1 - 0.88 * lanes)
        bulge = 0.021 * core * (0.30 + clouds) * (1 - 0.92 * lanes)
        sky[start:start + len(latitude)] = (
            np.array([0.00028, 0.00036, 0.00054])
            + body[..., None] * np.array([0.72, 0.78, 0.88])
            + bulge[..., None] * np.array([0.97, 0.86, 0.71])
        )
    return sky


def star_color(bv):
    bv = np.clip(bv, -0.35, 2.0)
    kelvin = 4600 * (1 / (0.92 * bv + 1.7) + 1 / (0.92 * bv + 0.62))
    t = kelvin / 100
    r = 255 if t <= 66 else 329.698727 * (t - 60) ** -0.1332048
    g = 99.470802 * np.log(t) - 161.119568 if t <= 66 else 288.122170 * (t - 60) ** -0.07551485
    blue = 255 if t >= 66 else 0 if t <= 19 else 138.517731 * np.log(t - 10) - 305.044793
    rgb = np.clip([r, g, blue], 0, 255) / 255
    linear = np.where(rgb <= 0.04045, rgb / 12.92, ((rgb + 0.055) / 1.055) ** 2.4)
    # Human vision sees subtler stellar colour than a saturated long-exposure photograph.
    return linear * 0.68 + 0.32


def add_stars(sky):
    rows = np.loadtxt(CATALOG, delimiter=",", skiprows=1)
    for ra, dec, magnitude, bv in rows:
        a, d = np.deg2rad([ra * 15, dec])
        equatorial = np.array([np.cos(d) * np.cos(a), np.cos(d) * np.sin(a), np.sin(d)])
        world = GALACTIC_TO_WORLD @ ICRS_TO_GALACTIC @ equatorial
        lon, lat = np.arctan2(world[0], world[2]), np.arcsin(np.clip(world[1], -1, 1))
        cx = (lon / (2 * np.pi) + 0.5) * WIDTH - 0.5
        cy = (0.5 - lat / np.pi) * HEIGHT - 0.5
        cosine = max(np.cos(lat), 0.008)
        strength = 1.7 * 10 ** (-0.27 * magnitude)
        sigma = 0.43 + 0.13 * np.clip((3 - magnitude) / 4, 0, 1)
        halo_sigma = 1.25 + max(0, 2.0 - magnitude) * 0.40
        extent = int(np.ceil(halo_sigma * 4 if magnitude < 2.5 else sigma * 4))
        xs = np.arange(int(cx) - int(np.ceil(extent / cosine)), int(cx) + int(np.ceil(extent / cosine)) + 1)
        ys = np.arange(max(0, int(cy) - extent), min(HEIGHT, int(cy) + extent + 1))
        dx, dy = np.meshgrid((xs - cx) * cosine, ys - cy)
        r2 = dx * dx + dy * dy
        profile = np.exp(-r2 / (2 * sigma * sigma))
        if magnitude < 2.5:
            profile += 0.021 * np.exp(-r2 / (2 * halo_sigma * halo_sigma))
        sky[ys[:, None], (xs % WIDTH)[None, :]] += (strength * profile)[..., None] * star_color(bv)
    return len(rows)


def srgb(linear):
    linear = np.clip(linear, 0, 1)
    return np.where(linear <= 0.0031308, linear * 12.92, 1.055 * linear ** (1 / 2.4) - 0.055)


def preview(image, output):
    """A 100-degree, monoscopic view for asset inspection; this is not a headset capture."""
    width, height = 1600, 1000
    x, y = np.meshgrid((np.arange(width) + 0.5 - width / 2) / (width / 2),
                       -(np.arange(height) + 0.5 - height / 2) / (width / 2))
    scale = np.tan(np.deg2rad(100) / 2)
    directions = np.stack([x * scale, y * scale, np.ones_like(x)], -1)
    directions /= np.linalg.norm(directions, axis=-1)[..., None]
    u = (np.arctan2(directions[..., 0], directions[..., 2]) / (2 * np.pi) + 0.5) * WIDTH - 0.5
    v = (0.5 - np.arcsin(directions[..., 1]) / np.pi) * HEIGHT - 0.5
    x0, y0 = np.floor(u).astype(int), np.floor(v).astype(int)
    fx, fy = (u - x0)[..., None], (v - y0)[..., None]
    pixels = np.asarray(image, dtype=np.float32)
    a = pixels[y0.clip(0, HEIGHT - 1), x0 % WIDTH] * (1 - fx) + pixels[y0.clip(0, HEIGHT - 1), (x0 + 1) % WIDTH] * fx
    b = pixels[(y0 + 1).clip(0, HEIGHT - 1), x0 % WIDTH] * (1 - fx) + pixels[(y0 + 1).clip(0, HEIGHT - 1), (x0 + 1) % WIDTH] * fx
    Image.fromarray(np.rint(a * (1 - fy) + b * fy).astype(np.uint8)).save(output)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-hyg", type=Path)
    parser.add_argument("--output", type=Path, default=OUTPUT)
    parser.add_argument("--preview", type=Path)
    args = parser.parse_args()
    if args.source_hyg:
        import_catalog(args.source_hyg)
    sky = sky_background()
    count = add_stars(sky)
    image = Image.fromarray(np.rint(srgb(sky) * 255).astype(np.uint8))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    image.save(args.output, optimize=True)
    if args.preview:
        preview(image, args.preview)
    print(f"{count} catalogued stars; {WIDTH}x{HEIGHT}; {args.output.stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
