package m.c.g.a.i_iwara.vr

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.meta.spatial.uiset.button.SecondaryButton
import com.meta.spatial.uiset.slider.SpatialSliderLarge
import com.meta.spatial.uiset.theme.SpatialTheme
import com.meta.spatial.uiset.theme.darkSpatialColorScheme

/**
 * 播放器的空间化控制条。
 *
 * # 为什么用官方 UI Set 而不是自己画
 *
 * `SpatialSliderLarge` 是官方**明写用于媒体 seek** 的组件（"seeking through media"），
 * 轨道 40dp 天然满足命中高度，且**支持点击轨道跳转**而不只是拖 thumb ——
 * 这一条在纯手势下是刚需：官方原话是
 * 「**Most users fail at the pinch-and-drag** scroll bar interaction without explicit teaching」，
 * 而进度条恰恰就是捏合拖拽。
 *
 * # 尺寸纪律
 *
 * 官方命中区下限：22mm × 22mm / 48dp / 角尺寸 2.5°–3°，主控件 60×60dp，间距 ≥12mm。
 * 本面板按 500dp/m 出图，所以 1dp = 2mm；按钮给到 80dp 高（≈16cm @2.4m ≈ 3.8°），
 * 高于官方下限。
 *
 * ⚠️ 没有触觉：官方原话「**Hands have no haptics.** … every successful poke, pinch, or grab
 * needs strong audiovisual feedback to compensate… **This is not optional.**」
 * 目前只有 UI Set 自带的视觉反馈，**音效还没做**，这是已知欠账。
 */
@Composable
fun VideoControlsPanel(
    isPlaying: Boolean,
    progress: Float,
    volume: Float,
    positionText: String,
    durationText: String,
    onPlayPause: () -> Unit,
    onSeek: (Float) -> Unit,
    onSeekFinished: () -> Unit,
    onVolume: (Float) -> Unit,
    onBackToApp: () -> Unit,
) {
    // ⛔ 必须套官方主题。不套的话组件用的是默认（浅色）配色，实测在暗色底板上
    // 两条滑块的轨道整条都是白的、看不出填充比例 —— 用户第一眼反馈就是「全白、跑到最大」。
    // 暗色方案也更符合官方那条「避免纯白 #FFFFFF / 浅色背景不要亮过 #DADADA」的配色纪律。
    SpatialTheme(colorScheme = darkSpatialColorScheme()) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            // ⛔ 官方配色纪律：避免纯黑 #000000。这里用近黑而非纯黑。
            .background(Color(0xFF1B1B1F))
            .padding(horizontal = 24.dp, vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            SecondaryButton(
                label = if (isPlaying) "暂停" else "播放",
                onClick = onPlayPause,
                modifier = Modifier.width(160.dp),
            )
            SecondaryButton(
                label = "返回应用",
                onClick = onBackToApp,
                modifier = Modifier.width(200.dp),
            )
        }

        // 进度：拖动中连续回调，抬手时再真正 seek 一次（避免拖动过程狂 seek）。
        SpatialSliderLarge(
            onChanged = onSeek,
            modifier = Modifier.fillMaxWidth(),
            value = progress,
            onValueChangedFinished = onSeekFinished,
            helperText = positionText to durationText,
        )

        // 音量。**这条刻意不碰系统音量**，调的是播放器自己的音量 —— 这是官方对媒体应用的
        // 明文要求：「App must include a mute/unmute button that adjusts audio **for the app
        // only**. **Using system-wide volume and system-wide mute is prohibited.**」
        // 所以「拖了它系统音量不动」是正确行为，不是 bug；标签里写清「应用音量」避免误解。
        SpatialSliderLarge(
            onChanged = onVolume,
            modifier = Modifier.fillMaxWidth(),
            value = volume,
            helperText = "应用音量·静音" to "最大",
        )
    }
    }
}
