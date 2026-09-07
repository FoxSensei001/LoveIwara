package m.c.g.a.i_iwara.vr

import com.meta.spatial.core.Pose
import com.meta.spatial.core.Quaternion
import com.meta.spatial.core.SystemManager
import com.meta.spatial.core.Vector2
import com.meta.spatial.core.Vector3
import kotlin.math.cos
import kotlin.math.sin
import m.c.g.a.i_iwara.questui.WindowFrameZone
import org.junit.Assert.*
import org.junit.Test

/** Exercise the real hit test and capture loop. Only native panel creation is omitted. */
class WindowManipulatorTest {
    private class Fixture(private val kind: WindowKind = WindowKind.SCREEN, val arc: Float = 0f) {
        var eye = Vector3(0f, 1.6f, 0f)
        var viewerTracked = true
        val manager = SystemManager()
        val input = SpatialInputPoller(manager)
        val window = WindowManipulator(manager, emptyMap(),
            basisPose = { origin, direction -> Pose(origin, Quaternion.fromDirection(direction)) },
            faceViewer = { position -> if (viewerTracked) Quaternion.fromDirection(position - eye) else null },
        )
        val state = window.frameState(kind)
        var moves = 0
        var resizes = 0
        var size = Vector2(2f, 1f)
        var pose = Pose(Vector3(0f, 1.6f, 2f), Quaternion())
        val host = object : WindowHost {
            override val kind = this@Fixture.kind
            override val resizePolicy = if (kind == WindowKind.UI) ResizePolicy.FREE else ResizePolicy.ASPECT_LOCKED
            override val minSize = Vector2(0.5f, 0.25f)
            override val maxSize = Vector2(4f, 2f)
            override val zIndex = 0
            override fun surfacePose() = pose
            override fun size() = this@Fixture.size
            override fun arcDegrees() = arc
            override fun moveTo(surface: Pose) { pose = surface; moves++ }
            override fun resizeTo(size: Vector2, surface: Pose, commit: Boolean) {
                this@Fixture.size = size
                pose = surface
                state.widthM = size.x + 0.1f
                state.heightM = size.y + 0.1f
                resizes++
            }
        }

        init {
            window.attach(host)
            // A visible host without an Android PanelSceneObject, using the same frame metrics.
            val field = WindowManipulator::class.java.getDeclaredField("slots").apply { isAccessible = true }
            val slot = (field.get(window) as Map<*, *>)[kind]!!
            slot.javaClass.getDeclaredField("parked").apply { isAccessible = true }.setBoolean(slot, false)
            state.widthM = 2.1f
            state.heightM = 1.1f
        }

        fun aimAt(point: Vector3, hand: Int = 0) {
            input.handActive[hand] = true
            input.handPoses[hand] = Pose(eye, Quaternion.fromDirection(point - eye))
        }

        fun surfacePoint(x: Float, y: Float): Vector3 {
            val radius = ScreenGeometry.radiusFor(arc, size.x)
            return if (radius == 0f) pose.t + Vector3(x, y, 0f) else
                pose.t + Vector3(radius * sin(x / radius), y, radius * (cos(x / radius) - 1f))
        }

        fun pinch(hand: Int = 0) {
            input.events.clear()
            input.events.selectDown = 1 shl hand
            input.selectHeld[hand] = true
            window.tick(input)
            input.events.clear()
        }
    }

    @Test fun releasingAndAimingAwayClearsTheFrameHighlight() {
        val f = Fixture()
        f.aimAt(Vector3(1.025f, 1.6f, 2f))
        f.pinch()
        assertTrue(f.window.isBusy(0))
        f.state.pointerZone = WindowFrameZone.EDGE_RIGHT // Last Compose hover; no Exit delivered.
        f.aimAt(Vector3(4f, 1.6f, 2f))
        f.input.selectHeld[0] = false
        f.window.tick(f.input)
        assertFalse(f.window.isBusy(0))
        assertEquals(WindowFrameZone.NONE, f.state.activeZone)
        assertEquals(WindowFrameZone.NONE, f.state.pointerZone)
    }

    @Test fun aStaleCornerCannotCaptureANewPinchOutsideTheWindow() {
        val f = Fixture()
        f.state.pointerZone = WindowFrameZone.CORNER_BR
        f.aimAt(Vector3(4f, 1.6f, 2f))
        f.pinch()
        f.window.tick(f.input)
        assertFalse(f.window.isBusy(0))
        assertEquals(0, f.moves)
        assertEquals(0, f.resizes)
    }

    @Test fun anotherHandsHoverCannotCaptureThisHandsPinch() {
        val f = Fixture()
        f.state.pointerZone = WindowFrameZone.EDGE_RIGHT
        f.aimAt(Vector3(1.025f, 1.6f, 2f), hand = 0)
        f.aimAt(Vector3(4f, 1.6f, 2f), hand = 1)
        f.pinch(hand = 1)
        assertFalse(f.window.isBusy(1))
    }

    @Test fun aFreshCornerGrabKeepsResizingOutsideTheFrameUntilRelease() {
        val f = Fixture()
        f.aimAt(Vector3(1.025f, 1.075f, 2f))
        f.pinch()
        assertTrue(f.window.isBusy(0))
        f.aimAt(Vector3(1.5f, 0.8f, 2f))
        f.window.tick(f.input)
        assertTrue(f.window.isBusy(0))
        assertTrue(f.resizes > 0)
        f.input.selectHeld[0] = false
        f.window.tick(f.input)
        assertFalse(f.window.isBusy(0))
        val resized = f.resizes
        f.aimAt(Vector3(4f, 1.6f, 2f))
        f.pinch()
        f.window.tick(f.input)
        assertFalse(f.window.isBusy(0))
        assertEquals(resized, f.resizes)
    }

