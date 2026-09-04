package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.background
import androidx.compose.foundation.Canvas
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.draw.drawWithContent
import kotlinx.coroutines.delay
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.hoverable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsHoveredAsState
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.PointerEventPass
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.button.BorderlessCircleButton
import com.meta.spatial.uiset.button.SecondaryCircleButton
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.ChevronLeft

/**
 * 面板的设计常量与共用积木。
 *
 * # 尺寸是怎么定的（都能对上官方数字，别随手改）
 *
 * 面板出图走 `DpPerMeterDisplayOptions(dpPerMeter = 500f)`，即 **1dp = 2mm**。
 * 官方的命中区下限是**角尺寸 2.5°–3°**（22mm/48dp 那组数字是按 0.42m 直触距离给的，
 * 到 2.2m 远就不适用了，必须按角度换算）。
 *
 * 面板放在 **2.2m** 处，3° 在这个距离上 = 2.2 × tan3° ≈ **11.5cm = 115mm = 58dp**。
 * 所以：
 * - 圆形主控件 [CIRCLE_SIZE] = **72dp**（≈14.4cm ≈ 3.7°），高于下限；
 * - 行内按钮高度 [ROW_BUTTON_HEIGHT] = **64dp**（≈12.8cm ≈ 3.3°）；
 * - 相邻件间距 ≥ **12mm = 6dp**，我们一律给 12dp 以上。
 */
object PanelTokens {

    /** 面板逻辑尺寸：2.2m × 1.0m @ 500dp/m。与 `ImmersiveActivity` 的常量成对，改要一起改。 */
    const val WIDTH_DP = 1100
    const val HEIGHT_DP = 360

    val CIRCLE_SIZE = 72.dp
    val ROW_BUTTON_HEIGHT = 64.dp

    /** 面板主体的圆角。 */
    val CORNER = 28.dp

    val PAGE_PADDING = 20.dp
    val GAP = 14.dp

    // ---- 配色 ----
    //
    // ⛔ 不用纯黑 `#000000`：官方 `display` 那页说 LCD 上「dark pixel values do not get
    // as dim as expected」，且 8-bit sRGB 低于 13/255 的亮度差别根本分辨不出来 ——
    // 纯黑背景上的层次会整片糊成一块。近黑 #1B1B1F 是安全值。
    //
    // 面板背景带 alpha 是配合 `PanelShapeLayerBlendType.ALPHA_BLEND` 的：
    // 顶栏那排圆钮要像参考软件一样**悬浮在窗外**，圆钮之间的缝必须透出后面的画面。
    val SURFACE = Color(0xF21B1B1F)
    val ON_SURFACE = Color(0xFFE6E6EA)
    val ON_SURFACE_DIM = Color(0xFFA8A8B0)
    val WARN = Color(0xFFFFB77C)
    val HOVER = Color(0xFF3A3A44)
    val PRESSED = Color(0xFF4A4A56)

    /** 充电时电池文字的强调色（Meta 官方深色主题里的绿）。 */
    val CHARGE = Color(0xFF7CE6A0)

    /** 弹层（音量/倍速）的底板色，比主 SURFACE 更实一点，避免上下叠加时糊在一起。 */
    val POPUP = Color(0xFF25252B)
}

/**
 * 子页共用的标题行：左边一枚返回圆钮，右边标题。
 *
 * 返回钮在**左**是刻意的：参考软件的子页也是左上角起标题，而 Quest 上惯用手多在右侧，
 * 左上是最不容易误触的位置 —— 这里放的是「离开当前页」这种不该被误点的动作。
 */
@Composable
fun PageHeader(
    title: String,
    subtitle: String? = null,
    onBack: () -> Unit,
    trailing: (@Composable () -> Unit)? = null,
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
    ) {
        CircleActionButton(SpatialIcons.Regular.ChevronLeft, "返回", onClick = onBack)
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                color = PanelTokens.ON_SURFACE,
                fontSize = 24.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            if (subtitle != null) {
                Text(
                    text = subtitle,
                    color = PanelTokens.ON_SURFACE_DIM,
                    fontSize = 15.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }
        if (trailing != null) trailing()
    }
}

/** 一行小节标题。 */
@Composable
fun SectionLabel(text: String, modifier: Modifier = Modifier) {
    Text(
        text = text,
        color = PanelTokens.ON_SURFACE_DIM,
        fontSize = 15.sp,
        modifier = modifier,
    )
}

/**
 * 顶栏那排圆钮里的一枚。
 *
 * ⛔ 强制 [PanelTokens.CIRCLE_SIZE]：UI Set 的圆钮默认尺寸是按直触距离给的，
 * 到 2.2m 外就掉到角尺寸下限以下了。
 */
@Composable
fun TopBarButton(icon: ImageVector, contentDescription: String, onClick: () -> Unit) {
    // 顶栏钮浮在透明区，UI Set 的半透明底色在这里没有深色底板衬着，看起来比卡片里的按钮淡一截
    // （用户 2026-09-05 反馈）。垫一层与卡片同色的实心圆，观感就与卡片里的按钮一致。
    Box(
        modifier = Modifier
            .size(PanelTokens.CIRCLE_SIZE)
            .clip(CircleShape)
            .background(PanelTokens.SURFACE),
        contentAlignment = Alignment.Center,
    ) {
        SecondaryCircleButton(
            icon = { Icon(icon, contentDescription) },
            onClick = onClick,
        )
    }
}

