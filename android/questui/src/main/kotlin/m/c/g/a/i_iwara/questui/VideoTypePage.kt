package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.button.SecondaryButton
import com.meta.spatial.uiset.button.TextTileButton
import com.meta.spatial.uiset.control.SpatialSwitch
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.Media180
import com.meta.spatial.uiset.theme.icons.regular.Media1803d
import com.meta.spatial.uiset.theme.icons.regular.Media2d
import com.meta.spatial.uiset.theme.icons.regular.Media360
import com.meta.spatial.uiset.theme.icons.regular.Media3603d
import com.meta.spatial.uiset.theme.icons.regular.Media3dHoriz
import com.meta.spatial.uiset.theme.icons.regular.Media3dVert
import com.meta.spatial.uiset.theme.icons.regular.MediaImmersiveVideo
import com.meta.spatial.uiset.theme.icons.regular.OpenTab
import com.meta.spatial.uiset.theme.icons.regular.Refresh
import com.meta.spatial.uiset.theme.icons.regular.Warning

/**
 * 视频类型页：**tab（投影/立体大类） + 每 tab 一版具体格式**（对齐 4XVR 面板）。
 *
 * # ⛔ 这是「用户说了算」的地方，不是自动判决
 *
 * 设计文档约束 C6（用户 2026-08-29 明确）：Iwara 既不给格式元数据、文件里也不带
 * 球面标记（实测 `st3d`/`sv3d` 零命中），所以「这是不是 VR 片」**原理上不可知**。
 * 自动推断只能作为默认档。所以这一页必须**随手可及、立即生效**。
 * 「自动识别」钮放在右上做二次机会；判断错了用户能自己扳回来。
 *
 * # ⛔ EAC 与鱼眼 tab 列出来但本机放不了
 *
 * Spatial SDK 的面板形状只有 **Quad / Equirect180 / Equirect360 / Cylinder**
 * （官方 API reference 逐字确认），既没有 EAC 也没有鱼眼。要做只能绕开面板路径、
 * 自建 `SceneMesh` + 着色器 —— 而官方对手写 `PanelConfigOptions` 那条路标了
 * **(Advanced)** 并附了 **Migration recommendation** 劝人迁离。
 *
 * 用户 2026-08-29 拍板：**列出来、标不支持、给外部播放器兜底**（`onHandOffToExternalPlayer`）。
 * 装作没有这回事更糟 —— 用户手上真有这种片子，看到歪画面得知道为什么。
 *
 * # 「180 全景当作 180 鱼眼」这个开关
 *
 * 有些片源实际是 180° 鱼眼但打标成 180° 全景，反过来也有。因为本机放不了鱼眼，
 * 这个开关**只作用于自动识别**（在自动识别遇到 180 时把它归到鱼眼这条走不通的路，
 * 从而弹「用其他应用打开」）—— 是防误判的口子，不是渲染开关。
 */
@Composable
fun VideoTypePage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .reportPanelTouches(cb)
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
    ) {
        PageHeader(
            title = "视频类型",
            subtitle = "认错了就在这儿改，立即生效",
            onBack = { cb.onRoute(ControlsRoute.PLAYER) },
            trailing = {
                SecondaryButton(
                    label = "自动识别",
                    leading = { Icon(SpatialIcons.Regular.Refresh, null) },
                    onClick = cb::onAutoDetectFormat,
                    modifier = Modifier.width(180.dp),
                )
            },
        )

        // ── 四个 tab（大类切换） ────────────────────────
        Row(
            modifier = Modifier.fillMaxWidth().height(72.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            FormatTab.entries.forEach { tab ->
                TextTileButton(
                    label = tab.label,
                    selected = state.formatTab == tab,
                    onSelectionChange = { cb.onPickFormatTab(tab) },
                    modifier = Modifier.weight(1f),
                )
            }
        }

        // ── 当前 tab 下的具体格式 ──────────────────────
        val formats = VideoFormat.inTab(state.formatTab)
        FormatTiles(formats = formats, current = state.format, onPick = cb::onPickFormat)

        // ── 底部提示 / 兜底出口 ────────────────────────
        if (!state.format.supported) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                Icon(SpatialIcons.Regular.Warning, null, tint = PanelTokens.WARN)
                Text(
                    text = "${state.format.label} 本机渲染不了，可以用其他应用打开",
                    color = PanelTokens.WARN,
                    fontSize = 15.sp,
                    modifier = Modifier.weight(1f),
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
                SecondaryButton(
                    label = "用其他应用打开",
                    leading = { Icon(SpatialIcons.Regular.OpenTab, null) },
                    onClick = cb::onHandOffToExternalPlayer,
                    modifier = Modifier.width(240.dp),
                )
            }
        }

        Spacer(Modifier.height(4.dp))

        // ── 自动识别时的口子（防误判） ─────────────────
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = "自动识别时，180° 全景当作 180° 鱼眼",
                    color = PanelTokens.ON_SURFACE,
                    fontSize = 16.sp,
                )
                Text(
                    text = "本机放不了鱼眼；打开后遇到 180 会弹「用其他应用打开」",
                    color = PanelTokens.ON_SURFACE_DIM,
                    fontSize = 13.sp,
                )
            }
            SpatialSwitch(
                checked = state.treat180AsFisheye,
                onCheckedChange = { cb.onToggleTreat180AsFisheye() },
            )
        }
    }
}

