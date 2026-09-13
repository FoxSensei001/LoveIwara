package m.c.g.a.i_iwara.questui

/** Viewing preferences shared by videos, photos and animated gallery images. */
data class MediaEffectsSettings(
    val enabled: Boolean = true,
    val edgeFeather: Float = 1f,
    /** Reference brightness control: spread, intensity and room colour move together. */
    val glowStrength: Float = 0.4f,
    /**
     * Room visibility in the passthrough environment: 0 = black, 1 = the lit room.
     * Retained when switching environments so returning restores the user's room setting.
     */
    val backgroundTransparency: Float = 1f,
) {
    fun normalized() = copy(
        edgeFeather = unitValue(edgeFeather, 1f),
        glowStrength = unitValue(glowStrength, 0.4f),
        backgroundTransparency = unitValue(backgroundTransparency, 1f),
    )

    val feather: Float get() = if (enabled) edgeFeather else 0f
    val glow: Float get() = if (enabled) glowStrength else 0f

    companion object {
        fun unitValue(value: Float, fallback: Float): Float =
            if (value.isFinite()) value.coerceIn(0f, 1f) else fallback
    }
}
