package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.button.SecondaryButton
import com.meta.spatial.uiset.button.SecondaryCircleButton
import com.meta.spatial.uiset.slider.SpatialSliderLarge
import com.meta.spatial.uiset.slider.SpatialSliderMedium
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.Media2d
import com.meta.spatial.uiset.theme.icons.regular.Pause
import com.meta.spatial.uiset.theme.icons.regular.Play
import com.meta.spatial.uiset.theme.icons.regular.PlayNext
import com.meta.spatial.uiset.theme.icons.regular.PlayPrev
import com.meta.spatial.uiset.theme.icons.regular.Reorient
import com.meta.spatial.uiset.theme.icons.regular.Television
import com.meta.spatial.uiset.theme.icons.regular.Time
import com.meta.spatial.uiset.theme.icons.regular.VolumeOff
import com.meta.spatial.uiset.theme.icons.regular.VolumeOn
import com.meta.spatial.uiset.theme.icons.regular.TenSecondsBackward
import com.meta.spatial.uiset.theme.icons.regular.TenSecondsForward

/**
 * 播放页 —— 面板的主页。
 *
 * 布局照参考软件：**标题行 / 进度条 / 走带行 / 音量行**，
 * 且「视频类型 · 屏幕类型」两枚入口就落在**音量行最右边**（参考软件里是一个六边形
 * 钮加一个长方形钮，位置一模一样）。
 *
 * # ⛔ 为什么进度条之外还要 ±10 秒
 *
 * 官方 `hands-ui-best-practices` 原话：「**Most users fail at the pinch-and-drag**
 * scroll bar interaction without explicit teaching」，而进度条恰恰就是捏合拖拽。
 * `SpatialSliderLarge` 官方明写用于 "seeking through media" 且**支持点击轨道跳转**，
 * ±10 秒是同一条结论的第二重保险 —— 让用户完全不必拖拽也能定位。
 */
@Composable
fun PlayerPage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
    ) {
        // ── 标题 + 时间 ────────────────────────────────────────────
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = state.title.ifBlank { "正在播放" },
                color = PanelTokens.ON_SURFACE,
                fontSize = 22.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f),
            )
            Text(
                text = if (state.buffering) {
                    "缓冲中…"
                } else {
                    "${state.positionText} / ${state.durationText}"
                },
                color = if (state.buffering) PanelTokens.WARN else PanelTokens.ON_SURFACE_DIM,
                fontSize = 18.sp,
            )
        }

        // 一行短提示（例如「这个片源本机放不了」）。有才占位，没有就不占。
        val notice = state.notice
        if (notice != null) {
            Text(text = notice, color = PanelTokens.WARN, fontSize = 15.sp, maxLines = 1)
        }

        // ── 进度 ──────────────────────────────────────────────────
        SpatialSliderLarge(
            onChanged = cb::onSeek,
            modifier = Modifier.fillMaxWidth(),
            value = state.progress,
            onValueChangedFinished = cb::onSeekFinished,
        )

        // ── 走带 ──────────────────────────────────────────────────
        Row(
            modifier = Modifier.fillMaxWidth().height(PanelTokens.CIRCLE_SIZE),
            horizontalArrangement = Arrangement.spacedBy(14.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
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
                    if (state.isPlaying) {
                        Icon(SpatialIcons.Regular.Pause, "暂停")
                    } else {
                        Icon(SpatialIcons.Regular.Play, "播放")
                    }
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

            Spacer(Modifier.width(10.dp))

            SecondaryButton(
                label = state.speedText,
                leading = { Icon(SpatialIcons.Regular.Time, null) },
                onClick = cb::onCycleSpeed,
                modifier = Modifier.width(170.dp),
            )
            SecondaryButton(
                label = "重新居中",
                leading = { Icon(SpatialIcons.Regular.Reorient, null) },
                onClick = cb::onRecenter,
                modifier = Modifier.width(210.dp),
            )
        }

        // ── 音量行（最右两枚就是参考软件的六边形钮 + 长方形钮） ───────
        Row(
            modifier = Modifier.fillMaxWidth().height(PanelTokens.CIRCLE_SIZE),
            horizontalArrangement = Arrangement.spacedBy(14.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // ⛔ 静音钮不是装饰：官方对媒体应用是 Requirement 级明文
            // 「App must include a **mute/unmute button** that adjusts audio **for the
            //  app only**. Using system-wide volume and system-wide mute is **prohibited**.」
            // 参考软件实测会联动系统音量，我们**刻意不跟**（用户 2026-08-29 拍板：
            // 只调应用音量，接受与参考软件手感不同，换合规）。
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
            SpatialSliderMedium(
                onChanged = cb::onVolume,
                modifier = Modifier.weight(1f),
                value = if (state.muted) 0f else state.volume,
                helperText = "应用音量" to "${((if (state.muted) 0f else state.volume) * 100).toInt()}%",
            )

            SecondaryButton(
                label = projectionShortLabel(state),
                leading = { Icon(SpatialIcons.Regular.Media2d, null) },
                onClick = { cb.onRoute(ControlsRoute.VIDEO_TYPE) },
                modifier = Modifier.width(230.dp),
            )
            SecondaryButton(
                label = state.curve.label,
                leading = { Icon(SpatialIcons.Regular.Television, null) },
                onClick = { cb.onRoute(ControlsRoute.SCREEN_TYPE) },
                modifier = Modifier.width(200.dp),
                isEnabled = state.curveAvailable,
            )
        }
    }
}

/** 音量行上那枚「视频类型」钮的短标签：投影 + 立体编排。 */
private fun projectionShortLabel(state: VideoControlsState): String {
    val stereo = when (state.stereo) {
        StereoLayout.MONO -> "2D"
        StereoLayout.SIDE_BY_SIDE -> "3D 左右"
        StereoLayout.TOP_BOTTOM -> "3D 上下"
    }
    return "${state.projection.label} · $stereo"
}
