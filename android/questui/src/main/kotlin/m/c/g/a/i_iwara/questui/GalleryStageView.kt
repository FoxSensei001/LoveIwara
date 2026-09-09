package m.c.g.a.i_iwara.questui

import android.content.Context
import androidx.annotation.StringRes
import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.calculateCentroid
import androidx.compose.foundation.gestures.calculatePan
import androidx.compose.foundation.gestures.calculateZoom
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.input.pointer.positionChanged
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.ChevronLeft
import com.meta.spatial.uiset.theme.icons.regular.ChevronRight
import kotlin.math.abs
import coil.ImageLoader
import coil.compose.AsyncImage
import coil.compose.AsyncImagePainter
import coil.decode.ImageDecoderDecoder
import coil.request.ImageRequest
import java.io.File

/**
 * 空间画廊的**幕布内容**：一张图（或一张 gif）。
 *
 * 这块面板与视频幕布是同一个「窗」（同一套曲率 / 距离 / 幕宽 / 抓挪缩放，见 `ImmersiveActivity`），
 * 只是画的东西不同：视频是 ExoPlayer 往 Surface 上画，图片是这里的 Compose + Coil。
 * 面板像素尺寸由 `:app` 按图片比例给（长边有上限），Coil 按面板尺寸降采样解码 —— 8000px 的原图
 * 也不会整张进显存。
 *
 * # 为什么背景透明
 *
 * 面板注册成 ALPHA_BLEND、这里不铺底色：幕布形状按图片比例走，换比例时形状有 320ms 过渡，
 * 过渡中间态图片会短暂 letterbox —— 透明底就是「照片浮在空间里」，实心底会露出一块黑边在缩放。
 * 透视场景下浮着的照片也比一块黑板好看。
 *
 * # 状态怎么来
 *
 * [GalleryStageState.model] 由 `:app` 写：一个本地文件路径（Dart 缓存里的）或退回的网络地址。
 * 加载结果通过 [GalleryStageState.onLoaded] / [GalleryStageState.onFailed] 回给 `:app`
 * （真实尺寸到了才知道该把幕布重塑成什么比例；失败要在面板上如实说）。
 */
class GalleryStageState {
    /** 当前要显示的东西：文件路径 / 网络地址 / null（空）。 */
    var model by mutableStateOf<String?>(null)

    /** 与 [model] 成对：这张图属于哪一项，回调时带回去，免得晚到的结果盖到下一张头上。 */
    var itemId by mutableStateOf("")

    /**
     * ⭐ 画布 ↔ 幕布的拉伸补偿，两个比例缺一不可（0 = 未知，退回 `ContentScale.Fit`）。
     *
     * # 为什么需要补偿
     *
     * 这块面板的**像素画布是方的、且建面板那一刻就定死**（[createGalleryStageView] 注册时给的
     * `DpDisplayOptions`）—— 真机实测 `reshape()` 只换得了幕布的**形状**，换不掉画布尺寸
     * （用户 2026-09-06：竖图进去再切宽图，「宽度和窗口一致、高度却很窄」；反过来则「高度撑满、宽度很窄」，
     * 正是画布留着上一张的比例、内容按它 Fit 之后再被贴到新形状上的样子）。
     *
     * 方画布 → 任意比例的幕布本身就是一次非等比拉伸，所以内容不能直接 Fit 满画布，
     * 要先在画布里占一块「贴到幕布上正好是 [imageAspect]」的矩形：
     * 画布的一块 (fx, fy) 贴到幕布上，横纵各按幕布尺寸缩放，最终比例 = fx/fy × [quadAspect]。
     * 令它等于 [imageAspect] 并让长边占满，就是 [StageImage] 里那两行。
     */
    var imageAspect by mutableStateOf(0f)

    /** 幕布**当前**的比例（形状过渡期间逐帧变），由 `:app` 写。 */
    var quadAspect by mutableStateOf(0f)

    /** 解码成功：真实像素尺寸。 */
    var onLoaded: ((itemId: String, width: Int, height: Int) -> Unit)? = null

    /** 解码失败。 */
    var onFailed: ((itemId: String, message: String) -> Unit)? = null


    // ---- 手势 ----

    /** 放大倍数，1 = 装满幕布；上限 [MAX_ZOOM]。 */
    var scale by mutableStateOf(1f)

