package m.c.g.a.i_iwara.vr

import android.content.res.AssetManager
import com.meta.spatial.core.Vector3
import org.json.JSONObject
import kotlin.math.cos
import kotlin.math.sin

/** Asset-authored composition. Distances are deliberately finite to provide stereo depth. */
internal data class OrbitalBody(
    val name: String, val yaw: Float, val pitch: Float, val angle: Float, val distance: Float,
    val longitude: Float, val latitude: Float, val spin: Float, val cloudSpin: Float,
    val eyePixels: Int, val zIndex: Int, val surface: String, val clouds: String?,
) {
    val direction = Vector3(sin(yaw * RAD) * cos(pitch * RAD), sin(pitch * RAD), cos(yaw * RAD) * cos(pitch * RAD))
    val center = direction * distance
    val radius = distance * sin(angle * RAD)
    // Fixed world-space proxy: never track the head with this plane. Its image
    // is recomputed from actual eye origins, including the sphere's own depth.
    val planeSize = 2f * radius / cos(angle * RAD) * 1.25f
    val frame = SpatialPlacement.frame(center, direction, Vector3(0f, 1f, 0f))
    private val facing = -direction
    private val up = (Vector3(0f, 1f, 0f) - facing * facing.y).normalize()
    val north = up * cos(latitude * RAD) + facing * sin(latitude * RAD)
    val meridian = facing * cos(latitude * RAD) - up * sin(latitude * RAD)
    val east = meridian.cross(north)

    companion object { const val RAD = 0.017453292519943295f }
}

internal data class OrbitalScene(val maxFps: Int, val motionFps: Int, val bodies: List<OrbitalBody>) {
    companion object {
        fun load(assets: AssetManager): OrbitalScene {
            val json = JSONObject(assets.open("environments/scene.json").bufferedReader().use { it.readText() })
            val list = json.getJSONArray("bodies")
            require(list.length() == 2)
            val bodies = (0 until list.length()).map { index ->
                val body = list.getJSONObject(index)
                fun number(key: String) = body.getDouble(key).toFloat().also { require(it.isFinite()) }
                OrbitalBody(body.getString("name"), number("yaw"), number("pitch"), number("angle"), number("distance"),
                    number("longitude"), number("latitude"), number("spin"), number("cloudSpin"),
                    body.getInt("eyePixels"), body.getInt("zIndex"), body.getString("surface"), body.optString("clouds").ifEmpty { null })
                    .also {
                        require(it.eyePixels in 128..1024 && it.zIndex in -99..-2)
                        require(it.distance >= 15f && it.angle in 1f..30f && it.pitch in -60f..60f)
                        require(it.surface.matches(Regex("[a-z]+\\.jpg")))
                        require(it.clouds == null || it.clouds.matches(Regex("[a-z]+\\.jpg")))
                    }
            }
            return OrbitalScene(json.getInt("maxFps").coerceIn(1, 30), json.getInt("motionFps").coerceIn(30, 60), bodies)
        }
    }
}

/** No catch-up bursts, no clock jump after a pause, and no unbounded time uniforms. */
internal class OrbitalCadence(private val idleFps: Int = 30, private val movingFps: Int = 60) {
    private var lastAt: Long? = null
    private var activeBefore = false
    private var elapsedMs = 0L
    private var lastDrawAt = Double.NEGATIVE_INFINITY
    private var fastUntil = 0L
    val seconds: Float get() = elapsedMs / 1000f

    fun tick(now: Long, active: Boolean) {
        if (active && activeBefore) elapsedMs = (elapsedMs + (now - (lastAt ?: now)).coerceIn(0, 100)) % 36_000_000L
        lastAt = now
        activeBefore = active
        if (!active) lastDrawAt = Double.NEGATIVE_INFINITY
    }

    fun request(now: Long, visible: Boolean, moving: Boolean): Boolean {
        if (!activeBefore || !visible) return false
        if (moving) fastUntil = now + 250L
        val interval = 1000.0 / if (now < fastUntil) movingFps else idleFps
        if (now - lastDrawAt < interval) return false
        lastDrawAt = now.toDouble()
        return true
    }
}
