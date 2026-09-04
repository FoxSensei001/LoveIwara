package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.button.TextTileButton
import com.meta.spatial.uiset.slider.SpatialSliderMedium
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.Television
import com.meta.spatial.uiset.theme.icons.regular.WidthExtrawide
import com.meta.spatial.uiset.theme.icons.regular.WidthMedium
import com.meta.spatial.uiset.theme.icons.regular.WidthWide

/**
 * 屏幕类型页：幕布的弯曲程度。对应参考软件 ref_06（直面屏 / 微曲面 / 中曲面 / 重曲面）。
 *
 * # 为什么要弯
 *
 * 曲率半径 = 观看距离时，每个像素到眼**等距** —— 没有梯形畸变、没有边缘离焦，
 * 转脖子的幅度也比「一堵平墙大屏」小。这就是 IMAX 的环抱感（设计文档 §6.6 模式 A）。
 *
 * # ⚠️ 这一页整个压在一个**未验证**的能力上
 *
 * `CylinderShapeOptions` 在类型系统上是合法的媒体面板形状
 * （`CylinderShapeOptions : MediaPanelShapeOptions`，本机 aar 逐字核过），
 * **但官方 `spatial-sdk-media-playback` 列的媒体面板形状只有
 * Quad / Equirect180 / Equirect360，没有 Cylinder**，且官方自家 Media View 样例里的
 * 弯屏视频用的是自建 `SceneMesh.cylinderSurface(...)`。
 *
 * ⛔ **能编译 ≠ 官方支持。** 所以：
 * - [ScreenCurve.FLAT] 永远走 `QuadShapeOptions`，是保证能用的那一档，也是默认；
 * - 三档曲面是**待真机验证**的东西，验不过就把它们藏起来，主路径不受影响。
 *
 * # ⛔ 球幕模式下这一页没有意义
 *
 * 180/360 时人在球心，弯的是整个世界，没有「屏幕」可言。这时整页禁用
 * （[VideoControlsState.curveAvailable] = false，入口钮也会灰掉）。
 */
@Composable
fun ScreenTypePage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
    ) {
        PageHeader(
            title = "屏幕类型",
            subtitle = if (state.curveAvailable) {
                "弯曲程度。曲率半径跟着观看距离走，画面到眼等距"
            } else {
                "球幕模式没有「屏幕」—— 人在球心，弯的是整个世界"
            },
            onBack = { cb.onRoute(ControlsRoute.PLAYER) },
        )

        // ⛔ 球幕时整排**不建**，而不是建出来再灰掉：`TextTileButton` 根本没有
        // `isEnabled` 参数（本机 aar 核过，官方文档把它列在「common parameters」里是
        // 不准的），灰不掉的选项点下去就会真的生效。
        if (state.curveAvailable) {
            Row(
                modifier = Modifier.fillMaxWidth().height(112.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                CurveTile(ScreenCurve.FLAT, "一块平幕", SpatialIcons.Regular.Television, state, cb)
                CurveTile(ScreenCurve.SLIGHT, "40° 弧", SpatialIcons.Regular.WidthMedium, state, cb)
                CurveTile(ScreenCurve.MEDIUM, "60° 弧", SpatialIcons.Regular.WidthWide, state, cb)
                CurveTile(ScreenCurve.DEEP, "85° 弧", SpatialIcons.Regular.WidthExtrawide, state, cb)
            }

            SectionLabel("幕宽")

            SpatialSliderMedium(
                onChanged = { cb.onScreenWidth(1.0f + (9.0f - 1.0f) * it.coerceIn(0f, 1f)) },
                modifier = Modifier.fillMaxWidth(),
                value = ((state.screenWidth - 1.0f) / 8.0f).coerceIn(0f, 1f),
                helperText = "幕宽" to "%.1f m".format(state.screenWidth),
            )

            // ⚠️ 换形状 = 重建面板，这是官方限制不是我们偷懒：`settingsCreator` **只在实体
            // 创建时跑一次**，SDK 没有「运行时热换形状」的 API。重建时我们会记住进度接回去，
            // 但用户会看到一次约 0.3–0.8s 的接缝。如实写在界面上，别让人以为是卡了。
            Text(
                text = "换屏幕类型会重建幕布，画面有一次短暂的接缝，进度会接回原处。",
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 15.sp,
            )
        } else {
            Text(
                text = "当前是球幕片源（180°/360°），画面本来就包在你四周。" +
                    "想调位置就用「场景」页的重新居中。",
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 16.sp,
            )
        }
    }
}

@Composable
private fun androidx.compose.foundation.layout.RowScope.CurveTile(
    curve: ScreenCurve,
    hint: String,
    icon: ImageVector,
    state: VideoControlsState,
    cb: VideoControlsCallbacks,
) {
    TextTileButton(
        label = curve.label,
        secondaryLabel = hint,
        icon = { Icon(icon, null) },
        selected = state.curve == curve,
        onSelectionChange = { cb.onPickCurve(curve) },
        modifier = Modifier.weight(1f),
    )
}
