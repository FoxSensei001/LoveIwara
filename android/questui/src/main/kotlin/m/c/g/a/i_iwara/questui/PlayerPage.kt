package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.background
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.Close
import com.meta.spatial.uiset.theme.icons.regular.Environment
import com.meta.spatial.uiset.theme.icons.regular.Home
import com.meta.spatial.uiset.theme.icons.regular.ListView
import com.meta.spatial.uiset.theme.icons.regular.Media2d
import com.meta.spatial.uiset.theme.icons.regular.Pause
import com.meta.spatial.uiset.theme.icons.regular.Play
import com.meta.spatial.uiset.theme.icons.regular.PlayNext
import com.meta.spatial.uiset.theme.icons.regular.PlayPrev
import com.meta.spatial.uiset.theme.icons.regular.Power
import com.meta.spatial.uiset.theme.icons.regular.Settings
import com.meta.spatial.uiset.theme.icons.regular.TenSecondsBackward
import com.meta.spatial.uiset.theme.icons.regular.TenSecondsForward
import com.meta.spatial.uiset.theme.icons.regular.Television
import com.meta.spatial.uiset.theme.icons.regular.Time
import com.meta.spatial.uiset.theme.icons.regular.VolumeOff
import com.meta.spatial.uiset.theme.icons.regular.VolumeOn

/**
 * 播放页 —— 面板的主页（1100×360dp 一张卡片）。
 *
 * ```
 * [✕]  标题…                  [缓冲中] 🕒05:36 🔋36%   [场景][列表][设置][返回]
 *
 * [🔊]   ⏮  ⏪10  ▶  ⏩10  ⏭                      [1.0×] [平面 · 2D] [直面屏]
 *
 * 00:18  ═══════●─────────────────────────────────────────────────  04:27
 * ```
 *
 * - 走带行居中，播放/暂停是反色的 72dp 主钮；其余圆钮 64dp。
 * - 进度条自绘细条 + 小圆拖块，两侧时间等宽（[TimeLabel]），拖动时左侧显示预览时间。
 *   缓冲态**不写进时间**（那会让轨道长度跟着抖），改成轨道变色 + 头部「缓冲中」chip。
 * - 🔊 点击弹竖向音量滑杆；倍速钮点击在走带行下方长出一排 chip。
 */
@Composable
fun PlayerPage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    var speedMenuOpen by remember { mutableStateOf(false) }

    Box(modifier = Modifier.fillMaxSize()) {
        Column(modifier = Modifier.fillMaxSize()) {
            HeaderRow(state, cb)

            val notice = state.notice
            if (notice != null) {
                Text(
                    text = notice,
                    color = PanelTokens.WARN,
                    fontSize = 15.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.padding(top = 6.dp),
                )
            }

            Spacer(Modifier.weight(1f))

            TransportRow(
                state = state,
                cb = cb,
                speedMenuOpen = speedMenuOpen,
                onToggleSpeedMenu = { speedMenuOpen = !speedMenuOpen },
            )

            // 倍速 chip 行：展开 / 收起带高度与透明度过渡，不再瞬间改版式（真机反馈）。
            AnimatedVisibility(
                visible = speedMenuOpen,
                enter = expandVertically() + fadeIn(),
                exit = shrinkVertically() + fadeOut(),
            ) {
                Column {
                    Spacer(Modifier.height(10.dp))
                    SpeedChipRow(
                        current = state.speed,
                        onPick = { s ->
                            cb.onPickSpeed(s)
                            speedMenuOpen = false
                        },
                    )
                }
            }

            Spacer(Modifier.weight(1f))

            ProgressRow(state, cb)
        }

        if (state.volumePopupOpen) {
            // 关闭底板画在弹层之下：弹层没消费的触碰才会掉到它上面。
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .pointerInput(cb) { detectTapGestures { cb.onVolumePopup(false) } },
            )
            VolumeVerticalPopup(
                state = state,
                cb = cb,
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(bottom = 60.dp),
            )
        }
    }
}

// ─────────────────────────────────────────────────────────── 头部行

@Composable
private fun HeaderRow(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        CircleActionButton(SpatialIcons.Regular.Close, "收起控制面板", onClick = cb::onHidePanel)

        Text(
            text = state.title.ifBlank { "正在播放" },
            color = PanelTokens.ON_SURFACE,
            fontSize = 20.sp,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f).padding(start = 4.dp),
        )

        // 状态区：缓冲 chip 在时间**左侧**（用户 2026-09-05 反馈）。
        if (state.buffering) {
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(14.dp))
                    .background(PanelTokens.WARN.copy(alpha = 0.18f))
                    .padding(horizontal = 12.dp, vertical = 5.dp),
            ) {
                Text("缓冲中…", color = PanelTokens.WARN, fontSize = 14.sp)
            }
        }
        if (state.clockText.isNotBlank()) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Icon(SpatialIcons.Regular.Time, null, tint = PanelTokens.ON_SURFACE_DIM, modifier = Modifier.size(18.dp))
                Text(state.clockText, color = PanelTokens.ON_SURFACE_DIM, fontSize = 15.sp)
            }
        }
        if (state.batteryPercent >= 0) {
            val batColor = if (state.batteryCharging) PanelTokens.CHARGE else PanelTokens.ON_SURFACE_DIM
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Icon(SpatialIcons.Regular.Power, null, tint = batColor, modifier = Modifier.size(18.dp))
                Text("${state.batteryPercent}%", color = batColor, fontSize = 15.sp)
            }
        }

        Spacer(Modifier.width(8.dp))

        CircleActionButton(SpatialIcons.Regular.Environment, "场景") { cb.onRoute(ControlsRoute.SCENE) }
        CircleActionButton(SpatialIcons.Regular.ListView, "播放列表") { cb.onRoute(ControlsRoute.PLAYLIST) }
        CircleActionButton(SpatialIcons.Regular.Settings, "设置") { cb.onRoute(ControlsRoute.SETTINGS) }
        // ⛔ 官方 Requirement：应用内自带返回。沉浸空间没有系统返回可用。
        CircleActionButton(SpatialIcons.Regular.Home, "返回应用", onClick = cb::onBackToApp)
    }
}

