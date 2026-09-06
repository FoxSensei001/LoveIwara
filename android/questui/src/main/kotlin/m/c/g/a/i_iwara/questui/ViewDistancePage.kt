package m.c.g.a.i_iwara.questui

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.hoverable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsHoveredAsState
import androidx.compose.foundation.interaction.collectIsPressedAsState
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
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.onClick
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
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
            Row(
                modifier = Modifier.widthIn(max = 900.dp).fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(20.dp),
            ) {
                DistanceActionButton(
                    icon = SpatialIcons.Regular.Scale,
                    label = stringResource(R.string.xr_view_nearer),
                    direction = -1,
                    cb = cb,
                    modifier = Modifier.weight(1f),
                )
                DistanceActionButton(
                    icon = SpatialIcons.Regular.Refresh,
                    label = stringResource(R.string.xr_view_distance_reset),
                    direction = null,
                    cb = cb,
                    modifier = Modifier.weight(1f),
                )
                DistanceActionButton(
                    icon = SpatialIcons.Regular.ScaleDown,
                    label = stringResource(R.string.xr_view_farther),
                    direction = 1,
                    cb = cb,
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}

@Composable
private fun DistanceActionButton(
    icon: ImageVector,
    label: String,
    direction: Int?,
    cb: VideoControlsCallbacks,
    modifier: Modifier,
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
    val action = if (direction == null) {
        Modifier.clickable(
            interactionSource = interaction,
            indication = null,
            role = Role.Button,
            onClick = cb::onResetViewDistance,
        )
    } else {
        Modifier
            .semantics(mergeDescendants = true) {
                role = Role.Button
                onClick(label) { cb.onViewDistanceStep(direction); true }
            }
            // Stable keys: changing pressed/hover visuals must not restart a held gesture.
            .pointerInput(cb, direction) {
                detectTapGestures(onPress = {
                    held = true
                    try {
                        cb.onViewDistanceHold(direction, true)
                        tryAwaitRelease()
                    } finally {
                        held = false
                        cb.onViewDistanceHold(direction, false)
                    }
                })
            }
    }
    val shape = RoundedCornerShape(20.dp)
    val foreground = if (direction == null && !pressed && !hovered) PanelTokens.ON_SURFACE_DIM else PanelTokens.ON_SURFACE
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
