package m.c.g.a.i_iwara.questui

import androidx.annotation.StringRes

/** A surrounding world, independent of the media's feathering and ambient glow. */
enum class EnvironmentKind(@StringRes val labelRes: Int) {
    PASSTHROUGH(R.string.xr_environment_passthrough),
    DEEP_SPACE(R.string.xr_environment_deep_space),
}

data class EnvironmentSettings(
    val kind: EnvironmentKind = EnvironmentKind.PASSTHROUGH,
    val spaceBrightness: Float = 0.65f,
) {
    fun normalized() = copy(spaceBrightness = MediaEffectsSettings.unitValue(spaceBrightness, 0.65f))
}
