package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.hoverable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsHoveredAsState
import androidx.compose.foundation.interaction.collectIsFocusedAsState
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.slider.SpatialSliderMedium
import kotlin.math.roundToInt

/** Shared by the player, gallery and the shorter browse panel. */
@Composable
internal fun BackgroundControls(
    state: VideoControlsState,
    cb: VideoControlsCallbacks,
    compact: Boolean = false,
) {
    val environment = state.environment
    Column(verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP)) {
        Column(
            modifier = Modifier.selectableGroup(),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            EnvironmentKind.entries.chunked(3).forEach { choices ->
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    choices.forEach { kind ->
                        EnvironmentChoice(
                            kind = kind, selected = environment.kind == kind, compact = compact,
                            onClick = { cb.onEnvironment(environment.copy(kind = kind)) },
                            modifier = Modifier.weight(1f),
                        )
                    }
                }
            }
        }
        if (environment.kind == EnvironmentKind.PASSTHROUGH) {
            BackgroundTransparencySlider(state.mediaEffects, cb::onMediaEffects, showHint = !compact)
        } else if (environment.kind.hasPanorama) {
            SpatialSliderMedium(
                value = environment.spaceBrightness,
                onChanged = { cb.onEnvironment(environment.copy(spaceBrightness = it)) },
                helperText = stringResource(R.string.xr_environment_brightness) to
                    "${(environment.spaceBrightness * 100f).roundToInt()}%",
                modifier = Modifier.fillMaxWidth(),
            )
            if (environment.kind == EnvironmentKind.DEEP_SPACE) {
                SwitchRow(
                    title = stringResource(R.string.xr_environment_show_earth),
                    checked = environment.showEarth,
                    onToggle = { cb.onEnvironment(environment.copy(showEarth = !environment.showEarth)) },
                )
                SwitchRow(
                    title = stringResource(R.string.xr_environment_show_moon),
                    checked = environment.showMoon,
                    onToggle = { cb.onEnvironment(environment.copy(showMoon = !environment.showMoon)) },
                )
                SwitchRow(
                    title = stringResource(R.string.xr_environment_dynamic),
                    hint = stringResource(R.string.xr_environment_dynamic_hint),
                    checked = environment.dynamicSpace,
                    onToggle = { cb.onEnvironment(environment.copy(dynamicSpace = !environment.dynamicSpace)) },
                )
            }
        }
        val message = when {
            state.environmentLoading -> R.string.xr_environment_loading
            state.environmentLoadFailed -> if (environment.kind == EnvironmentKind.DEEP_SPACE && !environment.dynamicSpace)
                R.string.xr_environment_dynamic_unavailable else R.string.xr_environment_failed
            !compact && environment.kind != EnvironmentKind.PASSTHROUGH -> environment.kind.hintRes
            else -> null
        }
        message?.let {
            Text(stringResource(it), color = PanelTokens.ON_SURFACE_DIM, fontSize = 15.sp)
        }
    }
}

/** Small baked previews; selecting a world never allocates a live preview renderer. */
@Composable
private fun EnvironmentChoice(
    kind: EnvironmentKind,
    selected: Boolean,
    compact: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val interaction = remember { MutableInteractionSource() }
    val hovered by interaction.collectIsHoveredAsState()
    val focused by interaction.collectIsFocusedAsState()
    val pressed by interaction.collectIsPressedAsState()
    val shape = RoundedCornerShape(16.dp)
    Box(
        modifier = modifier
            .height(if (compact) 76.dp else 112.dp)
            .clip(shape)
            .background(PanelTokens.POPUP)
            .hoverable(interaction)
            .selectable(
                selected = selected, role = Role.RadioButton, interactionSource = interaction,
                indication = null, onClick = onClick,
            )
            .border(
                if (selected || focused) 2.dp else 1.dp,
                if (selected || focused) PanelTokens.ON_SURFACE else PanelTokens.ON_SURFACE.copy(alpha = 0.12f),
                shape,
            ),
    ) {
        Image(
            painterResource(kind.previewRes), contentDescription = null,
            contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize(),
        )
        Box(Modifier.fillMaxSize().background(Brush.verticalGradient(
            listOf(Color.Transparent, Color.Black.copy(alpha = 0.82f)),
        )))
        if (hovered || pressed) {
            Box(Modifier.fillMaxSize().background(PanelTokens.ON_SURFACE.copy(alpha = if (pressed) 0.18f else 0.09f)))
        }
        Text(
            text = stringResource(kind.labelRes), color = PanelTokens.ON_SURFACE,
            fontSize = 16.sp, fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Medium,
            maxLines = 2, overflow = TextOverflow.Ellipsis,
            modifier = Modifier.align(Alignment.BottomStart).padding(start = 12.dp, end = 28.dp, top = 10.dp, bottom = 10.dp),
        )
        if (selected) {
            Text(
                "✓", color = PanelTokens.ON_SURFACE, fontSize = 16.sp,
                modifier = Modifier.align(Alignment.TopEnd).clearAndSetSemantics {}.padding(6.dp)
                    .background(PanelTokens.SURFACE, RoundedCornerShape(8.dp)).padding(horizontal = 5.dp),
            )
        }
    }
}
