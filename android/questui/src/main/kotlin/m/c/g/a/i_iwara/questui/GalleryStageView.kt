package m.c.g.a.i_iwara.questui

import android.content.Context
import androidx.annotation.StringRes
import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.calculatePan
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.input.pointer.positionChanged
import androidx.compose.ui.layout.ContentScale
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
    //
    // ⛔ 幕布里的内容**不能缩放、不能拖动**（用户 2026-09-13：快速点两下图片瞬间放大还能拖，
    // 「空间幕布不应该有这种效果」）。要看大图就把幕布本身拉大 / 拉近 —— 那是窗框和摇杆的事。
    // 捏合、双击放大、按住推摇杆放大镜三条已整只删掉，别再加回来。

    /**
     * 横拖**松手**且幅度过阈值：翻页。true = 下一张（向左拖）。
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
     * `:app` 用它记「这次按下落在幕布上」（叠层提前建、点按 toggle 面板的判定）。
     */
    var onPressChanged: ((pressed: Boolean, x: Float, y: Float) -> Unit)? = null

    internal fun notePress(pressed: Boolean, x: Float, y: Float) {
        onPressChanged?.invoke(pressed, x, y)
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
            .stageGestures(state),
    ) {
        // ⛔ 翻页预示浮标**不画在这里**：它在幕布叠层面板上（`vr_buffering_panel`），
        // 理由见 [StageSwipeHint]。这块画布是 2048 见方、贴到非方幕布上会被非等比拉伸。
        StageImage(state, model, itemId, context, loader)
    }
}

/** 画面本体。 */
@Composable
private fun BoxScope.StageImage(
    state: GalleryStageState,
    model: String?,
    itemId: String,
    context: Context,
    loader: ImageLoader,
) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        // 画布是方的、幕布不是：先在画布里占一块「贴上去正好是图片比例」的矩形 (fx, fy)。
        // 两个比例只要有一个不知道就退回老办法（Fit 满画布），至少不会变形得离谱。
        val ai = state.imageAspect
        val aq = state.quadAspect
        val known = ai > 0f && aq > 0f
        val fx = if (!known) 1f else if (ai >= aq) 1f else ai / aq
        val fy = if (!known) 1f else if (ai >= aq) aq / ai else 1f
        // ⛔ 这块矩形不能直接当布局尺寸交给 AsyncImage（2026-09-13 动图错位）：它在**画布像素**里
        // 不是图片比例，静图 BitmapPainter + FillBounds 会老实抻满，但 coil-gif 的 ImageDecoderDecoder
        // 把动图包进 `coil.drawable.ScaleDrawable`，按请求的 Scale **保比例**画 —— FillBounds 映射成
        // Scale.FILL＝保比例铺满再裁掉，幕布上看就是「放大 + 错位 + 缺一截」，而面板胶片里的缩略图
        // 没有方画布拉伸所以正常。
        // 所以布局给**图片原比例**的盒子（Fit 进画布，任何 Drawable 都画得对），再用 graphicsLayer
        // 把整层抻到 (fx, fy)。Coil 按布局尺寸解码，长边仍占满画布，清晰度与原来一致。
        val boxW = if (!known) 1f else minOf(1f, ai)
        val boxH = if (!known) 1f else minOf(1f, 1f / ai)
        val stretchX = fx / boxW
        val stretchY = fy / boxH
        // 换图走 Crossfade 而不是 Coil 自己的 crossfade：后者是「占位 → 图」，前者是「上一张 → 下一张」。
        Crossfade(targetState = model to itemId, animationSpec = tween(GALLERY_STAGE_FADE_MS), label = "stage") { (m, id) ->
            if (m != null) {
                val data: Any = if (m.startsWith("http://") || m.startsWith("https://")) m else File(m)
                AsyncImage(
                    model = ImageRequest.Builder(context).data(data).build(),
                    imageLoader = loader,
                    contentDescription = null,
                    contentScale = if (known) ContentScale.FillBounds else ContentScale.Fit,
                    modifier = Modifier
                        .fillMaxWidth(boxW)
                        .fillMaxHeight(boxH)
                        .graphicsLayer {
                            scaleX = stretchX
                            scaleY = stretchY
                        },
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
 * 幕布上的手势（手柄射线 / 手指都是 Compose 指针）—— 只剩一条：
 * - 单指横拖 = 攒翻页幅度（画面**不动**，只把进度写给 [StageSwipeHint]，松手过阈值才报
 *   [GalleryStageState.onSwipe]）；
 * - 短按不动：这里**什么都不做**，那一下留给 `:app` 的 selectUp 去 toggle 控制面板。
 *
 * ⛔ 没有缩放 / 平移（见 [GalleryStageState] 的「手势」段）。第二枚指针、或 `:app` 说正在两手缩放
 * **幕布本身**（`swipe.blocked`）时，这一次手势的翻页整只作废 —— 那段位移是捏出来的，不能松手顺带翻一页。
 * ⛔ 「点一下」**不消费**：它要落到 `:app` 的 selectDown / selectUp 判定里去 toggle 控制面板。
 * 这里只在真在横拖时才 consume。
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
                val pan = event.calculatePan()
                val now = event.changes.first().uptimeMillis
                // ⛔ 作废是**粘住这一次手势**的：两手缩放结束后手指多半还按着，不能等 blocked 一撤就接着算翻页。
                if (!swipeVoided && (event.changes.size > 1 || state.swipe.blocked)) {
                    swipeVoided = true
                    dragging = false
                    state.swipe.cancel()
                }
                // 横拖只攒幅度、不动画面。越过触摸阈值才起算 —— 手抖一下就弹出预示浮窗的话，每次点按都会闪一枚。
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
                lastAt = now
                event.changes.firstOrNull()?.let { last = it.position }
                if (dragging) event.changes.forEach { if (it.positionChanged()) it.consume() }
            } while (true)
            state.notePress(false, last.x - center.x, last.y - center.y)
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

/** 交给 `ComposeViewPanelRegistration` 的工厂（同 [createBufferingView]）。 */
fun createGalleryStageView(context: Context, state: GalleryStageState): ComposeView =
    ComposeView(context).apply {
        setContent { GalleryStage(state) }
    }