// ─────────────────────────────────────────────────────────── 走带行

@Composable
private fun TransportRow(
    state: VideoControlsState,
    cb: VideoControlsCallbacks,
    speedMenuOpen: Boolean,
    onToggleSpeedMenu: () -> Unit,
) {
    Row(
        modifier = Modifier.fillMaxWidth().height(PanelTokens.CIRCLE_SIZE),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // 🔊：单击开关竖向弹层；静音钮在弹层里（官方 Requirement 级：只调应用音量）。
        CircleActionButton(
            icon = if (state.muted || state.volume <= 0f) SpatialIcons.Regular.VolumeOff else SpatialIcons.Regular.VolumeOn,
            contentDescription = "音量",
            onClick = { cb.onVolumePopup(!state.volumePopupOpen) },
            selected = state.volumePopupOpen,
        )

        Spacer(Modifier.width(8.dp))

        CircleActionButton(SpatialIcons.Regular.PlayPrev, "上一条") { cb.onPlayAdjacent(false) }
        CircleActionButton(SpatialIcons.Regular.TenSecondsBackward, "后退 10 秒") { cb.onSeekBy(-10) }
        CircleActionButton(
            icon = if (state.isPlaying) SpatialIcons.Regular.Pause else SpatialIcons.Regular.Play,
            contentDescription = if (state.isPlaying) "暂停" else "播放",
            onClick = cb::onPlayPause,
            size = PanelTokens.CIRCLE_SIZE,
            emphasized = true,
        )
        CircleActionButton(SpatialIcons.Regular.TenSecondsForward, "前进 10 秒") { cb.onSeekBy(10) }
        CircleActionButton(SpatialIcons.Regular.PlayNext, "下一条") { cb.onPlayAdjacent(true) }

        Spacer(Modifier.weight(1f))

        PillButton(
            label = speedLabel(state.speed),
            icon = SpatialIcons.Regular.Time,
            onClick = onToggleSpeedMenu,
            selected = speedMenuOpen,
        )
        PillButton(
            label = state.format.shortLabel,
            icon = SpatialIcons.Regular.Media2d,
            onClick = { cb.onRoute(ControlsRoute.VIDEO_TYPE) },
        )
        PillButton(
            label = state.curve.label,
            icon = SpatialIcons.Regular.Television,
            onClick = { cb.onRoute(ControlsRoute.SCREEN_TYPE) },
            enabled = state.format.isFlat,
        )
    }
}

// ─────────────────────────────────────────────────────────── 进度行

@Composable
private fun ProgressRow(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        val preview = state.seekPreviewText
        TimeLabel(
            text = preview ?: state.positionText,
            color = if (preview != null) PanelTokens.ON_SURFACE else PanelTokens.ON_SURFACE_DIM,
            modifier = Modifier.width(TIME_LABEL_WIDTH),
        )
        SeekBar(
            progress = state.progress,
            onSeek = cb::onSeek,
            onSeekFinished = cb::onSeekFinished,
            buffering = state.buffering,
            modifier = Modifier.weight(1f),
        )
        TimeLabel(text = state.durationText, modifier = Modifier.width(TIME_LABEL_WIDTH))
    }
}

/** 装得下 「1:23:45」 的等宽标签。 */
private val TIME_LABEL_WIDTH = 84.dp

// ─────────────────────────────────────────────────────────── 速度菜单

@Composable
private fun SpeedChipRow(current: Float, onPick: (Float) -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        PLAYBACK_SPEEDS.forEach { s ->
            SpeedChip(label = speedLabel(s), selected = s == current, onClick = { onPick(s) })
        }
    }
}

@Composable
private fun androidx.compose.foundation.layout.RowScope.SpeedChip(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
) {
    PillButton(
        label = label,
        onClick = onClick,
        selected = selected,
        height = 40.dp,
        modifier = Modifier.weight(1f),
    )
}

// ─────────────────────────────────────────────────────────── 音量弹层

/** 竖向音量弹层：百分比 · 自绘竖条 · 静音钮。 */
@Composable
private fun VolumeVerticalPopup(
    state: VideoControlsState,
    cb: VideoControlsCallbacks,
    modifier: Modifier = Modifier,
) {
    val current = if (state.muted) 0f else state.volume
    Box(
        modifier = modifier
            .size(width = 104.dp, height = 300.dp)
            .clip(RoundedCornerShape(28.dp))
            .background(PanelTokens.POPUP)
            .padding(12.dp),
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween,
        ) {
            Text(text = "${(current * 100).toInt()}%", color = PanelTokens.ON_SURFACE, fontSize = 15.sp)
            VerticalLevelBar(
                level = current,
                onLevel = cb::onVolume,
                modifier = Modifier.height(170.dp),
            )
            CircleActionButton(
                icon = if (state.muted || state.volume <= 0f) SpatialIcons.Regular.VolumeOff else SpatialIcons.Regular.VolumeOn,
                contentDescription = if (state.muted) "取消静音" else "静音",
                onClick = cb::onToggleMute,
                size = 56.dp,
                selected = state.muted,
            )
        }
    }
}
