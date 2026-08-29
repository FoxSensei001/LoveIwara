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
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.button.ButtonShelf
import com.meta.spatial.uiset.button.TextTileButton
import com.meta.spatial.uiset.slider.SpatialSliderMedium
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.HandCursor
import com.meta.spatial.uiset.theme.icons.regular.Minimize
import com.meta.spatial.uiset.theme.icons.regular.PlayNext
import com.meta.spatial.uiset.theme.icons.regular.Replay
import com.meta.spatial.uiset.theme.icons.regular.Stop
import com.meta.spatial.uiset.theme.icons.regular.VolumeOn

/**
 * 设置页：**只放沉浸态才有意义的东西**。
 *
 * ⛔ 不把 2D 应用那一整套设置搬进来。那套设置有几十项、依赖 Flutter 的表单组件与
 * 输入法，而这块面板是原生 Compose；真要改画质、下载、账号，退回应用面板去改就是了
 * （顶栏「返回应用」一步到位）。这一页只管**空间形态自己的行为**。
 *
 * # 每一项的由来
 *
 * - **播完之后**：此前是硬编码 `REPEAT_MODE_ONE`（单集循环），连选项都没有。
 * - **空闲自动隐藏**：⛔ 这是官方成本推出来的必需品，不是偏好。原文：
 *   「It is common for app developers to create compositor layers, and supply them with
 *    a **0-alpha texture rather than destroy** the compositor layer. **Note that you will
 *    continue to pay the costs**」。所以隐藏必须**真销毁实体**，而不是调透明。
 * - **点按音效**：官方 `hands-ui-best-practices`：「**Hands have no haptics.** …
 *   every successful poke, pinch, or grab needs strong audiovisual feedback to
 *   compensate… **This is not optional.**」给开关是因为长时间观影时可能嫌吵，
 *   默认必须开。
 * - **唤出时摆到面前**：面板是世界锁定的，转过身之后它还在原地。开着这项，
 *   捏合唤出时把它挪到当前头部朝向前方 —— 这正是参考软件「朝任意方向点一下就出来」
 *   的观感。关掉则回到原来的世界坐标（有人喜欢面板固定在一个地方）。
 */
@Composable
fun SettingsPage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
    ) {
        PageHeader(
            title = "设置",
            subtitle = "只放沉浸态才有意义的项；其余设置回应用里改",
            onBack = { cb.onRoute(ControlsRoute.PLAYER) },
        )

        SectionLabel("播完之后")

        Row(
            modifier = Modifier.fillMaxWidth().height(112.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            RepeatTile(RepeatMode.ONE, "一直重放这一条", SpatialIcons.Regular.Replay, state, cb)
            RepeatTile(RepeatMode.NEXT, "接着放列表下一条", SpatialIcons.Regular.PlayNext, state, cb)
            RepeatTile(RepeatMode.STOP, "停在最后一帧", SpatialIcons.Regular.Stop, state, cb)
        }

        SectionLabel("控制面板")

        Row(
            modifier = Modifier.fillMaxWidth().height(112.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            ButtonShelf(
                label = if (state.autoHide) "空闲自动收起：开" else "空闲自动收起：关",
                icon = { Icon(SpatialIcons.Regular.Minimize, null) },
                selected = state.autoHide,
                onSelectionChange = { cb.onToggleAutoHide() },
                modifier = Modifier.weight(1f),
            )
            ButtonShelf(
                label = if (state.summonInFront) "唤出时摆到面前：开" else "唤出时摆到面前：关",
                icon = { Icon(SpatialIcons.Regular.HandCursor, null) },
                selected = state.summonInFront,
                onSelectionChange = { cb.onToggleSummonInFront() },
                modifier = Modifier.weight(1f),
            )
            ButtonShelf(
                label = if (state.clickSound) "点按音效：开" else "点按音效：关",
                icon = { Icon(SpatialIcons.Regular.VolumeOn, null) },
                selected = state.clickSound,
                onSelectionChange = { cb.onToggleClickSound() },
                modifier = Modifier.weight(1f),
            )
        }

        SpatialSliderMedium(
            onChanged = { cb.onAutoHideSeconds((MIN_SEC + (MAX_SEC - MIN_SEC) * it).toInt()) },
            modifier = Modifier.fillMaxWidth(),
            value = ((state.autoHideSeconds - MIN_SEC) / (MAX_SEC - MIN_SEC)).coerceIn(0f, 1f),
            helperText = "多久算空闲" to "${state.autoHideSeconds} 秒",
        )

        Text(
            text = "收起之后捏一下手指就能重新唤出，不用瞄准任何东西。" +
                "收起是真的销毁面板 —— 留着不画也照样吃合成层预算。",
            color = PanelTokens.ON_SURFACE_DIM,
            fontSize = 15.sp,
        )
    }
}

private const val MIN_SEC = 4f
private const val MAX_SEC = 60f


@Composable
private fun androidx.compose.foundation.layout.RowScope.RepeatTile(
    mode: RepeatMode,
    hint: String,
    icon: ImageVector,
    state: VideoControlsState,
    cb: VideoControlsCallbacks,
) {
    TextTileButton(
        label = mode.label,
        secondaryLabel = hint,
        icon = { Icon(icon, null) },
        selected = state.repeatMode == mode,
        onSelectionChange = { cb.onPickRepeatMode(mode) },
        modifier = Modifier.weight(1f),
    )
}
