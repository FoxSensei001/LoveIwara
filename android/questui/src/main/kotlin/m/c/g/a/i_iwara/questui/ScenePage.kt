package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.meta.spatial.uiset.button.SecondaryButton
import com.meta.spatial.uiset.button.TextTileButton
import com.meta.spatial.uiset.slider.SpatialSliderMedium
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.NightMode
import com.meta.spatial.uiset.theme.icons.regular.Refresh
import com.meta.spatial.uiset.theme.icons.regular.Reorient
import com.meta.spatial.uiset.theme.icons.regular.World

/**
 * 场景页：环境二选一 + 幕布几何微调。
 *
 * # ⛔ 只做两种场景
 *
 * 参考软件有 MAX影院 / 太空 / 热气球 等一排 3D 场景。**我们只做透视与虚空**
 * （用户 2026-08-29 拍板）—— 每个 3D 场景都是一份要打进包的 glTF 资产，收益纯装饰。
 *
 * # ⛔ passthrough 切换必须是渐变，不能硬切
 *
 * 官方 `mr-design-passthrough`：切换必须 **smooth blending**。且
 * `spatial-sdk-design-tips` 有一条更硬的：「用户本来在 passthrough 时不要擅自把他
 * 拉进独占沉浸」。渐变由调用方实现（见 `ImmersiveActivity.applyScene`）。
 *
 * # 幕布几何
 *
 * 参考软件的「场景调节」给的是**屏幕距离 / 屏幕偏移**两条滑块，我们照做，
 * 再加一条**幕宽**（参考软件靠抓着幕布拖，我们两条路都留着）。
 *
 * ⛔ 距离下限 **1.5m** 不是随手定的，见文件末尾 `MIN_DISTANCE_M` 的注释：
 * 官方对 UI 的下限是 1m（`hands-3d-best-practices`：「Avoid placing UI in the middle
 * distance (roughly 0.5m to 0.8m)… push it well into raycast range (**1m or more**)」），
 * 而控制面板必须落在幕布**前面**一截，两条一起反算出 1.5m。
 */
@Composable
fun ScenePage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
    ) {
        PageHeader(
            title = "场景",
            subtitle = "环境与幕布位置",
            onBack = { cb.onRoute(ControlsRoute.PLAYER) },
            trailing = {
                SecondaryButton(
                    label = "重新居中",
                    leading = { Icon(SpatialIcons.Regular.Reorient, null) },
                    onClick = cb::onRecenter,
                    modifier = Modifier.width(200.dp),
                )
            },
        )

        Row(
            modifier = Modifier.fillMaxWidth().height(104.dp),
            horizontalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
        ) {
            TextTileButton(
                label = "虚空",
                secondaryLabel = "纯黑环境，只剩画面",
                icon = { Icon(SpatialIcons.Regular.NightMode, null) },
                selected = state.scene == SceneKind.VOID,
                onSelectionChange = { cb.onPickScene(SceneKind.VOID) },
                modifier = Modifier.weight(1f),
            )
            TextTileButton(
                label = "透视",
                secondaryLabel = "看得见真实房间",
                icon = { Icon(SpatialIcons.Regular.World, null) },
                selected = state.scene == SceneKind.PASSTHROUGH,
                onSelectionChange = { cb.onPickScene(SceneKind.PASSTHROUGH) },
                modifier = Modifier.weight(1f),
            )
        }

        SectionLabel("幕布")

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            SpatialSliderMedium(
                onChanged = { cb.onScreenDistance(lerp(MIN_DISTANCE_M, MAX_DISTANCE_M, it)) },
                modifier = Modifier.weight(1f),
                value = unlerp(MIN_DISTANCE_M, MAX_DISTANCE_M, state.screenDistance),
                helperText = "距离" to "%.1f m".format(state.screenDistance),
            )
            SpatialSliderMedium(
                onChanged = { cb.onScreenWidth(lerp(MIN_WIDTH_M, MAX_WIDTH_M, it)) },
                modifier = Modifier.weight(1f),
                value = unlerp(MIN_WIDTH_M, MAX_WIDTH_M, state.screenWidth),
                helperText = "幕宽" to "%.1f m".format(state.screenWidth),
            )
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            SpatialSliderMedium(
                onChanged = { cb.onScreenOffset(lerp(MIN_OFFSET_M, MAX_OFFSET_M, it)) },
                modifier = Modifier.weight(1f),
                value = unlerp(MIN_OFFSET_M, MAX_OFFSET_M, state.screenOffset),
                helperText = "高度" to "%+.2f m".format(state.screenOffset),
            )
            SecondaryButton(
                label = "恢复默认几何",
                leading = { Icon(SpatialIcons.Regular.Refresh, null) },
                onClick = cb::onResetScreenGeometry,
                modifier = Modifier.width(260.dp),
            )
        }
    }
}

// ⛔ 这些上下限直接对应官方数字，见文件头注释。
// ⛔ 下限 1.5m 不是 1.0m：控制面板必须落在幕布**前面** 0.45m 处，而它自己又不能低于
// 官方的 1m 舒适下限（「Avoid placing UI in the middle distance (roughly 0.5m to 0.8m)…
// push it well into raycast range (1m or more)」）。1.5 − 0.45 = 1.05m，刚好站得住。
// 幕布拉得比这还近，面板就只能和它挤在一起，真机上表现为「浮窗被幕布挡住」。
private const val MIN_DISTANCE_M = 1.5f
private const val MAX_DISTANCE_M = 8.0f
private const val MIN_WIDTH_M = 1.0f
private const val MAX_WIDTH_M = 9.0f
private const val MIN_OFFSET_M = -0.6f
private const val MAX_OFFSET_M = 0.6f

private fun lerp(from: Float, to: Float, t: Float): Float = from + (to - from) * t.coerceIn(0f, 1f)

private fun unlerp(from: Float, to: Float, value: Float): Float =
    ((value - from) / (to - from)).coerceIn(0f, 1f)
