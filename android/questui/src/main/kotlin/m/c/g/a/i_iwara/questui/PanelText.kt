package m.c.g.a.i_iwara.questui

import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource

/**
 * 需要**拼**出来的面板文案。
 *
 * 单个词直接在调用点 `stringResource(...)` 就行；这里只放「大类 · 具体格式」这种
 * 由多条资源拼起来、又在两处以上用到的。拼接必须走带占位符的资源
 * （`xr_format_short_flat` = `平面 · %1$s`），不要在 Kotlin 里用 `"$a · $b"` ——
 * 分隔符与语序在别的语言里未必一样。
 */

/** 走带行右侧那枚钮上的短标签，例如「平面 · 3D HSBS」。 */
@Composable
fun VideoFormat.shortLabel(): String {
    val label = stringResource(labelRes)
    return when (tab) {
        FormatTab.FLAT -> stringResource(R.string.xr_format_short_flat, label)
        FormatTab.PANORAMA -> label
        FormatTab.EAC -> stringResource(R.string.xr_format_short_eac, label)
        FormatTab.FISHEYE -> stringResource(R.string.xr_format_short_fisheye, label)
    }
}
