package m.c.g.a.i_iwara.vr

import com.meta.spatial.core.Pose
import com.meta.spatial.core.Quaternion
import com.meta.spatial.core.Vector3
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.sin
import kotlin.math.tan

/** Viewer-relative placement. The captured frame is world-locked until an explicit recenter. */
internal object SpatialPlacement {
    const val SCREEN_CENTER_DROP_DEG = 8f
    private const val CONTROLS_DROP_DEG = 32f
    private const val DEG_TO_RAD = (Math.PI / 180.0).toFloat()
    private val WORLD_UP = Vector3(0f, 1f, 0f)

    fun viewFrame(head: Pose): Pose = frame(head.t, head.forward(), head.up())

    /** No Euler decomposition, guessed quaternion order, or abrupt switch of up at the poles. */
    fun frame(origin: Vector3, forward: Vector3, viewerUp: Vector3, dropDegrees: Float = 0f): Pose {
        val f0 = unit(forward, Vector3(0f, 0f, 1f))
        val levelUp = WORLD_UP - f0 * WORLD_UP.dot(f0)
        val projectedViewerUp = viewerUp - f0 * viewerUp.dot(f0)
        val fallback = if (abs(f0.y) < 0.9f) WORLD_UP else Vector3(0f, 0f, -1f)
        val headUp = unit(projectedViewerUp, unit(fallback - f0 * fallback.dot(f0), Vector3(1f, 0f, 0f)))
        val t = ((abs(f0.y) - 0.75f) / 0.23f).coerceIn(0f, 1f)
        val blend = t * t * (3f - 2f * t)
        val upright = unit(levelUp, headUp)
        val upReference = unit(upright * (1f - blend) + headUp * blend, headUp)
        val right = unit(upReference.cross(f0), Vector3(1f, 0f, 0f))
        val up0 = f0.cross(right).normalize()
        val drop = dropDegrees * DEG_TO_RAD
        val f = f0 * cos(drop) - up0 * sin(drop)
        val up = up0 * cos(drop) + f0 * sin(drop)
        return Pose(origin, Quaternion.fromDirection(f, up).normalize())
    }

    /** Lower the center, then face the actual viewing position without adding a separate tilt. */
    fun screenSurface(frame: Pose, distance: Float, offset: Float = 0f): Pose {
        val center = frame.t + frame.forward() * distance +
            frame.up() * (-distance * tan(SCREEN_CENTER_DROP_DEG * DEG_TO_RAD) + offset)
        return facingSurface(Pose(center, frame.q), frame)
    }

    /** Summoned controls use the requested downward bearing, independent of panel size. */
    fun controlsSurface(frame: Pose, distance: Float): Pose {
        val drop = CONTROLS_DROP_DEG * DEG_TO_RAD
        val direction = frame.forward() * cos(drop) - frame.up() * sin(drop)
        val center = frame.t + direction * distance
        return Pose(center, Quaternion.fromDirection(direction, frame.up()).normalize())
    }

    /** Move along the bearing seen by the current viewer, independent of the entry anchor. */
    fun atDistance(surface: Pose, viewer: Pose, distance: Float): Pose {
        val delta = surface.t - viewer.t
        val length = delta.length()
        if (!length.isFinite() || length < 0.05f) return surface
        return facingSurface(Pose(viewer.t + delta * (distance / length), surface.q), viewer)
    }

    /** The SDK FACE contract: both pitch and yaw point at the current eyes; there is no stored tilt. */
    fun facingSurface(surface: Pose, viewer: Pose): Pose {
        val direction = surface.t - viewer.t
        if (direction.length() < 0.05f) return surface
        return frame(surface.t, direction, viewer.up())
    }

    /** Restore saved controls near the preferred downward bearing. */
    fun controlsInView(surface: Pose, frame: Pose): Boolean {
        val delta = surface.t - frame.t
        val forward = delta.dot(frame.forward())
        if (forward < 0.05f) return false
        val down = -delta.dot(frame.up()) / forward
        val minimumDown = tan((CONTROLS_DROP_DEG - 12f) * DEG_TO_RAD)
        val maximumDown = tan((CONTROLS_DROP_DEG + 6f) * DEG_TO_RAD)
        return down in minimumDown..maximumDown &&
            abs(delta.dot(frame.right())) <= forward * tan(50f * DEG_TO_RAD)
    }

    fun isTracked(head: Pose?): Boolean = head != null &&
        head.t.x.isFinite() && head.t.y.isFinite() && head.t.z.isFinite() &&
        head.t.length() >= 0.05f && hasOrientation(head)

    /**
     * 3DoF（暗光 / 用户点了「继续，不追踪」）：位置钉在原点附近，但朝向仍是真的。
     * 渲染相机就在这个位置上，所以按它摆才对得上用户的眼睛 —— 自己编一个 1.6m 眼高才会整体仰视。
     */
    fun hasOrientation(head: Pose?): Boolean = head != null &&
        head.t.x.isFinite() && head.t.y.isFinite() && head.t.z.isFinite() &&
        head.q.norm().isFinite() && head.q.norm() > 0.5f

    private fun unit(v: Vector3, fallback: Vector3): Vector3 {
        val length = v.length()
        return if (length.isFinite() && length > 1e-5f) v / length else fallback
    }
}

/** Shared by initial entry and recenter; a non-null first tracking frame is not a settled pose. */
internal class HeadPoseReadiness {
    private var validFrames = 0
    private var ticks = 0
    val ready: Boolean get() = validFrames >= 8
    val timedOut: Boolean get() = ticks >= 120

    fun update(head: Pose?) {
        ticks++
        validFrames = if (SpatialPlacement.isTracked(head)) (validFrames + 1).coerceAtMost(8) else 0
    }

    fun reset() {
        validFrames = 0
        ticks = 0
    }
}

/** Rates use elapsed time, so hands and sticks feel the same at 72, 90 and 120 Hz. */
internal object ViewDistanceMotion {
    fun flatFactor(direction: Int, seconds: Float): Float = exp(direction.coerceIn(-1, 1) * 0.45f * seconds.coerceIn(0f, 0.05f))
    fun sphereDelta(direction: Int, seconds: Float): Float = direction.coerceIn(-1, 1) * 8f * seconds.coerceIn(0f, 0.05f)
}
