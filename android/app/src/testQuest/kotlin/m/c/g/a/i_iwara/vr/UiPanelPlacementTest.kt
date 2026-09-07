package m.c.g.a.i_iwara.vr

import org.junit.Assert.*
import org.junit.Test

class UiPanelPlacementTest {
    @Test fun untouchedFallbackSettlesOnceWhenHeadTrackingArrives() {
        val placement = UiPanelPlacement()
        assertFalse(placement.shouldSettle(headReady = false, timedOut = false))
        assertTrue(placement.shouldSettle(headReady = false, timedOut = true))
        placement.placed(show = true, headReady = false)
        assertFalse(placement.shouldSettle(headReady = false, timedOut = true))
        assertTrue(placement.shouldSettle(headReady = true, timedOut = true))
        placement.placed(show = true, headReady = true)
        assertFalse(placement.shouldSettle(headReady = true, timedOut = true))
    }

    @Test fun manualPlacementWinsOverLateTrackingUntilExplicitRecenter() {
        val placement = UiPanelPlacement()
        placement.placed(show = true, headReady = false)
        placement.moved()
        assertFalse(placement.shouldSettle(headReady = false, timedOut = true))
        assertFalse(placement.shouldSettle(headReady = true, timedOut = true))
        placement.reset()
        assertTrue(placement.shouldSettle(headReady = true, timedOut = true))
    }

    @Test fun returningFromMediaStartsANewPlacement() {
        val placement = UiPanelPlacement()
        placement.placed(show = true, headReady = true)
        placement.moved()
        placement.placed(show = false, headReady = true)
        assertFalse(placement.shown)
        assertTrue(placement.shouldSettle(headReady = true, timedOut = false))
    }
}