    @Test fun curvedCornersKeepResizingAfterTheRayLeavesTheOriginalSurface() {
        for (arc in listOf(8f, 40f, 60f, 85f)) {
            for (signX in listOf(-1f, 1f)) for (signY in listOf(-1f, 1f)) {
                val f = Fixture(arc = arc)
                val center = f.pose.t
                val outward = f.surfacePoint(signX * 1.4f, signY * 0.8f)
                f.aimAt(f.surfacePoint(signX * 1.025f, signY * 0.525f))
                f.pinch()
                assertTrue("The curved corner must capture at $arc degrees", f.window.isBusy(0))
                f.window.tick(f.input)
                val before = f.size.x
                val updates = f.resizes

                f.aimAt(outward)
                f.window.tick(f.input)
                assertTrue("A held curved corner must keep updating outside its old bounds ($arc degrees)", f.resizes > updates)
                assertTrue("An outward curved-corner drag must enlarge the window", f.size.x > before + 0.1f)
                assertEquals(0f, (f.pose.t - center).length(), 0.0001f)
                f.input.selectHeld[0] = false
                f.window.tick(f.input)
                assertFalse(f.window.isBusy(0))
            }
        }
    }

    @Test fun holdingACornerStillDoesNotResizeAndReturningTheRayRestoresTheSize() {
        for (kind in WindowKind.entries) for (arc in listOf(0f, 40f, 85f)) {
            val f = Fixture(kind, arc)
            val start = f.surfacePoint(1.025f, 0.525f)
            f.aimAt(start)
            f.pinch()
            repeat(3) { f.window.tick(f.input) }
            assertEquals(2f, f.size.x, 0.0001f)
            assertEquals(1f, f.size.y, 0.0001f)
            f.aimAt(start + Vector3(0.4f, 0.3f, 0f))
            f.window.tick(f.input)
            assertTrue(f.size.x > 2f)
            f.aimAt(start)
            f.window.tick(f.input)
            assertEquals(2f, f.size.x, 0.0001f)
            assertEquals(1f, f.size.y, 0.0001f)
        }
    }

    @Test fun curvedResizeContinuesBeyondTheTangentWhenTheViewerIsOutsideTheCylinder() {
        val f = Fixture(arc = 85f)
        f.pose = Pose(Vector3(0f, 1.6f, 4f), Quaternion())
        f.aimAt(f.surfacePoint(1.025f, 0.525f))
        f.pinch()
        assertTrue(f.window.isBusy(0))
        f.aimAt(Vector3(3f, 3f, 3.5f))
        f.window.tick(f.input)
        assertEquals(4f, f.size.x, 0.001f)
        assertEquals(2f, f.size.y, 0.001f)
        assertTrue(f.window.isBusy(0))
    }

    @Test fun draggingAnyWindowUpdatesBothPitchAndYawToFaceTheViewer() {
        for (kind in WindowKind.entries) {
            val f = Fixture(kind)
            f.aimAt(Vector3(1.025f, 1.6f, 2f))
            f.pinch()
            f.aimAt(Vector3(1.2f, 0.8f, 2f))
            f.window.tick(f.input)
            assertTrue(f.moves > 0)
            assertEquals(1f, f.pose.forward().dot((f.pose.t - f.eye).normalize()), 0.0001f)
            f.eye = Vector3(-0.5f, 1.2f, 0.2f)
            f.aimAt(Vector3(1.2f, 0.8f, 2f))
            f.window.tick(f.input)
            assertEquals("A held window must turn toward a viewer moving around it", 1f,
                f.pose.forward().dot((f.pose.t - f.eye).normalize()), 0.0001f)
        }
    }

    @Test fun blindGrabsUseTheSameFacingRuleAndTrackingLossKeepsTheLastRotation() {
        val f = Fixture()
        f.aimAt(Vector3(1f, 1.6f, 2f))
        f.input.gripHeld[0] = true
        assertTrue(f.window.startGrab(0, WindowKind.SCREEN, f.input))
        f.aimAt(Vector3(-0.5f, 0.8f, 2f))
        f.window.tick(f.input)
        assertEquals(1f, f.pose.forward().dot((f.pose.t - f.eye).normalize()), 0.0001f)
        val last = f.pose.q
        f.viewerTracked = false
        f.aimAt(Vector3(0.4f, 2.3f, 2f))
        f.window.tick(f.input)
        assertEquals(1f, kotlin.math.abs(last.dot(f.pose.q)), 0.0001f)
        f.viewerTracked = true
        f.window.tick(f.input)
        assertEquals(1f, f.pose.forward().dot((f.pose.t - f.eye).normalize()), 0.0001f)
    }

    @Test fun draggingTheInitialUiWindowSurvivesReleaseAfterTrackingTimesOut() {
        val f = Fixture(WindowKind.UI)
        val readiness = HeadPoseReadiness()
        val placement = UiPanelPlacement()
        val initial = f.pose
        repeat(120) { readiness.update(null) }
        fun settle() {
            if (placement.shouldSettle(readiness.ready, readiness.timedOut)) {
                f.pose = initial
                placement.placed(show = true, headReady = readiness.ready)
            }
        }

        settle()
        f.aimAt(Vector3(1.025f, 1.6f, 2f))
        f.pinch()
        f.aimAt(Vector3(1.5f, 1.6f, 2f))
        f.window.tick(f.input)
        val moved = f.pose
        assertTrue((moved.t - initial.t).length() > 0.1f)

        // Same order as onSceneTick: settle placement, then update/release the grab.
        f.input.selectHeld[0] = false
        repeat(3) {
            settle()
            f.window.tick(f.input)
            assertEquals("A released edge drag must not snap the content back into its old frame", 0f, (f.pose.t - moved.t).length(), 0.0001f)
        }
    }
}
