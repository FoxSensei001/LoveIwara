package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.button.SecondaryButton
import com.meta.spatial.uiset.slider.SpatialSliderMedium
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.Refresh
import com.meta.spatial.uiset.theme.icons.regular.Reorient

/**
 * 场景页：环境二选一 + 幕布几何微调。
 *
 * # ⛔ 没有「场景」这个选择题了，只剩一条背景不透明度
 *
 * 参考软件有 MAX 影院 / 太空 / 热气球 等一排 3D 场景，我们一开始只做「透视 / 虚空」
 * 两块磁贴。**2026-09-09 用户拍板把这道选择题整只删掉**：有了空间光晕之后，虚空
 * （纯黑）只是「背景不透明度拖到 0」的那一端，两个档位彼此重叠、还多一次点击。
 * 现在默认是**纯透明**（看得见真实房间），亮暗全交给 [MediaEffectsSection] 里那条
 * 滑块 —— 拖到 0 就是原来的虚空。
 *
 * # ⛔ passthrough 切换必须是渐变，不能硬切
 *
 * 官方 `mr-design-passthrough`：切换必须 **smooth blending**。且
 * `spatial-sdk-design-tips` 有一条更硬的：「用户本来在 passthrough 时不要擅自把他
 * 拉进独占沉浸」。滑块到 0 / 离开 0 那两下同样算切换，渐变由调用方实现
 * （见 `ImmersiveActivity.applyScene` 与 `MediaEffectsRenderer.setBackground`）。
 *
 * # 幕布几何
 *
 * 参考软件的「场景调节」给的是**屏幕距离 / 屏幕偏移 / 幕宽**三条滑块，我们照做。
 * 平面片保留精确的距离 / 幕宽 / 高度滑块；所有投影共用「远近」的单手按住操控。
 *
 * ⛔ 距离下限 **1.5m** 不是随手定的：官方对 UI 的下限是 1m
 * （`hands-3d-best-practices`：「Avoid placing UI in the middle distance
 * (roughly 0.5m to 0.8m)… push it well into raycast range (**1m or more**)」），
 * 而控制面板必须落在幕布**前面**一截，两条一起反算出 1.5m。
 */
@Composable
fun ScenePage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    val scroll = rememberScrollState()
    Column(
        modifier = Modifier
            .fillMaxSize()
            .reportPanelTouches(cb)
            .panelScrollbar(scroll).verticalScroll(scroll),
        verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
    ) {
        PageHeader(
            title = stringResource(R.string.xr_scene_title),
            subtitle = stringResource(
                if (state.format.isFlat) {
                    R.string.xr_scene_subtitle_flat
                } else {
                    R.string.xr_scene_subtitle_sphere
                },
            ),
            onBack = { cb.onRoute(ControlsRoute.PLAYER) },
            trailing = {
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp), verticalAlignment = Alignment.CenterVertically) {
                    ViewDistanceButton(cb)
                    if (state.format.isFlat) {
                        SecondaryButton(
                            label = stringResource(R.string.xr_reset),
                            leading = { Icon(SpatialIcons.Regular.Refresh, null) },
                            onClick = cb::onResetScreenGeometry,
                            modifier = Modifier.width(140.dp),
                        )
                    }
                    SecondaryButton(
                        label = stringResource(R.string.xr_recenter),
                        leading = { Icon(SpatialIcons.Regular.Reorient, null) },
                        onClick = cb::onRecenter,
                        modifier = Modifier.width(180.dp),
                    )
                }
            },
        )

        // ── 环境 ──────────────────────────────────
        SectionLabel(stringResource(R.string.xr_scene_section_environment))

        MediaEffectsSection(state, cb)

        // ── 幕宽 / 高度（平面片） ──────────────
        if (state.format.isFlat) {
            SectionLabel(stringResource(R.string.xr_scene_section_adjust))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                SpatialSliderMedium(
                    onChanged = { cb.onScreenDistance(lerp(MIN_DISTANCE_M, MAX_DISTANCE_M, it)) },
                    modifier = Modifier.weight(1f),
                    value = unlerp(MIN_DISTANCE_M, MAX_DISTANCE_M, state.screenDistance),
                    helperText = stringResource(R.string.xr_screen_distance) to
                        "%.1f m".format(state.screenDistance),
                )
                SpatialSliderMedium(
                    onChanged = { cb.onScreenWidth(lerp(MIN_WIDTH_M, MAX_WIDTH_M, it)) },
                    modifier = Modifier.weight(1f),
                    value = unlerp(MIN_WIDTH_M, MAX_WIDTH_M, state.screenWidth),
                    helperText = stringResource(R.string.xr_screen_width) to
                        "%.1f m".format(state.screenWidth),
                )
            }

            SpatialSliderMedium(
                onChanged = { cb.onScreenOffset(lerp(MIN_OFFSET_M, MAX_OFFSET_M, it)) },
                modifier = Modifier.fillMaxWidth(),
                value = unlerp(MIN_OFFSET_M, MAX_OFFSET_M, state.screenOffset),
                helperText = stringResource(R.string.xr_screen_offset) to
                    "%+.2f m".format(state.screenOffset),
            )
        } else {
            Text(
                text = stringResource(R.string.xr_scene_sphere_note),
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 16.sp,
            )
        }
    }
}

// ⛔ 这些上下限直接对应官方数字，见文件头注释。
// ⛔ 下限 1.5m 不是 1.0m：控制面板必须落在幕布**前面** 0.45m 处，而它自己又不能低于
// 官方的 1m 舒适下限（「Avoid placing UI in the middle distance (roughly 0.5m to 0.8m)…
// push it well into raycast range (1m or more)」）。1.5 − 0.45 = 1.05m，刚好站得住。
// 幕布拉得比这还近，面板就只能和它挤在一起，真机上表现为「浮窗被幕布挡住」。
private const val MIN_DISTANCE_M = 1.2f
private const val MAX_DISTANCE_M = 8.0f
private const val MIN_WIDTH_M = 1.0f
private const val MAX_WIDTH_M = 10.0f
private const val MIN_OFFSET_M = -1.5f
private const val MAX_OFFSET_M = 1.5f

private fun lerp(from: Float, to: Float, t: Float): Float = from + (to - from) * t.coerceIn(0f, 1f)

private fun unlerp(from: Float, to: Float, value: Float): Float =
    ((value - from) / (to - from)).coerceIn(0f, 1f)
