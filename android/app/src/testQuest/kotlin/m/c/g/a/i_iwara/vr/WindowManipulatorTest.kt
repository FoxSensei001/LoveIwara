package m.c.g.a.i_iwara.vr

import com.meta.spatial.core.Pose
import com.meta.spatial.core.Quaternion
import com.meta.spatial.core.SystemManager
import com.meta.spatial.core.Vector2
import com.meta.spatial.core.Vector3
import m.c.g.a.i_iwara.questui.WindowFrameZone
import org.junit.Assert.*
import org.junit.Test

/** Exercise the real hit test and capture loop. Only native panel creation is omitted. */
class WindowManipulatorTest {
    private class Fixture {
        val eye = Vector3(0f, 1.6f, 0f)
        val manager = SystemManager()
        val input = SpatialInputPoller(manager)
        val window = WindowManipulator(manager, emptyMap(),
            basisPose = { origin, direction -> Pose(origin, Quaternion.fromDirection(direction)) },
            faceViewer = { position -> Quaternion.fromDirection(position - eye) },
        )
        val state = window.frameState(WindowKind.SCREEN)
        var moves = 0
        var resizes = 0
        var pose = Pose(Vector3(0f, 1.6f, 2f), Quaternion())
        val host = object : WindowHost {
            override val kind = WindowKind.SCREEN
            override val resizePolicy = ResizePolicy.ASPECT_LOCKED
            override val minSize = Vector2(0.5f, 0.25f)
            override val maxSize = Vector2(4f, 2f)
            override val zIndex = 0
            override fun surfacePose() = pose
            override fun size() = Vector2(2f, 1f)
            override fun moveTo(surface: Pose) { pose = surface; moves++ }
            override fun resizeTo(size: Vector2, surface: Pose, commit: Boolean) { resizes++ }
        }

        init {
            window.attach(host)
            // A visible host without an Android PanelSceneObject, using the same frame metrics.
            val field = WindowManipulator::class.java.getDeclaredField("slots").apply { isAccessible = true }
            val slot = (field.get(window) as Map<*, *>)[WindowKind.SCREEN]!!
            slot.javaClass.getDeclaredField("parked").apply { isAccessible = true }.setBoolean(slot, false)
            state.widthM = 2.1f
            state.heightM = 1.1f
        }

        fun aimAt(point: Vector3, hand: Int = 0) {
            input.handActive[hand] = true
            input.handPoses[hand] = Pose(eye, Quaternion.fromDirection(point - eye))
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
        f.pinch()
        f.window.tick(f.input)
        assertFalse(f.window.isBusy(0))
        assertEquals(resized, f.resizes)
    }
}
