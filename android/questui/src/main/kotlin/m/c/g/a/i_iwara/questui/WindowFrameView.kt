package m.c.g.a.i_iwara.questui

import android.content.Context
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.input.pointer.PointerEventType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.ComposeView
import kotlin.math.max
import kotlin.math.min

/**
 * 窗框上的一个「区」。`:app` 用它决定抓住之后是**挪**还是**缩放**；这里用它决定高亮哪一段。
 *
 * - [BODY]：窗体本身（内容面板），不属于窗框，但手柄抓握扳机按在这里也能挪；
 * - 四条边：挪；
 * - 四个角：缩放（锁比例的窗按对角线等比，2D 应用面板可以自由拉）。
 */
enum class WindowFrameZone {
    NONE, BODY,
    EDGE_LEFT, EDGE_RIGHT, EDGE_TOP, EDGE_BOTTOM,
    CORNER_TL, CORNER_TR, CORNER_BL, CORNER_BR;

    val isCorner: Boolean get() = this == CORNER_TL || this == CORNER_TR || this == CORNER_BL || this == CORNER_BR
    val isEdge: Boolean get() = this == EDGE_LEFT || this == EDGE_RIGHT || this == EDGE_TOP || this == EDGE_BOTTOM

    /** 这个区能不能当「把手」抓着挪。 */
    val movesWindow: Boolean get() = this == BODY || isEdge
}

/**
 * 一块窗框的显示状态；`:app` 每帧写几何比例与命中态，面板读。对外是普通属性（理由同 [VideoControlsState]）。
 *
 * # 为什么全是「比例」而不是 dp
 *
 * 窗框面板随窗体一起 `reshape()` 时只换网格、不换像素，画布会被拉伸。用「占整幅的比例」画，
 * 拉伸之后边圈仍然贴着内容的边，不会一侧粗一侧细。
 */
class WindowFrameState {

    /** 射线此刻悬在窗框的哪一段（由本面板自己的指针事件判定，与像素坐标系严格一致）。 */
    var pointerZone by mutableStateOf(WindowFrameZone.NONE)

    /** 射线悬在窗体上但已**贴近边缘**（离边不到几厘米）：把手提前露面，光标一出窗就接得上。 */
    var nearEdge by mutableStateOf(false)

    /** 正在被抓着的区；NONE = 没在拖。 */
    var activeZone by mutableStateOf(WindowFrameZone.NONE)

    /** 边圈厚度 / 整幅宽（高）。 */
    var ringFracX by mutableStateOf(0.03f)
    var ringFracY by mutableStateOf(0.05f)

    /** 角把手的边长 / 整幅宽（高）。 */
    var cornerFracX by mutableStateOf(0.08f)
    var cornerFracY by mutableStateOf(0.14f)

    /** 内容面板的圆角 / 整幅高。 */
    var innerRadiusFrac by mutableStateOf(0f)

    /** 2D 应用面板能自由拉（目前只作记录，外观不区分）。 */
    var freeResize by mutableStateOf(false)

    /** 按当前比例把面板内的一点（0..1）归到某个区；与 `:app` 侧的射线判定用同一套阈值。 */
    fun classify(fx: Float, fy: Float): WindowFrameZone {
        if (fx < 0f || fx > 1f || fy < 0f || fy > 1f) return WindowFrameZone.NONE
        val inBodyX = fx > ringFracX && fx < 1f - ringFracX
        val inBodyY = fy > ringFracY && fy < 1f - ringFracY
        if (inBodyX && inBodyY) return WindowFrameZone.BODY
        val left = fx < cornerFracX
        val right = fx > 1f - cornerFracX
        val top = fy < cornerFracY
        val bottom = fy > 1f - cornerFracY
        return when {
            left && top -> WindowFrameZone.CORNER_TL
            right && top -> WindowFrameZone.CORNER_TR
            left && bottom -> WindowFrameZone.CORNER_BL
            right && bottom -> WindowFrameZone.CORNER_BR
            !inBodyX -> if (fx < 0.5f) WindowFrameZone.EDGE_LEFT else WindowFrameZone.EDGE_RIGHT
            else -> if (fy < 0.5f) WindowFrameZone.EDGE_TOP else WindowFrameZone.EDGE_BOTTOM
        }
    }
}

