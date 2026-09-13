package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.Close
import com.meta.spatial.uiset.theme.icons.regular.Refresh
import com.meta.spatial.uiset.theme.icons.regular.Scale
import com.meta.spatial.uiset.theme.icons.regular.ScaleDown

/**
 * 浏览态的空间控制面板：面板远近与背景环境。
 *
 * # 这一页是干什么的
 *
 * Quest 上整个应用常驻在自建的沉浸空间里，Flutter UI 是悬在空间中的一块面板。这块面板
 * 离人多远、背后透出多少真实房间，是每个人身高、坐姿、房间大小各不相同的一件事。
 * 影院态（幕布上放着片子）里这两件事分别在「远近」页与「场景」页上；浏览态原先什么都没有，
 * 只能长按侧栏那枚钮弹一张 2D 玻璃菜单 —— 用户 2026-09-09 拍板把那张菜单整只删掉，
 * 改成**和空间视频里同一块面板**：一样的形状、一样的手势、一样的两组控件。
 *
 * # ⛔ 仍然只有一块面板
 *
 * 这一页与播放页 / 场景页共用同一个 `R.id.vr_controls_panel` 实体（官方 `comfort`：
 * 「keep the main controls in a **single UI panel**」）。入口是侧栏那枚可见的钮
 * （Dart → `XrBridge.panelControls`），出口是这里的 ✕ 或手柄 B/Y。
 *
 * # ⛔ 左边那三枚钮调的是 2D 面板，不是幕布
 *
 * 与 [ViewDistancePage] 长得一模一样是刻意的（同一份 [DistanceActionButton]），
 * 但回调完全不同：那一页动的是幕布（`onViewDistance*`），这一页动的是承载 Flutter 的
 * 那块面板（`onUiPanelDistance*` → `ImmersiveActivity.adjustUiPanelDistance`）。
 */
@Composable
fun BrowsePanelPage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Column(
        modifier = Modifier.fillMaxSize().reportPanelTouches(cb),
        verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
    ) {
        // 这一页没有「上一页」可回：左上角是 ✕（收面板），与播放页顶行同一枚钮。
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
        ) {
            CircleActionButton(
                icon = SpatialIcons.Regular.Close,
                contentDescription = stringResource(R.string.xr_hide_panel),
                onClick = cb::onHidePanel,
            )
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = stringResource(R.string.xr_panel_settings_title),
                    color = PanelTokens.ON_SURFACE,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Medium,
                    maxLines = 1,
                )
                Text(
                    text = stringResource(R.string.xr_panel_settings_subtitle),
                    color = PanelTokens.ON_SURFACE_DIM,
                    fontSize = 15.sp,
                    maxLines = 1,
                )
            }
        }

        // 面板宽而矮（1100×360dp）：两件事并排放得下，就不要叠成一条需要滚动的长列。
        Row(
            modifier = Modifier.fillMaxWidth().weight(1f),
            horizontalArrangement = Arrangement.spacedBy(PanelTokens.GAP * 2),
        ) {
            Column(
                modifier = Modifier.weight(1.25f).fillMaxHeight(),
                verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    SectionLabel(stringResource(R.string.xr_panel_distance), Modifier.weight(1f))
                    // 按一下就看得见数字在动 —— 这是那条被删掉的 toast 留下的活儿。
                    Text(
                        text = "%.2f m".format(state.uiPanelDistance),
                        color = PanelTokens.ON_SURFACE,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Medium,
                    )
                }
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(16.dp),
                ) {
                    DistanceActionButton(
                        icon = SpatialIcons.Regular.Scale,
                        label = stringResource(R.string.xr_view_nearer),
                        modifier = Modifier.weight(1f),
                        onStep = { cb.onUiPanelDistanceStep(-1) },
                        onHold = { pressed -> cb.onUiPanelDistanceHold(-1, pressed) },
                    )
                    DistanceActionButton(
                        icon = SpatialIcons.Regular.Refresh,
                        label = stringResource(R.string.xr_view_distance_reset),
                        modifier = Modifier.weight(1f),
                        onStep = cb::onResetUiPanelDistance,
                    )
                    DistanceActionButton(
                        icon = SpatialIcons.Regular.ScaleDown,
                        label = stringResource(R.string.xr_view_farther),
                        modifier = Modifier.weight(1f),
                        onStep = { cb.onUiPanelDistanceStep(1) },
                        onHold = { pressed -> cb.onUiPanelDistanceHold(1, pressed) },
                    )
                }
                Text(
                    text = stringResource(R.string.xr_view_distance_hint),
                    color = PanelTokens.ON_SURFACE_DIM,
                    fontSize = 15.sp,
                )
            }
            Column(
                modifier = Modifier.weight(1f).fillMaxHeight(),
                verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
            ) {
                SectionLabel(stringResource(R.string.xr_panel_background))
                BackgroundControls(state, cb, compact = true)
            }
        }
    }
}
