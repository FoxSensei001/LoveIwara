package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.background
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
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.button.SecondaryButton
import com.meta.spatial.uiset.button.SecondaryCircleButton
import com.meta.spatial.uiset.slider.SpatialSliderLarge
import com.meta.spatial.uiset.slider.SpatialSliderSmall
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.Media2d
import com.meta.spatial.uiset.theme.icons.regular.Pause
import com.meta.spatial.uiset.theme.icons.regular.Play
import com.meta.spatial.uiset.theme.icons.regular.PlayNext
import com.meta.spatial.uiset.theme.icons.regular.PlayPrev
import com.meta.spatial.uiset.theme.icons.regular.Power
import com.meta.spatial.uiset.theme.icons.regular.TenSecondsBackward
import com.meta.spatial.uiset.theme.icons.regular.TenSecondsForward
import com.meta.spatial.uiset.theme.icons.regular.Television
import com.meta.spatial.uiset.theme.icons.regular.Time
import com.meta.spatial.uiset.theme.icons.regular.VolumeOff
import com.meta.spatial.uiset.theme.icons.regular.VolumeOn

/**
 * 播放页 —— 面板的主页。
 *
 * 布局照参考软件（4XVR，2026-09-04 用户实机截图）：
 *
 * ```
 * 标题                             🕒 时间   🔋 电量   [缓冲中…]
 * [notice]
 * [🔊] ⏮ ⏪10 ▶/⏸ ⏩10 ⏭       [速度][视频类型][屏幕类型]
 * ═══════●─────────────────      00:01:41 / 00:04:27
 * ```
 *
 * # 为什么进度条之外还要 ±10 秒
 *
 * 官方 `hands-ui-best-practices` 原话：「**Most users fail at the pinch-and-drag**
 * scroll bar interaction without explicit teaching」，而进度条恰恰就是捏合拖拽。
 * `SpatialSliderLarge` 官方明写用于 "seeking through media" 且**支持点击轨道跳转**，
 * ±10 秒是同一条结论的第二重保险 —— 让用户完全不必拖拽也能定位。
 *
 * # 音量竖向弹层：`SpatialSliderMedium` 旋转 -90°
 *
 * UI Set 的 slider 只有横向。要出参考软件那种「🔊 正上方竖起来一根」的效果只有两条路：
 * 自绘一整只（要重画 track/thumb/hit slop）或者拿现成的横 slider 硬旋转。
 * 后者代价小得多：外层 Box 定死 60×220dp 的**竖向逻辑尺寸**，内层 Box 用
 * `graphicsLayer { rotationZ = -90f }` 逆时针旋转，`size(200×40)` 是**旋转前**的
 * 逻辑尺寸。这样布局按外层的竖向 60×220 走，绘制按内层的横向 200×40 旋转后填进去，
 * 手感与横向 slider 完全一致（hit slop 都是官方给的）。
 *
 * 弹层的关闭手势：任何一次面板级的**面板其它地方**触碰或**再点 🔊** 都关。
 * 这里靠 [Box] 的兄弟节点绘制顺序 —— 关闭底板画在弹层内容之下，命中测试是**后画的
 * 先拿事件**，所以弹层内部的滑动/静音钮不会被吞。
 *
 * # 速度菜单：走带行**下面**长出一条 chip 行
 *
 * 官方 `SpatialDropdown` 是给表单场景用的，`label + helperText + placeholder` 一整套
 * 对这里过重。改成本地态 `speedMenuOpen`，开时在走带行与进度行之间插入一条水平
 * chip 行 —— 与参考软件表现一致，且不用 `Popup`（Popup 在 Spatial ComposeView
 * 里能否创建新窗口是未知的，把 runtime 未知项挡在外面）。
 */
