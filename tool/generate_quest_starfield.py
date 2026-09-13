#!/usr/bin/env python3
"""Bake the Quest sky once; no noise generation or star simulation runs on-device.

Requires numpy and Pillow. Run without arguments to reproduce the bundled sky.
--source-hyg imports the magnitude <= 6.5 subset of the HYG v4.0 CSV (.gz).
HYG-derived data and star imagery: CC BY-SA 4.0, see the adjacent NOTICE.
Earth and Moon surface maps, credits and source URLs: see the adjacent NOTICE.
Planet sizes/positions and illumination are composed for comfortable
viewing, not an ephemeris or a scale model of the Earth-Moon system.
"""

import argparse
import csv
from dataclasses import dataclass
import gzip
import json
from pathlib import Path
import shutil

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "tool/data/quest_starfield/hyg_bright.csv"
EARTH_MAP = CATALOG.parent / "earth_nasa.jpg"
EARTH_CLOUDS = CATALOG.parent / "earth_clouds_nasa.jpg"
MOON_MAP = CATALOG.parent / "moon_nasa.tif"
OUTPUT = ROOT / "android/app/src/quest/assets/environments/deep_space.png"
WIDTH, HEIGHT = 4096, 2048
SUN = np.array([-0.30, 0.65, -0.85])
SUN /= np.linalg.norm(SUN)

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


def background_radiance(world):
    # Empty space has no painted band or angular branch cut. In particular, the
    # former sin(3.2 * galactic_longitude) dust model was NOT 2*pi-periodic and
    # baked a visible discontinuity inside the texture, despite U=REPEAT.
    return np.broadcast_to(np.array([0.00012, 0.00015, 0.00023], dtype=np.float32), world.shape).copy()


def directions(longitude, latitude):
    """Unit directions; all spatial effects operate here, never on wrapped angles."""
    return np.stack([np.sin(longitude) * np.cos(latitude), np.sin(latitude),
                     np.cos(longitude) * np.cos(latitude)], -1)


def panorama_directions(start, stop, dx=0.5, dy=0.5):
    lon = (np.arange(WIDTH) + dx) / WIDTH * (2 * np.pi) - np.pi
    lat = np.pi / 2 - (np.arange(start, stop) + dy) / HEIGHT * np.pi
    return directions(*np.meshgrid(lon, lat))


def sky_background():
    return background_radiance(np.empty((HEIGHT, WIDTH, 3), dtype=np.float32))


def linear(srgb_color):
    return np.where(srgb_color <= 0.04045, srgb_color / 12.92, ((srgb_color + 0.055) / 1.055) ** 2.4)


def bilinear(pixels, u, v):
    """Pixel-centre lat-long sampling: wrap longitude, clamp latitude, like the SDK."""
    height, width = pixels.shape[:2]
    x, y = np.asarray(u) * width - 0.5, np.asarray(v) * height - 0.5
    x0, y0 = np.floor(x).astype(int), np.floor(y).astype(int)
    fx, fy = (x - x0)[..., None], (y - y0)[..., None]
    top = (pixels[y0.clip(0, height - 1), x0 % width] * (1 - fx)
           + pixels[y0.clip(0, height - 1), (x0 + 1) % width] * fx)
    bottom = (pixels[(y0 + 1).clip(0, height - 1), x0 % width] * (1 - fx)
              + pixels[(y0 + 1).clip(0, height - 1), (x0 + 1) % width] * fx)
    return top * (1 - fy) + bottom * fy


def load_surface(path):
    with Image.open(path) as source:
        source = source.convert("RGB")
        source.thumbnail((4096, 2048), Image.Resampling.LANCZOS)
        pixels = linear(np.asarray(source, dtype=np.float32) / 255)
    # All longitudes represent the SAME point at each pole. Collapse only the
    # outermost source row so even an exact polar sample is independent of atan2.
    pixels[0] = pixels[0].mean(axis=0)
    pixels[-1] = pixels[-1].mean(axis=0)
    return pixels


@dataclass(frozen=True)
class Planet:
    name: str
    yaw: float
    pitch: float
    angular_radius: float
    longitude: float
    latitude: float
    texture: np.ndarray
    clouds: np.ndarray | None = None

    @property
    def direction(self):
        return directions(*np.deg2rad([self.yaw, self.pitch]))

    @property
    def center(self):
        return self.direction / np.sin(np.deg2rad(self.angular_radius))

    def texture_coordinates(self, normal):
        facing = -self.direction
        up = np.array([0., 1., 0.])
        up -= facing * np.dot(up, facing)
        if np.linalg.norm(up) < 1e-8:
            up = np.array([0., 0., 1.])  # A body may also be placed over a pole.
        up /= np.linalg.norm(up)
        latitude = np.deg2rad(self.latitude)
        north = up * np.cos(latitude) + facing * np.sin(latitude)
        meridian = facing * np.cos(latitude) - up * np.sin(latitude)
        east = np.cross(meridian, north)
        lon = np.arctan2(normal @ east, normal @ meridian) + np.deg2rad(self.longitude)
        lat = np.arcsin(np.clip(normal @ north, -1, 1))
        return lon / (2 * np.pi) + 0.5, 0.5 - lat / np.pi


