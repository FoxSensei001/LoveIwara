package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.background
import androidx.compose.foundation.Canvas
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.onClick
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.draw.drawWithContent
import kotlinx.coroutines.delay
import kotlin.math.abs
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
import androidx.compose.foundation.layout.BoxScope
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
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.button.BorderlessCircleButton
import com.meta.spatial.uiset.button.SecondaryCircleButton
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.VolumeLow
import com.meta.spatial.uiset.theme.icons.regular.VolumeMid
import com.meta.spatial.uiset.theme.icons.regular.VolumeOff
import com.meta.spatial.uiset.theme.icons.regular.VolumeOn
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
        CircleActionButton(
            SpatialIcons.Regular.ChevronLeft,
            stringResource(R.string.xr_back),
            onClick = onBack,
        )
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
 *
 * # ⛔ 「悬停」与「按下」必须分成两条信号
 *
 * 这里收到的事件里，**绝大多数是悬停移动**：Quest 的射线只要扫过面板就一直发 move。
 * 早先两件事共用一条 [VideoControlsCallbacks.onPanelTouched]，于是「这一次按下落在面板上吗」
 * 被一条「任何一只手的射线扫过面板」的信号污染 —— 真机症状是**面板只能召唤、无法隐藏**
 * （用户 2026-09-05 报障）：另一只手的射线歇在面板上，`lastPanelTouchAt` 每帧刷新，
 * 「面板外点一下」的判定于是恒不成立。面板不存在时没有这条噪音，所以召唤一直是好的。
 *
 * 分家之后：
 *   - [VideoControlsCallbacks.onPanelTouched]（含悬停）→ 只用来续「空闲自动收起」的倒计时；
 *   - [VideoControlsCallbacks.onPanelPressed]（**仅按下**）→ 才是「这一次操作落在面板上」的证据，
 *     显隐 toggle 只认它。
 *
 * 覆盖面必须包含整块面板（含透明的顶栏那一带），所以调用点是 [VideoControlsPanel] 的
 * 最外层 Column，不是每个子页各挂一次。子页只在自己的根节点上重挂一次做兜底 ——
 * 万一某天顶层结构改了这里也不会漏。
 */
