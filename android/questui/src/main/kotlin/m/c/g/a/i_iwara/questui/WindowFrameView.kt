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
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.platform.ComposeView
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin

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
 * 一块窗框的显示状态；`:app` 每帧写几何与命中态，面板读。对外是普通属性（理由同 [VideoControlsState]）。
 *
 * # ⛔ 全部用「米」，不用 dp、也不用单轴比例
 *
 * 窗框面板随窗体 `reshape()` 时**只换网格、换不掉已经建好的像素画布**（§19 续十二真机实测），
 * 所以画布会被**非等比**拉到窗上：把窗拉长，画布横向就被抻开。此时
 *
 * - 用 dp 画 → 一侧粗一侧细；
 * - 用「圆」画 → 拉成椭圆（用户 2026-09-06：「拉得很长时四个角的圆角发生奇怪的形变」）。
 *
 * 唯一站得住的口径是**世界尺寸（米）**：这里给出整幅的米数 [widthM] / [heightM]，画的时候两个轴
 * 各自换算 px/米（见 `drawFrame`），窗拉成什么比例，把手在**人眼里**都是同一个粗细、同一个圆。
 */
class WindowFrameState {

    /** 本帧射线悬在窗框的哪一段；由原生命中循环统一写入，不依赖可能缺失的 Exit。 */
    var pointerZone by mutableStateOf(WindowFrameZone.NONE)

    /** 射线悬在窗体上但已**贴近边缘**（离边不到几厘米）：把手提前露面，光标一出窗就接得上。 */
    var nearEdge by mutableStateOf(false)

    /** 正在被抓着的区；NONE = 没在拖。 */
    var activeZone by mutableStateOf(WindowFrameZone.NONE)

    /** 整幅（内容 + 一圈边）的世界尺寸，米。 */
    var widthM by mutableStateOf(1f)
    var heightM by mutableStateOf(1f)

    /** 边圈厚度（米）：内容之外留给把手的那一圈。 */
    var ringM by mutableStateOf(0.05f)

    /** 角命中区的边长（米）：**只管判定**，与角把手画多大无关。 */
    var cornerZoneM by mutableStateOf(0.14f)

    /**
     * 内容面板**真实**的圆角（米），两个轴分开给。
     *
     * 分轴不是为了好看：2D 应用面板拖动中先用非等比 `Scale` 拉伸像素（松手才重排），
     * 那期间内容自己的圆角就是被拉成椭圆的 —— 窗框照着画才叫「与容器一致」。
     * 0 = 内容是直角（视频幕布、图库图片都是合成层，圆不了角），此时角把手退化成一枚小圆角的 L。
     */
    var cornerRadiusXM by mutableStateOf(0f)
    var cornerRadiusYM by mutableStateOf(0f)

    /** 2D 应用面板能自由拉（目前只作记录，外观不区分）。 */
    var freeResize by mutableStateOf(false)

