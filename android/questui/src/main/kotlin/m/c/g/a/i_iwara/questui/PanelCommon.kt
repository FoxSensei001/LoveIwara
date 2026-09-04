package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.background
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
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
    const val HEIGHT_DP = 500

    val CIRCLE_SIZE = 72.dp
    val ROW_BUTTON_HEIGHT = 64.dp

    /** 面板主体的圆角。 */
    val CORNER = 28.dp

    val PAGE_PADDING = 26.dp
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
        BorderlessCircleButton(
            icon = { Icon(SpatialIcons.Regular.ChevronLeft, null) },
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
    Box(modifier = Modifier.size(PanelTokens.CIRCLE_SIZE), contentAlignment = Alignment.Center) {
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
