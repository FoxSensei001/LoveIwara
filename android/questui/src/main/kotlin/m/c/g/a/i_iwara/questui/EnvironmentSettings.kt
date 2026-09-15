package m.c.g.a.i_iwara.questui

import androidx.annotation.StringRes
import androidx.annotation.DrawableRes

/** A surrounding world, independent of the media's feathering and ambient glow. */
enum class EnvironmentKind(
    @StringRes val labelRes: Int,
    @DrawableRes val previewRes: Int,
    @StringRes val hintRes: Int,
) {
    PASSTHROUGH(R.string.xr_environment_passthrough, R.drawable.environment_passthrough, R.string.xr_background_transparency_hint),
    DEEP_SPACE(R.string.xr_environment_deep_space, R.drawable.environment_deep_space, R.string.xr_environment_deep_space_hint),
    VOID(R.string.xr_environment_void, R.drawable.environment_void, R.string.xr_environment_void_hint),
    AURORA(R.string.xr_environment_aurora, R.drawable.environment_aurora, R.string.xr_environment_aurora_hint),
    SUNSET(R.string.xr_environment_sunset, R.drawable.environment_sunset, R.string.xr_environment_sunset_hint),
    MIST(R.string.xr_environment_mist, R.drawable.environment_mist, R.string.xr_environment_mist_hint);

    val hasPanorama: Boolean get() = this != PASSTHROUGH && this != VOID
}

data class EnvironmentSettings(
    val kind: EnvironmentKind = EnvironmentKind.PASSTHROUGH,
    val spaceBrightness: Float = 0.65f,
    val dynamicSpace: Boolean = false,
    val showEarth: Boolean = true,
    val showMoon: Boolean = true,
) {
    fun normalized() = copy(spaceBrightness = MediaEffectsSettings.unitValue(spaceBrightness, 0.65f))

    // Retain the user's Earth/Moon choices when visiting another world, but do
    // not allocate their stereo surfaces outside the space environment.
    val usesOrbitalBodies: Boolean
        get() = kind == EnvironmentKind.DEEP_SPACE && dynamicSpace && (showEarth || showMoon)
}
