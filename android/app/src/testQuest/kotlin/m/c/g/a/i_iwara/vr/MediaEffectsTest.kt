package m.c.g.a.i_iwara.vr

import m.c.g.a.i_iwara.questui.MediaEffectsSettings
import m.c.g.a.i_iwara.questui.VideoFormat
import org.junit.Assert.*
import org.junit.Test

class MediaEffectsTest {
    @Test fun equalAspectResizeKeepsTheSameUnitMeshAtEveryCurvature() {
        for (arc in listOf(0f, 40f, 60f, 85f)) {
            val initial = ScreenGeometry.normalizedRadiusFor(arc, 2.4f)
            for (step in 1..200) {
                assertEquals("arc=$arc step=$step", initial,
                    ScreenGeometry.normalizedRadiusFor(arc, 2.4f + step * 0.01f), 0f)
            }
        }
    }

    @Test fun unitMeshRetainsMinimumRadiusAndRespondsToCurvatureChanges() {
        for (arc in listOf(0f, 8f, 40f, 60f, 85f)) {
            for (width in listOf(0.1f, 0.3f, 0.7f, 2.4f, 4.4f)) {
                assertEquals(ScreenGeometry.radiusFor(arc, width),
                    ScreenGeometry.normalizedRadiusFor(arc, width) * width, 0.000001f)
            }
        }
        assertNotEquals(ScreenGeometry.normalizedRadiusFor(40f, 2.4f),
            ScreenGeometry.normalizedRadiusFor(60f, 2.4f))
    }

    @Test fun invalidPreferencesCannotSendNaNOrOutOfRangeValuesToShaders() {
        val defaults = MediaEffectsSettings()
        val restored = MediaEffectsSettings(
            edgeFeather = Float.NaN, glowStrength = Float.POSITIVE_INFINITY, backgroundTransparency = -2f,
        ).normalized()
        assertEquals(defaults.edgeFeather, restored.edgeFeather, 0f)
        assertEquals(defaults.glowStrength, restored.glowStrength, 0f)
        assertEquals(0f, restored.backgroundTransparency, 0f)
        assertEquals(1f, defaults.copy(edgeFeather = 8f).normalized().edgeFeather, 0f)
    }

    @Test fun switchingEffectsOffPreservesTheSelectedRoomVisibility() {
        val off = MediaEffectsSettings(enabled = false, backgroundTransparency = 0.65f)
        assertEquals(0f, off.feather, 0f)
        assertEquals(0f, off.glow, 0f)
        assertEquals(0.65f, off.backgroundTransparency, 0f)
        for (format in listOf(VideoFormat.FLAT_2D, VideoFormat.PANO_180_3D_LR)) {
            assertFalse(MediaEffectsRenderer.usesTextureEffects(off, format))
        }
    }

    @Test fun lowestBrightnessStillUsesTheTransparentTexturePath() {
        // An opaque compositor video cannot reveal passthrough at a feathered edge.
        val featherOnly = MediaEffectsSettings(edgeFeather = 0.7f, glowStrength = 0f)
        assertTrue(MediaEffectsRenderer.usesTextureEffects(featherOnly, VideoFormat.FLAT_2D))
        assertTrue(MediaEffectsRenderer.usesTextureEffects(featherOnly, VideoFormat.PANO_180_3D_LR))
        assertFalse(MediaEffectsRenderer.usesTextureEffects(featherOnly, VideoFormat.PANO_360_2D))
    }

    @Test fun fullPanoramasDoNotAcquireAnArtificialSeamOrGlow() {
        for (format in listOf(VideoFormat.PANO_360_2D, VideoFormat.PANO_360_3D_LR, VideoFormat.PANO_360_3D_TB)) {
            assertFalse(MediaEffectsRenderer.hasBoundary(format))
        }
        assertTrue(MediaEffectsRenderer.hasBoundary(VideoFormat.PANO_180_3D_LR))
    }
}