/**
 * 面板主体的那块圆角底板。
 *
 * 顶栏在它**外面**（透明区），主体在它里面 —— 这正是参考软件的样子：
 * 一排悬浮圆钮 + 一块深色窗。
 */
@Composable
fun PanelSurface(content: @Composable () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .clip(RoundedCornerShape(PanelTokens.CORNER))
            .background(PanelTokens.SURFACE)
            .padding(PanelTokens.PAGE_PADDING),
    ) {
        content()
    }
}

/** 竖向留白。 */
@Composable
fun VGap(dp: Int = 14) {
    Spacer(Modifier.height(dp.dp))
}

/**
 * 面板级触碰上报。
 *
 * ⛔ 挂在页面根节点上：拦 [PointerEventPass.Initial]（在子节点之前拿到事件）**且不消费**。
 * `:app` 侧的 `PanelInputBridge` 用这个信号做两件事：
 *   1. 续「空闲自动收起」的倒计时；
 *   2. 把「捏合唤出面板」的手势分家 —— 如果这次捏合发生在面板上，那就是普通交互，
 *      不当作召唤/收起手势看待。
 *
 * 覆盖面必须包含整块面板（含透明的顶栏那一带），所以调用点是 [VideoControlsPanel] 的
 * 最外层 Column，不是每个子页各挂一次。子页只在自己的根节点上重挂一次做兜底 ——
 * 万一某天顶层结构改了这里也不会漏。
 */
fun Modifier.reportPanelTouches(cb: VideoControlsCallbacks): Modifier =
    this.pointerInput(cb) {
        awaitPointerEventScope {
            while (true) {
                awaitPointerEvent(PointerEventPass.Initial)
                cb.onPanelTouched()
            }
        }
    }


// ─────────────────────────────────────────────────────────── 自绘控件

/**
 * 圆形动作钮：整个圆盘都是命中区。
 *
 * 不再用 UI Set 的 `SecondaryCircleButton`：它的命中区是自己那 56dp，套一圈底盘之后外圈点不到
 * （用户 2026-09-05 反馈「背景扩大了一圈，但多出来的部分无法点击」）。自绘之后顶栏钮与走带钮
 * 同一套样式、同一个命中区。
 *
 * @param emphasized 主按钮（播放/暂停）：反色实心。
 * @param selected 当前页对应的入口钮：描一圈亮边。
 */
@Composable
fun CircleActionButton(
    icon: ImageVector,
    contentDescription: String,
    modifier: Modifier = Modifier,
    size: Dp = PanelTokens.ROW_BUTTON_HEIGHT,
    emphasized: Boolean = false,
    selected: Boolean = false,
    enabled: Boolean = true,
    onClick: () -> Unit,
) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val hovered by interaction.collectIsHoveredAsState()
    val bg = when {
        !enabled -> PanelTokens.POPUP.copy(alpha = 0.4f)
        emphasized -> if (pressed) PanelTokens.ON_SURFACE_DIM else PanelTokens.ON_SURFACE
        pressed -> PanelTokens.PRESSED
        hovered -> PanelTokens.HOVER
        else -> PanelTokens.POPUP
    }
    val fg = when {
        !enabled -> PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.5f)
        emphasized -> PanelTokens.SURFACE
        else -> PanelTokens.ON_SURFACE
    }
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(bg)
            .then(if (selected) Modifier.border(2.dp, PanelTokens.ON_SURFACE, CircleShape) else Modifier)
            .hoverable(interaction, enabled)
            .clickable(interactionSource = interaction, indication = null, enabled = enabled, onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        Icon(icon, contentDescription, tint = fg, modifier = Modifier.size(size * 0.42f))
    }
}

/**
 * 自绘进度条：12dp 轨道 + 28dp 圆拖块，命中区整行 64dp（用户反馈太细太矮难点）。
 *
 * 不用 `SpatialSliderLarge`：它的拖块是一枚 60dp 宽的药丸，走到 98% 时看起来就是满的
 * （用户反馈「4:22 / 4:27 进度条视觉上已拉满」）。
 *
 * @param progress 0..1
 * @param onSeek 拖动 / 点按中连续回调
 * @param onSeekFinished 抬手
 */
