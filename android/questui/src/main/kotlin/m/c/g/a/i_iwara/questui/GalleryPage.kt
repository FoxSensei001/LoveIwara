package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.hoverable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsHoveredAsState
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.ChevronLeft
import com.meta.spatial.uiset.theme.icons.regular.ChevronRight
import com.meta.spatial.uiset.theme.icons.regular.Close
import com.meta.spatial.uiset.theme.icons.regular.Environment
import com.meta.spatial.uiset.theme.icons.regular.Home
import com.meta.spatial.uiset.theme.icons.regular.Image
import com.meta.spatial.uiset.theme.icons.regular.ListView
import com.meta.spatial.uiset.theme.icons.regular.Pause
import com.meta.spatial.uiset.theme.icons.regular.Play
import com.meta.spatial.uiset.theme.icons.regular.Power
import com.meta.spatial.uiset.theme.icons.regular.Replay
import com.meta.spatial.uiset.theme.icons.regular.Settings
import com.meta.spatial.uiset.theme.icons.regular.Television
import com.meta.spatial.uiset.theme.icons.regular.Time
import com.meta.spatial.uiset.theme.icons.regular.ViewGallery
import com.meta.spatial.uiset.theme.icons.regular.VolumeOff
import com.meta.spatial.uiset.theme.icons.regular.VolumeOn
import java.io.File

/**
 * 图集页 —— 幕布上放的是一本图库时，面板的主页（顶替 [PlayerPage]，1100×360dp 同一张卡片）。
 *
 * ```
 * [✕]  图库标题…                        [3 / 12] 🕒05:36 🔋36%   [场景][屏幕][设置][返回]
 *      作者 · 文件名 · 1920×1080
 *
 * [‹]  ▢▢▢▢ ▣ ▢▢▢▢▢▢▢▢  （胶片：当前一格描亮边，视频格带 ▶ 角标，正在读取的格压转圈）  [›]
 *
 * 图片：[▶ 幻灯片] [3s][5s][10s][20s]                                   [标准 / 原图] [直面屏]
 * 视频：[🔊] [▶]  [↻ 循环]  00:03 ═══●──────── 00:12                                 [直面屏]
 * ```
 *
 * # 为什么是「一条胶片」而不是把整本图库摊在空间里
 *
 * 一本图库动辄几十张，每张一块面板 = 几十块合成层，显存与合成预算都吃不消
 * （§14 显存释放路径至今失效）；参考软件的图集浏览也是「一块大幕布 + 一条缩略图」。
 * 翻页靠摇杆左右（按住连翻）、胶片点选、两端 ‹ ›。
 *
 * # 视频项
 *
 * 图库里混着的视频（多是几秒的短片）仍由那台 ExoPlayer 放在同一块幕布上，底行换成走带；
 * 默认单条循环；幻灯片开着时播完自动翻下一项。
 */
@Composable
fun GalleryPage(state: VideoControlsState, g: GalleryState, cb: VideoControlsCallbacks) {
    Column(modifier = Modifier.fillMaxSize().reportPanelTouches(cb)) {
        GalleryHeaderRow(state, g, cb)

        val notice = state.notice ?: g.error
        if (notice != null) {
            Text(
                text = notice,
                color = PanelTokens.WARN,
                fontSize = 15.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.padding(top = 6.dp),
            )
        }

        Spacer(Modifier.weight(1f))

        Filmstrip(g, cb, modifier = Modifier.fillMaxWidth().height(FILMSTRIP_HEIGHT))

        Spacer(Modifier.weight(1f))

        val current = g.current
        if (current != null && current.isVideo) {
            VideoBottomRow(state, g, cb)
        } else {
            ImageBottomRow(state, g, cb)
        }
    }
}

private val FILMSTRIP_HEIGHT = 128.dp
private val THUMB_HEIGHT = 112.dp

// ─────────────────────────────────────────────────────────── 头部行

