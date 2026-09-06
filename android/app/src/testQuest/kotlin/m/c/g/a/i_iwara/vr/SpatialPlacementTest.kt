package m.c.g.a.i_iwara.vr

import com.meta.spatial.core.Pose
import com.meta.spatial.core.Quaternion
import com.meta.spatial.core.Vector3
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin
import org.junit.Assert.*
import org.junit.Test

class SpatialPlacementTest {
    private val eye = Vector3(0.8f, 1.05f, -0.4f)

    @Test fun viewingCenterStaysBelowEyesForSeatedAndReclinedViewers() {
        for (pitch in listOf(-30f, 0f, 30f, 60f, 89.9f, 90f)) {
            for (yaw in listOf(0f, 90f, 180f, -110f)) {
                val head = head(pitch, yaw)
                val frame = SpatialPlacement.viewFrame(head)
                for (height in listOf(0.8f, 1.8f, 2.4f)) {
                    val screen = SpatialPlacement.screenSurface(frame, 1.6f)
                    val bottom = screen.t - screen.up() * (height / 2f) - eye
                    assertEquals(-8f, elevationIn(frame, screen.t - eye), 0.01f)
                    assertTrue(elevationIn(frame, bottom) < -8f)
                    assertTrue((screen.t - eye).dot(head.forward()) > 0f)
                    assertEquals(1f, screen.forward().dot((screen.t - eye).normalize()), 0.001f)
                    assertEquals(1f, screen.q.norm(), 0.001f)
                }
            }
        }
    }

    @Test fun controlsAreBelowScreenAndTiltedTowardTheViewer() {
        for (pitch in listOf(0f, 45f, 90f)) {
            val frame = SpatialPlacement.viewFrame(head(pitch, 35f))
            val height = 1.2f * 360f / 1100f
            val controls = SpatialPlacement.controlsSurface(frame, 1f, height)
            assertEquals(1f, (controls.t - eye).length(), 0.001f)
            assertTrue(elevationIn(frame, controls.t - eye) <= -32f)
            val top = controls.t + controls.up() * (height / 2f) - eye
            assertTrue(elevationIn(frame, top) <= -29.9f)
            assertEquals(1f, controls.forward().dot((controls.t - eye).normalize()), 0.001f)
            val enlarged = SpatialPlacement.controlsSurface(frame, 1f, height * 2f)
            assertTrue(elevationIn(frame, enlarged.t + enlarged.up() * height - eye) <= -29.9f)
        }
    }

    @Test fun stationaryGrabKeepsTheActualTiltIncludingADeskPanel() {
        val frame = SpatialPlacement.viewFrame(head(0f, 20f))
        val panels = listOf(
            SpatialPlacement.screenSurface(frame, 1.6f),
            SpatialPlacement.controlsSurface(frame, 1f, 0.39f),
        )
        for (surface in panels) {
            val facing = SpatialPlacement.frame(surface.t, surface.t - eye, frame.up()).q
            val grab = GrabOrientation(surface.q, facing)
            assertRotation(surface.q, grab.at(facing))
            val movedFacing = SpatialPlacement.frame(surface.t, surface.t - eye + frame.right() * 0.5f, frame.up()).q
            // Returning the hand to its start must return to the original tilt, without drift.
            grab.at(movedFacing)
            assertRotation(surface.q, grab.at(facing))
        }
    }

    @Test fun anOldTiltGraduallyFacesTheViewerAsTheScreenMoves() {
        val initial = head(25f, 20f).q
        val facing = head(0f, 20f).q
        val grab = GrabOrientation(initial, facing)
        assertRotation(initial, grab.at(facing))
        assertRotation(initial, grab.at(facing, 0.002f)) // Tracking jitter is not an intentional drag.
        val movedFacing = head(-30f, 25f).q
        assertRotation(movedFacing, grab.at(movedFacing, 0.2f))
        // Once corrected, returning to the grab position must not reapply the old awkward tilt.
        assertRotation(facing, grab.at(facing, 0f))
        assertRotation(facing, grab.at(null))
    }

    @Test fun defaultScreenDoesNotRequireLookingUpToSeeItsCenter() {
        val frame = SpatialPlacement.viewFrame(head(0f, 0f))
        val screen = SpatialPlacement.screenSurface(frame, PlayerPrefs.DEFAULT_VIEW_DISTANCE_M)
        val height = PlayerPrefs.DEFAULT_SCREEN_WIDTH_M / (16f / 9f)
        val top = screen.t + screen.up() * (height / 2f) - eye
        assertTrue(elevationIn(frame, screen.t - eye) < 0f)
        assertTrue(elevationIn(frame, top) < 15f)
    }

