package m.c.g.a.i_iwara.questui

/** Viewing preferences shared by videos, photos and animated gallery images. */
data class MediaEffectsSettings(
    val enabled: Boolean = true,
    val edgeFeather: Float = DEFAULT_EDGE_FEATHER,
    /** Reference brightness control: spread, intensity and room colour move together. */
    val glowStrength: Float = DEFAULT_GLOW_STRENGTH,
    /**
     * Room visibility in the passthrough environment: 0 = black, 1 = the lit room.
     * Retained when switching environments so returning restores the user's room setting.
     */
    val backgroundTransparency: Float = 1f,
) {
    fun normalized() = copy(
        edgeFeather = unitValue(edgeFeather, DEFAULT_EDGE_FEATHER),
        glowStrength = unitValue(glowStrength, DEFAULT_GLOW_STRENGTH),
        backgroundTransparency = unitValue(backgroundTransparency, 1f),
    )

    val feather: Float get() = if (enabled) edgeFeather else 0f
    val glow: Float get() = if (enabled) glowStrength else 0f

    companion object {
        /** 氛围模式默认值（用户 2026-09-14 指定）：边缘柔化 40%、光晕范围与强度 23%。 */
        const val DEFAULT_EDGE_FEATHER = 0.4f
        const val DEFAULT_GLOW_STRENGTH = 0.23f

        fun unitValue(value: Float, fallback: Float): Float =
            if (value.isFinite()) value.coerceIn(0f, 1f) else fallback
    }
}
