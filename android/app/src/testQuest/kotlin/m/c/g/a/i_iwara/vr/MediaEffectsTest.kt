package m.c.g.a.i_iwara.vr

import m.c.g.a.i_iwara.questui.MediaEffectsSettings
import m.c.g.a.i_iwara.questui.VideoFormat
import org.junit.Assert.*
import org.junit.Test

class MediaEffectsTest {
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
