package m.c.g.a.i_iwara.questui

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
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
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.CheckAlt
import com.meta.spatial.uiset.theme.icons.regular.ChevronDown
import com.meta.spatial.uiset.theme.icons.regular.ChevronLeft
import com.meta.spatial.uiset.theme.icons.regular.ChevronRight
import com.meta.spatial.uiset.theme.icons.regular.Computer
import com.meta.spatial.uiset.theme.icons.regular.Download
import com.meta.spatial.uiset.theme.icons.regular.Folder
import com.meta.spatial.uiset.theme.icons.regular.HeartOn
import com.meta.spatial.uiset.theme.icons.regular.Internet
import com.meta.spatial.uiset.theme.icons.regular.Library
import com.meta.spatial.uiset.theme.icons.regular.ListView
import com.meta.spatial.uiset.theme.icons.regular.LockOn
import com.meta.spatial.uiset.theme.icons.regular.MyMedia
import com.meta.spatial.uiset.theme.icons.regular.Notifications
import com.meta.spatial.uiset.theme.icons.regular.PasswordVisible
import com.meta.spatial.uiset.theme.icons.regular.Play
import com.meta.spatial.uiset.theme.icons.regular.Refresh
import com.meta.spatial.uiset.theme.icons.regular.SidebarPin
import com.meta.spatial.uiset.theme.icons.regular.Star
import com.meta.spatial.uiset.theme.icons.regular.Time
import com.meta.spatial.uiset.theme.icons.regular.ViewGallery
import kotlinx.coroutines.flow.distinctUntilChanged

/** 离末尾还有这么多张卡时就开始翻下一页。 */
private const val LOAD_MORE_PREFETCH = 3

/** 图标键映射到 UI Set 图标。 */
@Composable
private fun queueIcon(iconKey: String): ImageVector? = when (iconKey) {
    "source" -> SpatialIcons.Regular.ListView
    "subscriptions" -> SpatialIcons.Regular.Notifications
    "playlist" -> SpatialIcons.Regular.Library
    "favorite" -> SpatialIcons.Regular.HeartOn
    "folder" -> SpatialIcons.Regular.Folder
    "download" -> SpatialIcons.Regular.Download
    "devices" -> SpatialIcons.Regular.Computer
    "watchLater" -> SpatialIcons.Regular.Time
    "star" -> SpatialIcons.Regular.Star
    "videos" -> SpatialIcons.Regular.MyMedia
    "gallery" -> SpatialIcons.Regular.ViewGallery
    "play" -> SpatialIcons.Regular.Play
    "pin" -> SpatialIcons.Regular.SidebarPin
    else -> null
}

/**
 * 「接着看」页。
 *
 * # ⛔ 显示与交互照 2D 抽屉（`playback_queue_drawer.dart`），不另起一套
 *
 * 空间版原先是先做出来的 2D 版之外自己长的：分组药丸行、「正在播放 / 已看完 / 已下载」角标、
 * 一切分区就换池……两边越走越远（用户 2026-09-14）。现在逐条对齐：
 *
 * - 顶栏的**池胶囊**顶替标题（= 2D 的 `GlassDropdownPill`），忙碌只加一枚转圈、不改图标和字；
 * - 点胶囊开**池选择器**（= 2D 的多级玻璃菜单）：树由 Dart 的 `XrQueueCatalog` 逐项翻译过来，
 *   面板只管画，「‹ 标题」一行回上一层；
 * - **切池只是浏览，点卡片才换池**：「正在播」的标记只在浏览的池就是播放器在用的池时才画；
 * - 卡片内容 = 2D `_QueueRow`：封面左下时长 / 张数 / 站外、右下播放量、左上本地清晰度、底沿进度，
 *   文字区标题 + 「作者 · 🔒 · ♥ · 时间」；空 / 加载失败（点击重试）/ 加载中三态同 2D。
 *
 * # 保留的空间差异
 *
 * - 卡片流是**横向**的：面板矮而宽（[PanelTokens.WIDTH_DP] × [PanelTokens.HEIGHT_DP]），竖排一屏只放两三行；
 * - 选择器是三列网格而不是弹出菜单：面板上没有「浮在上面的一张菜单」这种层；
 * - 站外视频卡片压暗、点不动：沉浸空间里放不了；
 * - 没有长按预览弹窗。
 *
 * # ⛔ 滚动在 Quest 上有一条官方已知伤
 *
 * `spatial-sdk-known-issues`：直触可能触发不到滚动，得靠远距射线捏合拖动。所以卡片要大
 * （220dp 宽 @2.2m 远高于 2.5°–3° 命中下限），卡与卡之间留 14dp 缝。
 */
