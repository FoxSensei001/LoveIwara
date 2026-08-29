package m.c.g.a.i_iwara.questui

import android.content.Context
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material3.Text
import com.meta.spatial.uiset.button.SecondaryButton
import com.meta.spatial.uiset.slider.SpatialSliderLarge
import com.meta.spatial.uiset.slider.SpatialSliderMedium
import com.meta.spatial.uiset.theme.SpatialTheme
import com.meta.spatial.uiset.theme.darkSpatialColorScheme

/**
 * 播放器的空间化控制面板。
 *
 * # 设计依据（都能对上官方原文）
 *
 * - **进度条用 `SpatialSliderLarge`**：官方明写用于 "seeking through media"，轨道 40dp，
 *   并且**支持点击轨道跳转**而不只是拖 thumb —— 这在纯手势下是刚需，因为官方原话是
 *   「**Most users fail at the pinch-and-drag** scroll bar interaction without explicit
 *   teaching」，而进度条恰恰就是捏合拖拽。
 * - **另配 ±10 秒离散按钮**：同一条官方结论的第二重保险，让用户完全不必拖拽也能定位。
 * - **主控件尺寸**：官方命中区下限 22mm/48dp/2.5°–3°，主控件 60×60dp。本面板按
 *   500dp/m 出图（1dp = 2mm），按钮高度给到 72dp（≈14.4cm @2.2m ≈ 3.7°），高于下限。
 * - **主控件收敛在一块面板里**，不散成一堆浮窗（官方 `comfort`：
 *   「try to keep the main controls in a **single UI panel**, as opposed to having
 *   multiple windows floating around」）。
 * - **不用纯黑**：官方配色纪律要求避开 #000000，这里用近黑 #1B1B1F。
 *
 * # 已知欠账
 *
 * ⚠️ 没有触觉。官方原话：「**Hands have no haptics.** … every successful poke, pinch,
 * or grab needs strong audiovisual feedback to compensate… **This is not optional.**」
 * 音效由调用方（沉浸 Activity）在每个回调里播，视觉反馈由 UI Set 组件自带。
 */
@Composable
fun VideoControlsPanel(state: VideoControlsState, cb: VideoControlsCallbacks) {
    SpatialTheme(colorScheme = darkSpatialColorScheme()) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFF1B1B1F))
                .padding(horizontal = 28.dp, vertical = 18.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            // ── 标题 + 时间 ───────────────────────────────────────────────
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = state.title.ifBlank { "正在播放" },
                    color = Color(0xFFE6E6EA),
                    fontSize = 20.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f),
                )
                Text(
                    text = "${state.positionText} / ${state.durationText}",
                    color = Color(0xFFA8A8B0),
                    fontSize = 18.sp,
                )
            }

            // ── 进度 ─────────────────────────────────────────────────────
            SpatialSliderLarge(
                onChanged = cb::onSeek,
                modifier = Modifier.fillMaxWidth(),
                value = state.progress,
                onValueChangedFinished = cb::onSeekFinished,
            )

            // ── 播放控制簇 ───────────────────────────────────────────────
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                SecondaryButton(
                    label = "◀◀ 10秒",
                    onClick = { cb.onSeekBy(-10) },
                    modifier = Modifier.width(150.dp),
                )
                SecondaryButton(
                    label = if (state.isPlaying) "❚❚ 暂停" else "▶ 播放",
                    onClick = cb::onPlayPause,
                    modifier = Modifier.width(150.dp),
                )
                SecondaryButton(
                    label = "10秒 ▶▶",
                    onClick = { cb.onSeekBy(10) },
                    modifier = Modifier.width(150.dp),
                )
                // ⛔ 官方的 BorderlessButton 没有 modifier 参数（签名只有
                // label/onClick/icon/expanded/enabled），定宽的地方一律用 SecondaryButton。
                SecondaryButton(
                    label = "倍速 ${state.speedText}",
                    onClick = cb::onCycleSpeed,
                    modifier = Modifier.width(160.dp),
                )
                Spacer(Modifier.weight(1f))
                SecondaryButton(
                    label = "返回应用",
                    onClick = cb::onBackToApp,
                    modifier = Modifier.width(170.dp),
                )
            }

            // ── 画面与环境 ───────────────────────────────────────────────
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                SecondaryButton(
                    label = "投影 ${state.projectionText}",
                    onClick = cb::onCycleProjection,
                    modifier = Modifier.width(190.dp),
                )
                SecondaryButton(
                    label = "重新居中",
                    onClick = cb::onRecenter,
                    modifier = Modifier.width(150.dp),
                )
                SecondaryButton(
                    label = if (state.passthrough) "直通 开" else "直通 关",
                    onClick = cb::onTogglePassthrough,
                    modifier = Modifier.width(150.dp),
                )
                // 音量。⛔ **刻意只调播放器自己的音量，不碰系统音量** —— 这是官方对媒体
                // 应用的明文要求：「adjusts audio **for the app only**；Using system-wide
                // volume and system-wide mute is **prohibited**」。
                SpatialSliderMedium(
                    onChanged = cb::onVolume,
                    modifier = Modifier.weight(1f),
                    value = state.volume,
                    helperText = "应用音量" to "最大",
                )
            }
        }
    }
}

/**
 * 控制面板的状态。**对外只是普通的 Kotlin 属性**（内部用 Compose 的 mutableStateOf 实现），
 * 所以 `:app` 模块可以直接 `state.isPlaying = true` 地写它，
 * 而不需要在自己那边应用 Compose 编译器插件。
 */
class VideoControlsState {
    var title by mutableStateOf("")
    var isPlaying by mutableStateOf(false)
    var progress by mutableStateOf(0f)
    var volume by mutableStateOf(1f)
    var positionText by mutableStateOf("0:00")
    var durationText by mutableStateOf("0:00")
    var speedText by mutableStateOf("1.0×")
    var projectionText by mutableStateOf("平面")
    var passthrough by mutableStateOf(false)
}

/** 控制面板上的动作。由 `:app` 侧的沉浸 Activity 实现。 */
interface VideoControlsCallbacks {
    fun onPlayPause()
    fun onSeek(value: Float)
    fun onSeekFinished()
    fun onSeekBy(seconds: Int)
    fun onCycleSpeed()
    fun onCycleProjection()
    fun onRecenter()
    fun onTogglePassthrough()
    fun onVolume(value: Float)
    fun onBackToApp()
}

/**
 * 造出一块可以直接交给 `ComposeViewPanelRegistration` 的 [ComposeView]。
 *
 * ⭐ 这个工厂函数是本模块的**唯一出口**：所有 `@Composable` 都留在这里，
 * `:app` 只看到「给我一个 Context 和状态，还我一个 View」。
 */
fun createVideoControlsView(
    context: Context,
    state: VideoControlsState,
    callbacks: VideoControlsCallbacks,
): ComposeView = ComposeView(context).apply {
    setContent { VideoControlsPanel(state, callbacks) }
}
