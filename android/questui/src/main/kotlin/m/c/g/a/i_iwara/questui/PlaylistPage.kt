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
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.ChevronLeft
import com.meta.spatial.uiset.theme.icons.regular.Download
import com.meta.spatial.uiset.theme.icons.regular.Refresh
import kotlinx.coroutines.flow.distinctUntilChanged

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
 * # 两级来源（与 2D 抽屉同一套）
 *
 * 分区行画的是 [VideoControlsState.playlistGroups]（来源 / 订阅 / 我的播放列表 / 最爱 / 本地收藏 /
 * 已下载 / 稍后再看 / 作者的视频 / 作者的播放列表 / 他人的播放列表）。单选项分组点了直接选池；
 * 多选项分组（播放列表 / 收藏夹 / 下载分类 / 稍后再看筛选）点了把这一行**换成**选项行
 * （「‹ 分组名」+ 各选项），不另占一行——面板只有 360dp 高。选项对应的池还没开就
 * [VideoControlsCallbacks.onOpenQueue] 让 Dart 开出来。目录为空时（没有详情页在场）退回按分区画。
 *
 * # 自动把正在播的卡滚到可见
 *
 * 进入页面 / 换分区 / 换正在播的视频时，把正在播的卡 [animateScrollToItem] 到列表可见范围。
 * 用 [animateScrollToItem]（而不是 `scrollToItem`）是因为 Quest 上突然跳一大段容易让人晕，
 * 且用户可能正在滑动卡片流，动画滚动被打断的观感更友好。
 *
 * # 无限滚动
 *
 * 分区的 [PlaylistSection.hasMore] 为真时，卡片流末尾挂一张「加载更多」卡：滚到它附近
 * （[LOAD_MORE_PREFETCH] 张以内）自动请 Dart 翻一页，也能点。Dart 翻完把整套分区重推回来，
 * 卡片按 id 做 key，滚动位置不丢。这就是应用里列表的无限滚动，只是触发点在面板
 * （用户 2026-09-05：「原版支持无限滚动，面板里却只提示回应用翻」）。
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

    // 进页面 / 换分区 / 换正在播的视频 → 把正在播的卡滚到可见。
    // ⛔ key 里**不能**放 entries.size：翻页追加之后会把用户刚滚到末尾的列表拽回正在播的那张。
    LaunchedEffect(active?.queueId, state.nowPlayingId, entries.isEmpty()) {
        if (entries.isEmpty()) return@LaunchedEffect
        val idx = entries.indexOfFirst { it.id == state.nowPlayingId }
        if (idx >= 0) {
            // 让正在播的卡靠中间：LazyRow 没有直接的居中 API，先滚到目标 index，
            // 视口宽 1060 / 卡宽 220 ≈ 4.8 张，往前退两张就近似居中。
            val target = (idx - 2).coerceAtLeast(0)
            listState.animateScrollToItem(target)
        }
    }

    // 滚到末尾自动翻页。entries.size 进 key：一页太短没填满视口时接着翻，直到填满或到底。
    val hasMore = active?.hasMore == true
    val loadingMore = active != null && state.playlistLoadingMoreQueueId == active.queueId
    LaunchedEffect(active?.queueId, hasMore, entries.size) {
        val queueId = active?.queueId ?: return@LaunchedEffect
        if (!hasMore) return@LaunchedEffect
        snapshotFlow { listState.layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: -1 }
            .distinctUntilChanged()
            .collect { last ->
                if (last >= entries.size - LOAD_MORE_PREFETCH) cb.onLoadMorePlaylist(queueId)
            }
    }

    Column(
        modifier = Modifier.fillMaxSize().reportPanelTouches(cb),
        verticalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        PageHeader(
            title = stringResource(R.string.xr_playlist_title),
            subtitle = buildSubtitle(state, active, entries.size),
            onBack = { cb.onRoute(ControlsRoute.PLAYER) },
            trailing = {
                CircleActionButton(
                    icon = SpatialIcons.Regular.Refresh,
                    contentDescription = stringResource(R.string.xr_refresh),
                    onClick = cb::onRefreshPlaylist,
                )
            },
        )

        // ── 来源行：目录（两级）；没有目录时退回按分区画 ─────────────────────
        if (state.playlistGroups.isNotEmpty()) {
            GroupRow(state = state, cb = cb)
        } else if (state.playlistSections.isNotEmpty()) {
            SectionTabRow(state = state, cb = cb)
        }

        // ── 卡片流 / 空态 / 加载态 ───────────────
        Box(modifier = Modifier.weight(1f).fillMaxWidth()) {
            when {
                // 池刚开、第一页还没到：Dart 会先把空池推过来（adopt 那一刻），再等第一页到了重推——
                // 中间这段按 section.loading 画转圈，别露出「这个池里还没有条目」（用户 2026-09-05：切页签先空白）。
                (state.playlistLoading || active?.loading == true) && entries.isEmpty() -> LoadingCenter()
                state.playlistSections.isEmpty() && state.playlistGroups.isEmpty() -> EmptyCenter(cb)
                active == null -> EmptySectionCenter()
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
                            isSwitching = entry.id == state.switchingToId,
                            // 换片 / 开池在途时不再接点击：Dart 那边要几百毫秒到几秒，连点会排队换片。
                            onPlay = {
                                if (!state.playlistLoading && state.switchingToId == null) {
                                    cb.onPlayEntry(active.queueId, entry.id)
                                }
                            },
                        )
                    }
                    if (hasMore) {
                        item(key = "__more") {
                            LoadMoreCard(
                                loading = loadingMore,
                                onClick = { cb.onLoadMorePlaylist(active.queueId) },
                            )
                        }
                    }
                }
            }
            // 在途态：卡片流之上压一层 + 转圈，把「点了、正在等」说清楚（用户 2026-09-05：延迟期间要有 loading）。
            androidx.compose.animation.AnimatedVisibility(
                visible = state.playlistLoading && entries.isNotEmpty(),
                enter = androidx.compose.animation.fadeIn(),
                exit = androidx.compose.animation.fadeOut(),
                modifier = Modifier.fillMaxSize(),
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(PanelTokens.SURFACE.copy(alpha = 0.72f))
                        // 吃掉所有触碰（含滚动），在途期间列表不可操作。
                        .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {},
                    contentAlignment = Alignment.Center,
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                    ) {
                        CircularProgressIndicator(color = PanelTokens.ON_SURFACE, strokeWidth = 3.dp, modifier = Modifier.size(28.dp))
                        Text(
                            text = stringResource(
                            if (state.playlistPendingQueueId != null) {
                                R.string.xr_opening
                            } else {
                                R.string.xr_switching
                            },
                        ),
                            color = PanelTokens.ON_SURFACE,
                            fontSize = 16.sp,
                        )
                    }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────── 子件