@Composable
private fun GalleryHeaderRow(state: VideoControlsState, g: GalleryState, cb: VideoControlsCallbacks) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        CircleActionButton(SpatialIcons.Regular.Close, stringResource(R.string.xr_hide_panel), onClick = cb::onHidePanel)

        Column(modifier = Modifier.weight(1f).padding(start = 4.dp)) {
            Text(
                text = g.title.ifBlank { stringResource(R.string.xr_gallery_title_fallback) },
                color = PanelTokens.ON_SURFACE,
                fontSize = 20.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            // ⛔ 副标题里**不放文件名**：Iwara 的图片文件名是一串 UUID，用户读到的是「一堆 ID」
            //（用户 2026-09-06）。只留人看得懂的两样：作者与画面尺寸。
            val current = g.current
            val subtitle = buildList {
                if (g.author.isNotBlank()) add(g.author)
                if (current != null && current.width > 0 && current.height > 0) {
                    add(stringResource(R.string.xr_gallery_dims, current.width, current.height))
                }
            }.joinToString(stringResource(R.string.xr_dot_separator))
            if (subtitle.isNotBlank()) {
                Text(
                    text = subtitle,
                    color = PanelTokens.ON_SURFACE_DIM,
                    fontSize = 14.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }

        // 计数 chip；正在读取时换成读取态（与播放页的缓冲 chip 同一处位置、同一套配色）。
        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(14.dp))
                .background(if (g.loading) PanelTokens.WARN.copy(alpha = 0.18f) else PanelTokens.POPUP)
                .padding(horizontal = 12.dp, vertical = 5.dp),
        ) {
            Text(
                text = if (g.loading) {
                    stringResource(R.string.xr_loading)
                } else {
                    stringResource(R.string.xr_gallery_counter, g.index + 1, g.items.size)
                },
                color = if (g.loading) PanelTokens.WARN else PanelTokens.ON_SURFACE,
                fontSize = 14.sp,
            )
        }
        if (state.clockText.isNotBlank()) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Icon(SpatialIcons.Regular.Time, null, tint = PanelTokens.ON_SURFACE_DIM, modifier = Modifier.size(18.dp))
                Text(state.clockText, color = PanelTokens.ON_SURFACE_DIM, fontSize = 15.sp)
            }
        }
        if (state.batteryPercent >= 0) {
            val batColor = if (state.batteryCharging) PanelTokens.CHARGE else PanelTokens.ON_SURFACE_DIM
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Icon(SpatialIcons.Regular.Power, null, tint = batColor, modifier = Modifier.size(18.dp))
                Text("${state.batteryPercent}%", color = batColor, fontSize = 15.sp)
            }
        }

        Spacer(Modifier.width(8.dp))

        ViewDistanceButton(cb)
        CircleActionButton(SpatialIcons.Regular.Environment, stringResource(R.string.xr_nav_scene)) { cb.onRoute(ControlsRoute.SCENE) }
        CircleActionButton(SpatialIcons.Regular.Television, stringResource(R.string.xr_nav_screen_type)) { cb.onRoute(ControlsRoute.SCREEN_TYPE) }
        // 「接着看」：图库详情页的池（来源 / 最爱 / 稍后再看 / 作者的图库），点了换成那本图库。
        CircleActionButton(SpatialIcons.Regular.ListView, stringResource(R.string.xr_nav_playlist)) { cb.onRoute(ControlsRoute.PLAYLIST) }
        CircleActionButton(SpatialIcons.Regular.Settings, stringResource(R.string.xr_nav_settings)) { cb.onRoute(ControlsRoute.SETTINGS) }
        CircleActionButton(SpatialIcons.Regular.Home, stringResource(R.string.xr_nav_back_to_app), onClick = cb::onBackToApp)
    }
}

// ─────────────────────────────────────────────────────────── 胶片

/**
 * 缩略图胶片：按各项真实比例排格（宽 = 高 × 比例，夹在 0.6–1.9 之间），当前一格居中。
 *
 * 缩略图优先用 Dart 已交来的**本地文件**（[GalleryState.resolvedPath] / [GalleryItem.thumbPath]），
 * 没有才退回网络地址（原生这条网络不走应用内代理，能出图就出，出不了就是一块底色）。
 */
