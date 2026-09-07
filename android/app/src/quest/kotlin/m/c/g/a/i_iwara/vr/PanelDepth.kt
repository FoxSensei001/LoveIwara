package m.c.g.a.i_iwara.vr

import com.meta.spatial.core.Pose
import com.meta.spatial.core.Vector2
import com.meta.spatial.core.Vector3
import kotlin.math.abs
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin
import kotlin.math.sqrt

/** Keeps native scene cursors in front of the same content as their compositor panel. */
internal object PanelDepth {
    // Include the 5cm manipulation ring, cursor radius, and both eyes' viewing rays.
    private const val BOUNDS_PADDING_M = 0.09f
    private const val CURVE_ERROR_M = 0.001f
    private const val MIN_DISTANCE_M = 0.15f

    fun inFrontOfScreen(
        panel: Pose,
        panelSize: Vector2,
        viewer: Pose,
        screen: Pose,
        screenSize: Vector2,
        radius: Float,
        gap: Float,
    ): Pose {
        val delta = panel.t - viewer.t
        val distance = delta.length()
        if (!distance.isFinite() || distance < MIN_DISTANCE_M) return panel
        val facing = SpatialPlacement.facingSurface(panel, viewer)
        val right = facing.right()
        val up = facing.up()
        val forward = facing.forward()
        val halfWidth = panelSize.x / 2f + BOUNDS_PADDING_M
        val halfHeight = panelSize.y / 2f + BOUNDS_PADDING_M
        // Include both the current orientation and the one used after a depth adjustment.
        val extentX = max(halfWidth,
            abs(panel.right().dot(right)) * halfWidth + abs(panel.up().dot(right)) * halfHeight)
        val extentY = max(halfHeight,
            abs(panel.right().dot(up)) * halfWidth + abs(panel.up().dot(up)) * halfHeight)
        val extentZ = abs(panel.right().dot(forward)) * halfWidth + abs(panel.up().dot(forward)) * halfHeight
        val bounds = Vector2(extentX + CURVE_ERROR_M, extentY + CURVE_ERROR_M)

        fun local(point: Vector3): Vector3 {
            val offset = point - viewer.t
            return Vector3(offset.dot(right), offset.dot(up), offset.dot(forward))
        }

        val center = local(screen.t)
        val screenRight = Vector3(screen.right().dot(right), screen.right().dot(up), screen.right().dot(forward))
        val screenUp = Vector3(screen.up().dot(right), screen.up().dot(up), screen.up().dot(forward))
        val screenForward = Vector3(screen.forward().dot(right), screen.forward().dot(up), screen.forward().dot(forward))
        val vertical = screenUp * (screenSize.y / 2f)
        val sagitta = if (radius > 0f) radius * (1f - cos(screenSize.x / (2f * radius))) else 0f
        val minimumPossibleDepth = center.z - abs(screenRight.z) * screenSize.x / 2f -
            abs(vertical.z) - abs(screenForward.z) * sagitta - CURVE_ERROR_M
        // Most frames have a distant screen. Avoid polygon clipping in that common case.
        if (minimumPossibleDepth >= distance + extentZ + gap) return panel
        // The chord error is at most ds² / (8r). Inflate the clip bounds and subtract the
        // same error from depth, so tessellation cannot leave the actual curve ahead of us.
        val segments = if (radius > 0f) max(1, ceil(screenSize.x / sqrt(8f * radius * CURVE_ERROR_M)).toInt()) else 1
        fun edge(index: Int): Vector3 {
            val x = screenSize.x * (index.toFloat() / segments - 0.5f)
            return if (radius > 0f) {
                val angle = x / radius
                center + screenRight * (radius * sin(angle)) + screenForward * (radius * (cos(angle) - 1f))
            } else center + screenRight * x
        }

        var nearest = Float.POSITIVE_INFINITY
        var left = edge(0)
        for (index in 1..segments) {
            val next = edge(index)
            // Every eye-to-panel ray stays inside this rectangular prism. Only screen
            // geometry within it can hide a cursor; off-to-the-side screens do not pull UI in.
            var polygon = listOf(left - vertical, next - vertical, next + vertical, left + vertical)
            polygon = clip(polygon, 0, 1f, bounds.x)
            polygon = clip(polygon, 0, -1f, bounds.x)
            polygon = clip(polygon, 1, 1f, bounds.y)
            polygon = clip(polygon, 1, -1f, bounds.y)
            polygon = clip(polygon, 2, -1f, 0f)
            for (point in polygon) nearest = min(nearest, point.z - CURVE_ERROR_M)
            left = next
        }
        val limit = nearest - gap
        if (distance + extentZ <= limit) return panel
        // A fixed 45cm floor can itself put the controls behind a screen brought closer
        // than 60cm. Preserve the bearing and use the available depth down to the near limit.
        val targetDistance = min(distance, limit.coerceAtLeast(MIN_DISTANCE_M))
        return Pose(viewer.t + forward * targetDistance, facing.q)
    }

    /** Clip a convex polygon against sign * coordinate <= bound. */
    private fun clip(points: List<Vector3>, axis: Int, sign: Float, bound: Float): List<Vector3> {
        if (points.isEmpty()) return points
        fun distance(point: Vector3): Float = sign * when (axis) {
            0 -> point.x
            1 -> point.y
            else -> point.z
        } - bound
        val result = ArrayList<Vector3>(points.size + 1)
        var previous = points.last()
        var previousDistance = distance(previous)
        for (point in points) {
            val currentDistance = distance(point)
            if ((previousDistance <= 0f) != (currentDistance <= 0f)) {
                val fraction = previousDistance / (previousDistance - currentDistance)
                result.add(previous + (point - previous) * fraction)
            }
            if (currentDistance <= 0f) result.add(point)
            previous = point
            previousDistance = currentDistance
        }
        return result
    }
}
