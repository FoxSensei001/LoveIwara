package m.c.g.a.i_iwara.questui

import androidx.annotation.StringRes
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.ChevronLeft
import com.meta.spatial.uiset.theme.icons.regular.ChevronRight
import kotlin.math.abs

/**
 * 幕布上「横拖翻上一个 / 下一个」的**状态机 + 判定**，图片幕布与视频幕布共用一份。
 *
 * # 为什么是共享件
 *
 * 两块幕布的**输入来源不同**：图片幕布是 Compose 面板，拿得到指针事件（[GalleryStageView]）；
 * 视频幕布是 ExoPlayer 的 Surface 面板，没有 Compose，只能由 `:app` 用手柄射线 × 窗面自己算
 * （`ImmersiveActivity.updateStageSwipe`）。但**阈值、橡皮筋、甩动判定、浮窗长什么样**必须是
 * 同一份 —— 分两处写就是同一个手感调两遍。所以这里只收「幅度进来、翻不翻出去」。
 *
 * # 语义
 *
 * 拖动过程中幕布上的内容**一动不动**（用户 2026-09-06），只有 [StageSwipeHint] 那枚浮窗在长；
 * 松手过阈值才真翻页。[progress] 的单位是**阈值倍数**：±1 就是「松手会翻」。
 */
class StageSwipeState {
    /** 正在拖（浮窗的显隐闸门）。 */
    var active by mutableStateOf(false)
        private set

    /** 当前幅度，单位=阈值倍数；正 = 朝下一个。 */
    var progress by mutableStateOf(0f)
        private set

    /** 还有没有上一个 / 下一个：到头的方向不出进度，直接换成一句「到头了」（见 [StageSwipeHint]）。 */
    var canPrevious by mutableStateOf(false)
    var canNext by mutableStateOf(false)

    /**
     * 到头时那句话的词条：「已经是第一张 / 最后一张」。
     *
     * ⛔ 横拖翻片**只有空间画廊有**（视频详情页进来的那块幕布上没有，用户 2026-09-06），
     * 所以两块幕布——图片那块与图库里视频那块——说的都是「张」。留成可写的字段只是不想把
     * 词条钉死在这个共享件里。
     */
    var noPreviousRes by mutableStateOf(R.string.xr_swipe_no_previous_image)
    var noNextRes by mutableStateOf(R.string.xr_swipe_no_next_image)

    /**
     * 被 `:app` 否决：期间不接受 [update]、[end] 一律不翻，已经浮出来的立刻收。
     *
     * ⛔ 这是**两手抓取缩放**唯一挡得住的地方。Quest 上两只手柄的光标**不会**被 Compose 当成
     * 两枚指针（§19 续十二·第三轮真机实测：双指捏合没反应，缩放只能走原生两手抓取），所以
     * 图片幕布那块 Compose 只看得见其中一枚在横着走 —— 靠 `changes.size > 1` / `calculateZoom()`
     * 判「这是捏合不是横拖」永远不成立（用户 2026-09-06：两指放大时下面还在长翻页进度条）。
     * 谁在两手缩放只有 `:app` 知道，只能由它写进来。
     */
    var blocked: Boolean = false
        set(value) {
            if (field == value) return
            field = value
            if (value) cancel()
        }

    fun begin() {
        if (blocked) return
        active = true
        progress = 0f
    }

    /** [fraction] = 已拖过的横向位移 ÷ 幕宽，**正 = 朝下一个**（即向左拖）。 */
    fun update(fraction: Float) {
        if (blocked) return
        active = true
        val allowed = if (fraction > 0f) canNext else canPrevious
        val p = fraction / COMMIT_FRACTION
        progress = (if (allowed) p else p * BLOCKED_RUBBER).coerceIn(-MAX_PROGRESS, MAX_PROGRESS)
    }

    /**
     * 松手。[velocityPerSec] = 甩出速度（幕宽比例每秒，与 [update] 同向）。
     * @return +1 = 翻到下一个，-1 = 上一个，0 = 不翻（弹回）。
     */
    fun end(velocityPerSec: Float): Int {
        val p = progress
        active = false
        progress = 0f
        if (p == 0f) return 0
        val forward = p > 0f
        if (if (forward) !canNext else !canPrevious) return 0
        // 甩得够快也算数：方向要与位移一致，且已经拖出一小截（免得抬手抖一下就翻）。
        val flung = abs(velocityPerSec) >= FLING_PER_SEC &&
            (velocityPerSec > 0f) == forward &&
            abs(p) >= FLING_MIN_PROGRESS
        if (abs(p) < 1f && !flung) return 0
        return if (forward) 1 else -1
    }

    fun cancel() {
        active = false
        progress = 0f
    }