@Composable
private fun Filmstrip(g: GalleryState, cb: VideoControlsCallbacks, modifier: Modifier = Modifier) {
    val listState = rememberLazyListState()
    val density = LocalDensity.current

    // 当前项变了就把它滚到视口中间：LazyRow 没有居中 API，用负的 scrollOffset 把格子往右推半个视口。
    LaunchedEffect(g.index, g.items.size) {
        if (g.items.isEmpty()) return@LaunchedEffect
        val viewport = listState.layoutInfo.viewportEndOffset - listState.layoutInfo.viewportStartOffset
        val item = g.items.getOrNull(g.index)
        val itemPx = with(density) { thumbWidth(item).roundToPx() }
        val offset = if (viewport > 0) -((viewport - itemPx) / 2) else 0
        listState.animateScrollToItem(g.index.coerceIn(0, g.items.size - 1), offset)
    }

    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        if (g.items.isEmpty()) {
            Box(modifier = Modifier.weight(1f).fillMaxHeight(), contentAlignment = Alignment.Center) {
                Text(stringResource(R.string.xr_gallery_empty), color = PanelTokens.ON_SURFACE_DIM, fontSize = 16.sp)
            }
        } else {
            LazyRow(
                state = listState,
                modifier = Modifier.weight(1f).fillMaxHeight(),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                itemsIndexed(g.items, key = { _, item -> item.id }) { i, item ->
                    ThumbCell(
                        item = item,
                        path = g.resolvedPath[item.id] ?: item.thumbPath,
                        selected = i == g.index,
                        loading = i == g.index && g.loading,
                        onClick = { cb.onGalleryShow(i) },
                    )
                }
            }
        }
    }
}

/** 一格的宽：按项目真实比例，夹在 0.6–1.9（极端长图 / 全景条不把胶片撑爆）。没有尺寸按 4:3。 */
private fun thumbWidth(item: GalleryItem?): androidx.compose.ui.unit.Dp {
    val ratio = if (item != null && item.width > 0 && item.height > 0) {
        (item.width.toFloat() / item.height).coerceIn(0.6f, 1.9f)
    } else {
        4f / 3f
    }
    return THUMB_HEIGHT * ratio
}

@Composable
private fun ThumbCell(item: GalleryItem, path: String, selected: Boolean, loading: Boolean, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val hovered by interaction.collectIsHoveredAsState()
    val bg = when {
        pressed -> PanelTokens.PRESSED
        hovered -> PanelTokens.HOVER
        else -> PanelTokens.POPUP
    }
    val shape = RoundedCornerShape(12.dp)
    Box(
        modifier = Modifier
            .width(thumbWidth(item))
            .height(THUMB_HEIGHT)
            .clip(shape)
            .background(bg)
            .then(if (selected) Modifier.border(3.dp, PanelTokens.ON_SURFACE, shape) else Modifier)
            .hoverable(interaction)
            .clickable(interactionSource = interaction, indication = null, onClick = onClick),
    ) {
        val model: Any? = when {
            path.isNotBlank() -> File(path)
            item.thumbUrl.isNotBlank() -> item.thumbUrl
            else -> null
        }
        if (model != null) {
            AsyncImage(
                model = model,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize(),
            )
        } else {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Icon(SpatialIcons.Regular.Image, null, tint = PanelTokens.ON_SURFACE_DIM, modifier = Modifier.size(28.dp))
            }
        }
        // 非当前项压一层薄暗，当前项原色 —— 一眼看出停在哪。
        if (!selected) Box(modifier = Modifier.fillMaxSize().background(Color(0x55000000)))
        if (item.isVideo) {
            Row(
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(6.dp)
                    .clip(RoundedCornerShape(6.dp))
                    .background(Color(0xCC000000))
                    .padding(horizontal = 6.dp, vertical = 3.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(3.dp),
            ) {
                Icon(SpatialIcons.Regular.Play, null, tint = Color.White, modifier = Modifier.size(12.dp))
                Text(stringResource(R.string.xr_gallery_video_badge), color = Color.White, fontSize = 11.sp)
            }
        }
        if (loading) {
            Box(modifier = Modifier.fillMaxSize().background(Color(0x66000000)), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(
                    modifier = Modifier.size(28.dp),
                    color = Color.White,
                    trackColor = Color(0x33FFFFFF),
                    strokeWidth = 3.dp,
                )
            }
        }
    }
}

// ─────────────────────────────────────────────────────────── 底行：图片

