package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.gestures.detectTapGestures
import com.meta.spatial.uiset.button.SecondaryButton
import com.meta.spatial.uiset.button.TextTileButton
import com.meta.spatial.uiset.control.SpatialSwitch
import com.meta.spatial.uiset.slider.SpatialSliderMedium
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.PlayNext
import com.meta.spatial.uiset.theme.icons.regular.Refresh
import com.meta.spatial.uiset.theme.icons.regular.Replay
import com.meta.spatial.uiset.theme.icons.regular.Stop

/**
 * 设置页：**只放沉浸态才有意义的东西**（应用其它设置回 2D 面板里改）。
 *
 * # 每一节的由来
 *
 * - **屏幕尺寸**（只在平面片显示）：4XVR 有这一节，允许强制一个宽高比或者各自加个系数，
 *   对付「片源打标 16:9 但其实是竖屏」之类的坑。球幕片人在球心，没有「屏幕」。
 * - **倍速播放**：`PLAYBACK_SPEEDS` 与走带行的倍速菜单同一份数据。
 * - **沿用到下一条视频**：屏幕尺寸（宽高比 / 宽比 / 长比）与倍速换片时要不要带过去。
 *   默认关（用户 2026-09-05 的临时措施）—— 关着时每换一条片子这四项回默认。
 * - **播完之后**：`REPEAT_MODE_ONE` 是默认，选 `NEXT` 时接播放列表。
 * - **空闲自动收起**：⛔ 官方成本推出来的必需品，不是偏好。原文：
 *   「It is common for app developers to create compositor layers, and supply them with
 *    a **0-alpha texture rather than destroy** the compositor layer. **Note that you will
 *    continue to pay the costs**」。所以隐藏必须**真销毁实体**，而不是调透明。
 * - **点按音效**：官方 `hands-ui-best-practices`：「**Hands have no haptics.** …
 *   every successful poke, pinch, or grab needs strong audiovisual feedback to
 *   compensate… **This is not optional.**」给开关是因为长时间观影时可能嫌吵，
 *   默认必须开。
 * - **唤出时摆到面前**：面板世界锁定，转过身就在原地；开着这项，捏合唤出时
 *   把它挪到当前头部朝向前方 —— 参考软件「朝任意方向点一下就出来」的观感。
 *   关掉则回到原世界坐标（有人喜欢面板固定在一处）。
 * - **手柄 A/X 单击 = 播放暂停** / **系统菜单/摘下头显时暂停**：4XVR 同名开关。
 *   前者对轻度用户友好（不用瞄面板），后者是官方推的「focus loss」礼貌。
 */