    companion object {
        /**
         * 横拖这么多幕宽 = 松手就翻（进度条填满的那一点）。
         * ⛔ 0.18 太长（用户 2026-09-06 真机）：手柄射线是角位移，幕布越远越费劲。
         */
        const val COMMIT_FRACTION = 0.10f

        /** 到头那个方向的阻尼：拖多远都只推得动一点点（配合那句「到头了」）。 */
        const val BLOCKED_RUBBER = 0.25f

        /** 甩出去也算翻页：幕宽比例每秒。 */
        const val FLING_PER_SEC = 1.1f

        /** 甩之前至少得拖出这么多（阈值倍数）。 */
        const val FLING_MIN_PROGRESS = 0.35f

        /** 进度封顶（拖过头也不再长）。 */
        const val MAX_PROGRESS = 1.6f
    }
}

/**
 * 翻页预示浮窗：横拖时从幕布下沿浮出的一枚小胶囊。
 *
 * 它是**唯一**的翻页反馈（画面不跟手、两侧也没有预览贴图），所以三种状态必须一眼分得开：
 * - 攒着（没满）：方向箭头 + 白色进度条，松手弹回；
 * - 满了：转 [PanelTokens.CHARGE] 的绿并轻微放大 = 松手就翻；
 * - **到头**：不画进度条，直接换成一句「已经是最后一张」（[StageSwipeState.noNextRes]），
 *   胶囊只跟着手推一点点就推不动了（橡皮筋）。
 *
 * ⛔ 到头那一档为什么必须是**文字**：只把进度条染橙、填不满，用户读到的仍是「我触发了翻页却没反应」
 * （用户 2026-09-06 真机原话）。拖不动这件事必须自己说出来，不能让人从颜色去猜。
 */
@Composable
fun BoxScope.StageSwipeHint(state: StageSwipeState) {
    val raw = state.progress
    val visible = state.active && abs(raw) > 0.02f
    val appear by animateFloatAsState(
        targetValue = if (visible) 1f else 0f,
        animationSpec = tween(if (visible) 120 else 220),
        label = "swipeHintAppear",
    )
    if (appear <= 0.01f) return

    val forward = raw >= 0f
    val allowed = if (forward) state.canNext else state.canPrevious
    val armed = allowed && abs(raw) >= 1f
    val fill by animateFloatAsState(abs(raw).coerceAtMost(1f), tween(90), label = "swipeHintFill")
    val scale by animateFloatAsState(if (armed) 1.08f else 1f, tween(140), label = "swipeHintScale")
    // 到头时胶囊自己朝那个方向挪一点点（最多 12dp）就挪不动了 —— 橡皮筋的手感，配合那句话。
    val nudge by animateFloatAsState(
        targetValue = if (allowed) 0f else (raw.coerceIn(-1f, 1f) * -12f),
        animationSpec = tween(90),
        label = "swipeHintNudge",
    )
    val tint = when {
        !allowed -> PanelTokens.WARN
        armed -> PanelTokens.CHARGE
        else -> PanelTokens.ON_SURFACE
    }

    Row(
        modifier = Modifier
            .align(Alignment.BottomCenter)
            .padding(bottom = 28.dp)
            .graphicsLayer {
                alpha = appear
                scaleX = scale
                scaleY = scale
                translationX = nudge.dp.toPx()
                // 浮出来的那一下从下方 10px 抬上来，收回去时反过来。
                translationY = (1f - appear) * 10.dp.toPx()
            }
            .clip(RoundedCornerShape(50))
            .background(PanelTokens.POPUP.copy(alpha = 0.92f))
            .padding(horizontal = 16.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        // 箭头指向要去的那一个：向左拖 = 下一个 = 右箭头（与胶片、摇杆同一套方向约定）。
        if (!forward) SwipeHintIcon(SpatialIcons.Regular.ChevronLeft, R.string.xr_previous, tint)
        if (allowed) {
            Box(
                modifier = Modifier
                    .width(96.dp)
                    .height(6.dp)
                    .clip(RoundedCornerShape(50))
                    .background(PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.35f)),
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxHeight()
                        .fillMaxWidth(fill)
                        .align(if (forward) Alignment.CenterStart else Alignment.CenterEnd)
                        .clip(RoundedCornerShape(50))
                        .background(tint),
                )
            }
        } else {
            Text(
                text = stringResource(if (forward) state.noNextRes else state.noPreviousRes),
                color = tint,
                fontSize = 18.sp,
            )
        }
        if (forward) SwipeHintIcon(SpatialIcons.Regular.ChevronRight, R.string.xr_next, tint)
    }
}

@Composable
private fun SwipeHintIcon(icon: ImageVector, @StringRes descriptionRes: Int, tint: Color) {
    Icon(
        imageVector = icon,
        contentDescription = stringResource(descriptionRes),
        tint = tint,
        modifier = Modifier.size(22.dp),
    )
}
