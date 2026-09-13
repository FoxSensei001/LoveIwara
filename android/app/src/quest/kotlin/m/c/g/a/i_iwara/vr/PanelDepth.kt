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
    private const val MAX_POINTS = 16
    private val bufA = FloatArray(MAX_POINTS * 3)
    private val bufB = FloatArray(MAX_POINTS * 3)

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
            val p0 = left - vertical
            bufA[0] = p0.x
            bufA[1] = p0.y
            bufA[2] = p0.z
            val p1 = next - vertical
            bufA[3] = p1.x
            bufA[4] = p1.y
            bufA[5] = p1.z
            val p2 = next + vertical
            bufA[6] = p2.x
            bufA[7] = p2.y
            bufA[8] = p2.z
            val p3 = left + vertical
            bufA[9] = p3.x
            bufA[10] = p3.y
            bufA[11] = p3.z
            var count = 4
            count = clip(bufA, count, bufB, 0, 1f, bounds.x)
            count = clip(bufB, count, bufA, 0, -1f, bounds.x)
            count = clip(bufA, count, bufB, 1, 1f, bounds.y)
            count = clip(bufB, count, bufA, 1, -1f, bounds.y)
            count = clip(bufA, count, bufB, 2, -1f, 0f)
            for (i in 0 until count) nearest = min(nearest, bufB[i * 3 + 2] - CURVE_ERROR_M)
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
    private fun clip(src: FloatArray, count: Int, dst: FloatArray, axis: Int, sign: Float, bound: Float): Int {
        if (count == 0) return 0
        var outCount = 0
        val lastOffset = (count - 1) * 3
        var prevX = src[lastOffset]
        var prevY = src[lastOffset + 1]
        var prevZ = src[lastOffset + 2]
        var previousDistance = sign * src[lastOffset + axis] - bound
        for (i in 0 until count) {
            val currOffset = i * 3
            val currX = src[currOffset]
            val currY = src[currOffset + 1]
            val currZ = src[currOffset + 2]
            val currentDistance = sign * src[currOffset + axis] - bound
            if ((previousDistance <= 0f) != (currentDistance <= 0f)) {
                val fraction = previousDistance / (previousDistance - currentDistance)
                val outOffset = outCount * 3
                dst[outOffset] = prevX + (currX - prevX) * fraction
                dst[outOffset + 1] = prevY + (currY - prevY) * fraction
                dst[outOffset + 2] = prevZ + (currZ - prevZ) * fraction
                outCount++
            }
            if (currentDistance <= 0f) {
                val outOffset = outCount * 3
                dst[outOffset] = currX
                dst[outOffset + 1] = currY
                dst[outOffset + 2] = currZ
                outCount++
            }
            prevX = currX
            prevY = currY
            prevZ = currZ
            previousDistance = currentDistance
        }
        return outCount
    }
}