@Composable
fun SettingsPage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    val scroll = rememberScrollState()
    Column(
        modifier = Modifier
            .fillMaxSize()
            .reportPanelTouches(cb)
            .panelScrollbar(scroll).verticalScroll(scroll),
        verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
    ) {
        PageHeader(
            title = stringResource(R.string.xr_settings_title),
            subtitle = stringResource(R.string.xr_settings_subtitle),
            onBack = { cb.onRoute(ControlsRoute.PLAYER) },
        )

        // ── 屏幕尺寸 ─────────────────────────────
        if (state.format.isFlat) {
            SectionLabel(stringResource(R.string.xr_section_screen_size))

            AspectRow(state, cb)

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                SpatialSliderMedium(
                    onChanged = { cb.onWidthRatio(lerp(MIN_RATIO, MAX_RATIO, it)) },
                    modifier = Modifier.weight(1f),
                    value = unlerp(MIN_RATIO, MAX_RATIO, state.widthRatio),
                    helperText = stringResource(R.string.xr_width_ratio) to
                        "%.2f×".format(state.widthRatio),
                )
                SpatialSliderMedium(
                    onChanged = { cb.onHeightRatio(lerp(MIN_RATIO, MAX_RATIO, it)) },
                    modifier = Modifier.weight(1f),
                    value = unlerp(MIN_RATIO, MAX_RATIO, state.heightRatio),
                    helperText = stringResource(R.string.xr_height_ratio) to
                        "%.2f×".format(state.heightRatio),
                )
            }

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                SecondaryButton(
                    label = stringResource(R.string.xr_reset_screen_size),
                    leading = { Icon(SpatialIcons.Regular.Refresh, null) },
                    onClick = cb::onResetAspect,
                    modifier = Modifier.width(220.dp),
                )
            }
        }

        // ── 倍速播放 ─────────────────────────────
        SectionLabel(stringResource(R.string.xr_section_speed))
        SpeedChipsSetting(current = state.speed, onPick = cb::onPickSpeed)

        // 屏幕尺寸 + 倍速要不要带给下一条。默认关（临时措施）：关着时每换一条都回默认值。
        SwitchRow(
            title = stringResource(R.string.xr_carry_over),
            hint = stringResource(R.string.xr_carry_over_hint),
            checked = state.carryOverToNextVideo,
            onToggle = { cb.onToggleCarryOver() },
        )

        // ── 播完之后 ─────────────────────────────
        SectionLabel(stringResource(R.string.xr_section_after_playback))
        Row(
            modifier = Modifier.fillMaxWidth().height(110.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            RepeatTile(RepeatMode.ONE, R.string.xr_repeat_one_hint, SpatialIcons.Regular.Replay, state, cb)
            RepeatTile(RepeatMode.NEXT, R.string.xr_repeat_next_hint, SpatialIcons.Regular.PlayNext, state, cb)
            RepeatTile(RepeatMode.STOP, R.string.xr_repeat_stop_hint, SpatialIcons.Regular.Stop, state, cb)
        }

        // ── 面板 ────────────────────────────────
        SectionLabel(stringResource(R.string.xr_section_panel))

        SwitchRow(
            title = stringResource(R.string.xr_auto_hide),
            hint = stringResource(R.string.xr_auto_hide_hint),
            checked = state.autoHide,
            onToggle = { cb.onToggleAutoHide() },
        )

        // 自动收起秒数 —— 只有 autoHide=true 才让用
        if (state.autoHide) {
            Text(
                text = stringResource(R.string.xr_auto_hide_seconds_label),
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 13.sp,
            )
            SecondsChipsRow(current = state.autoHideSeconds, onPick = cb::onAutoHideSeconds)
        }

        SwitchRow(
            title = stringResource(R.string.xr_summon_in_front),
            hint = stringResource(R.string.xr_summon_in_front_hint),
            checked = state.summonInFront,
            onToggle = { cb.onToggleSummonInFront() },
        )

        SwitchRow(
            title = stringResource(R.string.xr_click_sound),
            hint = stringResource(R.string.xr_click_sound_hint),
            checked = state.clickSound,
            onToggle = { cb.onToggleClickSound() },
        )

        // ── 手柄与系统 ───────────────────────────
        SectionLabel(stringResource(R.string.xr_section_controller))

        SwitchRow(
            title = stringResource(R.string.xr_controller_tap),
            hint = stringResource(R.string.xr_controller_tap_hint),
            checked = state.controllerTapPlayPause,
            onToggle = { cb.onToggleControllerTapPlayPause() },
        )

        SwitchRow(
            title = stringResource(R.string.xr_pause_on_focus_loss),
            hint = stringResource(R.string.xr_pause_on_focus_loss_hint),
            checked = state.pauseOnFocusLoss,
            onToggle = { cb.onTogglePauseOnFocusLoss() },
        )

        // ── 手柄键位说明（只读） ─────────────────
        Spacer(Modifier.height(6.dp))
        SectionLabel(stringResource(R.string.xr_section_bindings))
        Text(
            text = stringResource(R.string.xr_controller_bindings),
            color = PanelTokens.ON_SURFACE_DIM,
            fontSize = 14.sp,
        )

        Spacer(Modifier.height(4.dp))
    }
}