/** 窗框出入场 / 高亮过渡时长（ms）。 */
const val WINDOW_FRAME_ANIM_MS = 160

/**
 * 三块窗（2D 应用 / 控制面板 / 幕布）共用的自绘窗框。
 *
 * 取代 ISDK 自带的「边缘抓条 + 四角缩放」：那套只在光标贴到边缘时才能拖、外观也改不了
 * （用户 2026-09-05：「不符合直觉，希望自己设置一套边缘」）。这里只负责**画**与**报告悬停区**，
 * 抓 / 挪 / 缩放的几何全在 `:app` 的 `WindowManipulator`。
 *
 * # 视觉：静止时什么都没有
 *
 * 第一版画了一圈半透明底 + 四个直角 L 形把手，用户一眼看出「缺少设计感」：像个包围盒。
 * 现在照 Horizon / visionOS 的窗：
 * - **静止**：完全透明，窗就是窗，没有边框；光标在窗体**内部**操作应用时同样什么都不出现；
 * - **光标到窗框上 / 贴近窗沿**：四条边的中点各现出一枚药丸抓条、四个角各现出一段圆角弧线把手，
 *   都是淡淡的（角只有弧，不画圆点；也不画光晕 / 阴影底 —— 用户 2026-09-05 两轮反馈）；
 * - **光标到某条边 / 某个角**：那一枚亮起来；
 * - **抓住**：亮成冷蓝。
 * 没有一处实心填充，透明区（ALPHA_BLEND）里看到的就是后面的场景。
 *
 * # 有出有入
 *
 * 所有显隐都走 [animateFloatAsState]，不硬切。
 */
@Composable
fun WindowFrame(state: WindowFrameState) {
    val reveal by animateFloatAsState(
        targetValue = if (state.pointerZone != WindowFrameZone.NONE || state.nearEdge ||
            state.activeZone != WindowFrameZone.NONE
        ) 1f else 0f,
        animationSpec = tween(WINDOW_FRAME_ANIM_MS), label = "reveal",
    )
    val active by animateFloatAsState(
        targetValue = if (state.activeZone != WindowFrameZone.NONE) 1f else 0f,
        animationSpec = tween(WINDOW_FRAME_ANIM_MS), label = "active",
    )
    val zoneLevels = WindowFrameZone.entries
        .filter { it.isCorner || it.isEdge }
        .associateWith { zone ->
            val lit = state.activeZone == zone || (state.activeZone == WindowFrameZone.NONE && state.pointerZone == zone)
            animateFloatAsState(if (lit) 1f else 0f, tween(WINDOW_FRAME_ANIM_MS), label = zone.name).value
        }

    Canvas(
        modifier = Modifier
            .fillMaxSize()
            .pointerInput(state) {
                awaitPointerEventScope {
                    while (true) {
                        val event = awaitPointerEvent()
                        val pos = event.changes.firstOrNull()?.position
                        state.pointerZone = when (event.type) {
                            PointerEventType.Exit -> WindowFrameZone.NONE
                            else -> if (pos == null || size.width == 0 || size.height == 0) {
                                WindowFrameZone.NONE
                            } else {
                                state.classify(pos.x / size.width, pos.y / size.height)
                            }
                        }
                    }
                }
            },
    ) {
        drawFrame(state, reveal, active, zoneLevels)
    }
}