/** 来源目录行：分组行 / 展开的选项行二选一。 */
@Composable
private fun GroupRow(state: VideoControlsState, cb: VideoControlsCallbacks) {
    val scroll = rememberScrollState()
    val activeId = state.activeSection?.queueId
    val expanded = state.playlistGroups.firstOrNull { it.id == state.expandedGroupId }

    fun pick(queueId: String) {
        if (state.playlistSections.any { it.queueId == queueId }) {
            cb.onPickPlaylistSection(queueId)
            cb.onExpandPlaylistGroup(null)
        } else {
            cb.onOpenQueue(queueId)
        }
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .horizontalScroll(scroll),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (expanded != null) {
            PillButton(
                label = expanded.title,
                icon = SpatialIcons.Regular.ChevronLeft,
                onClick = { cb.onExpandPlaylistGroup(null) },
                height = 44.dp,
            )
            expanded.choices.forEach { choice ->
                val pending = state.playlistPendingQueueId == choice.queueId
                PillButton(
                    label = when {
                        pending -> stringResource(R.string.xr_pill_pending, choice.title)
                        choice.count >= 0 ->
                            stringResource(R.string.xr_pill_count, choice.title, choice.count)
                        else -> choice.title
                    },
                    onClick = { if (!state.playlistLoading) pick(choice.queueId) },
                    selected = choice.queueId == activeId || pending,
                    enabled = choice.count != 0 && (!state.playlistLoading || pending),
                    height = 44.dp,
                )
            }
            if (expanded.choices.isEmpty()) {
                Text(
                    text = stringResource(
                        if (expanded.loading) R.string.xr_loading else R.string.xr_empty_choices,
                    ),
                    color = PanelTokens.ON_SURFACE_DIM,
                    fontSize = 14.sp,
                )
            }
        } else {
            state.playlistGroups.forEach { group ->
                val containsActive = group.choices.any { it.queueId == activeId }
                val pending = group.choices.any { it.queueId == state.playlistPendingQueueId }
                val single = group.choices.singleOrNull()
                val section = single?.let { s -> state.playlistSections.firstOrNull { it.queueId == s.queueId } }
                val label = when {
                    pending -> stringResource(R.string.xr_pill_pending, group.title)
                    section != null && section.entries.isNotEmpty() ->
                        stringResource(R.string.xr_pill_count, group.title, section.entries.size)
                    group.loading -> stringResource(R.string.xr_pill_pending, group.title)
                    group.subtitle.isNotBlank() ->
                        stringResource(R.string.xr_pill_subtitle, group.title, group.subtitle)
                    else -> group.title
                }
                PillButton(
                    label = label,
                    onClick = {
                        if (state.playlistLoading) return@PillButton
                        when {
                            single != null -> pick(single.queueId)
                            group.choices.isNotEmpty() -> cb.onExpandPlaylistGroup(group.id)
                            group.loading -> cb.onExpandPlaylistGroup(group.id)
                        }
                    },
                    selected = containsActive || pending,
                    enabled = (group.loading || group.choices.isNotEmpty()) && (!state.playlistLoading || pending),
                    height = 44.dp,
                )
            }
        }
    }
}

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
                    stringResource(R.string.xr_pill_count, section.title, section.entries.size)
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
    isSwitching: Boolean = false,
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
            // 已下载：右上角小角标，与左上角那枚互不冲突。
            if (entry.downloaded) {
                Row(
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(8.dp)
                        .clip(RoundedCornerShape(6.dp))
                        .background(PanelTokens.CHARGE.copy(alpha = 0.9f))
                        .padding(horizontal = 6.dp, vertical = 3.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(3.dp),
                ) {
                    androidx.compose.material3.Icon(
                        SpatialIcons.Regular.Download,
                        null,
                        tint = PanelTokens.SURFACE,
                        modifier = Modifier.size(12.dp),
                    )
                    Text(
                        text = stringResource(R.string.xr_badge_downloaded),
                        color = PanelTokens.SURFACE,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Medium,
                    )
                }
            }
            // 换片在途：封面上压一层转圈（用户 2026-09-05：卡片先 loading，好了再换播放器）。
            if (isSwitching) {
                Box(
                    modifier = Modifier.fillMaxSize().background(Color(0x99000000)),
                    contentAlignment = Alignment.Center,
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        CircularProgressIndicator(color = PanelTokens.ON_SURFACE, strokeWidth = 3.dp, modifier = Modifier.size(30.dp))
                        Text(
                            text = stringResource(R.string.xr_card_loading),
                            color = PanelTokens.ON_SURFACE,
                            fontSize = 12.sp,
                        )
                    }
                }
            }
            // 角标（同一时刻只画一枚，优先级：正在播 > 站外 > 已看完）
            when {
                isSwitching -> {}
                isNowPlaying -> CornerBadge(
                    text = stringResource(R.string.xr_badge_now_playing),
                    bg = PanelTokens.ON_SURFACE,
                    fg = PanelTokens.SURFACE,
                )
                !entry.playable -> CornerBadge(
                    text = stringResource(R.string.xr_badge_offsite),
                    bg = PanelTokens.WARN,
                    fg = PanelTokens.SURFACE,
                )
                entry.watched -> CornerBadge(
                    text = stringResource(R.string.xr_badge_watched),
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
                text = entry.title.ifBlank { stringResource(R.string.xr_untitled) },
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
 * 卡片流末尾的「加载更多」卡：滚到附近自动触发，也能点；翻页中显示转圈。
 * 低透明度描边与真卡片区分。
 */
@Composable
private fun LoadMoreCard(loading: Boolean, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val hovered by interaction.collectIsHoveredAsState()
    val bg = when {
        loading -> Color.Transparent
        pressed -> PanelTokens.PRESSED
        hovered -> PanelTokens.HOVER
        else -> Color.Transparent
    }
    Column(
        modifier = Modifier
            .width(220.dp)
            .fillMaxHeight()
            .clip(RoundedCornerShape(18.dp))
            .background(bg)
            .border(
                width = 1.dp,
                color = PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.45f),
                shape = RoundedCornerShape(18.dp),
            )
            .hoverable(interaction, enabled = !loading)
            .clickable(
                interactionSource = interaction,
                indication = null,
                enabled = !loading,
                onClick = onClick,
            ),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        if (loading) {
            CircularProgressIndicator(
                color = PanelTokens.ON_SURFACE,
                strokeWidth = 3.dp,
                modifier = Modifier.size(28.dp),
            )
            Spacer(Modifier.height(10.dp))
            Text(
                text = stringResource(R.string.xr_loading_next_page),
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 14.sp,
            )
        } else {
            Text(
                text = stringResource(R.string.xr_load_more),
                color = PanelTokens.ON_SURFACE,
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium,
            )
            Spacer(Modifier.height(4.dp))
            Text(
                text = stringResource(R.string.xr_load_more_hint),
                color = PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.7f),
                fontSize = 12.sp,
            )
        }
    }
}

/** 离末尾还有这么多张卡时就开始翻下一页。 */
private const val LOAD_MORE_PREFETCH = 3

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
                text = stringResource(R.string.xr_loading),
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
                text = stringResource(R.string.xr_playlist_empty_title),
                color = PanelTokens.ON_SURFACE,
                fontSize = 17.sp,
            )
            Text(
                text = stringResource(R.string.xr_playlist_empty_hint),
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 13.sp,
            )
            PillButton(
                label = stringResource(R.string.xr_refresh),
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
            text = stringResource(R.string.xr_section_empty),
            color = PanelTokens.ON_SURFACE_DIM,
            fontSize = 15.sp,
        )
    }
}

// ─────────────────────────────────────────────────────────── 文案

@Composable
private fun buildSubtitle(
    state: VideoControlsState,
    active: PlaylistSection?,
    count: Int,
): String? {
    if (state.playlistLoading && state.playlistSections.isEmpty()) {
        return stringResource(R.string.xr_loading)
    }
    if (state.playlistSections.isEmpty()) return null
    val pool = active?.title ?: return null
    val base = stringResource(R.string.xr_playlist_subtitle, pool, count)
    return if (active.hasMore) stringResource(R.string.xr_playlist_subtitle_more, base) else base
}