    /**
     * 把面板内的一点（0..1）归到某个区。
     *
     * ⛔ 阈值现算不缓存：`:app` 的射线判定与本面板的指针判定共用这一个函数，
     * 两边只要拿到同一份米数就一定同口径（以前各存一份 frac，改一处漏一处）。
     */
    fun classify(fx: Float, fy: Float): WindowFrameZone {
        if (fx < 0f || fx > 1f || fy < 0f || fy > 1f) return WindowFrameZone.NONE
        if (widthM <= 0f || heightM <= 0f) return WindowFrameZone.NONE
        val ringFracX = ringM / widthM
        val ringFracY = ringM / heightM
        val cornerFracX = min(0.45f, cornerZoneM / widthM)
        val cornerFracY = min(0.45f, cornerZoneM / heightM)
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
 * （用户 2026-09-05：「不符合直觉，希望自己设置一套边缘」）。这里只负责**画**，
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
        modifier = Modifier.fillMaxSize(),
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
    if (state.widthM <= 0f || state.heightM <= 0f) return

    // ⭐ 两个轴各算各的 px/米：画布与窗的比例对不上时（窗被拉长），这一对数就是全部补偿。
    val sx = w / state.widthM
    val sy = h / state.heightM

    val ringX = state.ringM * sx
    val ringY = state.ringM * sy
    // 窗体矩形 = 整幅去掉边圈。把手贴着窗体外沿一点点，不画任何底 / 光晕。
    val body = Rect(ringX, ringY, w - ringX, h - ringY)
    if (body.width <= 1f || body.height <= 1f) return

    // 把手的粗细与外偏都是**世界长度**，换算到两个轴上就成了两个不同的 px 值。
    val handleM = state.ringM * HANDLE_WIDTH_FRACTION
    val offsetM = state.ringM * HANDLE_OFFSET_FRACTION
    val handleX = max(2f, handleM * sx)
    val handleY = max(2f, handleM * sy)
    val offX = offsetM * sx
    val offY = offsetM * sy

    // ---- 四条边：中点一枚药丸抓条 ----
    for (zone in EDGES) {
        val lit = zoneLevels[zone] ?: 0f
        val color = handleColor(reveal, lit, active * lit)
        val grow = 1f + 0.35f * lit
        when (zone) {
            WindowFrameZone.EDGE_TOP, WindowFrameZone.EDGE_BOTTOM -> {
                // ⛔ 下限先夹到上限以内：窗被拉到很窄时 handleX*4 会超过半条边，coerceIn 会当场抛。
                val maxLen = body.width * 0.5f
                val len = (body.width * PILL_FRACTION).coerceIn(min(handleX * 4f, maxLen), maxLen)
                val th = handleY * grow
                val cy = if (zone == WindowFrameZone.EDGE_TOP) body.top - offY else body.bottom + offY
                drawRoundRect(
                    color = color,
                    topLeft = Offset(body.center.x - len / 2f, cy - th / 2f),
                    size = Size(len, th),
                    // 药丸的头是**世界里的半圆**：横向半径要按 sx/sy 拉回去，否则拉长的窗上两头变尖。
                    cornerRadius = CornerRadius(th / 2f * (sx / sy), th / 2f),
                )
            }
            else -> {
                val maxLen = body.height * 0.5f
                val len = (body.height * PILL_FRACTION).coerceIn(min(handleY * 4f, maxLen), maxLen)
                val th = handleX * grow
                val cx = if (zone == WindowFrameZone.EDGE_LEFT) body.left - offX else body.right + offX
                drawRoundRect(
                    color = color,
                    topLeft = Offset(cx - th / 2f, body.center.y - len / 2f),
                    size = Size(th, len),
                    cornerRadius = CornerRadius(th / 2f, th / 2f * (sy / sx)),
                )
            }
        }
    }

    // ---- 四个角：内容自己的圆角**往外平移一个外偏量**的一段角把手 ----
    //
    // ⛔ 圆心必须落在**内容圆角的圆心**上（离角 R），把手半径才是 R + 外偏量 —— 也就是「与内容那条圆角
    // 处处相距一个外偏量」，和四条边的药丸同一口径。
    // 圆心要是也往里挪一个外偏量（半径 R + off、圆心也 R + off），整条把手就正好**贴着窗体外沿**：
    // 一半压在面板底下看不见，露出来的那点又比真圆角更弯 —— 用户 2026-09-06 真机看到的
    // 「圆角做得太大」+「大部分被面板挡住」是同一个错的两个症状。
    val rxContent = state.cornerRadiusXM * sx
    val ryContent = state.cornerRadiusYM * sy
    for (zone in CORNERS) {
        val lit = zoneLevels[zone] ?: 0f
        val color = handleColor(reveal, lit, active * lit)
        val grow = 1f + 0.35f * lit
        val thX = handleX * grow
        val thY = handleY * grow
        val ux = if (zone == WindowFrameZone.CORNER_TL || zone == WindowFrameZone.CORNER_BL) -1f else 1f
        val uy = if (zone == WindowFrameZone.CORNER_TL || zone == WindowFrameZone.CORNER_TR) -1f else 1f
        // 圆心 = 内容圆角的圆心：从那个角往窗里缩一个**内容半径**（不含外偏量）。
        val cx = (if (ux < 0f) body.left else body.right) - ux * rxContent
        val cy = (if (uy < 0f) body.top else body.bottom) - uy * ryContent
        val rxCenter = rxContent + offX
        val ryCenter = ryContent + offY
        // 总跨度恒定：圆角吃掉多少，直尾巴就少多少。圆角大的窗（2D 面板 / 控制面板）几乎只剩一小段弧，
        // 直角的幕布则是一条完整的 L —— 两种窗上「角」的分量看起来一样重。
        val tailX = ((CORNER_SPAN_M * sx - rxContent).coerceAtLeast(CORNER_TAIL_MIN_M * sx))
            .coerceAtMost((body.width / 2f - rxCenter - thX).coerceAtLeast(0f))
        val tailY = ((CORNER_SPAN_M * sy - ryContent).coerceAtLeast(CORNER_TAIL_MIN_M * sy))
            .coerceAtMost((body.height / 2f - ryCenter - thY).coerceAtLeast(0f))
        drawPath(
            path = cornerHandlePath(
                cx = cx, cy = cy, ux = ux, uy = uy,
                rxOut = rxCenter + thX / 2f, ryOut = ryCenter + thY / 2f,
                rxIn = (rxCenter - thX / 2f).coerceAtLeast(0f), ryIn = (ryCenter - thY / 2f).coerceAtLeast(0f),
                tailX = tailX, tailY = tailY,
            ),
            color = color,
        )
    }
}

/**
 * 角把手的轮廓：外沿一圈 + 内沿一圈围成的一条「带」，**填充**而不是描边。
 *
 * ⛔ 为什么不能用 `drawArc(style = Stroke)`：描边的粗细只有一个数，画布被非等比拉过之后，
 * 同一条弧在横向与纵向会显出两种粗细（拉得越长越明显）。把内外两条椭圆弧自己围出来再填，
 * 粗细就是**世界里**恒定的一档。
 *
 * @param ux -1 = 这个角在左边，+1 = 右边；[uy] 同理（-1 上 / +1 下）。
 * @param tailX 顺着横边伸出去的直尾巴长度（px），[tailY] 是竖边那条。内容是直角时全靠它俩读出「角」。
 */
private fun cornerHandlePath(
    cx: Float, cy: Float,
    ux: Float, uy: Float,
    rxOut: Float, ryOut: Float,
    rxIn: Float, ryIn: Float,
    tailX: Float, tailY: Float,
): Path {
    // Compose 的角度：0° = +x，顺时针（+y 向下）。左上角这一段是 180°→270°。
    val startAngle = when {
        ux < 0f && uy < 0f -> 180f
        ux > 0f && uy < 0f -> 270f
        ux > 0f && uy > 0f -> 0f
        else -> 90f
    }
    val a0 = Math.toRadians(startAngle.toDouble())
    val a1 = a0 + Math.PI / 2.0
    val c0 = cos(a0).toFloat()
    val s0 = sin(a0).toFloat()
    val c1 = cos(a1).toFloat()
    val s1 = sin(a1).toFloat()
    // 尾巴方向 = 弧两头的切线：起点处倒着走，终点处顺着走。⛔ 四个角的「起点落在竖边还是横边」
    // 是轮着来的（左上从竖边起、右上从横边起），所以别按角的位置硬编码，按切线算。
    val d0x = s0
    val d0y = -c0
    val d1x = -s1
    val d1y = c1
    val t0 = if (abs(d0x) > abs(d0y)) tailX else tailY
    val t1 = if (abs(d1x) > abs(d1y)) tailX else tailY
    // 内沿半径见底：留一丝，免得 arcTo 拿到一个零尺寸的椭圆。
    val riX = rxIn.coerceAtLeast(0.5f)
    val riY = ryIn.coerceAtLeast(0.5f)
    val path = Path()
    val sOutX = cx + rxOut * c0
    val sOutY = cy + ryOut * s0
    val eOutX = cx + rxOut * c1
    val eOutY = cy + ryOut * s1
    val sInX = cx + riX * c0
    val sInY = cy + riY * s0
    val eInX = cx + riX * c1
    val eInY = cy + riY * s1
    path.moveTo(sOutX + d0x * t0, sOutY + d0y * t0)
    path.lineTo(sOutX, sOutY)
    path.arcTo(Rect(cx - rxOut, cy - ryOut, cx + rxOut, cy + ryOut), startAngle, 90f, false)
    path.lineTo(eOutX + d1x * t1, eOutY + d1y * t1)
    path.lineTo(eInX + d1x * t1, eInY + d1y * t1)
    path.lineTo(eInX, eInY)
    path.arcTo(Rect(cx - riX, cy - riY, cx + riX, cy + riY), startAngle + 90f, -90f, false)
    path.lineTo(sInX + d0x * t0, sInY + d0y * t0)
    path.close()
    return path
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

/**
 * 角把手从角点起量的**总跨度**（米）：圆角占掉一段，剩下的补成直尾巴。
 * 直角的幕布就是一条 5cm 的 L，圆角 3cm 的面板则是「3cm 弧 + 2cm 直尾」，两者一样重。
 */
private const val CORNER_SPAN_M = 0.05f

/** 就算圆角已经比总跨度还大，两头也至少留这么一截直线，让人看得出是「角」不是「弧」。 */
private const val CORNER_TAIL_MIN_M = 0.012f

/** 把手粗细 / 边圈厚度。 */
private const val HANDLE_WIDTH_FRACTION = 0.28f

/** 把手离窗体外沿的距离 / 边圈厚度。 */
private const val HANDLE_OFFSET_FRACTION = 0.3f
private val HANDLE_DIM = Color(0x8CFFFFFF)
private val HANDLE_LIT = Color(0xFFFFFFFF)
private val HANDLE_ACTIVE = Color(0xFF8ED0FF)

/** 交给 `ComposeViewPanelRegistration` 的工厂；`:app` 侧没有 Compose 编译器插件，只认 View。 */
fun createWindowFrameView(context: Context, state: WindowFrameState): ComposeView = ComposeView(context).apply {
    setContent { WindowFrame(state) }
}
