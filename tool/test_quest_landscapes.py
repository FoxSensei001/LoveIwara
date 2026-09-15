"""Continuity and display-budget checks for the shipping Quest panoramas."""

from pathlib import Path
import unittest

import numpy as np
from PIL import Image

import generate_quest_landscapes as env


class LandscapeTest(unittest.TestCase):
    def test_longitude_wrap_is_continuous_at_every_height(self):
        for name, render in env.RENDERERS.items():
            for lat in np.linspace(-np.pi / 2, np.pi / 2, 91):
                rays = env.directions(np.array([-np.pi + 1e-9, np.pi - 1e-9]), np.full(2, lat))
                color = env.srgb(render(rays))
                np.testing.assert_allclose(color[0], color[1], atol=1 / 255, err_msg=name)

    def test_poles_do_not_change_when_looking_around(self):
        for name, render in env.RENDERERS.items():
            for lat in (-np.pi / 2, np.pi / 2):
                rays = env.directions(np.linspace(-np.pi, np.pi, 25), np.full(25, lat))
                color = env.srgb(render(rays))
                np.testing.assert_allclose(color, np.broadcast_to(color[0], color.shape), atol=1e-6, err_msg=name)

    def test_fields_are_finite_nonnegative_and_forward_view_is_not_the_hotspot(self):
        lon, lat = np.meshgrid(np.linspace(-np.pi, np.pi, 200), np.linspace(-np.pi / 2, np.pi / 2, 100))
        rays = env.directions(lon, lat)
        forward = (np.abs(lon) < np.deg2rad(25)) & (lat > 0) & (lat < np.deg2rad(30))
        for name, render in env.RENDERERS.items():
            color = render(rays)
            self.assertTrue(np.isfinite(color).all(), name)
            self.assertGreaterEqual(float(color.min()), 0, name)
            luminance = color @ [.2126, .7152, .0722]
            self.assertLess(float(luminance[forward].max()), .35, name)

    def test_packaged_images_fit_the_compositor_and_have_no_polar_pinch(self):
        for name in env.RENDERERS:
            with Image.open(env.OUTPUT / f"{name}.png") as image:
                self.assertEqual(image.size, (4096, 2048))
                self.assertEqual(image.mode, "RGB")
                pixels = np.asarray(image)
            for row in (pixels[0], pixels[-1]):
                np.testing.assert_array_equal(row, np.broadcast_to(row[0], row.shape))
            # Ordinary adjacent pixel differences include dither; the wrap must
            # not introduce a stronger edge than the rest of this panorama.
            delta = np.abs(pixels[:, 0].astype(int) - pixels[:, -1].astype(int))
            self.assertLess(np.percentile(delta, 99.5), 8, name)
            self.assertLess((env.OUTPUT / f"{name}.png").stat().st_size, 12_000_000)

    def test_preview_assets_remain_small_and_quest_only(self):
        for name in [*env.RENDERERS, "void", "passthrough", "deep_space"]:
            with Image.open(env.THUMBNAILS / f"environment_{name}.webp") as image:
                self.assertEqual(image.size, (384, 192))
        self.assertFalse((env.OUTPUT / "void.png").exists(), "Black surroundings need no full-size texture")
        self.assertFalse((env.ROOT / "android/app/src/main/assets/environments").exists())


if __name__ == "__main__":
    unittest.main()