fun Modifier.reportPanelTouches(cb: VideoControlsCallbacks): Modifier =
    this.pointerInput(cb) {
        awaitPointerEventScope {
            var wasPressed = false
            while (true) {
                val event = awaitPointerEvent(PointerEventPass.Initial)
                cb.onPanelTouched()
                // 只在「从没按下变成按下」那一下报按压：按住不放期间的 move 不再重复上报，
                // 免得又变成一条会被当成「一直在面板上」的粘滞信号。
                val pressed = event.changes.any { it.pressed }
                if (pressed && !wasPressed) cb.onPanelPressed()
                wasPressed = pressed
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
 * 轨道分**三层**：空轨道 → 已缓冲 → 已播放 + 拖块。中间那层是网络片子「往前还能放到哪」，
 * 用户 2026-09-06 要的就是它 —— 换片 / 卡顿时能看见缓冲区在往前推，而不是干等一枚转圈。
 *
 * @param progress 0..1
 * @param buffered 0..1，已缓冲到的位置（[PlaybackEngine] 的 `bufferedPosition`）。
 *   0 或不大于 [progress] 时那一层不画（本地文件会直接满格，也就与轨道等长看不出来）。
 * @param onSeek 拖动 / 点按中连续回调
 * @param onSeekFinished 抬手
 * @param enabled false = 换片中：不接点按 / 拖动，整条压暗（拖块也不再是亮白）。
 */
@Composable
fun SeekBar(
    progress: Float,
    onSeek: (Float) -> Unit,
    onSeekFinished: () -> Unit,
    modifier: Modifier = Modifier,
    buffered: Float = 0f,
    buffering: Boolean = false,
    enabled: Boolean = true,
) {
    val trackColor = PanelTokens.POPUP
    val fillColor = when {
        !enabled -> PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.5f)
        buffering -> PanelTokens.WARN
        else -> PanelTokens.ON_SURFACE
    }
    val thumbColor = if (enabled) PanelTokens.ON_SURFACE else PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.5f)
    // 缓冲段夹在空轨道（近黑）与已播放（近白）之间：够看得见「还能往前放多少」，又不会被误读成已播放。
    val bufferedColor = PanelTokens.ON_SURFACE_DIM.copy(alpha = if (enabled) 0.38f else 0.2f)
    Box(
        modifier = modifier
            .height(64.dp)
            .pointerInput(onSeek, onSeekFinished, enabled) {
                if (!enabled) return@pointerInput
                val w = size.width.toFloat()
                detectTapGestures(
                    onPress = { offset ->
                        onSeek((offset.x / w).coerceIn(0f, 1f))
                        tryAwaitRelease()
                        onSeekFinished()
                    },
                )
            }
            .pointerInput(onSeek, onSeekFinished, enabled) {
                if (!enabled) return@pointerInput
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
            val bx = (size.width * buffered.coerceIn(0f, 1f))
            drawRoundRect(
                color = trackColor,
                topLeft = Offset(0f, cy - trackH / 2f),
                size = Size(size.width, trackH),
                cornerRadius = CornerRadius(trackH / 2f),
            )
            // 已缓冲：压在已播放之下、从 0 画起（一段就够，ExoPlayer 给的本来就是「从当前点起连续可播」的终点）。
            if (bx > x) {
                drawRoundRect(
                    color = bufferedColor,
                    topLeft = Offset(0f, cy - trackH / 2f),
                    size = Size(bx, trackH),
                    cornerRadius = CornerRadius(trackH / 2f),
                )
            }
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
 * 竖向滚动指示条：内容放不下时才画；刚进页面先亮 2s 提醒「下面还有」，滚动时常亮，停手 1.2s 后淡出。
 *
 * 官方 `hands-ui-best-practices` 明说别做传统滚动条（拖它的人多半失败），所以它**只指示、不可拖**，
 * 滚动仍靠在内容上划。用法：`Modifier.panelScrollbar(state).verticalScroll(state)` —— ⛔ 顺序不能反，见实现内注释。
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
        // ⛔ 本修饰符必须挂在 verticalScroll **之前**（外层节点）：这样 size 是视口、坐标不随滚动平移。
        // 挂在之后会拿到整段内容的高度，指示条又长又跟着内容一起滚出画面（真机反馈）。
        val viewport = size.height
        val content = viewport + max
        val thumbH = (viewport * viewport / content).coerceAtLeast(28.dp.toPx())
        val thumbY = (viewport - thumbH) * (state.value.toFloat() / max)
        val w = 6.dp.toPx()
        drawRoundRect(
            color = PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.55f * alpha),
            topLeft = Offset(size.width - w, thumbY),
            size = Size(w, thumbH),
            cornerRadius = CornerRadius(w / 2f),
        )
    }
}


/**
 * 药丸按钮：图标 + 文字，带 hover / 按下态，与 [CircleActionButton] 同一套材质。
 *
 * 走带行右侧「倍速 / 视频类型 / 屏幕类型」与倍速 chip 用它，不再混用 UI Set 的 SecondaryButton
 * （没有 hover 反馈、样式与圆钮不成套 —— 真机反馈）。
 */
@Composable
fun PillButton(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    selected: Boolean = false,
    enabled: Boolean = true,
    height: Dp = 56.dp,
) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val hovered by interaction.collectIsHoveredAsState()
    val bg by animateColorAsState(
        when {
            !enabled -> PanelTokens.POPUP.copy(alpha = 0.4f)
            selected -> PanelTokens.ON_SURFACE
            pressed -> PanelTokens.PRESSED
            hovered -> PanelTokens.HOVER
            else -> PanelTokens.POPUP
        },
        label = "pillBg",
    )
    val fg = when {
        !enabled -> PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.5f)
        selected -> PanelTokens.SURFACE
        else -> PanelTokens.ON_SURFACE
    }
    Row(
        modifier = modifier
            .height(height)
            .clip(RoundedCornerShape(height / 2))
            .background(bg)
            .hoverable(interaction, enabled)
            .clickable(interactionSource = interaction, indication = null, enabled = enabled, onClick = onClick)
            .padding(horizontal = 18.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        if (icon != null) Icon(icon, null, tint = fg, modifier = Modifier.size(22.dp))
        Text(text = label, color = fg, fontSize = 16.sp, maxLines = 1)
    }
}

/**
 * 「拉近 / 重置 / 拉远」那一组大方块钮里的一枚：一枚图标压一行字，整块都是命中区。
 *
 * # ⛔ 为什么它在公共积木里，而不是留在某一页里
 *
 * 这一组钮有两个主人：幕布的远近（[ViewDistancePage]）与 2D 应用面板的远近
 * （[BrowsePanelPage]）。两处调的是完全不同的东西，但**手势契约必须一模一样** ——
 * 点一下走一格、按住连走、松手即停。抄第二份的那一刻，两边就会开始各自漂移
 * （本项目已经吃过「同类问题一处一处修」的亏）。
 *
 * @param onStep 点一下走一格。也是无障碍那条路的动作（射线用户可能只发得出 click）。
 * @param onHold 按住 / 松开；给 null 表示这枚是「重置」那种一下就完事的钮 ——
 *   它同时也画得淡一档（复位动作不该和方向钮抢注意力）。
 */
