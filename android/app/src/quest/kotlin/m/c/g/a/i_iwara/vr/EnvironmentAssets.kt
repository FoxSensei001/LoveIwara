package m.c.g.a.i_iwara.vr

import m.c.g.a.i_iwara.questui.EnvironmentKind
import m.c.g.a.i_iwara.questui.EnvironmentSettings

/** Null means no panorama allocation, including the explicit black viewing space. */
internal fun environmentAsset(settings: EnvironmentSettings): String? = when (settings.kind) {
    EnvironmentKind.PASSTHROUGH, EnvironmentKind.VOID -> null
    EnvironmentKind.AURORA -> "environments/aurora.png"
    EnvironmentKind.SUNSET -> "environments/sunset.png"
    EnvironmentKind.MIST -> "environments/mist.png"
    EnvironmentKind.DEEP_SPACE -> when {
        settings.dynamicSpace || (!settings.showEarth && !settings.showMoon) -> "environments/stars.png"
        settings.showEarth && settings.showMoon -> "environments/deep_space.png"
        settings.showEarth -> "environments/deep_space_earth.png"
        else -> "environments/deep_space_moon.png"
    }
}