    @Test fun migratingADistantLayoutPreservesApparentWidthAndKeepsCloserChoices() {
        val closer = PlayerPrefs.nearerLayout(2.4f, 3.2f)
        assertEquals(1.6f, closer[0], 0.001f)
        assertEquals(3.2f / 2.4f, closer[1] / closer[0], 0.001f)
        val alreadyClose = PlayerPrefs.nearerLayout(1.2f, 1.4f)
        assertEquals(1.2f, alreadyClose[0], 0f)
        assertEquals(1.4f, alreadyClose[1], 0.001f)
    }

    @Test fun trackingUnavailableAtGrabDoesNotIntroduceALaterSnap() {
        val initial = head(30f, 50f).q
        val grab = GrabOrientation(initial, null)
        assertRotation(initial, grab.at(head(0f, 0f).q))
        assertRotation(initial, grab.at(null))
    }

    @Test fun upDirectionIsContinuousAcrossTheFormerVerticalThreshold() {
        val before = SpatialPlacement.viewFrame(head(58.1f, 45f))
        val after = SpatialPlacement.viewFrame(head(58.3f, 45f))
        assertTrue(before.up().dot(after.up()) > 0.999f)
        assertTrue(before.right().dot(after.right()) > 0.999f)
    }

    @Test fun firstValidPoseAndARecenterBothWaitForTrackingToSettle() {
        val readiness = HeadPoseReadiness()
        repeat(7) { readiness.update(head(0f, 0f)); assertFalse(readiness.ready) }
        readiness.update(head(0f, 0f))
        assertTrue(readiness.ready)
        readiness.reset()
        assertFalse(readiness.ready)
        repeat(7) { readiness.update(head(70f, 90f)) }
        assertFalse(readiness.ready)
        readiness.update(head(70f, 90f))
        assertTrue(readiness.ready)
    }

    @Test fun invalidTrackingResetsTheStreakAndTimeoutDoesNotPretendTrackingIsReady() {
        val readiness = HeadPoseReadiness()
        repeat(7) { readiness.update(head(0f, 0f)) }
        readiness.update(Pose())
        readiness.update(head(0f, 0f))
        assertFalse(readiness.ready)
        repeat(120) { readiness.update(null) }
        assertTrue(readiness.timedOut)
        assertFalse(readiness.ready)
        assertFalse(SpatialPlacement.isTracked(Pose(Vector3(Float.NaN, 1f, 0f), Quaternion())))
    }

    @Test fun distanceControlsHaveTheSameSpeedAtEveryQuestRefreshRate() {
        val factors = listOf(72, 90, 120).map { hz ->
            var factor = 1f
            var offset = 0f
            repeat(hz) {
                factor *= ViewDistanceMotion.flatFactor(1, 1f / hz)
                offset += ViewDistanceMotion.sphereDelta(1, 1f / hz)
            }
            assertEquals(8f, offset, 0.001f)
            factor
        }
        factors.forEach { assertEquals(factors.first(), it, 0.0001f) }
        assertEquals(1f, ViewDistanceMotion.flatFactor(0, 0.05f), 0f)
        assertEquals(0f, ViewDistanceMotion.sphereDelta(0, 0.05f), 0f)
        assertEquals(1f, ViewDistanceMotion.flatFactor(1, 0.02f) * ViewDistanceMotion.flatFactor(-1, 0.02f), 0.0001f)
    }

    private fun head(pitch: Float, yaw: Float): Pose {
        val p = pitch * PI.toFloat() / 180f
        val y = yaw * PI.toFloat() / 180f
        val forward = Vector3(sin(y) * cos(p), sin(p), cos(y) * cos(p))
        val up = Vector3(-sin(y) * sin(p), cos(p), -cos(y) * sin(p))
        return Pose(eye, Quaternion.fromDirection(forward, up))
    }

    private fun elevationIn(frame: Pose, delta: Vector3): Float =
        atan2(delta.dot(frame.up()), delta.dot(frame.forward())) * 180f / PI.toFloat()

    private fun assertRotation(expected: Quaternion, actual: Quaternion) {
        assertEquals(1f, kotlin.math.abs(expected.normalize().dot(actual.normalize())), 0.00001f)
    }
}