def smoothstep(low, high, value):
    x = np.clip((value - low) / (high - low), 0, 1)
    return x * x * (3 - 2 * x)


def planet_layer(world, planet):
    """Ray/sphere intersection returns radiance and opaque coverage separately.

    Even the unlit hemisphere occludes stars. There are no rectangular cutouts,
    billboard edges or longitude-dependent illumination in this layer.
    """
    center = planet.center
    projection = world @ center
    impact2 = np.maximum(np.dot(center, center) - projection ** 2, 0)
    hit = (projection > 0) & (impact2 <= 1)
    radiance = np.zeros(world.shape, dtype=np.float32)
    if np.any(hit):
        rays = world[hit]
        distance = projection[hit] - np.sqrt(np.maximum(1 - impact2[hit], 0))
        normal = rays * distance[..., None] - center
        normal /= np.linalg.norm(normal, axis=-1)[..., None]
        coordinates = planet.texture_coordinates(normal)
        albedo = bilinear(planet.texture, *coordinates)
        sunlight = np.maximum(normal @ SUN, 0)
        if planet.name == "earth":
            cloud = (bilinear(planet.clouds, *coordinates).mean(axis=-1)[..., None]
                     if planet.clouds is not None else np.zeros((len(normal), 1)))
            albedo = albedo * (1 - cloud * 0.90) + cloud * np.array([0.80, 0.84, 0.88])
            color = albedo * (sunlight[..., None] * 0.95 + 0.0008)
            mu = np.maximum(np.sum(normal * -rays, axis=-1), 0)
            haze = (0.065 + 0.20 * (1 - mu) ** 3) * sunlight
            color += haze[..., None] * np.array([0.065, 0.30, 0.78])
        else:
            # A subdued lunar surface; almost no light on the night side.
            color = albedo * (1.25 * sunlight[..., None] + 0.002)
        radiance[hit] = color

    if planet.name == "earth":
        impact = np.sqrt(impact2)
        limb = (projection > 0) & (np.abs(impact - 1) < 0.04)
        if np.any(limb):
            tangent = world[limb] * projection[limb, None] - center
            tangent /= np.linalg.norm(tangent, axis=-1)[..., None]
            day = smoothstep(-0.08, 0.45, tangent @ SUN)
            height = np.abs(impact[limb] - 1)
            glow = 0.28 * np.exp(-height / 0.008) * (1 - smoothstep(0.025, 0.04, height)) * day
            radiance[limb] += glow[..., None] * np.array([0.055, 0.29, 0.90])
    return radiance, hit.astype(np.float32)


def add_planets(sky, planets):
    # Supersample the curved silhouettes, without blurring the star catalogue.
    # The fixed composition has disjoint bodies; draw the distant Moon first.
    for planet in planets:
        for start in range(0, HEIGHT, 64):
            stop = min(start + 64, HEIGHT)
            radiance = np.zeros((stop - start, WIDTH, 3), dtype=np.float32)
            coverage = np.zeros((stop - start, WIDTH), dtype=np.float32)
            for dx, dy in [(0.25, 0.25), (0.75, 0.25), (0.25, 0.75), (0.75, 0.75)]:
                color, opacity = planet_layer(panorama_directions(start, stop, dx, dy), planet)
                radiance += color * 0.25
                coverage += opacity * 0.25
            sky[start:stop] = sky[start:stop] * (1 - coverage[..., None]) + radiance


def load_planets():
    return [Planet("moon", 32, 22, 4.6, 0, 5, load_surface(MOON_MAP)),
            Planet("earth", -34, 12, 21, 100, 17, load_surface(EARTH_MAP), load_surface(EARTH_CLOUDS))]