@Composable
private fun ImageBottomRow(state: VideoControlsState, g: GalleryState, cb: VideoControlsCallbacks) {
    Row(
        modifier = Modifier.fillMaxWidth().height(PanelTokens.ROW_BUTTON_HEIGHT),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        PillButton(
            label = stringResource(if (g.slideshow) R.string.xr_gallery_slideshow_stop else R.string.xr_gallery_slideshow),
            icon = if (g.slideshow) SpatialIcons.Regular.Pause else SpatialIcons.Regular.Play,
            onClick = cb::onGalleryToggleSlideshow,
            selected = g.slideshow,
            enabled = g.items.size > 1,
        )
        SLIDESHOW_SECONDS.forEach { s ->
            PillButton(
                label = stringResource(R.string.xr_gallery_interval, s),
                onClick = { cb.onGallerySlideshowSeconds(s) },
                selected = s == g.slideshowSeconds,
                height = 44.dp,
            )
        }

        Spacer(Modifier.weight(1f))

        // ⛔ 这里原先有一组「− / 百分比 / +」的缩放钮，已整组移除（用户 2026-09-06）：
        // 缩放本来就该在幕布上做（捏合 / 双击 / 摇杆上下），面板上那一组只是重复入口。
        val original = g.quality == GALLERY_QUALITY_ORIGINAL
        PillButton(
            label = stringResource(if (original) R.string.xr_gallery_quality_original else R.string.xr_gallery_quality_standard),
            icon = SpatialIcons.Regular.ViewGallery,
            onClick = { cb.onGalleryPickQuality(if (original) GALLERY_QUALITY_STANDARD else GALLERY_QUALITY_ORIGINAL) },
            selected = original,
        )
        PillButton(
            label = stringResource(state.curve.labelRes),
            icon = SpatialIcons.Regular.Television,
            onClick = { cb.onRoute(ControlsRoute.SCREEN_TYPE) },
        )
    }
}

// ─────────────────────────────────────────────────────────── 底行：视频

@Composable
private fun VideoBottomRow(state: VideoControlsState, g: GalleryState, cb: VideoControlsCallbacks) {
    Row(
        modifier = Modifier.fillMaxWidth().height(PanelTokens.ROW_BUTTON_HEIGHT),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        CircleActionButton(
            icon = if (state.muted || state.volume <= 0f) SpatialIcons.Regular.VolumeOff else SpatialIcons.Regular.VolumeOn,
            contentDescription = stringResource(if (state.muted) R.string.xr_unmute else R.string.xr_mute),
            onClick = cb::onToggleMute,
            selected = state.muted,
        )
        CircleActionButton(
            icon = if (state.isPlaying) SpatialIcons.Regular.Pause else SpatialIcons.Regular.Play,
            contentDescription = stringResource(if (state.isPlaying) R.string.xr_pause else R.string.xr_play),
            onClick = cb::onPlayPause,
            emphasized = true,
        )
        PillButton(
            label = stringResource(R.string.xr_gallery_loop),
            icon = SpatialIcons.Regular.Replay,
            onClick = cb::onGalleryToggleLoop,
            selected = g.loopVideo && !g.slideshow,
            enabled = !g.slideshow,
        )
        PillButton(
            label = stringResource(if (g.slideshow) R.string.xr_gallery_slideshow_stop else R.string.xr_gallery_slideshow),
            icon = if (g.slideshow) SpatialIcons.Regular.Pause else SpatialIcons.Regular.Play,
            onClick = cb::onGalleryToggleSlideshow,
            selected = g.slideshow,
            enabled = g.items.size > 1,
        )

        val preview = state.seekPreviewText
        TimeLabel(
            text = preview ?: state.positionText,
            color = if (preview != null) PanelTokens.ON_SURFACE else PanelTokens.ON_SURFACE_DIM,
            modifier = Modifier.width(64.dp),
        )
        SeekBar(
            progress = state.progress,
            onSeek = cb::onSeek,
            onSeekFinished = cb::onSeekFinished,
            buffered = state.buffered,
            buffering = state.buffering,
            modifier = Modifier.weight(1f),
        )
        TimeLabel(text = state.durationText, modifier = Modifier.width(64.dp))

        PillButton(
            label = stringResource(state.curve.labelRes),
            icon = SpatialIcons.Regular.Television,
            onClick = { cb.onRoute(ControlsRoute.SCREEN_TYPE) },
        )
    }
}
