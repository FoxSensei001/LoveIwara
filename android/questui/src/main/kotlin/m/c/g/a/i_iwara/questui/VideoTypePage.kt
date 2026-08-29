package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.button.SecondaryButton
import com.meta.spatial.uiset.button.TextTileButton
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.Media180
import com.meta.spatial.uiset.theme.icons.regular.Media2d
import com.meta.spatial.uiset.theme.icons.regular.Media360
import com.meta.spatial.uiset.theme.icons.regular.Media3dHoriz
import com.meta.spatial.uiset.theme.icons.regular.Media3dVert
import com.meta.spatial.uiset.theme.icons.regular.OpenTab
import com.meta.spatial.uiset.theme.icons.regular.Warning

/**
 * 视频类型页：投影 + 立体编排。对应参考软件 ref_02～ref_05。
 *
 * # ⛔ 这是「用户说了算」的地方，不是自动判决
 *
 * 设计文档约束 C6（用户 2026-08-29 明确）：Iwara 既不给格式元数据、文件里也不带
 * 球面标记（实测 `st3d`/`sv3d` 零命中），所以「这是不是 VR 片」**原理上不可知**。
 * 自动推断只能作为默认档。所以这一页必须**随手可及、立即生效**。
 *
 * # ⛔ EAC 与鱼眼列出来但放不了
 *
 * Spatial SDK 的面板形状只有 **Quad / Equirect180 / Equirect360 / Cylinder**
 * （官方 API reference 逐字确认），既没有 EAC 也没有鱼眼。要做只能绕开面板路径、
 * 自建 `SceneMesh` + 着色器 —— 而官方对手写 `PanelConfigOptions` 那条路标了
 * **(Advanced)** 并附了 **Migration recommendation** 劝人迁离。
 *
 * 用户 2026-08-29 拍板：**列出来、标不支持、给外部播放器兜底**。
 * 装作没有这回事更糟 —— 用户手上真有这种片子，看到歪画面得知道为什么。
 */
@Composable
fun VideoTypePage(state: VideoControlsState, cb: VideoControlsCallbacks) {
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
    ) {
        PageHeader(
            title = "视频类型",
            subtitle = "认错了就在这儿改，立即生效",
            onBack = { cb.onRoute(ControlsRoute.PLAYER) },
            // 选到放不了的那两档时，给一条出路而不是一句「不支持」就完了。
            // ⛔ 放在标题行而不是另起一行：正文只有 366dp，多一行就溢出（面板会静默裁掉）。
            trailing = if (state.projection.supported) {
                null
            } else {
                {
                    SecondaryButton(
                        label = "用其他应用打开",
                        leading = { Icon(SpatialIcons.Regular.OpenTab, null) },
                        onClick = cb::onHandOffToExternalPlayer,
                        modifier = Modifier.width(280.dp),
                    )
                }
            },
        )

        Row(
            modifier = Modifier.fillMaxWidth().height(104.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            ProjectionTile(VideoProjection.FLAT, "普通 16:9 之类", SpatialIcons.Regular.Media2d, state, cb)
            ProjectionTile(VideoProjection.PANORAMA_180, "半球环绕", SpatialIcons.Regular.Media180, state, cb)
            ProjectionTile(VideoProjection.PANORAMA_360, "整球环绕", SpatialIcons.Regular.Media360, state, cb)
            ProjectionTile(VideoProjection.EAC, "本机放不了", SpatialIcons.Regular.Warning, state, cb)
            ProjectionTile(VideoProjection.FISHEYE, "本机放不了", SpatialIcons.Regular.Warning, state, cb)
        }

        SectionLabel("立体编排")

        Row(
            modifier = Modifier.fillMaxWidth().height(96.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            StereoTile(StereoLayout.MONO, "一整幅画面", SpatialIcons.Regular.Media2d, state, cb)
            StereoTile(StereoLayout.SIDE_BY_SIDE, "左右各半幅", SpatialIcons.Regular.Media3dHoriz, state, cb)
            StereoTile(StereoLayout.TOP_BOTTOM, "上下各半幅", SpatialIcons.Regular.Media3dVert, state, cb)
        }

        if (!state.projection.supported) {
            Text(
                text = "${state.projection.label} 投影本机渲染不了 —— " +
                    "SDK 的面板形状只有平面 / 180° / 360° / 弧面这几种。",
                color = PanelTokens.WARN,
                fontSize = 16.sp,
                maxLines = 1,
            )
        }
    }
}

@Composable
private fun androidx.compose.foundation.layout.RowScope.ProjectionTile(
    projection: VideoProjection,
    hint: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    state: VideoControlsState,
    cb: VideoControlsCallbacks,
) {
    TextTileButton(
        label = projection.label,
        secondaryLabel = hint,
        icon = { Icon(icon, null) },
        selected = state.projection == projection,
        onSelectionChange = { cb.onPickProjection(projection) },
        modifier = Modifier.weight(1f),
    )
}

@Composable
private fun androidx.compose.foundation.layout.RowScope.StereoTile(
    layout: StereoLayout,
    hint: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    state: VideoControlsState,
    cb: VideoControlsCallbacks,
) {
    TextTileButton(
        label = layout.label,
        secondaryLabel = hint,
        icon = { Icon(icon, null) },
        selected = state.stereo == layout,
        onSelectionChange = { cb.onPickStereo(layout) },
        modifier = Modifier.weight(1f),
    )
}