@Composable
fun PlaylistPage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .reportPanelTouches(cb),
        verticalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        // ── 5.1 顶栏（一行）：返回圆钮 + 池胶囊 + 刷新圆钮 ──
        TopBar(state = state, cb = cb)

        // ── 主体区域：选择器展开时显示多级目录树，否则显示横向卡片流 ──
        Box(modifier = Modifier.weight(1f).fillMaxWidth()) {
            if (state.pickerOpen) {
                PickerView(state = state, cb = cb)
            } else {
                CardStreamView(state = state, cb = cb)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────── 5.1 顶栏

@Composable
private fun TopBar(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        CircleActionButton(
            icon = SpatialIcons.Regular.ChevronLeft,
            contentDescription = stringResource(R.string.xr_back),
            onClick = { cb.onRoute(ControlsRoute.PLAYER) },
        )

        QueuePillButton(state = state, cb = cb)

        Spacer(Modifier.weight(1f))

        CircleActionButton(
            icon = SpatialIcons.Regular.Refresh,
            contentDescription = stringResource(R.string.xr_refresh),
            onClick = cb::onRefreshPlaylist,
        )
    }
}

/**
 * 顶栏池胶囊：展示当前正在浏览的池名与图标，点击展开/收起池选择器。
 */
@Composable
private fun QueuePillButton(state: VideoControlsState, cb: VideoControlsCallbacks) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val hovered by interaction.collectIsHoveredAsState()

    val enabled = state.playlistCatalog != null
    val selected = state.pickerOpen
    val busy = state.pendingBrowseQueueId != null || state.pendingExpandNodeId != null

    // pending 期间 browseSection 为 null 时沿用上一次显示的 section
    var lastNonNullSection by remember { mutableStateOf<PlaylistSection?>(null) }
    state.browseSection?.let { lastNonNullSection = it }
    val currentSection = state.browseSection ?: lastNonNullSection

    val poolTitle = currentSection?.title?.ifBlank { null }
        ?: state.playlistTexts["upNext"].orEmpty()
    val poolIcon = queueIcon(currentSection?.icon.orEmpty())

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
    val pickerDesc = stringResource(R.string.xr_queue_picker)

    Row(
        modifier = Modifier
            .height(56.dp)
            .clip(RoundedCornerShape(28.dp))
            .background(bg)
            .hoverable(interaction, enabled)
            .clickable(
                interactionSource = interaction,
                indication = null,
                enabled = enabled,
                onClick = { cb.onTogglePicker(!state.pickerOpen) },
            )
            .semantics { contentDescription = pickerDesc }
            .padding(horizontal = 18.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        if (busy) {
            CircularProgressIndicator(
                color = fg,
                strokeWidth = 2.dp,
                modifier = Modifier.size(20.dp),
            )
        }
        if (poolIcon != null) {
            Icon(poolIcon, contentDescription = null, tint = fg, modifier = Modifier.size(22.dp))
        }
        Text(
            text = poolTitle,
            color = fg,
            fontSize = 20.sp,
            fontWeight = FontWeight.SemiBold,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.widthIn(max = 620.dp),
        )
        Icon(
            SpatialIcons.Regular.ChevronDown,
            contentDescription = null,
            tint = fg,
            modifier = Modifier.size(20.dp),
        )
    }
}

// ─────────────────────────────────────────────────────────── 5.2 池选择器

@Composable
private fun PickerView(state: VideoControlsState, cb: VideoControlsCallbacks) {
    val level = state.pickerLevel ?: return
    val isRoot = state.pickerPath.isEmpty() || level.id == "root"

    // 本层只要有任一 option 带 icon 或 avatarUrl != null，所有 option 都留同宽 32dp 槽
    val reservedLeadWidth = level.children.any {
        it.type == "option" && (it.icon.isNotBlank() || it.avatarUrl != null)
    }

    LazyVerticalGrid(
        columns = GridCells.Fixed(3),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp),
        modifier = Modifier.fillMaxSize(),
    ) {
        // 非根层标题行：「‹ 层标题」
        if (!isRoot) {
            item(key = "__level_header", span = { GridItemSpan(maxLineSpan) }) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .clickable { cb.onPickerPop() }
                        .padding(horizontal = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Icon(
                        SpatialIcons.Regular.ChevronLeft,
                        contentDescription = null,
                        tint = PanelTokens.ON_SURFACE_DIM,
                        modifier = Modifier.size(22.dp),
                    )
                    Text(
                        text = level.title,
                        color = PanelTokens.ON_SURFACE,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.SemiBold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
            }
            item(key = "__level_divider", span = { GridItemSpan(maxLineSpan) }) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(1.dp)
                        .background(PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.25f)),
                )
            }
        }

        // 子节点渲染
        level.children.forEachIndexed { index, node ->
            when (node.type) {
                "separator" -> {
                    item(key = "sep_${node.id}_$index", span = { GridItemSpan(maxLineSpan) }) {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp)
                                .height(1.dp)
                                .background(PanelTokens.ON_SURFACE_DIM.copy(alpha = 0.25f)),
                        )
                    }
                }
                "header" -> {
                    item(key = "hdr_${node.id}_$index", span = { GridItemSpan(maxLineSpan) }) {
                        Text(
                            text = node.title,
                            color = PanelTokens.ON_SURFACE_DIM,
                            fontSize = 13.sp,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(start = 8.dp, top = 4.dp, bottom = 4.dp),
                        )
                    }
                }
                "retry" -> {
                    item(key = "retry_${node.id}_$index", span = { GridItemSpan(maxLineSpan) }) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(52.dp)
                                .clip(RoundedCornerShape(12.dp))
                                .clickable { cb.onExpandCatalogNode(node.expandNodeId) }
                                .padding(horizontal = 12.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                        ) {
                            Icon(
                                SpatialIcons.Regular.Refresh,
                                contentDescription = null,
                                tint = PanelTokens.ON_SURFACE,
                                modifier = Modifier.size(20.dp),
                            )
                            Text(
                                text = node.title,
                                color = PanelTokens.ON_SURFACE,
                                fontSize = 15.sp,
                            )
                        }
                    }
                }
                else -> {
                    item(key = "opt_${node.id}_$index") {
                        CatalogOptionCell(
                            node = node,
                            reservedLeadWidth = reservedLeadWidth,
                            cb = cb,
                        )
                    }
                }
            }
        }

        // 当前层 loading 或 lazy 时末尾追加 full-span 转圈
        if (level.loading || level.lazy) {
            item(key = "__level_loading", span = { GridItemSpan(maxLineSpan) }) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    CircularProgressIndicator(
                        color = PanelTokens.ON_SURFACE,
                        strokeWidth = 2.dp,
                        modifier = Modifier.size(20.dp),
                    )
                    Spacer(Modifier.width(8.dp))
                    Text(
                        text = stringResource(R.string.xr_loading),
                        color = PanelTokens.ON_SURFACE_DIM,
                        fontSize = 14.sp,
                    )
                }
            }
        }
    }
}

