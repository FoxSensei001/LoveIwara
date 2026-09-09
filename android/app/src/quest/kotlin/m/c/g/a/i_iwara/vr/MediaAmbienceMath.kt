package m.c.g.a.i_iwara.vr

import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow

/** The two nonlinear curves the ambience is built on, shared by the shader and the panel. */
internal object MediaAmbienceMath {
    const val DEFAULT_BRIGHTNESS = 0.4f
    const val LOCAL_SCREEN_WIDTH = 1.92f
    const val LOCAL_GLOW_SIZE = 60f

    private fun sigmoid(value: Float, slope: Float, midpoint: Float): Float =
        1f / (1f + 2.7182817f.pow(-slope * (value - midpoint)))

    // The slider is not the shader's intensity. A normalised sigmoid puts the
    // visible part of the range in the middle of the travel, where it is set.
    fun shaderIntensity(brightness: Float): Float =
        ((sigmoid(brightness.coerceIn(0f, 1f), 8f, 0.2f) - 0.16798161f) / 0.8303596f).coerceIn(0f, 1f)

    // Keep the asymmetric black-level subtraction. Replacing it with a plain
    // tint or a lerp loses the relationship between room brightness and screen
    // colour, and dark scenes stop dimming the room at all.
    fun roomColor(red: Float, green: Float, blue: Float, brightness: Float): FloatArray {
        val rgb = floatArrayOf(red.coerceIn(0f, 1f), green.coerceIn(0f, 1f), blue.coerceIn(0f, 1f))
        val value = max(rgb[0], max(rgb[1], rgb[2]))
        val chroma = value - min(rgb[0], min(rgb[1], rgb[2]))
        val saturation = if (value == 0f) 0f else chroma / value
        var hue = when {
            chroma == 0f -> 0f
            value == rgb[0] -> (rgb[1] - rgb[2]) / chroma
            value == rgb[1] -> (rgb[2] - rgb[0]) / chroma + 2f
            else -> (rgb[0] - rgb[1]) / chroma + 4f
        } / 6f
        if (hue < 0f) hue += 1f
        val s = brightness.coerceIn(0f, 1f)
        val exponent = (sigmoid(s, 8f, 0.85f) - 0.0011125361f) / -0.7674122f * 0.4f + 1.2f
        val softenedSaturation = saturation * (exponent + 1f - saturation.pow(exponent)) / (exponent + 1f)
        val a = sigmoid(s, 8f, 0.4f) - 0.039165724f
        val b = sigmoid(s, 8f, 0.8f) - 0.0016588012f
        val litValue = sigmoid(value, 8f * a, 0.2f - 0.1f * b) - sigmoid(0f, 8f * a, 0.2f + b)
        val sector = hue * 6f
        val f = sector - floor(sector)
        val p = litValue * (1f - softenedSaturation)
        val q = litValue * (1f - softenedSaturation * f)
        val t = litValue * (1f - softenedSaturation * (1f - f))
        return when (floor(sector).toInt() % 6) {
            0 -> floatArrayOf(litValue, t, p)
            1 -> floatArrayOf(q, litValue, p)
            2 -> floatArrayOf(p, litValue, t)
            3 -> floatArrayOf(p, q, litValue)
            4 -> floatArrayOf(t, p, litValue)
            else -> floatArrayOf(litValue, p, q)
        }
    }
}
