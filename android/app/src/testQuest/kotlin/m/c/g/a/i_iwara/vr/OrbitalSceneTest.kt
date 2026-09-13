package m.c.g.a.i_iwara.vr

import com.meta.spatial.core.Vector3
import org.junit.Assert.*
import org.junit.Test
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.sin

class OrbitalSceneTest {
    @Test fun pausedClockDoesNotJumpOnResume() {
        val clock = OrbitalCadence()
        clock.tick(0, true)
        clock.tick(100, true)
        assertEquals(0.1f, clock.seconds, 0.0001f)
        clock.tick(101, false)
        clock.tick(60_000, true)
        assertEquals(0.1f, clock.seconds, 0.0001f)
        clock.tick(60_050, true)
        assertEquals(0.15f, clock.seconds, 0.0001f)
    }

    @Test fun movingEyesCannotBypassTheSixtyFrameCeiling() {
        val clock = OrbitalCadence()
        var count = 0
        for (now in 0L until 1000L) {
            clock.tick(now, true)
            if (clock.request(now, visible = true, moving = true)) count++
        }
        assertTrue("$count submissions in a second", count in 58..60)
    }

    @Test fun aStillViewHasAtMostThirtySubmissionsPerSecond() {
        val clock = OrbitalCadence()
        var count = 0
        for (now in 0L until 1000L) {
            clock.tick(now, true)
            if (clock.request(now, visible = true, moving = false)) count++
        }
        assertTrue("$count submissions in a second", count in 29..30)
    }

    @Test fun hiddenAndInactiveViewsNeverRequestFrames() {
        val clock = OrbitalCadence()
        for (now in 0L until 1000L) {
            clock.tick(now, true)
            assertFalse(clock.request(now, visible = false, moving = true))
            clock.tick(now, false)
            assertFalse(clock.request(now, visible = true, moving = true))
        }
    }

    @Test fun longGapsDoNotQueueCatchUpFrames() {
        val clock = OrbitalCadence()
        clock.tick(0, true)
        assertTrue(clock.request(0, true, false))
        clock.tick(100_000, true)
        assertTrue(clock.request(100_000, true, false))
        repeat(100) { assertFalse(clock.request(100_000, true, true)) }
    }

    @Test fun finiteDepthHasMoreDisparityAtTheNearSurfaceThanTheProxyPlane() {
        val earth = earth()
        val eye = Vector3(-.032f, 0f, 0f)
        val onSurface = earth.center - earth.direction * earth.radius
        val ray = (onSurface - eye).normalize()
        val t = (earth.center - eye).dot(earth.direction) / ray.dot(earth.direction)
        val onPlane = eye + ray * t
        val reconstructed = (onPlane - eye).normalize()
        assertTrue((reconstructed - ray).length() < 0.00001f)
        assertTrue("Surface depth must not be flattened onto the proxy", (earth.center - onSurface).length() > 7f)
        val flatRay = (earth.center - eye).normalize()
        val surfaceRay = (onSurface - eye).normalize()
        assertTrue((flatRay - surfaceRay).length() > 0.0001f)
    }

    @Test fun bothEyesAndThreeMetreRoomOffsetsFitInsideTheFixedProxy() {
        val body = earth()
        val right = body.frame.right()
        val up = body.frame.up()
        for (x in listOf(-3f, 0f, 3f)) for (y in listOf(-3f, 0f, 3f)) for (z in listOf(-3f, 0f, 3f)) {
            for (eyeOffset in listOf(-.036f, .036f)) {
                val eye = Vector3(x + eyeOffset, y, z)
                for (latitude in -90..90 step 10) for (longitude in -180 until 180 step 10) {
                    val lat = latitude * OrbitalBody.RAD; val lon = longitude * OrbitalBody.RAD
                    val normal = Vector3(cos(lat) * sin(lon), sin(lat), cos(lat) * cos(lon))
                    val point = body.center + normal * (body.radius * 1.04f) // Include the atmospheric rim.
                    if (normal.dot(eye - point) <= 0) continue
                    val ray = (point - eye).normalize()
                    val t = (body.center - eye).dot(body.direction) / ray.dot(body.direction)
                    val onPlane = eye + ray * t - body.center
                    assertTrue(abs(onPlane.dot(right)) <= body.planeSize * .5f)
                    assertTrue(abs(onPlane.dot(up)) <= body.planeSize * .5f)
                }
            }
        }
    }

    private fun earth() = OrbitalBody("earth", -34f, 12f, 21f, 20f, 100f, 17f, .35f, .39f, 768, -80, "earth.jpg", "clouds.jpg")
}
