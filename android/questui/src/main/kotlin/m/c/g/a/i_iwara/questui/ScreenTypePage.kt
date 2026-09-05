package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.button.TextTileButton
import com.meta.spatial.uiset.control.SpatialSwitch
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.Television
import com.meta.spatial.uiset.theme.icons.regular.WidthExtrawide
import com.meta.spatial.uiset.theme.icons.regular.WidthMedium
import com.meta.spatial.uiset.theme.icons.regular.WidthWide

/**
 * 屏幕类型页：**幕布弯曲程度** + **3D 视频显示**。
 *
 * # 为什么要弯
 *
 * 曲率半径 = 观看距离时，每个像素到眼**等距** —— 没有梯形畸变、没有边缘离焦，
 * 转脖子的幅度也比「一堵平墙大屏」小。这就是 IMAX 的环抱感（设计文档 §6.6 模式 A）。
 *
 * # ⚠️ 曲面部分压在一个**未验证**的能力上
 *
 * `CylinderShapeOptions` 在类型系统上是合法的媒体面板形状
 * （`CylinderShapeOptions : MediaPanelShapeOptions`，本机 aar 逐字核过），
 * **但官方 `spatial-sdk-media-playback` 列的媒体面板形状只有
 * Quad / Equirect180 / Equirect360，没有 Cylinder**，且官方自家 Media View 样例里的
 * 弯屏视频用的是自建 `SceneMesh.cylinderSurface(...)`。
 *
 * ⛔ **能编译 ≠ 官方支持。** 这里全部四档都画出来，实机若某档翻车退化到直面屏。
 *
 * # ⛔ 「左右眼互换」本机做不了，不要做
 *
 * 需求文档写明。SDK 的 `StereoMode` 没有「swap」参数；要做只能自建 `SceneMesh`
 * 并在 shader 里换 UV，那不是这一期的活儿。「强制以 2D 方式显示 3D 视频」是够用
 * 的兜底 —— 若立体编排猜错、看着头晕，直接压回 2D 起码画面不会串。
 */
@Composable
fun ScreenTypePage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    val scroll = rememberScrollState()
    Column(
        modifier = Modifier
            .fillMaxSize()
            .reportPanelTouches(cb)
            .panelScrollbar(scroll).verticalScroll(scroll),
        verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
    ) {
        PageHeader(
            title = stringResource(R.string.xr_screen_type_title),
            subtitle = stringResource(R.string.xr_screen_type_subtitle),
            onBack = { cb.onRoute(ControlsRoute.PLAYER) },
        )

        // ── 弯曲程度 ────────────────────────────
        Row(
            modifier = Modifier.fillMaxWidth().height(112.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            CurveTile(ScreenCurve.FLAT, R.string.xr_curve_flat_hint, SpatialIcons.Regular.Television, state, cb)
            CurveTile(ScreenCurve.SLIGHT, R.string.xr_curve_slight_hint, SpatialIcons.Regular.WidthMedium, state, cb)
            CurveTile(ScreenCurve.MEDIUM, R.string.xr_curve_medium_hint, SpatialIcons.Regular.WidthWide, state, cb)
            CurveTile(ScreenCurve.DEEP, R.string.xr_curve_deep_hint, SpatialIcons.Regular.WidthExtrawide, state, cb)
        }

        // ⚠️ 换形状 = 重建幕布，是官方限制不是我们偷懒：`settingsCreator` **只在实体
        // 创建时跑一次**，SDK 没有「运行时热换形状」的 API。用户会看到一次约 0.3–0.8s
        // 的接缝，进度会接回原处。如实写在界面上，别让人以为是卡了。
        Text(
            text = stringResource(R.string.xr_curve_rebuild_note),
            color = PanelTokens.ON_SURFACE_DIM,
            fontSize = 14.sp,
        )

        // ── 3D 视频显示 ─────────────────────────
        SectionLabel(stringResource(R.string.xr_section_3d_display))

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = stringResource(R.string.xr_force_mono),
                    color = if (state.format.isStereo) PanelTokens.ON_SURFACE else PanelTokens.ON_SURFACE_DIM,
                    fontSize = 16.sp,
                )
                Text(
                    text = stringResource(
                        if (state.format.isStereo) {
                            R.string.xr_force_mono_hint_stereo
                        } else {
                            R.string.xr_force_mono_hint_mono
                        },
                    ),
                    color = PanelTokens.ON_SURFACE_DIM,
                    fontSize = 13.sp,
                )
            }
            SpatialSwitch(
                checked = state.forceMono,
                onCheckedChange = { cb.onToggleForceMono() },
                enabled = state.format.isStereo,
            )
        }
    }
}

@Composable
private fun androidx.compose.foundation.layout.RowScope.CurveTile(
    curve: ScreenCurve,
    @androidx.annotation.StringRes hintRes: Int,
    icon: ImageVector,
    state: VideoControlsState,
    cb: VideoControlsCallbacks,
) {
    TextTileButton(
        label = stringResource(curve.labelRes),
        secondaryLabel = stringResource(hintRes),
        icon = { Icon(icon, null) },
        selected = state.curve == curve,
        onSelectionChange = { cb.onPickCurve(curve) },
        modifier = Modifier.weight(1f),
    )
}
