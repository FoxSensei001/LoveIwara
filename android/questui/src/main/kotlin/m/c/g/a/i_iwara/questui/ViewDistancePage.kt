package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.ChevronLeft
import com.meta.spatial.uiset.theme.icons.regular.Distance
import com.meta.spatial.uiset.theme.icons.regular.Refresh
import com.meta.spatial.uiset.theme.icons.regular.Scale
import com.meta.spatial.uiset.theme.icons.regular.ScaleDown

/** Same size, icon family and hit target as its neighbouring toolbar actions. */
@Composable
fun ViewDistanceButton(cb: VideoControlsCallbacks) {
    CircleActionButton(
        icon = SpatialIcons.Regular.Distance,
        contentDescription = stringResource(R.string.xr_view_distance),
        onClick = { cb.onRoute(ControlsRoute.DISTANCE) },
    )
}

/** One-handed distance controls, arranged around a shared center and label baseline. */
@Composable
fun ViewDistancePage(cb: VideoControlsCallbacks) {
    Column(Modifier.fillMaxSize()) {
        Box(Modifier.fillMaxWidth().height(PanelTokens.ROW_BUTTON_HEIGHT)) {
            CircleActionButton(
                icon = SpatialIcons.Regular.ChevronLeft,
                contentDescription = stringResource(R.string.xr_back),
                modifier = Modifier.align(Alignment.CenterStart),
                onClick = { cb.onRoute(ControlsRoute.PLAYER) },
            )
            // Equal reserves on both sides keep the title centered on the panel, not the free space.
            Column(
                modifier = Modifier.align(Alignment.Center).fillMaxWidth().padding(horizontal = 80.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(4.dp),
            ) {
                Text(
                    text = stringResource(R.string.xr_view_distance),
                    color = PanelTokens.ON_SURFACE,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Medium,
                    textAlign = TextAlign.Center,
                    maxLines = 1,
                )
                Text(
                    text = stringResource(R.string.xr_view_distance_hint),
                    color = PanelTokens.ON_SURFACE_DIM,
                    fontSize = 16.sp,
                    textAlign = TextAlign.Center,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }
        Box(Modifier.weight(1f).fillMaxWidth(), contentAlignment = Alignment.Center) {
            // ⛔ 三枚钮的样式与手势契约在 [DistanceActionButton] 里，与浏览态那一页共用同一份。
            Row(
                modifier = Modifier.widthIn(max = 900.dp).fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(20.dp),
            ) {
                DistanceActionButton(
                    icon = SpatialIcons.Regular.Scale,
                    label = stringResource(R.string.xr_view_nearer),
                    modifier = Modifier.weight(1f),
                    onStep = { cb.onViewDistanceStep(-1) },
                    onHold = { pressed -> cb.onViewDistanceHold(-1, pressed) },
                )
                DistanceActionButton(
                    icon = SpatialIcons.Regular.Refresh,
                    label = stringResource(R.string.xr_view_distance_reset),
                    modifier = Modifier.weight(1f),
                    onStep = cb::onResetViewDistance,
                )
                DistanceActionButton(
                    icon = SpatialIcons.Regular.ScaleDown,
                    label = stringResource(R.string.xr_view_farther),
                    modifier = Modifier.weight(1f),
                    onStep = { cb.onViewDistanceStep(1) },
                    onHold = { pressed -> cb.onViewDistanceHold(1, pressed) },
                )
            }
        }
    }
}