@Composable
fun DistanceActionButton(
    icon: ImageVector,
    label: String,
    modifier: Modifier = Modifier,
    onStep: () -> Unit,
    onHold: ((pressed: Boolean) -> Unit)? = null,
) {
    val interaction = remember { MutableInteractionSource() }
    val hovered by interaction.collectIsHoveredAsState()
    val clickPressed by interaction.collectIsPressedAsState()
    var held by remember { mutableStateOf(false) }
    val pressed = held || clickPressed
    val background by animateColorAsState(
        targetValue = when {
            pressed -> PanelTokens.PRESSED
            hovered -> PanelTokens.HOVER
            else -> PanelTokens.POPUP
        },
        animationSpec = tween(100),
        label = "distanceButtonBackground",
    )
    val outline by animateColorAsState(
        targetValue = when {
            pressed -> PanelTokens.ON_SURFACE.copy(alpha = 0.32f)
            hovered -> PanelTokens.ON_SURFACE.copy(alpha = 0.16f)
            else -> Color.Transparent
        },
        animationSpec = tween(100),
        label = "distanceButtonOutline",
    )
    val action = if (onHold == null) {
        Modifier.clickable(
            interactionSource = interaction,
            indication = null,
            role = Role.Button,
            onClick = onStep,
        )
    } else {
        Modifier
            .semantics(mergeDescendants = true) {
                role = Role.Button
                onClick(label) { onStep(); true }
            }
            // Stable keys: changing pressed/hover visuals must not restart a held gesture.
            .pointerInput(onHold) {
                detectTapGestures(onPress = {
                    held = true
                    try {
                        onHold(true)
                        tryAwaitRelease()
                    } finally {
                        held = false
                        onHold(false)
                    }
                })
            }
    }
    val shape = RoundedCornerShape(20.dp)
    val foreground = if (onHold == null && !pressed && !hovered) PanelTokens.ON_SURFACE_DIM else PanelTokens.ON_SURFACE
    Column(
        modifier = modifier
            .height(144.dp)
            .clip(shape)
            .background(background)
            .border(1.dp, outline, shape)
            .hoverable(interaction)
            .then(action)
            .padding(horizontal = 20.dp, vertical = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(icon, contentDescription = null, tint = foreground, modifier = Modifier.size(36.dp))
        Spacer(Modifier.height(12.dp))
        Text(
            text = label,
            modifier = Modifier.fillMaxWidth(),
            color = foreground,
            fontSize = 20.sp,
            fontWeight = FontWeight.Medium,
            lineHeight = 26.sp,
            textAlign = TextAlign.Center,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

// ─────────────────────────────────────────────────────────── 音量弹层

/**
 * 音量弹层 + 它的关闭底板。**播放页与空间画廊共用同一只** —— 两边底行最左都是那枚 🔊，
 * 弹层因此都贴左下角，手指从钮上抬起来就落在条上。
 * 调用方只要在根 `Box` 的最后放一行 `VolumePopupOverlay(state, cb)`。
 *
 * 条上调的是**系统**音量（见 [VideoControlsState.volume]）；静音钮只静本应用。
 */
@Composable
fun BoxScope.VolumePopupOverlay(state: VideoControlsState, cb: VideoControlsCallbacks) {
    if (!state.volumePopupOpen) return
    // 关闭底板画在弹层之下：弹层没消费的触碰才会掉到它上面。
    Box(
        modifier = Modifier
            .fillMaxSize()
            .pointerInput(cb) { detectTapGestures { cb.onVolumePopup(false) } },
    )
    VolumePopupCard(
        state = state,
        cb = cb,
        modifier = Modifier
            .align(Alignment.BottomStart)
            .padding(bottom = 76.dp),
    )
}

/**
 * 音量图标按当前响度分四档（UI Set 自带 `VolumeOff / VolumeLow / VolumeMid / VolumeOn`）。
 *
 * 一眼能看出「现在大概多响」，不用去读数字 —— 面板收起时那枚 🔊 也是这个形状，
 * 于是「音量现在多大」这件事在**不展开弹层**的情况下也说得清。
 */
@Composable
fun volumeIcon(muted: Boolean, level: Float): ImageVector = when {
    muted || level <= 0f -> SpatialIcons.Regular.VolumeOff
    level < 0.34f -> SpatialIcons.Regular.VolumeLow
    level < 0.67f -> SpatialIcons.Regular.VolumeMid
    else -> SpatialIcons.Regular.VolumeOn
}

/**
 * 横向音量条：14dp 轨道 + 32dp 圆拖块，命中区整行 64dp（与 [SeekBar] 同一套手感）。
 *
 * ⛔ **不再用竖条**：竖条被面板高度卡死（面板只有 [PanelTokens.HEIGHT_DP] = 360dp，
 * 弹层还要留出触发钮的位置），行程撑死 200dp 出头，用户 2026-09-11 反馈「有点短」。
 * 横过来能给到 400dp 以上，同样的 16 档，每档的手感宽了一倍。
 *
 * @param steps 系统真实的档数（Quest 上 15 ⇒ 16 档）。2..32 之间会在轨道上画出**刻度点**——
 *   音量本来就是跳档的，把档位画出来，比让用户以为「拖不顺」要诚实。
 */
@Composable
fun HorizontalLevelBar(
    level: Float,
    steps: Int,
    onLevel: (Float) -> Unit,
    modifier: Modifier = Modifier,
) {
    val thumbRadius = 16.dp
    fun levelAt(x: Float, w: Float, r: Float): Float {
        val span = (w - 2f * r).coerceAtLeast(1f)
        return ((x - r) / span).coerceIn(0f, 1f)
    }
    Box(
        modifier = modifier
            .height(64.dp)
            .pointerInput(onLevel) {
                val w = size.width.toFloat()
                val r = thumbRadius.toPx()
                detectTapGestures(onPress = { o -> onLevel(levelAt(o.x, w, r)) })
            }
            .pointerInput(onLevel) {
                val w = size.width.toFloat()
                val r = thumbRadius.toPx()
                detectHorizontalDragGestures { change, _ ->
                    change.consume()
                    onLevel(levelAt(change.position.x, w, r))
                }
            },
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val trackH = 14.dp.toPx()
            val thumbR = thumbRadius.toPx()
            val cy = size.height / 2f
            val left = thumbR
            val right = size.width - thumbR
            val x = left + (right - left) * level.coerceIn(0f, 1f)
            drawRoundRect(
                color = PanelTokens.SURFACE,
                topLeft = Offset(left, cy - trackH / 2f),
                size = Size(right - left, trackH),
                cornerRadius = CornerRadius(trackH / 2f),
            )
            if (x > left) {
                drawRoundRect(
                    color = PanelTokens.ON_SURFACE,
                    topLeft = Offset(left, cy - trackH / 2f),
                    size = Size(x - left, trackH),
                    cornerRadius = CornerRadius(trackH / 2f),
                )
            }
            // 刻度点：落在已填充段上的画暗色、落在空轨道上的画亮色，两边都看得见。
            if (steps in 2..32) {
                val dotR = 2.dp.toPx()
                for (i in 0..steps) {
                    val tx = left + (right - left) * i / steps
                    if (abs(tx - x) < thumbR * 0.8f) continue // 拖块底下那几点不画，免得从白圆里透出来
                    drawCircle(
                        color = if (tx < x) PanelTokens.SURFACE.copy(alpha = 0.55f)
                                else PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.45f),
                        radius = dotR,
                        center = Offset(tx, cy),
                    )
                }
            }
            drawCircle(color = PanelTokens.ON_SURFACE, radius = thumbR, center = Offset(x, cy))
        }
    }
}

/**
 * 音量弹层卡片：一行标题（说清这调的是**系统**音量）+ 大百分比，一行静音钮 + 长横条。
 *
 * 版式是横的而不是竖的，理由见 [HorizontalLevelBar]。宽度吃掉面板的一半多一点，
 * 贴在触发钮正上方 —— 手指从 🔊 抬上来就落在条上，不用横跨整块面板。
 */
@Composable
private fun VolumePopupCard(
    state: VideoControlsState,
    cb: VideoControlsCallbacks,
    modifier: Modifier = Modifier,
) {
    val current = if (state.muted) 0f else state.volume
    Column(
        modifier = modifier
            .width(608.dp)
            .clip(RoundedCornerShape(28.dp))
            .background(PanelTokens.POPUP)
            .padding(horizontal = 20.dp, vertical = 16.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.Bottom,
        ) {
            Text(
                text = stringResource(R.string.xr_volume),
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 15.sp,
                modifier = Modifier.weight(1f),
            )
            Text(
                text = if (state.muted) stringResource(R.string.xr_muted_badge) else "${(current * 100).toInt()}%",
                color = if (state.muted) PanelTokens.WARN else PanelTokens.ON_SURFACE,
                fontSize = 24.sp,
                fontWeight = FontWeight.Medium,
            )
        }
        Spacer(Modifier.height(6.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            CircleActionButton(
                icon = volumeIcon(state.muted, state.volume),
                contentDescription = stringResource(if (state.muted) R.string.xr_unmute else R.string.xr_mute),
                onClick = cb::onToggleMute,
                selected = state.muted,
            )
            HorizontalLevelBar(
                level = current,
                steps = state.volumeSteps,
                onLevel = cb::onVolume,
                modifier = Modifier.weight(1f),
            )
        }
    }
}
