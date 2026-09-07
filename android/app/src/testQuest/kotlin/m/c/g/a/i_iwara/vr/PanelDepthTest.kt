package m.c.g.a.i_iwara.vr

import com.meta.spatial.core.Pose
import com.meta.spatial.core.Quaternion
import com.meta.spatial.core.Vector2
import com.meta.spatial.core.Vector3
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.min
import kotlin.math.sin
import org.junit.Assert.*
import org.junit.Test

class PanelDepthTest {
    private val viewer = Pose(Vector3(0f, 1.6f, 0f), Quaternion())
    private val panelSize = Vector2(1.2f, 1.2f * 360f / 1100f)
    private val screenSize = Vector2(2.4f, 1.35f)
    private val base = SpatialPlacement.controlsSurface(viewer, 1f)

    @Test fun curvedScreenCanHideACursorEvenWhenItsCenterIsBehindTheControls() {
        val screen = SpatialPlacement.screenSurface(viewer, 0.6f)
        val radius = ScreenGeometry.radiusFor(85f, screenSize.x)
        val oldDistance = ((screen.t - viewer.t).length() - 0.15f).coerceAtLeast(0.45f)
        val old = SpatialPlacement.atDistance(base, viewer, oldDistance)
        assertTrue("The former center-distance clamp leaves the curved edge ahead of a cursor",
            minimumScreenClearance(old, panelSize, screen, screenSize, radius) < -0.005f)

        val adjusted = place(base, panelSize, screen, screenSize, radius)
        assertTrue(minimumScreenClearance(adjusted, panelSize, screen, screenSize, radius) > 0.02f)
        assertEquals(1f, (base.t - viewer.t).normalize().dot((adjusted.t - viewer.t).normalize()), 0.0001f)
        assertEquals(1f, adjusted.forward().dot((adjusted.t - viewer.t).normalize()), 0.0001f)
    }

    @Test fun aCloseFlatScreenDoesNotPutTheControlsBehindAFixedMinimumDistance() {
        val screen = SpatialPlacement.screenSurface(viewer, 0.4f)
        val adjusted = place(base, panelSize, screen, screenSize, 0f)
        assertTrue((adjusted.t - viewer.t).length() < 0.45f)
        assertTrue(minimumScreenClearance(adjusted, panelSize, screen, screenSize, 0f) > 0.02f)
    }

    @Test fun theWholePanelAndItsHandlesStayAheadAcrossCurvatureAndScale() {
        for (arc in listOf(0f, 40f, 60f, 85f)) {
            val radius = ScreenGeometry.radiusFor(arc, screenSize.x)
            for (distance in listOf(0.8f, 1.2f, 1.6f)) {
                val screen = SpatialPlacement.screenSurface(viewer, distance)
                for (scale in listOf(0.6f, 1f, 2f)) {
                    val size = Vector2(panelSize.x * scale, panelSize.y * scale)
                    val adjusted = place(base, size, screen, screenSize, radius)
                    assertTrue("arc=$arc distance=$distance scale=$scale",
                        minimumScreenClearance(adjusted, size, screen, screenSize, radius) > 0.02f)
                }
            }
        }
    }

    @Test fun distantOrNonOverlappingScreensPreserveTheSavedPose() {
        val far = SpatialPlacement.screenSurface(viewer, 2.4f)
        assertSame(base, place(base, panelSize, far, screenSize, ScreenGeometry.radiusFor(85f, screenSize.x)))
        val beside = Pose(viewer.t + Vector3(3f, 0f, 0.4f), Quaternion())
        assertSame(base, place(base, panelSize, beside, screenSize, 0f))
        val below = Pose(viewer.t + Vector3(0f, -3f, 0.4f), Quaternion())
        assertSame(base, place(base, panelSize, below, screenSize, 0f))
        val behind = Pose(viewer.t + Vector3(0f, 0f, -0.4f), Quaternion())
        assertSame(base, place(base, panelSize, behind, screenSize, 0f))
    }

    @Test fun depthAdjustmentIsIndependentOfSeatedOrReclinedWorldOrientation() {
        val screen = SpatialPlacement.screenSurface(viewer, 0.8f)
        val radius = ScreenGeometry.radiusFor(85f, screenSize.x)
        val expected = place(base, panelSize, screen, screenSize, radius)
        for (rotation in listOf(Quaternion(50f, 35f, 0f), Quaternion(90f, -60f, 0f))) {
            fun rotated(pose: Pose) = Pose(viewer.t + rotation * (pose.t - viewer.t), rotation * pose.q)
            val result = PanelDepth.inFrontOfScreen(rotated(base), panelSize, rotated(viewer),
                rotated(screen), screenSize, radius, 0.15f)
            assertEquals((expected.t - viewer.t).length(), (result.t - viewer.t).length(), 0.0001f)
            assertEquals(1f, result.forward().dot((result.t - viewer.t).normalize()), 0.0001f)
        }
    }

    private fun place(panel: Pose, size: Vector2, screen: Pose, screenSize: Vector2, radius: Float): Pose =
        PanelDepth.inFrontOfScreen(panel, size, viewer, screen, screenSize, radius, 0.15f)

    /** Independently project dense samples of the actual surface into each eye's panel view. */
    private fun minimumScreenClearance(panel: Pose, size: Vector2, screen: Pose, screenSize: Vector2, radius: Float): Float {
        var minimum = Float.POSITIVE_INFINITY
        for (eyeX in listOf(-0.035f, 0.035f)) {
            val eye = viewer.t + viewer.right() * eyeX
            val panelDepth = (panel.t - eye).dot(panel.forward())
            for (column in 0..160) {
                val x = screenSize.x * (column / 160f - 0.5f)
                val horizontal = if (radius > 0f) {
                    screen.right() * (radius * sin(x / radius)) + screen.forward() * (radius * (cos(x / radius) - 1f))
                } else screen.right() * x
                for (row in 0..40) {
                    val point = screen.t + horizontal + screen.up() * (screenSize.y * (row / 40f - 0.5f))
                    val ray = point - eye
                    val depth = ray.dot(panel.forward())
                    if (depth <= 0.001f) continue
                    val projected = eye + ray * (panelDepth / depth) - panel.t
                    if (abs(projected.dot(panel.right())) <= size.x / 2f + 0.05f &&
                        abs(projected.dot(panel.up())) <= size.y / 2f + 0.05f
                    ) minimum = min(minimum, (point - panel.t).dot(panel.forward()))
                }
            }
        }
        return minimum
    }
}
