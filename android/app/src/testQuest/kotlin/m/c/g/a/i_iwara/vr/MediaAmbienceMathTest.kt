package m.c.g.a.i_iwara.vr

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class MediaAmbienceMathTest {
    @Test fun environmentCurveMatchesReferenceFixtures() {
        // Greys, primaries and a dark low-saturation case, each at three
        // brightness settings. Columns: r, g, b, brightness, then the result.
        val fixtures = arrayOf(
            floatArrayOf(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f),
            floatArrayOf(0.0f, 0.0f, 0.0f, 0.4f, 0.032532960176467896f, 0.032532960176467896f, 0.032532960176467896f),
            floatArrayOf(0.0f, 0.0f, 0.0f, 1.0f, 0.29042696952819824f, 0.29042696952819824f, 0.29042696952819824f),
            floatArrayOf(1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f),
            floatArrayOf(1.0f, 1.0f, 1.0f, 0.4f, 0.6567939519882202f, 0.6567939519882202f, 0.6567939519882202f),
            floatArrayOf(1.0f, 1.0f, 1.0f, 1.0f, 0.9984183311462402f, 0.9984183311462402f, 0.9984183311462402f),
            floatArrayOf(1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f),
            floatArrayOf(1.0f, 0.0f, 0.0f, 0.4f, 0.6567939519882202f, 0.3003562390804291f, 0.3003562390804291f),
            floatArrayOf(1.0f, 0.0f, 0.0f, 1.0f, 0.9984183311462402f, 0.5546768307685852f, 0.5546768307685852f),
            floatArrayOf(0.0f, 0.4f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f),
            floatArrayOf(0.0f, 0.4f, 1.0f, 0.4f, 0.3003562390804291f, 0.44293126463890076f, 0.6567939519882202f),
            floatArrayOf(0.0f, 0.4f, 1.0f, 1.0f, 0.5546768307685852f, 0.7321733832359314f, 0.9984183311462402f),
            floatArrayOf(0.25f, 0.1f, 0.05f, 0.0f, 0.0f, 0.0f, 0.0f),
            floatArrayOf(0.25f, 0.1f, 0.05f, 0.4f, 0.2552906274795532f, 0.1558675318956375f, 0.12272650003433228f),
            floatArrayOf(0.25f, 0.1f, 0.05f, 1.0f, 0.7333974242210388f, 0.4978574514389038f, 0.41934412717819214f),
            floatArrayOf(0.1f, 0.8f, 0.35f, 0.0f, 0.0f, 0.0f, 0.0f),
            floatArrayOf(0.1f, 0.8f, 0.35f, 0.4f, 0.2838476002216339f, 0.6084572076797485f, 0.3997795879840851f),
            floatArrayOf(0.1f, 0.8f, 0.35f, 1.0f, 0.5585761666297913f, 0.994156002998352f, 0.7141404151916504f),
        )
        for (row in fixtures) {
            val actual = MediaAmbienceMath.roomColor(row[0], row[1], row[2], row[3])
            for (channel in 0..2) assertEquals("${row.toList()} channel=$channel", row[channel + 4], actual[channel], 0.000002f)
        }
    }

    @Test fun brightnessUsesTheReferenceNormalizedSigmoid() {
        assertEquals(0f, MediaAmbienceMath.shaderIntensity(0f), 0.000001f)
        assertEquals(1f, MediaAmbienceMath.shaderIntensity(1f), 0.000001f)
        val middle = MediaAmbienceMath.shaderIntensity(0.4f)
        assertEquals(0.79969746f, middle, 0.000002f)
        var previous = 0f
        for (percent in 0..100) {
            val current = MediaAmbienceMath.shaderIntensity(percent / 100f)
            assertTrue(current >= previous)
            previous = current
        }
    }
}