// ─────────────────────────────────────────────────────────── 复用件

@Composable
internal fun SwitchRow(
    title: String,
    hint: String,
    checked: Boolean,
    onToggle: () -> Unit,
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(title, color = PanelTokens.ON_SURFACE, fontSize = 16.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(hint, color = PanelTokens.ON_SURFACE_DIM, fontSize = 13.sp, maxLines = 2, overflow = TextOverflow.Ellipsis)
        }
        SpatialSwitch(
            checked = checked,
            onCheckedChange = { onToggle() },
        )
    }
}

@Composable
private fun AspectRow(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Row(
        modifier = Modifier.fillMaxWidth().height(84.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        AspectPreset.entries.forEach { preset ->
            TextTileButton(
                label = stringResource(preset.labelRes),
                selected = state.aspectPreset == preset,
                onSelectionChange = { cb.onPickAspect(preset) },
                modifier = Modifier.weight(1f),
            )
        }
    }
}

@Composable
private fun SpeedChipsSetting(current: Float, onPick: (Float) -> Unit) {
    // 11 档一行有点密，切成两行 6/5。
    val rows = PLAYBACK_SPEEDS.chunked(6)
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        rows.forEach { row ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                row.forEach { s ->
                    SmallChip(
                        label = speedLabel(s),
                        selected = s == current,
                        onClick = { onPick(s) },
                        modifier = Modifier.weight(1f),
                    )
                }
                repeat(6 - row.size) { Spacer(Modifier.weight(1f)) }
            }
        }
    }
}

@Composable
private fun SecondsChipsRow(current: Int, onPick: (Int) -> Unit) {
    val options = listOf(4, 8, 12, 20, 30, 60)
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        options.forEach { sec ->
            SmallChip(
                label = "${sec}s",
                selected = current == sec,
                onClick = { onPick(sec) },
                modifier = Modifier.weight(1f),
            )
        }
    }
}

/**
 * 一枚扁 chip：给倍速与「多久算空闲」两处秒数复用。
 *
 * ⛔ 不走 [SecondaryButton]：那个组件最小高度 64dp，一整行 6 枚会把设置页撑到
 * 装不下。这里用 [Box] + `pointerInput` 自绘一枚 40dp 的 chip，同样有按下高亮。
 */
@Composable
private fun SmallChip(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val bg = if (selected) PanelTokens.ON_SURFACE else PanelTokens.POPUP
    val fg = if (selected) PanelTokens.POPUP else PanelTokens.ON_SURFACE
    Box(
        modifier = modifier
            .height(40.dp)
            .clip(RoundedCornerShape(20.dp))
            .background(bg)
            .pointerInput(onClick) { detectTapGestures { onClick() } }
            .padding(horizontal = 12.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(label, color = fg, fontSize = 14.sp, maxLines = 1)
    }
}

@Composable
private fun androidx.compose.foundation.layout.RowScope.RepeatTile(
    mode: RepeatMode,
    @androidx.annotation.StringRes hintRes: Int,
    icon: ImageVector,
    state: VideoControlsState,
    cb: VideoControlsCallbacks,
) {
    TextTileButton(
        label = stringResource(mode.labelRes),
        secondaryLabel = stringResource(hintRes),
        icon = { Icon(icon, null) },
        selected = state.repeatMode == mode,
        onSelectionChange = { cb.onPickRepeatMode(mode) },
        modifier = Modifier.weight(1f),
    )
}

// ── 数值上下限（宽比 / 长比） ───────────────
private const val MIN_RATIO = 0.5f
private const val MAX_RATIO = 2.0f

private fun lerp(from: Float, to: Float, t: Float): Float = from + (to - from) * t.coerceIn(0f, 1f)
private fun unlerp(from: Float, to: Float, value: Float): Float =
    ((value - from) / (to - from)).coerceIn(0f, 1f)
