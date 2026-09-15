#!/usr/bin/env python3
"""Bake original, stationary Quest vistas. Requires numpy and Pillow, no downloads.

All fields are evaluated on directions or world coordinates, so longitude has
no branch cut. Render in strips to bound memory. The headset only samples one
4096x2048 sRGB panorama; none of this noise, lighting or water runs on-device.
"""

import argparse
from pathlib import Path
import shutil

import numpy as np
from PIL import Image, ImageDraw

from generate_quest_starfield import bilinear, directions, linear, srgb

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "android/app/src/quest/assets/environments"
THUMBNAILS = ROOT / "android/questui/src/main/res/drawable-nodpi"
WIDTH, HEIGHT = 4096, 2048
VIEWS = {"aurora": (-42, 17), "sunset": (48, 2), "mist": (-30, 5)}


def smooth(a, b, x):
    t = np.clip((x - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


def mix(a, b, t):
    return np.asarray(a) * (1 - t[..., None]) + np.asarray(b) * t[..., None]


def noise(p):
    """Continuous value noise in 3D, with a deterministic integer hash."""
    cell = np.floor(p).astype(np.int32)
    f = p - cell
    f = f * f * (3 - 2 * f)
    result = np.zeros(p.shape[:-1], dtype=np.float32)
    for x in (0, 1):
        for y in (0, 1):
            for z in (0, 1):
                h = ((cell[..., 0] + x).astype(np.uint32) * np.uint32(374761393)
                     + (cell[..., 1] + y).astype(np.uint32) * np.uint32(668265263)
                     + (cell[..., 2] + z).astype(np.uint32) * np.uint32(2246822519))
                h = (h ^ (h >> 13)) * np.uint32(1274126177)
                value = (h ^ (h >> 16)).astype(np.float64) / 4294967295
                weight = ((f[..., 0] if x else 1 - f[..., 0])
                          * (f[..., 1] if y else 1 - f[..., 1])
                          * (f[..., 2] if z else 1 - f[..., 2]))
                result += value * weight
    return result


def fbm(p, octaves=5):
    result = np.zeros(p.shape[:-1], dtype=np.float32)
    strength = 0.5
    for _ in range(octaves):
        result += strength * noise(p)
        p = p * 2.03 + np.array([7.1, 11.7, 3.4])
        strength *= 0.5
    return result / (1 - 0.5 ** octaves)


def angular(d):
    return np.arctan2(d[..., 0], d[..., 2]), np.arcsin(np.clip(d[..., 1], -1, 1))


def ridge(lon, seed, height, roughness=0.024):
    # Circular coordinates, including the high-frequency rock detail. Never
    # multiply an atan2 longitude by a non-integer frequency.
    circle = np.stack([np.sin(lon), np.full_like(lon, seed), np.cos(lon)], -1)
    broad = np.zeros_like(lon)
    for yaw, amplitude, width in [(-66, 1, .055), (77, .82, .085), (153, .75, .12), (-143, .70, .09)]:
        offset = np.deg2rad(yaw) + seed * .16
        distance = np.sqrt(np.maximum(0, 2 - 2 * np.cos(lon - offset)))
        broad += amplitude * np.exp(-(distance / np.sqrt(width)) ** 1.05)
        broad += amplitude * .28 * np.exp((np.cos(lon - offset - .15) - 1) / (width * .18))
    detail = fbm(circle * np.array([33, 1, 33]), 5) - .5
    return .018 + height * broad + roughness * detail


def clouds(d):
    p = d * np.array([5.0, 15.0, 5.0]) + [8, 0, 12]
    body = fbm(p, 5)
    return smooth(.44, .72, body) * smooth(.015, .13, d[..., 1]) * (1 - smooth(.65, .96, d[..., 1]))


def aurora(d):
    lon, lat = angular(d)
    horizon = np.exp(-np.maximum(lat, 0) * 6)
    sky = mix([.0025, .006, .014], [.026, .052, .07], horizon)
    # Long, folded light curtains, offset above and beside the viewing area.
    quiet_front = .28 + .72 * (1 - np.exp((np.cos(lon) - 1) / .35))
    pole_fade = 1 - smooth(.9, 1.35, lat)
    circle = np.stack([np.sin(lon), np.full_like(lon, 5), np.cos(lon)], -1)
    folds = fbm(circle * [5, 1, 5], 5)
    for layer, strength in [(0, 1), (1, .28)]:
        base = .29 + layer * .22 + .12 * np.sin(lon * 3 + layer * 1.9) + .17 * (folds - .5)
        altitude = lat - base
        warped = lon + .045 * np.sin(altitude * 7 + lon * 5)
        strands = np.stack([np.sin(warped) * 100, altitude * 2 + layer * 8, np.cos(warped) * 100], -1)
        ribs = .18 + 1.30 * fbm(strands, 3) ** 1.7
        folded = .2 + .8 * smooth(.25, .68, folds)
        envelope = smooth(-.028, .04, altitude) * np.exp(-np.maximum(altitude, 0) * (7 + 2 * layer))
        emission = envelope * ribs * folded * quiet_front * pole_fade * strength
        color = mix([.052, .36, .19], [.095, .038, .15], smooth(.05, .24, altitude))
        sky += color * emission[..., None]
    sky += clouds(d)[..., None] * [.005, .009, .014]
    ground = mix([.012, .021, .032], [.055, .079, .094], np.exp(-np.abs(lat + .025) * 7))
    ground += (fbm(d * [14, 2, 14] + [0, 12, 0], 4) - .5)[..., None] * [.008, .013, .017]
    result = mix(ground, sky, smooth(-.003, .003, lat))
    for i, height in [(0, .16), (1, .24), (2, .12)]:
        seed = i * 2.2 + 1
        peak = ridge(lon, seed, height, .05)
        mask = (1 - smooth(peak - .0009, peak + .0009, lat)) * smooth(-.12, -.015, lat)
        circle = np.stack([np.sin(lon) * 30, lat * 22, np.cos(lon) * 30], -1)
        rock = fbm(circle + i * 8, 5)
        snowline = peak * .34 + (rock - .5) * .07
        snow = smooth(snowline, snowline + .023, lat)
        # Shade a two-dimensional rock field. A longitude-only ridge normal
        # produces vertical bars across the whole mountain in a headset.
        slope = fbm(circle + [.15, .08, 0], 4) - fbm(circle - [.15, .08, 0], 4)
        face = np.clip(.53 + slope * 3.6 + (rock - .5) * .48, .16, 1)
        stone = mix([.013, .024, .035], [.043, .064, .078], face)
        ice = mix([.044, .075, .102], [.14, .20, .23], face)
        mountain = mix(stone, ice, snow) * (1 - i * .16)
        mountain = mix(mountain, [.036, .059, .078], np.exp(-np.maximum(lat, 0) * 22) * .6)
        result = mix(result, mountain, mask)
    return result


SUN = directions(*np.deg2rad([68, 4.5]))


def sunset_sky(d, detailed=True):
    y = np.maximum(d[..., 1], 0)
    near_sun = np.maximum(0, d @ SUN)
    warm = np.exp(-y * 9) * (.20 + .80 * near_sun ** 5)
    base = mix([.020, .027, .063], [.23, .12, .070], np.exp(-y * 3.4))
    base = mix(base, [.56, .235, .075], warm * .72)
    base += np.exp((d @ SUN - 1) / .023)[..., None] * [.19, .064, .012]
    # A small, soft-edged solar disc, far enough off axis to leave the film alone.
    disk = smooth(np.cos(np.deg2rad(.88)), np.cos(np.deg2rad(.66)), d @ SUN)
    base = mix(base, [.92, .60, .24], disk)
    if detailed:
        cloud = clouds(d)
        base = mix(base, mix([.043, .033, .065], [.37, .18, .115], near_sun ** 5), cloud * .52)
    return base


def sunset(d):
    lon, lat = angular(d)
    sky = sunset_sky(d)
    distance = 1 / np.maximum(-d[..., 1], .007)
    x, z = d[..., 0] * distance, d[..., 2] * distance
    nx, nz = np.zeros_like(x), np.zeros_like(x)
    for a, wavelength, strength, phase in [(0.3, 3.1, .014, 1), (1.8, 1.3, .011, 4), (-.5, .57, .008, 7), (2.4, .21, .004, 3)]:
        frequency = 2 * np.pi / wavelength
        # Suppress subpixel waves at the horizon, rather than baking shimmer.
        amplitude = strength / (1 + (distance * frequency / 180) ** 2)
        wave = np.cos((x * np.cos(a) + z * np.sin(a)) * frequency + phase) * amplitude
        nx += wave * np.cos(a)
        nz += wave * np.sin(a)
    normal = np.stack([nx, np.ones_like(nx), nz], -1)
    normal /= np.linalg.norm(normal, axis=-1)[..., None]
    reflected = d - 2 * np.sum(d * normal, axis=-1)[..., None] * normal
    reflected[..., 1] = np.abs(reflected[..., 1])
    fresnel = .035 + .965 * (1 - np.maximum(-d[..., 1], 0)) ** 5
    sea = sunset_sky(reflected, detailed=False) * fresnel[..., None] * .74
    sea += np.asarray([.008, .016, .026]) * (1 - fresnel[..., None])
    result = mix(sea, sky, smooth(-.0015, .0015, lat))
    # Remote headlands frame the sides. No nearby props or false stereo depth.
    headland = ridge(lon, 6, .038, .004) - .018
    mask = (1 - smooth(headland - .0007, headland + .0007, lat)) * smooth(-.006, .001, lat)
    return mix(result, [.061, .049, .064], mask * .88)


def mist(d):
    lon, lat = angular(d)
    sky = mix([.080, .105, .12], [.24, .265, .26], np.exp(-np.maximum(lat, 0) * 4))
    sky += (fbm(d * [5, 16, 5] + [7, 9, 2], 4) - .5)[..., None] * .018
    ground = mix([.025, .045, .059], [.19, .22, .22], np.exp(-np.abs(lat) * 5))
    result = mix(ground, sky, smooth(-.045, .035, lat))
    for i in range(7):
        peak = ridge(lon, 9 - i * 1.05, .105 + i * .028, .012 + i * .002)
        mask = 1 - smooth(peak - .0008, peak + .0008, lat)
        # Each range disappears into its own valley fog rather than forming a
        # stack of flat, opaque cut-outs. The foreground merges into the nadir.
        mask *= smooth(-.25 + i * .019, -.018 + i * .009, lat)
        depth = i / 6
        ink = mix([.145, .18, .19], [.020, .048, .064], np.full_like(lat, depth))
        folds = fbm(np.stack([np.sin(lon) * 26, lat * 9, np.cos(lon) * 26], -1) + i, 4)
        ink *= (.82 + .30 * folds)[..., None]
        mist_height = lat + .018 + .014 * np.sin(lon * 4 + i * 1.3)
        veil = np.exp(-np.maximum(mist_height, 0) * (11 + i)) * (.8 - i * .065)
        ink = mix(ink, [.21, .24, .24], veil)
        result = mix(result, ink, mask)
    return result


RENDERERS = {"aurora": aurora, "sunset": sunset, "mist": mist}


def bake(name, width=WIDTH, height=HEIGHT):
    pixels = np.empty((height, width, 3), dtype=np.uint8)
    rng = np.random.default_rng(240915)
    lon = (np.arange(width) + .5) / width * (2 * np.pi) - np.pi
    for start in range(0, height, 32):
        end = min(height, start + 32)
        lat = np.pi / 2 - (np.arange(start, end) + .5) / height * np.pi
        rays = directions(*np.meshgrid(lon, lat)).astype(np.float32)
        encoded = srgb(RENDERERS[name](rays))
        # Sub-LSB dither avoids long visible bands in the Quest LCD's dark sky.
        encoded += rng.uniform(-.5 / 255, .5 / 255, encoded.shape)
        pixels[start:end] = np.rint(np.clip(encoded, 0, 1) * 255).astype(np.uint8)
    if name == "aurora":
        add_night_stars(pixels)
    # Texture pixel centres approach, but never reach, the poles. Their outer
    # rows still represent one point under clamped filtering: collapse them.
    pixels[0] = np.rint(pixels[0].mean(axis=0)).astype(np.uint8)
    pixels[-1] = np.rint(pixels[-1].mean(axis=0)).astype(np.uint8)
    return Image.fromarray(pixels)


def add_night_stars(pixels):
    height, width = pixels.shape[:2]
    rng = np.random.default_rng(518)
    for _ in range(2100):
        longitude = rng.uniform(-np.pi, np.pi)
        latitude = np.arcsin(rng.uniform(.36, .995))
        x = (longitude / (2 * np.pi) + .5) * width - .5
        y = (.5 - latitude / np.pi) * height - .5
        radius = .36 + rng.random() * .26
        xs = np.arange(int(x) - 5, int(x) + 6)
        ys = np.arange(max(1, int(y) - 2), min(height - 1, int(y) + 3))
        dx, dy = np.meshgrid((xs - x) * np.cos(latitude), ys - y)
        light = np.exp(-(dx * dx + dy * dy) / (2 * radius * radius)) * rng.uniform(18, 90)
        patch = pixels[ys[:, None], (xs % width)[None, :]].astype(np.float32)
        patch += light[..., None] * [0.82, .91, 1]
        pixels[ys[:, None], (xs % width)[None, :]] = np.clip(patch, 0, 255).astype(np.uint8)


def perspective(image, yaw=0, pitch=0, width=1280, height=800, fov=100, brightness=.65):
    x, y = np.meshgrid((np.arange(width) + .5 - width / 2) / (width / 2),
                       -(np.arange(height) + .5 - height / 2) / (width / 2))
    rays = np.stack([x * np.tan(np.deg2rad(fov) / 2), y * np.tan(np.deg2rad(fov) / 2), np.ones_like(x)], -1)
    rays /= np.linalg.norm(rays, axis=-1)[..., None]
    a, p = np.deg2rad([yaw, pitch])
    rays = rays @ np.array([[1, 0, 0], [0, np.cos(p), np.sin(p)], [0, -np.sin(p), np.cos(p)]]).T
    rays = rays @ np.array([[np.cos(a), 0, np.sin(a)], [0, 1, 0], [-np.sin(a), 0, np.cos(a)]]).T
    lon, lat = angular(rays)
    texture = linear(np.asarray(image, dtype=np.float32) / 255)
    color = srgb(bilinear(texture, lon / (2 * np.pi) + .5, .5 - lat / np.pi) * brightness)
    return Image.fromarray(np.rint(color * 255).astype(np.uint8))


def thumbnails(images, target):
    target.mkdir(parents=True, exist_ok=True)
    for name, image in images.items():
        yaw, pitch = VIEWS.get(name, (-15, 12))
        perspective(image, yaw, pitch, 384, 192).save(target / f"environment_{name}.webp", quality=90)
    Image.new("RGB", (384, 192), (5, 6, 9)).save(target / "environment_void.webp", lossless=True)
    # An abstract room pictogram, never a photograph of the user's room.
    room = Image.new("RGB", (384, 192), (43, 52, 58))
    draw = ImageDraw.Draw(room)
    draw.polygon([(0, 192), (75, 121), (300, 121), (384, 192)], fill=(58, 69, 72))
    draw.line([(75, 0), (75, 121), (0, 192)], fill=(96, 110, 112), width=2)
    draw.line([(300, 0), (300, 121), (384, 192)], fill=(96, 110, 112), width=2)
    draw.line([(75, 121), (300, 121)], fill=(96, 110, 112), width=2)
    draw.rounded_rectangle((110, 26, 239, 99), radius=4, fill=(133, 155, 158))
    draw.line([(174, 26), (174, 99)], fill=(61, 74, 80), width=3)
    room.save(target / "environment_passthrough.webp", quality=90)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=OUTPUT)
    parser.add_argument("--thumbnails", type=Path, default=THUMBNAILS)
    parser.add_argument("--preview-dir", type=Path)
    parser.add_argument("--only", choices=RENDERERS)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    images = {}
    for name in ([args.only] if args.only else RENDERERS):
        image = bake(name)
        destination = args.output / f"{name}.png"
        image.save(destination, optimize=True)
        images[name] = image
        print(f"{name}: {WIDTH}x{HEIGHT}, {destination.stat().st_size:,} bytes", flush=True)
        if args.preview_dir:
            args.preview_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy2(destination, args.preview_dir / destination.name)
            perspective(image, *VIEWS[name]).save(args.preview_dir / f"{name}_perspective.jpg", quality=94)
    with Image.open(OUTPUT / "deep_space.png") as space:
        images["deep_space"] = space.convert("RGB")
    thumbnails(images, args.thumbnails)
    if args.preview_dir:
        shutil.copy2(ROOT / "tool/quest_landscapes_preview.html", args.preview_dir / "index.html")
        shutil.copy2(OUTPUT / "deep_space.png", args.preview_dir / "deep_space.png")
        shutil.copy2(OUTPUT / "NOTICE.txt", args.preview_dir / "NOTICE.txt")


if __name__ == "__main__":
    main()
