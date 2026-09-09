package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.sp
import com.meta.spatial.uiset.button.SecondaryButton
import com.meta.spatial.uiset.slider.SpatialSliderMedium
import kotlin.math.roundToInt

/** The scene page is shared by the player and gallery; adjustments remain visible in the media. */
@Composable
internal fun MediaEffectsSection(state: VideoControlsState, cb: VideoControlsCallbacks) {
    val effects = state.mediaEffects
    Column(verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP)) {
        if (state.format.projection != Projection.PANORAMA_360) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
            ) {
                Column(Modifier.weight(1f)) {
                    SwitchRow(
                        title = stringResource(R.string.xr_media_effects),
                        hint = stringResource(R.string.xr_media_effects_hint),
                        checked = effects.enabled,
                        onToggle = { cb.onMediaEffects(effects.copy(enabled = !effects.enabled)) },
                    )
                }
                SecondaryButton(
                    label = stringResource(R.string.xr_media_effects_reset),
                    onClick = { cb.onMediaEffects(MediaEffectsSettings()) },
                )
            }
            if (effects.enabled) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
                ) {
                    SpatialSliderMedium(
                        value = effects.edgeFeather,
                        onChanged = { cb.onMediaEffects(effects.copy(edgeFeather = it)) },
                        helperText = stringResource(R.string.xr_edge_feather) to percent(effects.edgeFeather),
                        modifier = Modifier.weight(1f),
                    )
                    SpatialSliderMedium(
                        value = effects.glowStrength,
                        onChanged = { cb.onMediaEffects(effects.copy(glowStrength = it)) },
                        helperText = stringResource(R.string.xr_ambient_glow) to percent(effects.glowStrength),
                        modifier = Modifier.weight(1f),
                    )
                }
            }
        } else {
            Text(
                stringResource(R.string.xr_media_effects_360_hint),
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 15.sp,
            )
        }
        if (state.scene == SceneKind.PASSTHROUGH) {
            SpatialSliderMedium(
                value = effects.backgroundTransparency,
                onChanged = { cb.onMediaEffects(effects.copy(backgroundTransparency = it)) },
                helperText = stringResource(R.string.xr_background_transparency) to percent(effects.backgroundTransparency),
                modifier = Modifier.fillMaxWidth(),
            )
            Text(
                stringResource(R.string.xr_background_transparency_hint),
                color = PanelTokens.ON_SURFACE_DIM,
                fontSize = 15.sp,
            )
        }
    }
}

private fun percent(value: Float): String = "${(value * 100f).roundToInt()}%"
