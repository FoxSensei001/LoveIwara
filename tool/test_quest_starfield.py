"""Continuity checks on the actual offline environment renderer, without a headset."""

import unittest
from unittest.mock import patch
import numpy as np
from PIL import Image
import generate_quest_starfield as sky


class EnvironmentContinuityTest(unittest.TestCase):
    def test_galactic_longitude_branch_has_no_hidden_internal_seam(self):
        # The old sin(3.2 * atan2(y,x)) dust lane jumped inside the panorama,
        # far away from the image's U=0/1 edge. Repeat texture sampling cannot fix it.
        for latitude in [0.0, 0.03, -0.03]:
            a, b = -np.pi + 1e-8, np.pi - 1e-8
            directions = np.array([
                [np.cos(latitude) * np.cos(l), np.cos(latitude) * np.sin(l), np.sin(latitude)]
                for l in [a, b]
            ]) @ sky.GALACTIC_TO_WORLD.T
            colors = sky.srgb(sky.background_radiance(directions))
            np.testing.assert_allclose(colors[0], colors[1], atol=1 / 255,
                                       err_msg="An almost identical sky direction changes brightness at the longitude cut")

    def test_surface_sampler_repeats_longitude(self):
        texture = np.random.default_rng(71).random((8, 16, 3))
        u, v = np.array([-.001, 0., .999, 1.001]), np.array([.1, .7, .9, .4])
        np.testing.assert_allclose(sky.bilinear(texture, u, v), sky.bilinear(texture, u + 1, v), atol=1e-12)
        np.testing.assert_allclose(sky.bilinear(texture, 1e-10, .3), sky.bilinear(texture, 1 - 1e-10, .3), atol=1e-8)

    def test_earth_spanning_panorama_wrap_has_continuous_clouds_and_light(self):
        texture = np.random.default_rng(14).random((32, 64, 3))
        earth = sky.Planet("earth", 180, 0, 21, 75, 17, texture, clouds=texture)
        rays = sky.directions(np.array([-np.pi + 1e-9, np.pi - 1e-9]), np.zeros(2))
        color, coverage = sky.planet_layer(rays, earth)
        np.testing.assert_array_equal(coverage, [1, 1])
        np.testing.assert_allclose(color[0], color[1], atol=1e-6)

    def test_earth_at_pole_does_not_depend_on_longitude(self):
        earth = sky.Planet("earth", 0, 90, 21, 75, 17, np.ones((8, 16, 3)) * .25)
        rays = sky.directions(np.linspace(-np.pi, np.pi, 13), np.full(13, np.pi / 2))
        color, coverage = sky.planet_layer(rays, earth)
        np.testing.assert_array_equal(coverage, np.ones(13))
        self.assertTrue(np.isfinite(color).all())
        np.testing.assert_allclose(color, np.broadcast_to(color[0], color.shape), atol=1e-7)

    def test_night_side_still_occludes_stars(self):
        moon = sky.Planet("moon", 32, 22, 4.6, 0, 5, np.ones((8, 16, 3)))
        with patch.object(sky, "SUN", moon.direction):
            color, coverage = sky.planet_layer(moon.direction[None, :], moon)
        np.testing.assert_array_equal(coverage, [1])
        composited = np.ones((1, 3)) * (1 - coverage[:, None]) + color
        self.assertLess(float(composited.max()), .005)

    def test_sphere_does_not_occlude_opposite_direction(self):
        moon = sky.Planet("moon", 32, 22, 4.6, 0, 5, np.ones((8, 16, 3)))
        color, coverage = sky.planet_layer(-moon.direction[None, :], moon)
        np.testing.assert_array_equal(coverage, [0])
        np.testing.assert_array_equal(color, np.zeros((1, 3)))

    def test_packaged_static_variants_remove_only_the_hidden_body(self):
        def pixels(name):
            with Image.open(sky.OUTPUT.parent / name) as image:
                self.assertEqual(image.size, (sky.WIDTH, sky.HEIGHT))
                return np.asarray(image.convert("RGB"))

        stars = pixels("stars.png")
        earth = pixels("deep_space_earth.png")
        moon = pixels("deep_space_moon.png")
        both = pixels("deep_space.png")
        earth_changed = np.any(earth != stars, axis=-1)
        moon_changed = np.any(moon != stars, axis=-1)
        self.assertTrue(earth_changed.any())
        self.assertTrue(moon_changed.any())
        self.assertFalse(np.any(earth_changed & moon_changed))
        # Hiding one body must reveal the original stars without disturbing the other.
        np.testing.assert_array_equal(both, np.where(earth_changed[..., None], earth, moon))
        for changed, yaw, pitch in [(earth_changed, -34, 12), (moon_changed, 32, 22)]:
            x = int((yaw / 360 + .5) * sky.WIDTH)
            y = int((.5 - pitch / 180) * sky.HEIGHT)
            self.assertTrue(changed[y, x])
        for variant in [earth, moon, both]:
            np.testing.assert_array_equal(variant[:, [0, -1]], stars[:, [0, -1]])
            np.testing.assert_array_equal(variant[[0, -1]], stars[[0, -1]])


if __name__ == "__main__":
    unittest.main()