    /** 放大后画面的平移（像素，相对幕布中心）。1× 时恒为零。 */
    var offset by mutableStateOf(Offset.Zero)

    /**
     * 1× 下横拖**松手**且幅度过阈值：翻页。true = 下一张（向左拖）。
     *
     * ⛔ 拖动过程中幕布**不动**：图片不跟手、两侧也没有预览贴图，只有 [swipe] 那枚浮窗在长
     *（用户 2026-09-06）。阈值与浮窗都在 [StageSwipeState]，与视频幕布共用一份。
     */
    var onSwipe: ((forward: Boolean) -> Unit)? = null

    /**
     * 横拖状态机（`:app` 每次换项写它的 `canPrevious/canNext`）。
     *
     * ⛔ 可写：`:app` 会把**幕布叠层那一份**（`BufferingState.swipe`）塞进来，让图片幕布与视频幕布
     * 共用同一个实例 —— 预示浮标从此只画在叠层面板上（见 [StageSwipeHint] 的「为什么换载体」）。
     * 这块图片面板是方画布贴非方幕布，在这里画浮标会被拉变形、还跟着幕布一起缩放。
     */
    var swipe: StageSwipeState = StageSwipeState()

    /**
     * 指针按下 / 抬起。[x] [y] = 按压点相对幕布中心的像素坐标。
     *
     * `:app` 用它两件事：主幕布记「摇杆上下改成缩放内容」，侧面板记「这次按下落在面板上」。
     */
    var onPressChanged: ((pressed: Boolean, x: Float, y: Float) -> Unit)? = null

    /** 倍数变了（捏合 / 双击 / 按住推摇杆）：`:app` 拿它续「面板空闲收起」的倒计时。 */
    var onZoomChanged: ((scale: Float) -> Unit)? = null

    /** 幕布像素尺寸，由布局回填；缩放夹边界要用。 */
    private var viewport = Size.Zero

    /** 最近一次按下的位置（相对幕布中心）：摇杆缩放以它为原点。 */
    private var pressPoint = Offset.Zero

    internal fun noteViewport(width: Float, height: Float) {
        viewport = Size(width, height)
    }

    internal fun notePress(pressed: Boolean, x: Float, y: Float) {
        if (pressed) pressPoint = Offset(x, y)
        onPressChanged?.invoke(pressed, x, y)
    }

    fun resetZoom() {
        if (scale != 1f || offset != Offset.Zero) {
            scale = 1f
            offset = Offset.Zero
            onZoomChanged?.invoke(1f)
        }
    }

    /**
     * 以**最近一次按下的那一点**为原点缩放（指着图按住扳机再推摇杆上下 = 放大镜）。
     * 与捏合同一套原点公式：那一点在缩放前后停在原地。
     */
    fun zoomAtPress(factor: Float) {
        val next = (scale * factor).coerceIn(1f, MAX_ZOOM)
        if (next <= 1.001f) {
            resetZoom()
            return
        }
        val ratio = next / scale
        offset = clampOffset(pressPoint - (pressPoint - offset) * ratio, next, viewport.width, viewport.height)
        scale = next
        onZoomChanged?.invoke(scale)
    }

    companion object {
        const val MAX_ZOOM = 6f
    }
}

/** 图片切换的淡入淡出时长（ms）。 */
const val GALLERY_STAGE_FADE_MS = 220

@Composable
fun GalleryStage(state: GalleryStageState) {
    val context = LocalContext.current
    // 带 gif 解码器的 loader：coil-compose 默认那只只解静图（gif 只出第一帧）。
    val loader = remember(context) {
        ImageLoader.Builder(context)
            .components { add(ImageDecoderDecoder.Factory()) }
            .crossfade(false)
            .build()
    }
    val model = state.model
    val itemId = state.itemId
    Box(
        modifier = Modifier
            .fillMaxSize()
            .onSizeChanged { state.noteViewport(it.width.toFloat(), it.height.toFloat()) }
            .stageGestures(state),
    ) {
        // ⛔ 翻页预示浮标**不画在这里**：它在幕布叠层面板上（`vr_buffering_panel`），
        // 理由见 [StageSwipeHint]。这块画布是 2048 见方、贴到非方幕布上会被非等比拉伸。
        StageImage(state, model, itemId, context, loader)
    }
}