// ─────────────────────────────────────────────────────────── 格式网格

/**
 * 当前 tab 下把具体格式铺出来，按 3 列换行（平面 5 项 → 2 行；全景 6 项 → 2 行；
 * 鱼眼 5 项 → 2 行；EAC 2 项 → 1 行）。空缺用不可见占位撑住宽度，避免最后一行
 * 的按钮被拉宽。
 */
@Composable
private fun FormatTiles(
    formats: List<VideoFormat>,
    current: VideoFormat,
    onPick: (VideoFormat) -> Unit,
) {
    val columns = 3
    val rows = formats.chunked(columns)
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        rows.forEach { rowFormats ->
            Row(
                modifier = Modifier.fillMaxWidth().height(96.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                rowFormats.forEach { fmt ->
                    TextTileButton(
                        label = fmt.label,
                        secondaryLabel = if (fmt.supported) null else "本机放不了",
                        icon = { Icon(iconFor(fmt), null) },
                        selected = current == fmt,
                        onSelectionChange = { onPick(fmt) },
                        modifier = Modifier.weight(1f),
                    )
                }
                // 用不可见占位撑住剩余列
                repeat(columns - rowFormats.size) {
                    Spacer(modifier = Modifier.weight(1f))
                }
            }
        }
    }
}

/**
 * 给每种格式挑一枚合适的 UI Set 图标。⚠️ 图标只是提示，不承担唯一识别
 * （文字标签是唯一识别）。
 *
 * ⛔ 必须 `@Composable`：UI Set 图标是 `@Composable` 属性 getter（要读主题里的
 * `LocalDensity`/`ImageVectorCache`），当普通常量用会编不过。
 */
@androidx.compose.runtime.Composable
private fun iconFor(fmt: VideoFormat): ImageVector = when (fmt) {
    VideoFormat.FLAT_2D -> SpatialIcons.Regular.Media2d
    VideoFormat.FLAT_3D_HSBS,
    VideoFormat.FLAT_3D_FSBS -> SpatialIcons.Regular.Media3dHoriz
    VideoFormat.FLAT_3D_HOU,
    VideoFormat.FLAT_3D_FOU -> SpatialIcons.Regular.Media3dVert
    VideoFormat.PANO_180_2D -> SpatialIcons.Regular.Media180
    VideoFormat.PANO_180_3D_LR,
    VideoFormat.PANO_180_3D_TB -> SpatialIcons.Regular.Media1803d
    VideoFormat.PANO_360_2D -> SpatialIcons.Regular.Media360
    VideoFormat.PANO_360_3D_LR,
    VideoFormat.PANO_360_3D_TB -> SpatialIcons.Regular.Media3603d
    VideoFormat.EAC_360_2D,
    VideoFormat.EAC_360_3D -> SpatialIcons.Regular.Warning
    VideoFormat.FISHEYE_2D,
    VideoFormat.FISHEYE_180_3D,
    VideoFormat.FISHEYE_190_3D,
    VideoFormat.FISHEYE_200_3D,
    VideoFormat.FISHEYE_220_3D -> SpatialIcons.Regular.MediaImmersiveVideo
}
