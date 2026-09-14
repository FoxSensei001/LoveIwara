package m.c.g.a.i_iwara.vr

import org.junit.Assert.*
import org.junit.Test

class ScenePresenceTest {
    @Test fun mountingCannotResumeAPausedVrSession() {
        val state = ScenePresence()
        state.vrVisible = true
        assertTrue(state.foreground)
        state.vrVisible = false
        state.hmdMounted = false
        state.hmdMounted = true
        assertFalse(state.foreground)
        state.vrVisible = true
        assertTrue(state.foreground)
    }

    @Test fun vrReadyCannotResumeAnUnmountedHeadset() {
        val state = ScenePresence()
        assertFalse(state.foreground)
        state.hmdMounted = false
        state.vrVisible = true
        assertFalse(state.foreground)
        state.hmdMounted = true
        assertTrue(state.foreground)
    }
}