def export_runtime_assets(stars, planets, destination):
    """One static panorama per visibility choice; small maps for optional GPU bodies."""
    destination.mkdir(parents=True, exist_ok=True)
    Image.fromarray(np.rint(srgb(stars) * 255).astype(np.uint8)).save(destination / "stars.png", optimize=True)
    for planet in planets:
        sky = stars.copy()
        add_planets(sky, [planet])
        Image.fromarray(np.rint(srgb(sky) * 255).astype(np.uint8)).save(
            destination / f"deep_space_{planet.name}.png", optimize=True)
    for source, name, size in [(EARTH_MAP, "earth.jpg", (2048, 1024)),
                               (EARTH_CLOUDS, "clouds.jpg", (2048, 1024)),
                               (MOON_MAP, "moon.jpg", (1024, 512))]:
        with Image.open(source) as image:
            image = image.convert("RGB").resize(size, Image.Resampling.LANCZOS)
            pixels = np.array(image)
            pixels[0] = np.rint(pixels[0].mean(axis=0)).astype(np.uint8)
            pixels[-1] = np.rint(pixels[-1].mean(axis=0)).astype(np.uint8)
            Image.fromarray(pixels).save(destination / name, quality=95, subsampling=0, optimize=True)
    scene = {"maxFps": 30, "motionFps": 60, "bodies": [
        {"name": "earth", "yaw": -34, "pitch": 12, "angle": 21, "distance": 20,
         "longitude": 100, "latitude": 17, "spin": 0.35, "cloudSpin": 0.39,
         "eyePixels": 768, "zIndex": -80, "surface": "earth.jpg", "clouds": "clouds.jpg"},
        {"name": "moon", "yaw": 32, "pitch": 22, "angle": 4.6, "distance": 40,
         "longitude": 0, "latitude": 5, "spin": 0.02, "cloudSpin": 0,
         "eyePixels": 256, "zIndex": -90, "surface": "moon.jpg"},
    ]}
    (destination / "scene.json").write_text(json.dumps(scene, indent=2) + "\n")


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
    """A monoscopic perspective for asset inspection; this is not a headset capture."""
    width, height = 1600, 1000
    x, y = np.meshgrid((np.arange(width) + 0.5 - width / 2) / (width / 2),
                       -(np.arange(height) + 0.5 - height / 2) / (width / 2))
    scale = np.tan(np.deg2rad(110) / 2)
    rays = np.stack([x * scale, y * scale, np.ones_like(x)], -1)
    rays /= np.linalg.norm(rays, axis=-1)[..., None]
    pitch = np.deg2rad(8)
    rays = rays @ np.array([[1, 0, 0], [0, np.cos(pitch), np.sin(pitch)], [0, -np.sin(pitch), np.cos(pitch)]]).T
    u = np.arctan2(rays[..., 0], rays[..., 2]) / (2 * np.pi) + 0.5
    v = 0.5 - np.arcsin(rays[..., 1]) / np.pi
    pixels = linear(np.asarray(image, dtype=np.float32) / 255)
    color = srgb(bilinear(pixels, u, v) * 0.65)
    output.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(np.rint(color * 255).astype(np.uint8)).save(output)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-hyg", type=Path)
    parser.add_argument("--output", type=Path, default=OUTPUT)
    parser.add_argument("--preview", type=Path)
    parser.add_argument("--preview-dir", type=Path, help="Export the draggable 360-degree viewer and its panorama")
    parser.add_argument("--runtime-assets", type=Path, help="Export static visibility variants and the dynamic environment's source maps")
    parser.add_argument("--dynamic-preview-dir", type=Path, help="Export the shared-shader dynamic viewer (requires runtime assets)")
    args = parser.parse_args()
    if args.source_hyg:
        import_catalog(args.source_hyg)
    sky = sky_background()
    count = add_stars(sky)
    planets = load_planets()
    if args.runtime_assets:
        export_runtime_assets(sky, planets, args.runtime_assets)
    add_planets(sky, planets)
    image = Image.fromarray(np.rint(srgb(sky) * 255).astype(np.uint8))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    image.save(args.output, optimize=True)
    if args.preview:
        preview(image, args.preview)
    if args.preview_dir:
        args.preview_dir.mkdir(parents=True, exist_ok=True)
        destination = args.preview_dir / "deep_space.png"
        if args.output.resolve() != destination.resolve():
            shutil.copy2(args.output, destination)
        shutil.copy2(ROOT / "tool/quest_environment_preview.html", args.preview_dir / "index.html")
        shutil.copy2(CATALOG.parent / "NOTICE.txt", args.preview_dir / "NOTICE.txt")
    if args.dynamic_preview_dir:
        args.dynamic_preview_dir.mkdir(parents=True, exist_ok=True)
        runtime = args.runtime_assets or OUTPUT.parent
        for name in ["stars.png", "deep_space_earth.png", "deep_space_moon.png", "earth.jpg", "clouds.jpg", "moon.jpg", "scene.json"]:
            shutil.copy2(runtime / name, args.dynamic_preview_dir / name)
        for name in ["orbital.glsl", "orbital.frag", "orbital.vert"]:
            shutil.copy2(OUTPUT.parent / name, args.dynamic_preview_dir / name)
        shutil.copy2(args.output, args.dynamic_preview_dir / "deep_space.png")
        shutil.copy2(CATALOG.parent / "NOTICE.txt", args.dynamic_preview_dir / "NOTICE.txt")
        shutil.copy2(ROOT / "tool/quest_orbital_preview.html", args.dynamic_preview_dir / "index.html")
    print(f"{count} catalogued stars; {WIDTH}x{HEIGHT}; {args.output.stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