@Composable
fun SeekBar(
    progress: Float,
    onSeek: (Float) -> Unit,
    onSeekFinished: () -> Unit,
    modifier: Modifier = Modifier,
    buffering: Boolean = false,
) {
    val trackColor = PanelTokens.POPUP
    val fillColor = if (buffering) PanelTokens.WARN else PanelTokens.ON_SURFACE
    val thumbColor = PanelTokens.ON_SURFACE
    Box(
        modifier = modifier
            .height(64.dp)
            .pointerInput(onSeek, onSeekFinished) {
                val w = size.width.toFloat()
                detectTapGestures(
                    onPress = { offset ->
                        onSeek((offset.x / w).coerceIn(0f, 1f))
                        tryAwaitRelease()
                        onSeekFinished()
                    },
                )
            }
            .pointerInput(onSeek, onSeekFinished) {
                val w = size.width.toFloat()
                detectHorizontalDragGestures(
                    onDragStart = { offset -> onSeek((offset.x / w).coerceIn(0f, 1f)) },
                    onDragEnd = { onSeekFinished() },
                    onDragCancel = { onSeekFinished() },
                ) { change, _ ->
                    change.consume()
                    onSeek((change.position.x / w).coerceIn(0f, 1f))
                }
            },
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val trackH = 12.dp.toPx()
            val thumbR = 14.dp.toPx()
            val cy = size.height / 2f
            val x = (size.width * progress.coerceIn(0f, 1f))
            drawRoundRect(
                color = trackColor,
                topLeft = Offset(0f, cy - trackH / 2f),
                size = Size(size.width, trackH),
                cornerRadius = CornerRadius(trackH / 2f),
            )
            drawRoundRect(
                color = fillColor,
                topLeft = Offset(0f, cy - trackH / 2f),
                size = Size(x, trackH),
                cornerRadius = CornerRadius(trackH / 2f),
            )
            drawCircle(color = thumbColor, radius = thumbR, center = Offset(x, cy))
        }
    }
}

/** 等宽的时间标签：进度条两侧的时间不能随内容变宽，否则轨道长度会跟着抖。 */
@Composable
fun TimeLabel(text: String, modifier: Modifier = Modifier, color: Color = PanelTokens.ON_SURFACE_DIM) {
    Text(
        text = text,
        color = color,
        fontSize = 16.sp,
        maxLines = 1,
        modifier = modifier,
        textAlign = TextAlign.Center,
    )
}


/**
 * 自绘竖向音量条：宽轨道 + 圆拖块，命中区整列。
 *
 * 不再用旋转过的 UI Set 横向 slider：太细、太矮（用户 2026-09-05 反馈）。
 * @param level 0..1，上满下空。
 */
@Composable
fun VerticalLevelBar(
    level: Float,
    onLevel: (Float) -> Unit,
    modifier: Modifier = Modifier,
) {
    val trackColor = PanelTokens.SURFACE
    val fillColor = PanelTokens.ON_SURFACE
    Box(
        modifier = modifier
            .width(56.dp)
            .pointerInput(onLevel) {
                val h = size.height.toFloat()
                detectTapGestures(onPress = { o -> onLevel((1f - o.y / h).coerceIn(0f, 1f)) })
            }
            .pointerInput(onLevel) {
                val h = size.height.toFloat()
                detectVerticalDragGestures { change, _ ->
                    change.consume()
                    onLevel((1f - change.position.y / h).coerceIn(0f, 1f))
                }
            },
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val trackW = 14.dp.toPx()
            val thumbR = 14.dp.toPx()
            val cx = size.width / 2f
            val y = size.height * (1f - level.coerceIn(0f, 1f))
            drawRoundRect(
                color = trackColor,
                topLeft = Offset(cx - trackW / 2f, 0f),
                size = Size(trackW, size.height),
                cornerRadius = CornerRadius(trackW / 2f),
            )
            drawRoundRect(
                color = fillColor,
                topLeft = Offset(cx - trackW / 2f, y),
                size = Size(trackW, size.height - y),
                cornerRadius = CornerRadius(trackW / 2f),
            )
            drawCircle(color = fillColor, radius = thumbR, center = Offset(cx, y))
        }
    }
}

/**
 * 竖向滚动指示条：内容放不下时才画；刚进页面先亮 2s 提醒「下面还有」，滚动时常亮，停手 1.2s 后淡出。
 *
 * 官方 `hands-ui-best-practices` 明说别做传统滚动条（拖它的人多半失败），所以它**只指示、不可拖**，
 * 滚动仍靠在内容上划。用法：`Modifier.verticalScroll(state).panelScrollbar(state)` —— 挂在同一个节点上。
 */
@Composable
fun Modifier.panelScrollbar(state: ScrollState): Modifier {
    val scrolling = state.isScrollInProgress
    var visible by remember { mutableStateOf(true) }
    LaunchedEffect(scrolling, state.value) {
        visible = true
        if (!scrolling) {
            delay(if (state.value == 0) 2000L else 1200L)
            visible = false
        }
    }
    val alpha by animateFloatAsState(if (visible) 1f else 0f, label = "scrollbar")
    return this.drawWithContent {
        drawContent()
        val max = state.maxValue
        if (max <= 0 || alpha <= 0.01f) return@drawWithContent
        val viewport = size.height
        val content = viewport + max
        val thumbH = (viewport * viewport / content).coerceAtLeast(28.dp.toPx())
        val thumbY = (viewport - thumbH) * (state.value.toFloat() / max) + state.value
        val w = 6.dp.toPx()
        drawRoundRect(
            color = PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.55f * alpha),
            topLeft = Offset(size.width - w, thumbY),
            size = Size(w, thumbH),
            cornerRadius = CornerRadius(w / 2f),
        )
    }
}
