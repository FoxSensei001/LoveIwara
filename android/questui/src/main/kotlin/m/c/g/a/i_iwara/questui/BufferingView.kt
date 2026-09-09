package m.c.g.a.i_iwara.questui

import android.content.Context
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.draw.clip
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * 幕布上那块叠层面板的状态；`:app` 写、面板读。对外是普通属性，理由同 [VideoControlsState]。
 *
 * 三种内容共用一块面板（同形同位叠在画面上）：**缓冲转圈**、**摇杆拖动进度的预览**
 * （[scrubText] 非空时显示目标时间 + 增量 + 一条细进度，代替转圈），以及**横拖翻片的预示浮窗**
 * （[swipe]，与转圈各画各的、互不遮挡）。
 *
 * 翻片预示为什么落在这块面板上：视频幕布是 ExoPlayer 的 Surface 面板，**没有 Compose 层**可画；
 * 而这块叠层本来就与幕布同形同位、按需创建。⛔ 别为它另开一块面板。
 */
class BufferingState {
    var visible by mutableStateOf(false)

    /** 幕布上横拖翻上一条 / 下一条的预示（由 `:app` 用手柄射线驱动，见 `updateStageSwipe`）。 */
    val swipe = StageSwipeState()

    /** 拖动进度的目标时间，例如「01:23:45」；null = 不在拖动（显示缓冲转圈）。 */
    var scrubText by mutableStateOf<String?>(null)

    /** 相对起点的增量，例如「+2:30」/「−12:00」。 */
    var scrubDeltaText by mutableStateOf("")

    /** 目标位置 0..1。 */
    var scrubProgress by mutableStateOf(0f)

    /**
     * 已缓冲到哪（0..1）。摇杆拖进度时面板通常是收着的，这条细线是**唯一**看得见的轨道 ——
     * 缓冲段画在上面，用户才知道「拖到这里要不要重新等」（用户 2026-09-06）。
     */
    var scrubBuffered by mutableStateOf(0f)

    /** 转圈下面那行字：视频是「缓冲中…」，空间画廊等图片下载时换成「正在读取…」。 */
    var loadingLabelRes by mutableStateOf(R.string.xr_buffering)
}

/** 出入场时长（ms）；`:app` 隐藏后要等这么久再销毁实体，让退场动画播完。 */
const val BUFFERING_ANIM_MS = 220

/**
 * 缓冲指示：整块面板与幕布同形同位叠在画面上（`:app` 负责几何），这里只画一枚转圈 + 「缓冲中…」。
 *
 * - **没有底、没有阴影**：不压暗画面，文字不描影（用户 2026-09-05：「移除缓冲提示的阴影」）。
 * - **有出有入**：淡入放大出现、淡出缩小消失；实体在退场播完之后才销毁。
 */
@Composable
fun BufferingIndicator(state: BufferingState) {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        // 翻页光轮也压在正中：拖起来的那一刻把转圈 / 拖动预览让出去，别两团东西叠在一起
        //（有出有入：这里是淡出，不是硬切）。
        AnimatedVisibility(
            visible = state.visible && !state.swipe.active,
            enter = fadeIn(tween(BUFFERING_ANIM_MS)) + scaleIn(tween(BUFFERING_ANIM_MS), initialScale = 0.85f),
            exit = fadeOut(tween(BUFFERING_ANIM_MS)) + scaleOut(tween(BUFFERING_ANIM_MS), targetScale = 0.85f),
        ) {
            val scrub = state.scrubText
            if (scrub != null) {
                ScrubPreview(
                    text = scrub,
                    delta = state.scrubDeltaText,
                    progress = state.scrubProgress,
                    buffered = state.scrubBuffered,
                )
            } else {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                ) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(72.dp),
                        color = Color.White,
                        trackColor = Color(0x33FFFFFF),
                        strokeWidth = 6.dp,
                    )
                    Text(text = stringResource(state.loadingLabelRes), color = Color.White, fontSize = 22.sp)
                }
            }
        }
        // 横拖翻片的预示光轮：拖动期间它独占正中（转圈已经让位）。
        StageSwipeHint(state.swipe)
    }
}

/**
 * 摇杆拖动进度时压在画面正中的预览：目标时间（大字）· 增量（小字）· 一条细进度。
 * 只有文字与线，不解码画面（用户 2026-09-05 选的轻量版）；不压暗画面、不描影，与缓冲指示同一风格。
 *
 * 细线的三层与面板上的 [SeekBar] 同构：空轨道 → 已缓冲 → 目标位置。
 */
@Composable
private fun ScrubPreview(text: String, delta: String, progress: Float, buffered: Float) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        Text(text = text, color = Color.White, fontSize = 44.sp)
        Text(text = delta, color = Color(0xCCFFFFFF), fontSize = 24.sp)
        Box(
            modifier = Modifier
                .width(SCRUB_BAR_WIDTH)
                .height(6.dp)
                .clip(RoundedCornerShape(3.dp))
                .background(Color(0x55FFFFFF)),
        ) {
            val played = progress.coerceIn(0f, 1f)
            val loaded = buffered.coerceIn(0f, 1f)
            if (loaded > played) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth(loaded)
                        .height(6.dp)
                        .background(Color(0x88FFFFFF)),
                )
            }
            Box(
                modifier = Modifier
                    .fillMaxWidth(played)
                    .height(6.dp)
                    .background(Color.White),
            )
        }
    }
}

private val SCRUB_BAR_WIDTH = 260.dp

/**
 * 交给 `ComposeViewPanelRegistration` 的工厂；`:app` 侧没有 Compose 编译器插件，只认 View。
 *
 * ⛔ 内容包一层 [PanelLocalization]：文案跟应用内选定的语言走，不跟系统语言走。
 */
fun createBufferingView(context: Context, state: BufferingState): ComposeView =
    ComposeView(context).apply {
        setContent { PanelLocalization { BufferingIndicator(state) } }
    }