@Composable
fun PlayerPage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    var speedMenuOpen by remember { mutableStateOf(false) }

    Box(modifier = Modifier.fillMaxSize().reportPanelTouches(cb)) {

        Column(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
        ) {
            // ── 标题 + 系统信息 ─────────────────────────────
            TitleStatusRow(state)

            // 一行短提示。有才占位；没有就不占。
            val notice = state.notice
            if (notice != null) {
                Text(text = notice, color = PanelTokens.WARN, fontSize = 15.sp, maxLines = 1)
            }

            // ── 走带行 ────────────────────────────────────
            TransportRow(
                state = state,
                cb = cb,
                onToggleSpeedMenu = { speedMenuOpen = !speedMenuOpen },
                speedMenuOpen = speedMenuOpen,
            )

            // 速度菜单 chip 行（开时才占位）
            if (speedMenuOpen) {
                SpeedChipRow(
                    current = state.speed,
                    onPick = { s ->
                        cb.onPickSpeed(s)
                        speedMenuOpen = false
                    },
                )
            }

            // 把进度行挤到底部
            Spacer(Modifier.weight(1f))

            // ── 进度 + 时间 ────────────────────────────────
            ProgressRow(state, cb)
        }

        // ── 音量竖向弹层（画在最上层） ──────────────────
        if (state.volumePopupOpen) {
            // 关闭底板：⛔ 必须画在弹层之前（更靠底），事件先分派给后画的弹层，
            // 弹层没消费的（弹层之外的空白）才会掉到关闭底板上。
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .pointerInput(cb) {
                        detectTapGestures { cb.onVolumePopup(false) }
                    }
            )
            VolumeVerticalPopup(
                state = state,
                cb = cb,
                // 摆在左下角，恰好落在 🔊 上方（🔊 在走带行最左）。
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(bottom = 96.dp),
            )
        }
    }
}

// ─────────────────────────────────────────────────────────── 标题行

@Composable
private fun TitleStatusRow(state: VideoControlsState) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        Text(
            text = state.title.ifBlank { "正在播放" },
            color = PanelTokens.ON_SURFACE,
            fontSize = 22.sp,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f),
        )
        if (state.clockText.isNotBlank()) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Icon(SpatialIcons.Regular.Time, null, tint = PanelTokens.ON_SURFACE_DIM)
                Text(state.clockText, color = PanelTokens.ON_SURFACE_DIM, fontSize = 16.sp)
            }
        }
        if (state.batteryPercent >= 0) {
            val batColor = if (state.batteryCharging) PanelTokens.CHARGE else PanelTokens.ON_SURFACE_DIM
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Icon(SpatialIcons.Regular.Power, null, tint = batColor)
                Text("${state.batteryPercent}%", color = batColor, fontSize = 16.sp)
            }
        }
        if (state.buffering) {
            Text("缓冲中…", color = PanelTokens.WARN, fontSize = 16.sp)
        }
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
        horizontalArrangement = Arrangement.spacedBy(14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // 🔊 音量弹层触发钮（⛔ 静音钮不是装饰：官方对媒体应用是 Requirement 级明文
        // 「App must include a **mute/unmute button** that adjusts audio **for the
        //  app only**. Using system-wide volume and system-wide mute is **prohibited**.」）
        // 单击不静音、只开关竖向弹层；静音钮在弹层里。
        SecondaryCircleButton(
            icon = {
                if (state.muted || state.volume <= 0f) {
                    Icon(SpatialIcons.Regular.VolumeOff, "音量")
                } else {
                    Icon(SpatialIcons.Regular.VolumeOn, "音量")
                }
            },
            onClick = { cb.onVolumePopup(!state.volumePopupOpen) },
        )

        // ⏮ ⏪10 ▶/⏸ ⏩10 ⏭
        SecondaryCircleButton(
            icon = { Icon(SpatialIcons.Regular.PlayPrev, "上一条") },
            onClick = { cb.onPlayAdjacent(false) },
        )
        SecondaryCircleButton(
            icon = { Icon(SpatialIcons.Regular.TenSecondsBackward, "后退 10 秒") },
            onClick = { cb.onSeekBy(-10) },
        )
        SecondaryCircleButton(
            icon = {
                if (state.isPlaying) Icon(SpatialIcons.Regular.Pause, "暂停")
                else Icon(SpatialIcons.Regular.Play, "播放")
            },
            onClick = cb::onPlayPause,
        )
        SecondaryCircleButton(
            icon = { Icon(SpatialIcons.Regular.TenSecondsForward, "前进 10 秒") },
            onClick = { cb.onSeekBy(10) },
        )
        SecondaryCircleButton(
            icon = { Icon(SpatialIcons.Regular.PlayNext, "下一条") },
            onClick = { cb.onPlayAdjacent(true) },
        )

        Spacer(Modifier.weight(1f))

        // 倍速
        SecondaryButton(
            label = speedLabel(state.speed),
            leading = { Icon(SpatialIcons.Regular.Time, null) },
            onClick = onToggleSpeedMenu,
            modifier = Modifier.width(140.dp),
        )

        // 视频类型入口
        SecondaryButton(
            label = state.format.shortLabel,
            leading = { Icon(SpatialIcons.Regular.Media2d, null) },
            onClick = { cb.onRoute(ControlsRoute.VIDEO_TYPE) },
            modifier = Modifier.widthIn(min = 200.dp),
        )

        // 屏幕类型入口。⛔ 球幕（非 flat）时禁用。
        SecondaryButton(
            label = state.curve.label,
            leading = { Icon(SpatialIcons.Regular.Television, null) },
            onClick = { cb.onRoute(ControlsRoute.SCREEN_TYPE) },
            modifier = Modifier.widthIn(min = 140.dp),
            isEnabled = state.format.isFlat,
        )
    }
}