private fun DrawScope.drawFrame(
    state: WindowFrameState,
    reveal: Float,
    active: Float,
    zoneLevels: Map<WindowFrameZone, Float>,
) {
    if (reveal <= 0.005f) return
    val w = size.width
    val h = size.height
    if (w <= 0f || h <= 0f) return
    val rx = state.ringFracX * w
    val ry = state.ringFracY * h
    val ring = min(rx, ry)
    val innerR = state.innerRadiusFrac * h

    // 窗体矩形 = 整幅去掉边圈。把手贴着窗体外沿一点点，不画任何底 / 光晕。
    val body = Rect(rx, ry, w - rx, h - ry)
    val handleWidth = max(3f, ring * 0.28f)
    val offset = ring * HANDLE_OFFSET_FRACTION

    // ---- 四条边：中点一枚药丸抓条 ----
    for (zone in EDGES) {
        val lit = zoneLevels[zone] ?: 0f
        val color = handleColor(reveal, lit, active * lit)
        val horizontal = zone == WindowFrameZone.EDGE_TOP || zone == WindowFrameZone.EDGE_BOTTOM
        val span = if (horizontal) body.width else body.height
        val len = (span * PILL_FRACTION).coerceIn(handleWidth * 4f, span * 0.5f)
        val cx = body.center.x
        val cy = body.center.y
        val (a, b) = when (zone) {
            WindowFrameZone.EDGE_TOP -> Offset(cx - len / 2f, body.top - offset) to Offset(cx + len / 2f, body.top - offset)
            WindowFrameZone.EDGE_BOTTOM -> Offset(cx - len / 2f, body.bottom + offset) to Offset(cx + len / 2f, body.bottom + offset)
            WindowFrameZone.EDGE_LEFT -> Offset(body.left - offset, cy - len / 2f) to Offset(body.left - offset, cy + len / 2f)
            else -> Offset(body.right + offset, cy - len / 2f) to Offset(body.right + offset, cy + len / 2f)
        }
        drawLine(color, a, b, strokeWidth = handleWidth * (1f + 0.35f * lit), cap = StrokeCap.Round)
    }

    // ---- 四个角：一段圆角弧，顺着窗的圆角往外偏一点；窗是直角时弧心往窗里缩，弧在角外拐过去 ----
    // 半径刻意小（用户：「过渡角度更小」），看起来是一个利落的角而不是一段大圆弧。
    val arcR = max(innerR + offset, ring * 0.6f)
    val inset = arcR - offset // 弧心离窗体外沿的距离
    val sweep = 90f
    for (zone in CORNERS) {
        val lit = zoneLevels[zone] ?: 0f
        val color = handleColor(reveal, lit, active * lit)
        val (cxArc, cyArc, startAngle) = when (zone) {
            WindowFrameZone.CORNER_TL -> Triple(body.left + inset, body.top + inset, 180f)
            WindowFrameZone.CORNER_TR -> Triple(body.right - inset, body.top + inset, 270f)
            WindowFrameZone.CORNER_BR -> Triple(body.right - inset, body.bottom - inset, 0f)
            else -> Triple(body.left + inset, body.bottom - inset, 90f)
        }
        val stroke = handleWidth * (1f + 0.35f * lit)
        drawArc(
            color = color,
            startAngle = startAngle + (sweep - ARC_SWEEP) / 2f,
            sweepAngle = ARC_SWEEP,
            useCenter = false,
            topLeft = Offset(cxArc - arcR, cyArc - arcR),
            size = Size(arcR * 2f, arcR * 2f),
            style = Stroke(width = stroke, cap = StrokeCap.Round),
        )
    }
}

/** 把手颜色：露面时淡白，悬停到它时亮白，抓住时冷蓝。 */
private fun handleColor(reveal: Float, lit: Float, active: Float): Color {
    val base = HANDLE_DIM.copy(alpha = HANDLE_DIM.alpha * reveal)
    val hover = lerp(base, HANDLE_LIT, lit)
    return lerp(hover, HANDLE_ACTIVE, active)
}

private val CORNERS = listOf(
    WindowFrameZone.CORNER_TL, WindowFrameZone.CORNER_TR,
    WindowFrameZone.CORNER_BL, WindowFrameZone.CORNER_BR,
)
private val EDGES = listOf(
    WindowFrameZone.EDGE_TOP, WindowFrameZone.EDGE_BOTTOM,
    WindowFrameZone.EDGE_LEFT, WindowFrameZone.EDGE_RIGHT,
)

/** 边中点药丸占那条边的比例。 */
private const val PILL_FRACTION = 0.22f

/** 角弧扫过的角度：整个 90° 都画，两头再各伸一点直线才像「角」。 */
private const val ARC_SWEEP = 90f

/** 把手离窗体外沿的距离 / 边圈厚度。 */
private const val HANDLE_OFFSET_FRACTION = 0.3f
private val HANDLE_DIM = Color(0x8CFFFFFF)
private val HANDLE_LIT = Color(0xFFFFFFFF)
private val HANDLE_ACTIVE = Color(0xFF8ED0FF)

/** 交给 `ComposeViewPanelRegistration` 的工厂；`:app` 侧没有 Compose 编译器插件，只认 View。 */
fun createWindowFrameView(context: Context, state: WindowFrameState): ComposeView = ComposeView(context).apply {
    setContent { WindowFrame(state) }
}