/**
 * 菜单格：高 64dp，圆角 16dp，支持头像/图标、主副标题、计数与分支箭头/打勾。
 */
@Composable
private fun CatalogOptionCell(
    node: CatalogNode,
    reservedLeadWidth: Boolean,
    cb: VideoControlsCallbacks,
) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val hovered by interaction.collectIsHoveredAsState()

    val baseBg = when {
        pressed -> PanelTokens.PRESSED
        hovered -> PanelTokens.HOVER
        else -> PanelTokens.POPUP
    }

    val onClick: () -> Unit = {
        if (node.enabled) {
            when {
                node.branch -> cb.onPickerPush(node.id)
                node.queueId.isNotBlank() -> cb.onBrowseQueue(node.queueId)
            }
        }
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(64.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(baseBg)
            .then(
                if (node.selected) {
                    Modifier.background(PanelTokens.ON_SURFACE.copy(alpha = 0.12f))
                } else {
                    Modifier
                },
            )
            .alpha(if (node.enabled) 1f else 0.4f)
            .hoverable(interaction, enabled = node.enabled)
            .clickable(
                interactionSource = interaction,
                indication = null,
                enabled = node.enabled,
                onClick = onClick,
            )
            .padding(horizontal = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        // 左侧头像/图标槽（32dp）
        if (reservedLeadWidth) {
            Box(
                modifier = Modifier.width(32.dp),
                contentAlignment = Alignment.Center,
            ) {
                val avatar = node.avatarUrl
                if (avatar != null) {
                    if (avatar.isNotBlank()) {
                        AsyncImage(
                            model = avatar,
                            contentDescription = null,
                            contentScale = ContentScale.Crop,
                            modifier = Modifier
                                .size(28.dp)
                                .clip(CircleShape),
                        )
                    } else {
                        Box(
                            modifier = Modifier
                                .size(28.dp)
                                .clip(CircleShape)
                                .background(PanelTokens.POPUP),
                            contentAlignment = Alignment.Center,
                        ) {
                            Text(
                                text = node.title.firstOrNull()?.toString().orEmpty(),
                                color = PanelTokens.ON_SURFACE,
                                fontSize = 14.sp,
                                fontWeight = FontWeight.SemiBold,
                            )
                        }
                    }
                } else {
                    val icon = queueIcon(node.icon)
                    if (icon != null) {
                        Icon(
                            icon,
                            contentDescription = null,
                            tint = PanelTokens.ON_SURFACE,
                            modifier = Modifier.size(22.dp),
                        )
                    }
                }
            }
        }

        // 中间主副标题
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.Center,
        ) {
            Text(
                text = node.title,
                color = PanelTokens.ON_SURFACE,
                fontSize = 16.sp,
                fontWeight = if (node.selected) FontWeight.SemiBold else FontWeight.Normal,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            if (node.subtitle.isNotBlank()) {
                Text(
                    text = node.subtitle,
                    color = PanelTokens.ON_SURFACE_DIM,
                    fontSize = 13.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }

        // 右侧尾部：计数与分支指示符/选中对勾
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(4.dp),
        ) {
            if (node.trailing.isNotBlank()) {
                Text(
                    text = node.trailing,
                    color = PanelTokens.ON_SURFACE_DIM,
                    fontSize = 14.sp,
                    maxLines = 1,
                )
            }
            if (node.branch) {
                Icon(
                    SpatialIcons.Regular.ChevronRight,
                    contentDescription = null,
                    tint = PanelTokens.ON_SURFACE_DIM,
                    modifier = Modifier.size(20.dp),
                )
            } else if (node.selected && node.showCheck) {
                Icon(
                    SpatialIcons.Regular.CheckAlt,
                    contentDescription = null,
                    tint = PanelTokens.ON_SURFACE,
                    modifier = Modifier.size(20.dp),
                )
            }
        }
    }
}

// ─────────────────────────────────────────────────────────── 5.3 卡片区

@Composable
private fun CardStreamView(state: VideoControlsState, cb: VideoControlsCallbacks) {
    val browseSection = state.browseSection
    val entries = browseSection?.entries.orEmpty()
    // 每个池各记各的滚动位置：共用一份的话，在长池里滚到第 40 张再切去一个短池，
    // 新池一开局就停在尾巴上、还顺手触发一次翻页。
    val listState = key(browseSection?.queueId) { rememberLazyListState() }

    // 自动滚到正在播：只有在正在浏览 activeQueueId 时才滚
    // ⛔ key 里不能放 entries.size：翻页追加之后会把用户刚滚到末尾的列表拽回正在播的那张。
    LaunchedEffect(browseSection?.queueId, state.nowPlayingId, entries.isEmpty()) {
        if (entries.isEmpty() || !state.isBrowsingActive) return@LaunchedEffect
        val idx = entries.indexOfFirst { it.id == state.nowPlayingId }
        if (idx >= 0) {
            val target = (idx - 2).coerceAtLeast(0)
            listState.animateScrollToItem(target)
        }
    }

    // 自动翻页：最后可见 index ≥ size - LOAD_MORE_PREFETCH 时触发
    val hasMore = browseSection?.hasMore == true
    val queueId = browseSection?.queueId
    LaunchedEffect(queueId, hasMore, entries.size) {
        val qId = queueId ?: return@LaunchedEffect
        if (!hasMore) return@LaunchedEffect
        snapshotFlow { listState.layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: -1 }
            .distinctUntilChanged()
            .collect { last ->
                if (last >= entries.size - LOAD_MORE_PREFETCH) cb.onLoadMorePlaylist(qId)
            }
    }

    when {
        // 1. 什么都还没推过来：第一次开页 / 刷新在等 → 转圈；等完仍是空的 → EmptyCenter
        state.playlistSections.isEmpty() && state.playlistCatalog == null ->
            if (state.playlistLoading) LoadingCenter() else EmptyCenter(cb)

        // 2. browseSection == null（pending 中）或（entries 为空且 loading）→ LoadingCenter
        browseSection == null || (entries.isEmpty() && browseSection.loading) -> LoadingCenter()

        // 3. entries 为空 且 !loading 且 hasMore → 加载失败，整块可点重试
        entries.isEmpty() && !browseSection.loading && browseSection.hasMore -> {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .clickable { cb.onLoadMorePlaylist(browseSection.queueId) },
                contentAlignment = Alignment.Center,
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Icon(
                        SpatialIcons.Regular.Refresh,
                        contentDescription = null,
                        tint = PanelTokens.ON_SURFACE,
                        modifier = Modifier.size(28.dp),
                    )
                    Text(
                        text = state.playlistTexts["loadFailed"].orEmpty(),
                        color = PanelTokens.ON_SURFACE_DIM,
                        fontSize = 15.sp,
                    )
                }
            }
        }

        // 4. entries 为空 且 !hasMore → 居中文字（按 mediaType 二选一），不可点
        entries.isEmpty() && !browseSection.hasMore -> {
            val emptyText = if (browseSection.mediaType == "gallery") {
                state.playlistTexts["emptyGallery"].orEmpty()
            } else {
                state.playlistTexts["emptyVideo"].orEmpty()
            }
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text(
                    text = emptyText,
                    color = PanelTokens.ON_SURFACE_DIM,
                    fontSize = 15.sp,
                )
            }
        }

        // 5. 正常卡片流 LazyRow
        else -> {
            LazyRow(
                state = listState,
                modifier = Modifier.fillMaxSize(),
                horizontalArrangement = Arrangement.spacedBy(14.dp),
            ) {
                items(entries, key = { it.id }) { entry ->
                    PlaylistCard(
                        entry = entry,
                        isCurrent = state.isBrowsingActive && entry.id == state.nowPlayingId,
                        isSwitching = entry.id == state.switchingToId,
                        onPlay = {
                            if (state.switchingToId == null) {
                                cb.onPlayEntry(browseSection.queueId, entry.id)
                            }
                        },
                    )
                }
                if (hasMore) {
                    item(key = "__more_spinner") {
                        Box(
                            modifier = Modifier
                                .width(120.dp)
                                .fillMaxHeight(),
                            contentAlignment = Alignment.Center,
                        ) {
                            CircularProgressIndicator(
                                color = PanelTokens.ON_SURFACE,
                                strokeWidth = 3.dp,
                                modifier = Modifier.size(28.dp),
                            )
                        }
                    }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────── 5.4 卡片

@Composable
private fun PlaylistCard(
    entry: PlaylistEntry,
    isCurrent: Boolean,
    isSwitching: Boolean,
    onPlay: () -> Unit,
) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val hovered by interaction.collectIsHoveredAsState()
    val enabled = entry.playable

    val baseBg = when {
        pressed -> PanelTokens.PRESSED
        hovered -> PanelTokens.HOVER
        else -> PanelTokens.POPUP
    }

    Column(
        modifier = Modifier
            .width(220.dp)
            .fillMaxHeight()
            .clip(RoundedCornerShape(18.dp))
            .background(baseBg)
            .then(
                if (isCurrent) {
                    Modifier.background(PanelTokens.ON_SURFACE.copy(alpha = 0.14f))
                } else {
                    Modifier
                },
            )
            .alpha(if (enabled) 1f else 0.55f)
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
                    modifier = Modifier.fillMaxSize(),
                )
            }

            // 左上角清晰度标签
            if (entry.qualityText.isNotBlank()) {
                Box(
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .clip(RoundedCornerShape(bottomEnd = 6.dp))
                        .background(Color(0x8A000000))
                        .padding(horizontal = 6.dp, vertical = 2.dp),
                ) {
                    Text(
                        text = entry.qualityText,
                        color = Color.White,
                        fontSize = 12.sp,
                        maxLines = 1,
                    )
                }
            }

            // 底沿一排标签（有进度条时整排抬高 3dp）
            val hasProgress = entry.progressRatio > 0f
            val leadIcon = when (entry.leadKind) {
                "external" -> SpatialIcons.Regular.Internet
                "images" -> SpatialIcons.Regular.ViewGallery
                "duration" -> SpatialIcons.Regular.Time
                else -> null
            }
            val hasLead = entry.leadText.isNotBlank() || leadIcon != null
            val hasViews = entry.viewsText.isNotBlank()

            if (hasLead || hasViews) {
                Row(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .fillMaxWidth()
                        .then(if (hasProgress) Modifier.padding(bottom = 3.dp) else Modifier),
                    verticalAlignment = Alignment.Bottom,
                ) {
                    if (hasLead) {
                        Row(
                            modifier = Modifier
                                .clip(RoundedCornerShape(topEnd = 6.dp))
                                .background(Color(0x8A000000))
                                .padding(horizontal = 6.dp, vertical = 2.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(3.dp),
                        ) {
                            if (leadIcon != null) {
                                Icon(
                                    leadIcon,
                                    contentDescription = null,
                                    tint = Color.White,
                                    modifier = Modifier.size(13.dp),
                                )
                            }
                            if (entry.leadText.isNotBlank()) {
                                Text(
                                    text = entry.leadText,
                                    color = Color.White,
                                    fontSize = 12.sp,
                                    maxLines = 1,
                                )
                            }
                        }
                    }

                    Spacer(Modifier.weight(1f))

                    if (hasViews) {
                        Row(
                            modifier = Modifier
                                .clip(RoundedCornerShape(topStart = 6.dp))
                                .background(Color(0x8A000000))
                                .padding(horizontal = 6.dp, vertical = 2.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(3.dp),
                        ) {
                            Icon(
                                SpatialIcons.Regular.PasswordVisible,
                                contentDescription = null,
                                tint = Color.White,
                                modifier = Modifier.size(13.dp),
                            )
                            Text(
                                text = entry.viewsText,
                                color = Color.White,
                                fontSize = 12.sp,
                                maxLines = 1,
                            )
                        }
                    }
                }
            }

            // 底沿进度条：progress > 0 时画，高 3dp
            if (hasProgress) {
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomStart)
                        .fillMaxWidth()
                        .height(3.dp)
                        .background(Color(0x61000000)),
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxHeight()
                            .fillMaxWidth(entry.progressRatio.coerceIn(0f, 1f))
                            .background(PanelTokens.ON_SURFACE),
                    )
                }
            }

            // 换片在途遮罩 + 转圈
            if (isSwitching) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color(0x99000000)),
                    contentAlignment = Alignment.Center,
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(6.dp),
                    ) {
                        CircularProgressIndicator(
                            color = PanelTokens.ON_SURFACE,
                            strokeWidth = 3.dp,
                            modifier = Modifier.size(30.dp),
                        )
                        Text(
                            text = stringResource(R.string.xr_card_loading),
                            color = PanelTokens.ON_SURFACE,
                            fontSize = 12.sp,
                        )
                    }
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
                fontWeight = if (isCurrent) FontWeight.SemiBold else FontWeight.Medium,
                modifier = Modifier.weight(1f, fill = false),
            )

            // meta 一行：作者 → private 时 LockOn 13dp → likesText 非空时 HeartOn 13dp + likesText → timeText 非空时 timeText
            val hasMeta = entry.author.isNotBlank() || entry.isPrivate ||
                entry.likesText.isNotBlank() || entry.timeText.isNotBlank()
            if (hasMeta) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                ) {
                    if (entry.author.isNotBlank()) {
                        Text(
                            text = entry.author,
                            color = PanelTokens.ON_SURFACE_DIM,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Medium,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.weight(1f, fill = false),
                        )
                    }
                    if (entry.isPrivate) {
                        Icon(
                            SpatialIcons.Regular.LockOn,
                            contentDescription = null,
                            tint = PanelTokens.ON_SURFACE_DIM,
                            modifier = Modifier.size(13.dp),
                        )
                    }
                    if (entry.likesText.isNotBlank()) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(2.dp),
                        ) {
                            Icon(
                                SpatialIcons.Regular.HeartOn,
                                contentDescription = null,
                                tint = PanelTokens.ON_SURFACE_DIM,
                                modifier = Modifier.size(13.dp),
                            )
                            Text(
                                text = entry.likesText,
                                color = PanelTokens.ON_SURFACE_DIM,
                                fontSize = 13.sp,
                                maxLines = 1,
                            )
                        }
                    }
                    if (entry.timeText.isNotBlank()) {
                        Text(
                            text = entry.timeText,
                            color = PanelTokens.ON_SURFACE_DIM,
                            fontSize = 13.sp,
                            maxLines = 1,
                        )
                    }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────── 辅助全屏居中态

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