// ─────────────────────────────────────────────────────────── 进度行

@Composable
private fun ProgressRow(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        SpatialSliderLarge(
            onChanged = cb::onSeek,
            modifier = Modifier.weight(1f),
            value = state.progress,
            onValueChangedFinished = cb::onSeekFinished,
        )
        Text(
            text = when {
                state.seekPreviewText != null -> "${state.seekPreviewText} / ${state.durationText}"
                state.buffering -> "缓冲中…"
                else -> "${state.positionText} / ${state.durationText}"
            },
            color = when {
                state.seekPreviewText != null -> PanelTokens.ON_SURFACE
                state.buffering -> PanelTokens.WARN
                else -> PanelTokens.ON_SURFACE_DIM
            },
            fontSize = 16.sp,
        )
    }
}

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
    // 一枚小 chip：用 Text + clickable，避免走 SecondaryButton 的 64dp 最小高度
    // 把整条 chip 行撑成第二个走带行那么高。
    val bg = if (selected) PanelTokens.ON_SURFACE else PanelTokens.POPUP
    val fg = if (selected) PanelTokens.POPUP else PanelTokens.ON_SURFACE
    Box(
        modifier = Modifier
            .weight(1f)
            .height(40.dp)
            .clip(RoundedCornerShape(20.dp))
            .background(bg)
            .pointerInput(onClick) { detectTapGestures { onClick() } },
        contentAlignment = Alignment.Center,
    ) {
        Text(text = label, color = fg, fontSize = 15.sp, maxLines = 1)
    }
}

// ─────────────────────────────────────────────────────────── 音量弹层

@Composable
private fun VolumeVerticalPopup(
    state: VideoControlsState,
    cb: VideoControlsCallbacks,
    modifier: Modifier = Modifier,
) {
    val current = if (state.muted) 0f else state.volume
    Box(
        modifier = modifier
            .size(width = 96.dp, height = 300.dp)
            .clip(RoundedCornerShape(28.dp))
            .background(PanelTokens.POPUP)
            .padding(12.dp),
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween,
        ) {
            Text(
                text = "${(current * 100).toInt()}%",
                color = PanelTokens.ON_SURFACE,
                fontSize = 15.sp,
            )
            // 竖向 slider：内层按旋转前的横向尺寸给，外层按旋转后的竖向尺寸给。
            Box(modifier = Modifier.size(width = 60.dp, height = 170.dp)) {
                Box(
                    modifier = Modifier
                        .align(Alignment.Center)
                        .size(width = 170.dp, height = 40.dp)
                        .graphicsLayer { rotationZ = -90f },
                ) {
                    SpatialSliderSmall(
                        onChanged = cb::onVolume,
                        modifier = Modifier.fillMaxSize(),
                        value = current,
                    )
                }
            }
            SecondaryCircleButton(
                icon = {
                    if (state.muted || state.volume <= 0f) {
                        Icon(SpatialIcons.Regular.VolumeOff, "取消静音")
                    } else {
                        Icon(SpatialIcons.Regular.VolumeOn, "静音")
                    }
                },
                onClick = cb::onToggleMute,
            )
        }
    }
}
