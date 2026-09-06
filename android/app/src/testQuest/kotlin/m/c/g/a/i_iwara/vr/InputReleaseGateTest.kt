package m.c.g.a.i_iwara.vr

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class InputReleaseGateTest {
    @Test fun inactiveFramesCannotReleaseARecenterGuard() {
        val gate = InputReleaseGate()
        gate.reset(awaitRelease = true)
        repeat(3) { assertFalse(gate.read(active = false, pressed = false)) }
        assertFalse(gate.read(active = true, pressed = true))
        assertFalse(gate.read(active = true, pressed = false))
        assertTrue(gate.read(active = true, pressed = true))
    }

    @Test fun trackingLossRequiresAFreshPressFromThatHand() {
        val left = InputReleaseGate()
        val right = InputReleaseGate()
        assertTrue(left.read(active = true, pressed = true))
        assertFalse(left.read(active = false, pressed = false))
        // The other controller being neutral must not release this hand's guard.
        assertFalse(right.read(active = true, pressed = false))
        assertFalse(left.read(active = true, pressed = true))
        assertFalse(left.read(active = true, pressed = false))
        assertTrue(left.read(active = true, pressed = true))
    }
}
