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

/**
 * The scene page is shared by the player and gallery; adjustments remain visible in the media.
 *
 * 背景不透明度对三处（空间视频 / 空间图库 / 图库大图）是同一条：0% 是纯黑的虚空，
 * 100% 是环境光照着的真实房间，**默认 100%**。
 */
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
        // ⛔ 这条滑块**恒在**，不再挂任何条件。它此前只在「透视」场景下露面，而
        // 「虚空」不过是它拖到 0 的那一端 —— 两者并存的结果是用户先要在两块磁贴里
        // 选对一块，滑块才出现（2026-09-09 用户拍板收成一条）。
        BackgroundTransparencySlider(effects, cb::onMediaEffects)
    }
}

/**
 * 背景不透明度：0% 纯黑虚空，100% 环境光照着的真实房间。
 *
 * ⛔ 单独一枚积木，因为它有两个主人：影院态的场景页（[MediaEffectsSection]）与浏览态那一页
 * （[BrowsePanelPage]）。**两处改的是同一条设置**（同一份 [MediaEffectsSettings]、同一个落盘键），
 * 所以连滑块与那行说明都必须是同一份代码 —— 抄第二份就会出现「在这一页拖到 0、回到另一页却
 * 还写着 100%」这种自相矛盾。
 */
@Composable
internal fun BackgroundTransparencySlider(
    effects: MediaEffectsSettings,
    onChange: (MediaEffectsSettings) -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(verticalArrangement = Arrangement.spacedBy(PanelTokens.GAP), modifier = modifier) {
        SpatialSliderMedium(
            value = effects.backgroundTransparency,
            onChanged = { onChange(effects.copy(backgroundTransparency = it)) },
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

private fun percent(value: Float): String = "${(value * 100f).roundToInt()}%"
