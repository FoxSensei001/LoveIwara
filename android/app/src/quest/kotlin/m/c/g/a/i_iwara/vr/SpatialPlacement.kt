package m.c.g.a.i_iwara.vr

import com.meta.spatial.core.Pose
import com.meta.spatial.core.Quaternion
import com.meta.spatial.core.Vector3
import kotlin.math.abs
import kotlin.math.atan
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.max
import kotlin.math.sin
import kotlin.math.tan

/** Viewer-relative placement. The captured frame is world-locked until an explicit recenter. */
internal object SpatialPlacement {
    const val SCREEN_CENTER_DROP_DEG = 8f
    private const val CONTROLS_DROP_DEG = 32f
    private const val CONTROLS_TOP_DROP_DEG = 30f
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

    /** Keep the main viewing area below neutral gaze; tall content must not push its center overhead. */
    fun screenSurface(frame: Pose, distance: Float, offset: Float = 0f): Pose {
        val center = frame.t + frame.forward() * distance +
            frame.up() * (-distance * tan(SCREEN_CENTER_DROP_DEG * DEG_TO_RAD) + offset)
        return Pose(center, Quaternion.fromDirection(center - frame.t, frame.up()).normalize())
    }

    /** A gently tilted desk below the screen, including clearance for a user-resized control panel. */
    fun controlsSurface(frame: Pose, distance: Float, height: Float): Pose {
        val drop = max(
            CONTROLS_DROP_DEG * DEG_TO_RAD,
            CONTROLS_TOP_DROP_DEG * DEG_TO_RAD + atan(height / (2f * distance)),
        )
        val direction = frame.forward() * cos(drop) - frame.up() * sin(drop)
        val center = frame.t + direction * distance
        return Pose(center, Quaternion.fromDirection(direction, frame.up()).normalize())
    }

    fun isTracked(head: Pose?): Boolean = head != null &&
        head.t.x.isFinite() && head.t.y.isFinite() && head.t.z.isFinite() &&
        head.t.length() >= 0.05f && head.q.norm().isFinite() && head.q.norm() > 0.5f

    private fun unit(v: Vector3, fallback: Vector3): Vector3 {
        val length = v.length()
        return if (length.isFinite() && length > 1e-5f) v / length else fallback
    }
}

/** No jump at touch-down; real movement progressively aligns the surface with the viewer. */
internal class GrabOrientation(private val initial: Quaternion, facingAtGrab: Quaternion?) {
    private val offset = facingAtGrab?.let { it.inverse() * initial }
    private var distanceMoved = 0f
    private var last = initial

    fun at(facingNow: Quaternion?, displacement: Float = 0f): Quaternion {
        if (facingNow == null) return last
        distanceMoved = max(distanceMoved, displacement)
        val t = ((distanceMoved - 0.005f) / 0.15f).coerceIn(0f, 1f)
        val blend = t * t * (3f - 2f * t)
        val preserved = offset?.let { facingNow * it } ?: initial
        last = preserved.slerp(facingNow, blend).normalize()
        return last
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
