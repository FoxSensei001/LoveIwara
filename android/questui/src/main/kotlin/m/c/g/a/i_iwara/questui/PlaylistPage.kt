package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.button.SecondaryButton
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.Play
import com.meta.spatial.uiset.theme.icons.regular.Refresh

/**
 * 播放列表页：接应用已有的**「稍后再看」**。
 *
 * # 为什么是稍后再看，而不是别的队列
 *
 * 用户 2026-08-29 定的。它正好是应用里唯一一条**跨页面存在、带看完/进度、有容量上限**
 * 的临时队列（见 `WatchLaterService` 的类注释），语义上就是「接着看」。
 * 内层播放列表、作者作品那些池都绑在具体页面上，沉浸态里没有那个上下文。
 *
 * # ⛔ 为什么只有文字没有缩略图
 *
 * 官方面板预算：**video panel 3 个就掉出 90FPS、5 个持续低于**，缩略图若做成面板
 * 会直接吃掉预算（设计文档 §6.6 已写明队列轨必须是静态图）。而要在 Compose 面板里贴
 * 网络图，得往 `:questui` 里引一个图片加载库并处理 Iwara 的鉴权/缓存 —— 那是另一条线。
 * 文字行同样能选片，先把能力打通。
 *
 * # ⛔ 滚动在 Quest 上有一条官方已知伤
 *
 * `spatial-sdk-known-issues`：「**Scrollable views may not respond to direct hand
 * interaction (physical touch)**, though distance pointer interaction may still work」
 * ——**至今无 fix**。所以列表**必须能用远距射线捏合拖动**，且行本身要足够高
 * （一行 92dp ≈ 18.4cm @2.2m ≈ 4.8°，远高于官方 2.5°–3° 下限），
 * 让「点错行」这种事在直触失灵时也不会发生。
 */
@Composable
fun PlaylistPage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        PageHeader(
            title = "接着看",
            subtitle = if (state.playlistLoading) {
                "正在读取…"
            } else {
                "共 ${state.playlist.size} 条"
            },
            onBack = { cb.onRoute(ControlsRoute.PLAYER) },
            trailing = {
                SecondaryButton(
                    label = "刷新",
                    leading = { Icon(SpatialIcons.Regular.Refresh, null) },
                    onClick = cb::onRefreshPlaylist,
                    modifier = Modifier.width(170.dp),
                )
            },
        )

        if (state.playlist.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text(
                    text = if (state.playlistLoading) {
                        "正在读取稍后再看…"
                    } else {
                        "稍后再看是空的。在应用里把想看的加进去，这里就能直接接着放。"
                    },
                    color = PanelTokens.ON_SURFACE_DIM,
                    fontSize = 17.sp,
                )
            }
        } else {
            // ⛔ 官方 `hands-ui-best-practices`：「**Size the window so content is clearly
            // cut off at the edge.** A visible content clip is the affordance that tells the
            // user the panel is scrollable when no scroll bar is present.」
            // 这里的列表高度刻意不是行高整数倍，让最后一行露半截当作可滚动的提示。
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                items(state.playlist, key = { it.id }) { entry ->
                    PlaylistRow(
                        entry = entry,
                        isNowPlaying = entry.id == state.nowPlayingId,
                        onPlay = { cb.onPlayEntry(entry.id) },
                    )
                }
            }
        }
    }
}

@Composable
private fun PlaylistRow(entry: PlaylistEntry, isNowPlaying: Boolean, onPlay: () -> Unit) {
    val rowColor = when {
        isNowPlaying -> Color(0xFF2E3550)
        else -> Color(0xFF25252B)
    }
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(ROW_HEIGHT)
            .clip(RoundedCornerShape(18.dp))
            .background(rowColor)
            .padding(horizontal = 18.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = entry.title.ifBlank { "（无标题）" },
                color = if (entry.watched) PanelTokens.ON_SURFACE_DIM else PanelTokens.ON_SURFACE,
                fontSize = 18.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Text(
                text = buildString {
                    if (entry.author.isNotBlank()) append(entry.author).append(" · ")
                    append(entry.durationText)
                    if (entry.watched) {
                        append(" · 已看完")
                    } else if (entry.progressRatio > 0.01f) {
                        append(" · 看到 ${(entry.progressRatio * 100).toInt()}%")
                    }
                    if (!entry.playable) append(" · 站外视频，这里放不了")
                },
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 15.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            // 进度条：一条 4dp 的细线，不抢视觉。
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(4.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(Color(0xFF3A3A44)),
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxHeight()
                        .fillMaxWidth(entry.progressRatio.coerceIn(0f, 1f))
                        .background(Color(0xFF6E8BFF)),
                )
            }
        }
        SecondaryButton(
            label = if (isNowPlaying) "正在放" else "播放",
            leading = { Icon(SpatialIcons.Regular.Play, null) },
            onClick = onPlay,
            modifier = Modifier.width(180.dp),
            isEnabled = entry.playable && !isNowPlaying,
        )
    }
}

/** 一行 92dp ≈ 18.4cm @2.2m ≈ 4.8°，远高于官方 2.5°–3° 的角尺寸下限。 */
private val ROW_HEIGHT = 92.dp
