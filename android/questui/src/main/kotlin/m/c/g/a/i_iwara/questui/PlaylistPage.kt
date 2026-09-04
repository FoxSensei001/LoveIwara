package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.hoverable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsHoveredAsState
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.Refresh

/**
 * 「接着看」页：横向卡片流，按分区（= 详情页的视频池）切 tab。
 *
 * # 为什么是横向而不是竖向
 *
 * 面板是 1100×360dp 的**矮而宽**的窗（[PanelTokens.WIDTH_DP] × [PanelTokens.HEIGHT_DP]），
 * 竖向列表在这里一屏只放两三行，横向卡片流才用得满。参考软件的「继续观看」抽屉也是横滚。
 *
 * # 与详情页数据一致
 *
 * 分区来自 [VideoControlsState.playlistSections]：Dart 侧把详情页正在用的视频池整套推过来
 * （来源 / 播放列表 / 稍后再看 / 作者作品……），头显里看到的与用户在应用里看到的是同一份东西
 * （用户 2026-09-05）。点分区 tab 触发 [VideoControlsCallbacks.onPickPlaylistSection]，
 * 换池由 Dart 完成后再把 [VideoControlsState.activeQueueId] 推回来。
 *
 * # 自动把正在播的卡滚到可见
 *
 * 进入页面 / 换分区 / 换正在播的视频时，把正在播的卡 [animateScrollToItem] 到列表可见范围。
 * 用 [animateScrollToItem]（而不是 `scrollToItem`）是因为 Quest 上突然跳一大段容易让人晕，
 * 且用户可能正在滑动卡片流，动画滚动被打断的观感更友好。
 *
 * # ⛔ 滚动在 Quest 上有一条官方已知伤
 *
 * `spatial-sdk-known-issues`：直触可能触发不到滚动，得靠远距射线捏合拖动。所以卡片本身要大
 * （220×~200dp @2.2m ≈ 44×40mm，远高于官方 2.5°–3° 命中下限），且卡与卡之间留 14dp 缝，
 * 让「点错卡」这种事在直触失灵时也不易发生。
 */