/** 画面本体：缩放 / 平移都作用在这一层。 */
@Composable
private fun BoxScope.StageImage(
    state: GalleryStageState,
    model: String?,
    itemId: String,
    context: Context,
    loader: ImageLoader,
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .graphicsLayer {
                // 以幕布中心为原点放大 + 平移；1× 时都是恒等，不额外花钱。
                scaleX = state.scale
                scaleY = state.scale
                translationX = state.offset.x
                translationY = state.offset.y
            },
        contentAlignment = Alignment.Center,
    ) {
        // 画布是方的、幕布不是：先在画布里占一块「贴上去正好是图片比例」的矩形，再 FillBounds 铺满它。
        // 两个比例只要有一个不知道就退回老办法（Fit 满画布），至少不会变形得离谱。
        val ai = state.imageAspect
        val aq = state.quadAspect
        val known = ai > 0f && aq > 0f
        val fx = if (!known) 1f else if (ai >= aq) 1f else ai / aq
        val fy = if (!known) 1f else if (ai >= aq) aq / ai else 1f
        // 换图走 Crossfade 而不是 Coil 自己的 crossfade：后者是「占位 → 图」，前者是「上一张 → 下一张」。
        Crossfade(targetState = model to itemId, animationSpec = tween(GALLERY_STAGE_FADE_MS), label = "stage") { (m, id) ->
            if (m != null) {
                val data: Any = if (m.startsWith("http://") || m.startsWith("https://")) m else File(m)
                AsyncImage(
                    model = ImageRequest.Builder(context).data(data).build(),
                    imageLoader = loader,
                    contentDescription = null,
                    contentScale = if (known) ContentScale.FillBounds else ContentScale.Fit,
                    modifier = Modifier.fillMaxWidth(fx).fillMaxHeight(fy),
                    onState = { s ->
                        when (s) {
                            is AsyncImagePainter.State.Success -> {
                                val d = s.result.drawable
                                state.onLoaded?.invoke(id, d.intrinsicWidth, d.intrinsicHeight)
                            }
                            is AsyncImagePainter.State.Error ->
                                state.onFailed?.invoke(id, s.result.throwable.message ?: s.result.throwable.javaClass.simpleName)
                            else -> Unit
                        }
                    },
                )
            }
        }
    }
}

/**
 * 幕布上的手势（手柄射线 / 手指都是 Compose 指针）：
 * - 单指拖：1× 时横拖 = 攒翻页幅度（画面**不动**，只把进度写给 [StageSwipeHint]，松手过阈值才
 *   报 [GalleryStageState.onSwipe]）；放大后 = 平移画面（夹在画面边界内）；
 * - 双指捏合（两只手 / 两支手柄各一枚光标）：以两指中心为原点缩放，1×–[GalleryStageState.MAX_ZOOM]；
 * - 双击：1× ↔ 2.5×（以点按处为原点）；
 * - 短按不动：这里**什么都不做**，那一下留给 `:app` 的 selectUp 去 toggle 控制面板。
 *
 * ⛔ **缩放与翻页互斥**：这一次手势里只要出现过第二枚指针、或真的缩放过，翻页那条就整只作废
 * （[swipeVoided]）—— 捏合几乎总是先有一枚指针落下、动一小截，第二枚才到；不作废的话
 * 「两指放大」会在松手时顺带翻一页（用户 2026-09-06）。缩回 1× 也不恢复：那一次的位移是捏出来的。
 * ⛔ 「点一下」（短按不动）**不消费**：它要落到 `:app` 的 selectDown / selectUp 判定里去 toggle 控制面板。
 * 这里只在真有位移 / 缩放时才 consume。
 */
