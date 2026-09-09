package m.c.g.a.i_iwara.questui

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.ChevronLeft
import com.meta.spatial.uiset.theme.icons.regular.ChevronRight
import kotlinx.coroutines.launch
import kotlin.math.abs
import kotlin.math.tanh

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

    /**
     * 跨过 / 退回「松手就翻」那条线的一次性回调 —— `:app` 拿它出一声。
     *
     * 官方 hands-ui：「**Hands have no haptics.** … This is not optional.」翻页是幕布上唯一
     * 画面完全不动的操作，没有声音就只剩眼睛一条通道。⛔ 只在**跨越**那一刻发，不是每帧。
     */
    var onArmedChanged: ((armed: Boolean) -> Unit)? = null

    private var armed = false

    private fun setArmed(value: Boolean) {
        if (armed == value) return
        armed = value
        onArmedChanged?.invoke(value)
    }

    fun begin() {
        if (blocked) return
        active = true
        progress = 0f
        armed = false
    }

    /** [fraction] = 已拖过的横向位移 ÷ 幕宽，**正 = 朝下一个**（即向左拖）。 */
    fun update(fraction: Float) {
        if (blocked) return
        active = true
        val allowed = if (fraction > 0f) canNext else canPrevious
        val p = fraction / COMMIT_FRACTION
        progress = (if (allowed) p else p * BLOCKED_RUBBER).coerceIn(-MAX_PROGRESS, MAX_PROGRESS)
        setArmed(allowed && abs(progress) >= 1f)
    }

    /**
     * 松手。[velocityPerSec] = 甩出速度（幕宽比例每秒，与 [update] 同向）。
     * @return +1 = 翻到下一个，-1 = 上一个，0 = 不翻（弹回）。
     */
    fun end(velocityPerSec: Float): Int {
        val p = progress
        active = false
        progress = 0f
        // 松手不再报「退回阈值下」：翻页本身另有反馈，这一声会跟它撞在一起。
        armed = false
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
        armed = false
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
 * 翻页预示：压在幕布**正中**的一枚「光轮」。
 *
 * # 为什么从底部胶囊改成正中光轮（2026-09-09，用户）
 *
 * 老样子是贴幕布下沿的一枚胶囊，三条账一起烂：
 * 1. **看不见** —— 大幕布的下沿离视线很远，翻页是幕布上唯一没有画面反馈的动作，提示却摆在余光外；
 * 2. **会变形** —— 画廊那份画在图片面板 `vr_image_panel` 上，而它是 `DpDisplayOptions(2048,2048)`
 *    的**方**画布贴到**非方**幕布上：16:9 的图把胶囊横向拉 1.78×，9:16 的图反过来压成细高条，
 *    每张图比例不同、丑法还不一样（图片本体有 `imageAspect/quadAspect` 补偿，浮窗没有）；
 * 3. **会跟着幕布一起缩放** —— 同一个方画布，幕布拉大一倍胶囊也大一倍。
 *
 * ⭐ 2、3 两条**不是靠改样式修的**，是靠换载体：现在两块幕布的浮标都画在幕布叠层面板
 * （`vr_buffering_panel`）上 —— 那块是 `DpPerMeterDisplayOptions`，dp 就是固定物理尺寸，
 * 既不随幕宽缩放也不被比例拉伸。图片幕布这边把 [StageSwipeState] 实例交给叠层共用即可
 * （`ImmersiveActivity`: `stage.swipe = bufferingState.swipe`），**别再在图片面板里画一份**。
 * 居中也顺带让它对叠层的形状是否跟得上幕布改形免疫：中心永远是中心。
 *
 * # 长相
 *
 * 与空间里那圈媒体环境光同一套语言：**没有硬边**。底是一团朝外淡到全透的暗晕（不是一块方牌子），
 * 外面再罩一层跟着进度变亮的同色辉光；进度是一圈从 12 点朝目标方向扫的发光弧（下一张顺时针、
 * 上一张逆时针），中心一枚方向箭头随进度往那边挪一点、亮一档。
 *
 * 三态一眼分得开：
 * - **攒着**：白弧 + 暗箭头；
 * - **满了**（松手就翻）：整圈转 [PanelTokens.CHARGE] 绿、一次过冲回弹、一圈扩散涟漪、中心闪一下；
 * - **到头**：不画弧，改画一根「顶住」的门闩 + 那句「已经是最后一张」，整只朝那边 tanh 阻尼推一点点
 *   就推不动（⛔ 到头必须**说出来**，不能只靠颜色让人猜 —— 用户 2026-09-06 真机原话）。
 *
 * # 动效
 *
 * ⭐ **跟手的通道一律零动画**（弧长、箭头位移、门闩阻尼都直接由 [StageSwipeState.progress] 驱动）。
 * 老实现给 `fill` 挂了 90ms tween，等于给直接操作加了一档固定延迟 —— VR 里这就是「不跟手」。
 * 弹簧只留给**离散事件**：出现、过阈值那一下、退回阈值下。
 */
@Composable
fun BoxScope.StageSwipeHint(state: StageSwipeState) {
    val raw = state.progress
    val visible = state.active && abs(raw) > 0.015f
    // 出场用弹簧（有脾气），退场用短 tween（别在收的时候还晃）。
    val appear by animateFloatAsState(
        targetValue = if (visible) 1f else 0f,
        animationSpec = if (visible) {
            spring(dampingRatio = 0.72f, stiffness = 520f)
        } else {
            tween(160)
        },
        label = "swipeHintAppear",
    )
    if (appear <= 0.004f) return

    val forward = raw >= 0f
    val allowed = if (forward) state.canNext else state.canPrevious
    val progress = abs(raw).coerceAtMost(1f) // 跟手：不经过任何动画
    val armed = allowed && abs(raw) >= 1f
    // 到头顶死：橡皮筋推到底那一刻抖一下（一次，不循环）。到头方向有 [BLOCKED_RUBBER] 的阻尼，
    // 0.6 ≈ 已经拖了 0.24 幕宽 —— 「用力推了但推不动」的那一点。
    val jammed = !allowed && abs(raw) >= 0.6f

    val tint by animateColorAsState(
        targetValue = when {
            !allowed -> PanelTokens.WARN
            armed -> PanelTokens.CHARGE
            else -> PanelTokens.ON_SURFACE
        },
        animationSpec = tween(120),
        label = "swipeHintTint",
    )

    // 过阈值那一下的三件事：中心闪白、涟漪外扩、整只过冲。
    val flash = remember { Animatable(0f) }
    val ripple = remember { Animatable(0f) }
    LaunchedEffect(armed) {
        if (!armed) {
            ripple.snapTo(0f)
            return@LaunchedEffect
        }
        launch {
            flash.snapTo(1f)
            flash.animateTo(0f, tween(240))
        }
        launch {
            ripple.snapTo(0f)
            ripple.animateTo(1f, tween(340, easing = FastOutSlowInEasing))
        }
    }
    val pop by animateFloatAsState(
        targetValue = if (armed) 1.09f else 1f,
        animationSpec = spring(dampingRatio = 0.42f, stiffness = 700f),
        label = "swipeHintPop",
    )
    val shake = remember { Animatable(0f) }
    LaunchedEffect(jammed) {
        if (!jammed) return@LaunchedEffect
        shake.snapTo(1f)
        shake.animateTo(0f, spring(dampingRatio = 0.22f, stiffness = 1400f))
    }

    // 到头那一侧：tanh 自带阻尼，越推越推不动（推到底约 14dp）。
    // ⛔ 朝**要去的那一边**推（与箭头、门闩同侧），不是朝手移动的那一边 —— 三者同侧才读得出
    // 「顶在门闩上推不动」；朝手那边推的话轮子是在**离开**门闩，看着像自己躲开了。
    val nudgeDp = if (allowed) 0f else tanh(raw * 1.15f) * 14f
    val dir = if (forward) 1f else -1f

    Box(
        modifier = Modifier
            .align(Alignment.Center)
            .size(HINT_BOX)
            .graphicsLayer {
                alpha = appear
                val s = (0.88f + 0.12f * appear) * pop
                scaleX = s
                scaleY = s
                translationX = (nudgeDp + shake.value * 2.4f * dir).dp.toPx()
            },
        contentAlignment = Alignment.Center,
    ) {
        StageSwipeDial(
            progress = progress,
            forward = forward,
            allowed = allowed,
            tint = tint,
            flash = flash.value,
            ripple = ripple.value,
        )
        // 箭头指向要去的那一个：向左拖 = 下一个 = 右箭头（与胶片、摇杆同一套方向约定）。
        Icon(
            imageVector = if (forward) SpatialIcons.Regular.ChevronRight else SpatialIcons.Regular.ChevronLeft,
            contentDescription = stringResource(if (forward) R.string.xr_next else R.string.xr_previous),
            tint = tint.copy(alpha = if (allowed) 0.55f + 0.45f * progress else 0.5f),
            modifier = Modifier
                .size(44.dp)
                .offset(x = (dir * 7f * progress).dp),
        )
        // ⛔ 那句话垫在轮子下面、容器尺寸恒定：老实现是把进度条整条换成文字，胶囊宽度会跳一下。
        if (!allowed) {
            Text(
                text = stringResource(if (forward) state.noNextRes else state.noPreviousRes),
                color = tint,
                fontSize = 20.sp,
                modifier = Modifier.offset(y = DIAL_RADIUS + 34.dp),
            )
        }
    }
}

/**
 * 轮子本体（一整块画布画完：暗晕 → 外辉光 → 轨道 → 进度弧 / 门闩 → 涟漪 → 中心闪）。
 *
 * 用 Canvas 而不是叠一堆 Box：辉光要的是**没有边界**的渐变，`background(shape)` 一定带硬边，
 * 压在照片上就是一块贴纸（记忆 `glass-rim-directional-hairline` 同一条账：身子不透明，边上画什么都难看）。
 */
@Composable
private fun StageSwipeDial(
    progress: Float,
    forward: Boolean,
    allowed: Boolean,
    tint: Color,
    flash: Float,
    ripple: Float,
) {
    Canvas(modifier = Modifier.size(HINT_BOX)) {
        val c = center
        val r = DIAL_RADIUS.toPx()
        val track = TRACK_WIDTH.toPx()

        // 1. 暗晕：中心 62% 不透明、朝外淡到全透 —— 亮照片上也读得清，且没有一条边。
        drawCircle(
            brush = Brush.radialGradient(
                colorStops = arrayOf(
                    0f to PanelTokens.POPUP.copy(alpha = 0.62f),
                    0.58f to PanelTokens.POPUP.copy(alpha = 0.44f),
                    1f to Color.Transparent,
                ),
                center = c,
                radius = r * 1.9f,
            ),
            radius = r * 1.9f,
            center = c,
        )

        // 2. 外辉光：跟着进度变亮的同色光晕，和空间里那圈媒体环境光是同一门语言。
        if (progress > 0.01f) {
            val bloom = 0.10f + 0.24f * progress
            drawCircle(
                brush = Brush.radialGradient(
                    colorStops = arrayOf(
                        0.55f to Color.Transparent,
                        0.82f to tint.copy(alpha = bloom),
                        1f to Color.Transparent,
                    ),
                    center = c,
                    radius = r * 1.55f,
                ),
                radius = r * 1.55f,
                center = c,
            )
        }

        // 3. 轨道
        drawCircle(
            color = PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.24f),
            radius = r,
            center = c,
            style = Stroke(width = track, cap = StrokeCap.Round),
        )

        if (allowed) {
            // 4. 进度弧：从 12 点起，下一张顺时针 / 上一张逆时针。三层同色描边冒充辉光
            //    （Modifier.blur 在面板层上不划算，这个便宜且稳）。
            val sweep = 360f * progress * (if (forward) 1f else -1f)
            if (abs(sweep) > 0.5f) {
                val topLeft = Offset(c.x - r, c.y - r)
                val arcSize = androidx.compose.ui.geometry.Size(r * 2f, r * 2f)
                listOf(
                    track * 3.4f to 0.10f,
                    track * 2.0f to 0.20f,
                    track to 1f,
                ).forEach { (w, a) ->
                    drawArc(
                        color = tint.copy(alpha = a),
                        startAngle = -90f,
                        sweepAngle = sweep,
                        useCenter = false,
                        topLeft = topLeft,
                        size = arcSize,
                        style = Stroke(width = w, cap = StrokeCap.Round),
                    )
                }
            }
        } else {
            // 4'. 到头：一根竖着的「门闩」顶在要去的那一侧，越推越实。
            val x = c.x + (if (forward) 1f else -1f) * (r + 13.dp.toPx())
            val half = 20.dp.toPx()
            drawLine(
                color = tint.copy(alpha = 0.35f + 0.5f * progress),
                start = Offset(x, c.y - half),
                end = Offset(x, c.y + half),
                strokeWidth = 6.dp.toPx(),
                cap = StrokeCap.Round,
            )
        }

        // 5. 过阈值：一圈扩散出去的涟漪 + 中心闪一下。
        if (ripple > 0.001f) {
            drawCircle(
                color = tint.copy(alpha = (1f - ripple) * 0.40f),
                radius = r * (1f + 0.45f * ripple),
                center = c,
                style = Stroke(width = track * (1f - ripple * 0.55f), cap = StrokeCap.Round),
            )
        }
        if (flash > 0.001f) {
            drawCircle(color = Color.White.copy(alpha = 0.16f * flash), radius = r, center = c)
        }
    }
}

/** 浮标外框（正方）：暗晕与涟漪都在这块画布里画完，别往外溢。 */
private val HINT_BOX = 260.dp

/** 轮子半径。叠层面板是 500dp/m，所以这是 **0.248m 的实物直径**，与幕布多大无关。 */
private val DIAL_RADIUS = 62.dp

private val TRACK_WIDTH = 5.dp
