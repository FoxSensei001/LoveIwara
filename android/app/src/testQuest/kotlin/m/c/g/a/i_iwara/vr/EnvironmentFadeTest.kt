package m.c.g.a.i_iwara.vr

import m.c.g.a.i_iwara.questui.EnvironmentKind
import m.c.g.a.i_iwara.questui.EnvironmentSettings
import org.junit.Assert.*
import org.junit.Test

class EnvironmentFadeTest {
    @Test fun reversingMidTransitionStartsAtTheVisibleLevel() {
        val fade = EnvironmentFade(450)
        fade.setVisible(true, 1000)
        val before = fade.valueAt(1180)
        assertTrue(before > 0f && before < 1f)
        fade.setVisible(false, 1180)
        assertEquals(before, fade.valueAt(1180), 0f)
        assertTrue(fade.valueAt(1300) < before)
        assertEquals(0f, fade.valueAt(1630), 0f)
    }

    @Test fun perFrameSettingsUpdatesDoNotKeepTheSkyPermanentlyFading() {
        val fade = EnvironmentFade(450)
        fade.setVisible(true, 1000)
        var previous = 0f
        for (now in 1000L..1500L step 10) {
            fade.setVisible(true, now)
            val value = fade.valueAt(now)
            assertTrue(value >= previous && value <= 1f)
            previous = value
        }
        assertEquals(1f, previous, 0f)
    }

    @Test fun anOpaquePanoramaCanReleaseTheSkyImmediatelyAndLaterFadeItBack() {
        val fade = EnvironmentFade(450)
        fade.setVisible(true, 1000, immediate = true)
        assertEquals(1f, fade.valueAt(1000), 0f)
        fade.setVisible(false, 1100, immediate = true)
        assertEquals(0f, fade.valueAt(1100), 0f)
        fade.setVisible(true, 2000)
        assertEquals(0f, fade.valueAt(2000), 0f)
        assertEquals(0.5f, fade.valueAt(2225), 0.00001f)
        assertEquals(1f, fade.valueAt(2450), 0f)
    }

    @Test fun aPauseFinishesTheTransitionWithoutOvershoot() {
        val fade = EnvironmentFade(450)
        fade.setVisible(true, 1000)
        assertEquals(1f, fade.valueAt(60_000), 0f)
        fade.setVisible(false, 60_000)
        assertEquals(0f, fade.valueAt(120_000), 0f)
    }

    @Test fun invalidBrightnessFallsBackWithoutChangingTheSelectedWorld() {
        val defaults = EnvironmentSettings()
        assertEquals(EnvironmentKind.PASSTHROUGH, defaults.kind)
        val invalid = EnvironmentSettings(EnvironmentKind.DEEP_SPACE, Float.NaN).normalized()
        assertEquals(EnvironmentKind.DEEP_SPACE, invalid.kind)
        assertEquals(defaults.spaceBrightness, invalid.spaceBrightness, 0f)
        assertEquals(0f, defaults.copy(spaceBrightness = -1f).normalized().spaceBrightness, 0f)
        assertEquals(1f, defaults.copy(spaceBrightness = 2f).normalized().spaceBrightness, 0f)
    }
}