@Composable
fun PlaylistPage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    val active = state.activeSection
    val entries = active?.entries.orEmpty()
    val listState = rememberLazyListState()

    // 进页面 / 换分区 / 换正在播的视频 → 把正在播的卡滚到可见
    LaunchedEffect(active?.queueId, state.nowPlayingId, entries.size) {
        if (entries.isEmpty()) return@LaunchedEffect
        val idx = entries.indexOfFirst { it.id == state.nowPlayingId }
        if (idx >= 0) {
            // 让正在播的卡靠中间：LazyRow 没有直接的居中 API，先滚到目标 index，
            // 视口宽 1060 / 卡宽 220 ≈ 4.8 张，往前退两张就近似居中。
            val target = (idx - 2).coerceAtLeast(0)
            listState.animateScrollToItem(target)
        }
    }

    Column(
        modifier = Modifier.fillMaxSize().reportPanelTouches(cb),
        verticalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        PageHeader(
            title = "接着看",
            subtitle = buildSubtitle(state, active, entries.size),
            onBack = { cb.onRoute(ControlsRoute.PLAYER) },
            trailing = {
                CircleActionButton(
                    icon = SpatialIcons.Regular.Refresh,
                    contentDescription = "刷新",
                    onClick = cb::onRefreshPlaylist,
                )
            },
        )

        // ── 分区 tab 行 ─────────────────────────────
        // 只有一个分区也照样画（作为标题的一部分），保持一致的视觉锚点。
        if (state.playlistSections.isNotEmpty()) {
            SectionTabRow(state = state, cb = cb)
        }

        // ── 卡片流 / 空态 / 加载态 ───────────────
        Box(modifier = Modifier.weight(1f).fillMaxWidth()) {
            when {
                state.playlistLoading && entries.isEmpty() -> LoadingCenter()
                state.playlistSections.isEmpty() -> EmptyCenter(cb)
                entries.isEmpty() -> EmptySectionCenter()
                else -> LazyRow(
                    state = listState,
                    modifier = Modifier.fillMaxSize(),
                    horizontalArrangement = Arrangement.spacedBy(14.dp),
                ) {
                    items(entries, key = { it.id }) { entry ->
                        PlaylistCard(
                            entry = entry,
                            isNowPlaying = entry.id == state.nowPlayingId,
                            onPlay = { cb.onPlayEntry(active!!.queueId, entry.id) },
                        )
                    }
                    if (active?.hasMore == true) {
                        item(key = "__more") { MorePlaceholderCard() }
                    }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────── 子件

/** 分区 tab 行；宽度超过视口时横向滚。 */
@Composable
private fun SectionTabRow(state: VideoControlsState, cb: VideoControlsCallbacks) {
    val scroll = rememberScrollState()
    val activeId = state.activeSection?.queueId
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .horizontalScroll(scroll),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        state.playlistSections.forEach { section ->
            PillButton(
                label = if (section.entries.isEmpty()) {
                    section.title
                } else {
                    "${section.title} · ${section.entries.size}"
                },
                onClick = { cb.onPickPlaylistSection(section.queueId) },
                selected = section.queueId == activeId,
                height = 44.dp,
            )
        }
    }
}

/**
 * 一张视频卡：封面 16:9 + 标题（2 行）+ 作者 · 时长。
 *
 * 三种状态影响观感：
 * - **正在播**：亮描边 + 「正在播放」角标 + 标题加粗。
 * - **已看完**：封面压暗 + 「已看完」角标（进度条按 [PlaylistEntry.progressRatio] 满格）。
 * - **站外**（`playable = false`）：整张卡压暗、点不动、「站外」角标（WARN 色）。
 */
@Composable
private fun PlaylistCard(
    entry: PlaylistEntry,
    isNowPlaying: Boolean,
    onPlay: () -> Unit,
) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val hovered by interaction.collectIsHoveredAsState()
    val enabled = entry.playable

    val bg = when {
        !enabled -> PanelTokens.POPUP.copy(alpha = 0.55f)
        pressed -> PanelTokens.PRESSED
        hovered -> PanelTokens.HOVER
        else -> PanelTokens.POPUP
    }

    Column(
        modifier = Modifier
            .width(220.dp)
            .fillMaxHeight()
            .clip(RoundedCornerShape(18.dp))
            .background(bg)
            .then(
                if (isNowPlaying) {
                    Modifier.border(2.dp, PanelTokens.ON_SURFACE, RoundedCornerShape(18.dp))
                } else {
                    Modifier
                },
            )
            .hoverable(interaction, enabled = enabled)
            .clickable(
                interactionSource = interaction,
                indication = null,
                enabled = enabled,
                onClick = onPlay,
            ),
    ) {
        // ── 封面 16:9 ──
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(16f / 9f)
                .background(PanelTokens.POPUP),
        ) {
            if (entry.thumbnailUrl.isNotBlank()) {
                AsyncImage(
                    model = entry.thumbnailUrl,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .fillMaxSize()
                        .alpha(if (entry.watched || !entry.playable) 0.42f else 1f),
                )
            }
            // 角标（同一时刻只画一枚，优先级：正在播 > 站外 > 已看完）
            when {
                isNowPlaying -> CornerBadge(
                    text = "正在播放",
                    bg = PanelTokens.ON_SURFACE,
                    fg = PanelTokens.SURFACE,
                )
                !entry.playable -> CornerBadge(
                    text = "站外",
                    bg = PanelTokens.WARN,
                    fg = PanelTokens.SURFACE,
                )
                entry.watched -> CornerBadge(
                    text = "已看完 ✓",
                    bg = PanelTokens.POPUP.copy(alpha = 0.85f),
                    fg = PanelTokens.ON_SURFACE_DIM,
                )
            }
            // 底部进度细线（有进度时才画；已看完按满格）
            val ratio = entry.progressRatio.coerceIn(0f, 1f)
            if (ratio > 0.005f || entry.watched) {
                val shown = if (entry.watched) 1f else ratio
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomStart)
                        .fillMaxWidth()
                        .height(3.dp)
                        .background(Color(0x66000000)),
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxHeight()
                            .fillMaxWidth(shown)
                            .background(
                                if (entry.watched) PanelTokens.ON_SURFACE_DIM else PanelTokens.ON_SURFACE,
                            ),
                    )
                }
            }
        }

        // ── 文字区 ──
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .padding(horizontal = 12.dp, vertical = 10.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp),
        ) {
            Text(
                text = entry.title.ifBlank { "（无标题）" },
                color = if (enabled) PanelTokens.ON_SURFACE else PanelTokens.ON_SURFACE_DIM,
                fontSize = 15.sp,
                lineHeight = 19.sp,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
                fontWeight = if (isNowPlaying) FontWeight.SemiBold else FontWeight.Normal,
                modifier = Modifier.weight(1f, fill = false),
            )
            Text(
                text = buildString {
                    if (entry.author.isNotBlank()) append(entry.author).append(" · ")
                    append(entry.durationText)
                },
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 13.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }
    }
}

