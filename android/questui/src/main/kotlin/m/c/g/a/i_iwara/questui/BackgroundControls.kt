package m.c.g.a.i_iwara.questui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
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
    Column(verticalArrangement = Arrangement.spacedBy(if (compact) 8.dp else PanelTokens.GAP)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(PanelTokens.GAP),
        ) {
            EnvironmentKind.entries.forEach { kind ->
                PillButton(
                    label = stringResource(kind.labelRes),
                    selected = environment.kind == kind,
                    onClick = { cb.onEnvironment(environment.copy(kind = kind)) },
                    height = 60.dp,
                    modifier = Modifier.weight(1f).semantics {
                        selected = environment.kind == kind
                        role = Role.RadioButton
                    },
                )
            }
        }
        if (environment.kind == EnvironmentKind.PASSTHROUGH) {
            BackgroundTransparencySlider(state.mediaEffects, cb::onMediaEffects, showHint = !compact)
        } else {
            SpatialSliderMedium(
                value = environment.spaceBrightness,
                onChanged = { cb.onEnvironment(environment.copy(spaceBrightness = it)) },
                helperText = stringResource(R.string.xr_environment_brightness) to
                    "${(environment.spaceBrightness * 100f).roundToInt()}%",
                modifier = Modifier.fillMaxWidth(),
            )
        }
        val message = when {
            state.environmentLoading -> R.string.xr_environment_loading
            state.environmentLoadFailed -> R.string.xr_environment_failed
            !compact && environment.kind == EnvironmentKind.DEEP_SPACE -> R.string.xr_environment_deep_space_hint
            else -> null
        }
        message?.let {
            Text(
                stringResource(it), color = PanelTokens.ON_SURFACE_DIM, fontSize = 15.sp,
                maxLines = if (compact) 1 else Int.MAX_VALUE, overflow = TextOverflow.Ellipsis,
            )
        }
    }
}