private fun Modifier.stageGestures(state: GalleryStageState): Modifier = this
    .pointerInput(state) {
        awaitEachGesture {
            val down = awaitFirstDown(requireUnconsumed = false)
            val width = size.width.toFloat().coerceAtLeast(1f)
            val center = Offset(size.width / 2f, size.height / 2f)
            state.notePress(true, down.position.x - center.x, down.position.y - center.y)
            var totalDx = 0f
            var swipeVoided = false
            var dragging = false
            var velocity = 0f // 幕宽比例每秒
            var lastAt = down.uptimeMillis
            var last = down.position
            var pressed: Boolean
            do {
                val event = awaitPointerEvent()
                pressed = event.changes.any { it.pressed }
                if (!pressed) break
                val zoom = event.calculateZoom()
                val pan = event.calculatePan()
                val zooming = abs(zoom - 1f) > 1e-3f
                val now = event.changes.first().uptimeMillis
                // 第二枚指针一到（或真缩放了一下、或 `:app` 说正在两手缩放）：这一次手势归缩放，
                // 翻页整只作废并把已经浮出来的收掉。⛔ 作废是**粘住这一次手势**的：两手缩放结束后
                // 手指多半还按着，那段位移是捏出来的，不能等 blocked 一撤就接着算翻页。
                if (!swipeVoided && (event.changes.size > 1 || zooming || state.swipe.blocked)) {
                    swipeVoided = true
                    dragging = false
                    state.swipe.cancel()
                }
                if (zooming) {
                    val centroid = event.calculateCentroid() - center
                    val next = (state.scale * zoom).coerceIn(1f, GalleryStageState.MAX_ZOOM)
                    val ratio = next / state.scale
                    // 以两指中心为原点：中心那一点在缩放前后停在原地。
                    state.offset = centroid - (centroid - state.offset) * ratio
                    state.scale = next
                }
                if (state.scale > 1.001f) {
                    state.offset = clampOffset(state.offset + pan, state.scale, size.width.toFloat(), size.height.toFloat())
                } else {
                    state.offset = Offset.Zero
                    // 1× 且单指：横拖只攒幅度、不动画面。越过触摸阈值才起算 ——
                    // 手抖一下就弹出预示浮窗的话，每次点按都会闪一枚。
                    if (!swipeVoided) {
                        totalDx += pan.x
                        if (!dragging && abs(totalDx) > viewConfiguration.touchSlop) dragging = true
                        if (dragging) {
                            if (pan.x != 0f) {
                                val dt = (now - lastAt).coerceAtLeast(1L) / 1000f
                                val v = -(pan.x / width) / dt
                                velocity = if (velocity == 0f) v else velocity * 0.6f + v * 0.4f
                            }
                            state.swipe.update(-totalDx / width)
                        }
                    }
                }
                lastAt = now
                event.changes.firstOrNull()?.let { last = it.position }
                if (zooming || dragging || (state.scale > 1.001f && pan != Offset.Zero)) {
                    if (zooming) state.onZoomChanged?.invoke(state.scale)
                    event.changes.forEach { if (it.positionChanged()) it.consume() }
                }
            } while (true)
            state.notePress(false, last.x - center.x, last.y - center.y)
            if (state.scale <= 1.001f && state.offset != Offset.Zero) state.offset = Offset.Zero
            // 短按不动：什么都不做 —— 那一下要留给 `:app` 的 selectUp 去 toggle 控制面板。
            if (dragging) {
                when (state.swipe.end(velocity)) {
                    1 -> state.onSwipe?.invoke(true)
                    -1 -> state.onSwipe?.invoke(false)
                }
            } else {
                state.swipe.cancel()
            }
        }
    }
    .pointerInput(state) {
        detectTapGestures(
            onDoubleTap = { pos ->
                if (state.scale > 1.001f) {
                    state.resetZoom()
                } else {
                    val centroid = pos - Offset(size.width / 2f, size.height / 2f)
                    val next = DOUBLE_TAP_ZOOM
                    state.offset = clampOffset(centroid - centroid * next, next, size.width.toFloat(), size.height.toFloat())
                    state.scale = next
                    state.onZoomChanged?.invoke(next)
                }
            },
        )
    }

/** 放大后的平移夹在画面边界内（画面比例与幕布一致，所以边界只由倍数决定）。 */
private fun clampOffset(offset: Offset, scale: Float, width: Float, height: Float): Offset {
    val maxX = (width * (scale - 1f) / 2f).coerceAtLeast(0f)
    val maxY = (height * (scale - 1f) / 2f).coerceAtLeast(0f)
    return Offset(offset.x.coerceIn(-maxX, maxX), offset.y.coerceIn(-maxY, maxY))
}

private const val DOUBLE_TAP_ZOOM = 2.5f

/** 交给 `ComposeViewPanelRegistration` 的工厂（同 [createBufferingView]）。 */
fun createGalleryStageView(context: Context, state: GalleryStageState): ComposeView =
    ComposeView(context).apply {
        setContent { GalleryStage(state) }
    }