/** 封面左上角标。 */
@Composable
private fun BoxScope.CornerBadge(text: String, bg: Color, fg: Color) {
    Box(
        modifier = Modifier
            .align(Alignment.TopStart)
            .padding(8.dp)
            .clip(RoundedCornerShape(6.dp))
            .background(bg)
            .padding(horizontal = 8.dp, vertical = 3.dp),
    ) {
        Text(
            text = text,
            color = fg,
            fontSize = 11.sp,
            fontWeight = FontWeight.Medium,
            maxLines = 1,
        )
    }
}

/**
 * 「还有更多…」占位卡：只是提示这个池还有下一页没拉，本身不可点。
 * 用虚线感的边框（低透明度）与真卡片区分。
 */
@Composable
private fun MorePlaceholderCard() {
    Column(
        modifier = Modifier
            .width(220.dp)
            .fillMaxHeight()
            .clip(RoundedCornerShape(18.dp))
            .border(
                width = 1.dp,
                color = PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.45f),
                shape = RoundedCornerShape(18.dp),
            ),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(
            text = "还有更多…",
            color = PanelTokens.ON_SURFACE_DIM,
            fontSize = 15.sp,
        )
        Spacer(Modifier.height(4.dp))
        Text(
            text = "回应用里翻更多",
            color = PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.6f),
            fontSize = 12.sp,
        )
    }
}

@Composable
private fun LoadingCenter() {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            CircularProgressIndicator(
                color = PanelTokens.ON_SURFACE,
                strokeWidth = 3.dp,
                modifier = Modifier.size(36.dp),
            )
            Text(
                text = "正在读取…",
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 15.sp,
            )
        }
    }
}

/** 全空态：一条分区都没有。 */
@Composable
private fun EmptyCenter(cb: VideoControlsCallbacks) {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Text(
                text = "没有可接着看的内容",
                color = PanelTokens.ON_SURFACE,
                fontSize = 17.sp,
            )
            Text(
                text = "回应用里把想看的加进队列，这里就能直接接着放",
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 13.sp,
            )
            PillButton(
                label = "刷新",
                icon = SpatialIcons.Regular.Refresh,
                onClick = cb::onRefreshPlaylist,
                height = 44.dp,
            )
        }
    }
}

/** 分区选中了但该分区没条目：不重新出「刷新」，因为其它分区可能有货。 */
@Composable
private fun EmptySectionCenter() {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(
            text = "这个池里还没有条目 —— 换上面的 tab 试试其它分区",
            color = PanelTokens.ON_SURFACE_DIM,
            fontSize = 15.sp,
        )
    }
}

// ─────────────────────────────────────────────────────────── 文案

private fun buildSubtitle(
    state: VideoControlsState,
    active: PlaylistSection?,
    count: Int,
): String? {
    if (state.playlistLoading && state.playlistSections.isEmpty()) return "正在读取…"
    if (state.playlistSections.isEmpty()) return null
    val pool = active?.title ?: return null
    val base = "$pool · 共 $count 条"
    return if (active.hasMore) "$base（还有更多）" else base
}
