package m.c.g.a.i_iwara.vr

import com.meta.spatial.core.SystemManager
import com.meta.spatial.runtime.ButtonBits
import org.junit.Assert.*
import org.junit.Test

/** Replay controller frames through the same reducer used by the scene tick. */
class SpatialInputPollerTest {
    private class Fixture {
        val input = SpatialInputPoller(SystemManager())

        fun frame(left: Int = 0, right: Int = 0, active: Boolean = true): SpatialInputPoller.Events {
            input.events.clear()
            input.handActive.fill(active)
            input.isController.fill(active)
            input.updateButtonState(
                intArrayOf(left, right),
                booleanArrayOf(left and ButtonBits.ButtonTriggerL != 0, right and ButtonBits.ButtonTriggerR != 0),
                booleanArrayOf(left and ButtonBits.ButtonSqueezeL != 0, right and ButtonBits.ButtonSqueezeR != 0),
            )
            return input.events
        }
    }

    @Test fun repeatedBackPressesRecoverAfterEntryWhileFingersRestOnTheController() {
        val f = Fixture()
        val resting = ButtonBits.ButtonThumbRTouch or ButtonBits.ButtonBTouch
        f.input.reset(awaitRelease = true)
        f.frame(right = resting)
        repeat(3) {
            assertTrue("A fresh B press must return after entering/recentering", f.frame(right = resting or ButtonBits.ButtonB).back)
            assertFalse("Holding B is not another press", f.frame(right = resting or ButtonBits.ButtonB).back)
            assertFalse(f.frame(right = resting).back)
        }
    }

    @Test fun stickRecoversAfterTrackingLossWithoutLiftingTheThumb() {
        val f = Fixture()
        f.frame(active = false)
        f.frame(right = ButtonBits.ButtonThumbRTouch)
        assertTrue(f.frame(right = ButtonBits.ButtonThumbRTouch or ButtonBits.ButtonThumbRU).volumeUp)
        assertTrue(f.frame(right = ButtonBits.ButtonThumbRTouch or ButtonBits.ButtonThumbRU).volumeUp)
        assertFalse(f.frame(right = ButtonBits.ButtonThumbRTouch).volumeUp)
    }

    @Test fun aHeldGripDoesNotBlockANewBackPressAfterTheBackButtonWasReleased() {
        val f = Fixture()
        f.input.reset(awaitRelease = true)
        f.frame(right = ButtonBits.ButtonSqueezeR)
        assertTrue(f.frame(right = ButtonBits.ButtonSqueezeR or ButtonBits.ButtonB).back)
        assertFalse("The held grip still needs a physical release", f.input.gripHeld[1])
    }

    @Test fun oneHandsStickAxisDoesNotLockTheOtherHandsStick() {
        val f = Fixture()
        assertTrue(f.frame(left = ButtonBits.ButtonThumbLL).seekLeft)
        val e = f.frame(left = ButtonBits.ButtonThumbLL, right = ButtonBits.ButtonThumbRU)
        assertTrue(e.seekLeft)
        assertTrue("Right stick up must work while the left stick is horizontal", e.volumeUp)
    }

    @Test fun diagonalMotionStaysOnTheInitialAxisUntilThatStickReturnsToNeutral() {
        val f = Fixture()
        assertTrue(f.frame(right = ButtonBits.ButtonThumbRU).volumeUp)
        val diagonal = f.frame(right = ButtonBits.ButtonThumbRU or ButtonBits.ButtonThumbRR)
        assertTrue(diagonal.volumeUp)
        assertFalse(diagonal.seekRight)
        f.frame()
        assertTrue(f.frame(right = ButtonBits.ButtonThumbRR).seekRight)
    }

    @Test fun aBackButtonHeldAcrossRecenterDoesNotBecomeAFreshPress() {
        val f = Fixture()
        f.input.reset(awaitRelease = true)
        assertFalse(f.frame(right = ButtonBits.ButtonB).back)
        assertFalse(f.frame(right = ButtonBits.ButtonB).back)
        f.frame()
        assertTrue(f.frame(right = ButtonBits.ButtonB).back)
    }

    @Test fun panelScrollingOnlyConsumesThePointingHandsStick() {
        val f = Fixture()
        val e = f.frame(left = ButtonBits.ButtonThumbLL, right = ButtonBits.ButtonThumbRU)
        val stage = e.stickForHands(0b01.inv()) // Left hand points at the controls.
        assertFalse(stage.left)
        assertTrue("The right stick still changes viewing distance", stage.up)
        val panel = e.stickForHands(0b01)
        assertTrue(panel.left)
        assertFalse(panel.up)
    }

    @Test fun aStickHeldAcrossRecenterMustCenterBeforeSwitchingAxes() {
        val f = Fixture()
        f.input.reset(awaitRelease = true)
        assertFalse(f.frame(right = ButtonBits.ButtonThumbRU).volumeUp)
        assertFalse(f.frame(right = ButtonBits.ButtonThumbRU or ButtonBits.ButtonThumbRR).seekRight)
        f.frame(right = ButtonBits.ButtonThumbRTouch)
        assertTrue(f.frame(right = ButtonBits.ButtonThumbRTouch or ButtonBits.ButtonThumbRR).seekRight)
    }

    @Test fun everyStickDirectionRecoversForEitherHandWhileTheThumbIsResting() {
        val directions = arrayOf(
            intArrayOf(ButtonBits.ButtonThumbLL, ButtonBits.ButtonThumbLR, ButtonBits.ButtonThumbLU, ButtonBits.ButtonThumbLD),
            intArrayOf(ButtonBits.ButtonThumbRL, ButtonBits.ButtonThumbRR, ButtonBits.ButtonThumbRU, ButtonBits.ButtonThumbRD),
        )
        for (hand in 0..1) {
            val f = Fixture()
            val resting = if (hand == 0) ButtonBits.ButtonThumbLTouch else ButtonBits.ButtonThumbRTouch
            fun frame(bits: Int) = if (hand == 0) f.frame(left = bits) else f.frame(right = bits)
            f.input.reset(awaitRelease = true)
            for ((direction, bit) in directions[hand].withIndex()) {
                frame(resting)
                val e = frame(resting or bit)
                val held = listOf(e.seekLeft, e.seekRight, e.volumeUp, e.volumeDown)
                assertEquals(listOf(0, 1, 2, 3).map { it == direction }, held)
            }
        }
    }
}
