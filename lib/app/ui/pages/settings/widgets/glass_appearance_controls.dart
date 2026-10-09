import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/glass_appearance_settings.dart';
import 'package:i_iwara/app/services/theme_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_slider.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;
import 'glass_setting_tiles.dart';

class GlassAppearanceControls extends StatelessWidget {
  const GlassAppearanceControls({super.key, required this.service});
  final ThemeService service;

  @override
  Widget build(BuildContext context) => Obx(() {
    final settings = service.glassSettings;
    final quality = chromeGlassQuality(context);
    final labels = {
      GlassQualityPreference.auto: t.settings.glassQualityAuto,
      GlassQualityPreference.standard: t.settings.glassQualityStandard,
      GlassQualityPreference.premium: t.settings.glassQualityPremium,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.settings.glassQuality,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${t.settings.glassQualityCurrent}: ${quality == lgw.GlassQuality.premium ? labels[GlassQualityPreference.premium] : labels[GlassQualityPreference.standard]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        for (final preference in GlassQualityPreference.values)
          GlassChoiceItem<GlassQualityPreference>(
            title: Text(labels[preference]!),
            subtitle: Text(switch (preference) {
              GlassQualityPreference.auto => t.settings.glassQualityAutoDesc,
              GlassQualityPreference.standard =>
                t.settings.glassQualityStandardDesc,
              GlassQualityPreference.premium =>
                t.settings.glassQualityPremiumDesc,
            }),
            value: preference,
            groupValue: settings.quality,
            onChanged: (value) {
              service.previewGlassSetting('quality', value.name);
              service.saveGlassSettings();
            },
          ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            t.settings.glassChromeParametersDesc,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        _slider(
          context,
          t.settings.glassOpacity,
          'opacity',
          settings.opacity,
          0,
          0.8,
          divisions: 80,
          percentage: true,
        ),
        _slider(
          context,
          t.settings.glassBlur,
          'blur',
          settings.blur,
          0,
          12,
          divisions: 24,
          subtitle: t.settings.glassBlurDesc,
        ),
        ExpansionTile(
          title: Text(t.settings.glassAdvancedParameters),
          children: [
            _slider(
              context,
              t.settings.glassThickness,
              'thickness',
              settings.thickness,
              0,
              40,
              divisions: 40,
            ),
            _slider(
              context,
              t.settings.glassRefractiveIndex,
              'refractiveIndex',
              settings.refractiveIndex,
              1,
              2,
              divisions: 100,
              decimals: 2,
            ),
            _slider(
              context,
              t.settings.glassLightIntensity,
              'lightIntensity',
              settings.lightIntensity,
              0,
              2,
              divisions: 40,
              decimals: 2,
            ),
            _slider(
              context,
              t.settings.glassSaturation,
              'saturation',
              settings.saturation,
              0,
              2,
              divisions: 40,
              decimals: 2,
            ),
            _slider(
              context,
              t.settings.glassChromaticAberration,
              'chromaticAberration',
              settings.chromaticAberration,
              0,
              0.03,
              divisions: 30,
              decimals: 3,
            ),
            GlassSwitchItem(
              title: Text(t.settings.glassShadows),
              value: settings.shadows,
              onChanged: (value) {
                service.previewGlassSetting('shadows', value);
                service.saveGlassSettings();
              },
            ),
          ],
        ),
        ExpansionTile(
          title: Text(t.settings.glassPanelParameters),
          subtitle: Text(t.settings.glassPanelParametersDesc),
          children: [
            _slider(
              context,
              t.settings.glassOpacity,
              'panelOpacity',
              settings.panelOpacity,
              0,
              0.8,
              divisions: 80,
              percentage: true,
            ),
            _slider(
              context,
              t.settings.glassBlur,
              'panelBlur',
              settings.panelBlur,
              0,
              20,
              divisions: 40,
            ),
          ],
        ),
        GlassSettingTile(
          icon: Icons.restore,
          title: Text(t.settings.glassResetParameters),
          onTap: service.resetGlassSettings,
        ),
      ],
    );
  });

  Widget _slider(
    BuildContext context,
    String title,
    String key,
    double value,
    double min,
    double max, {
    required int divisions,
    int decimals = 1,
    bool percentage = false,
    String? subtitle,
  }) {
    final formatted = percentage
        ? '${(value * 100).round()}%'
        : value.toStringAsFixed(decimals);
    return Column(
      children: [
        GlassSettingTile(
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle),
          trailing: Text(
            formatted,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Semantics(
          label: title,
          child: GlassSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: formatted,
            onChanged: (value) => service.previewGlassSetting(key, value),
            onChangeEnd: (_) => service.saveGlassSettings(),
          ),
        ),
      ],
    );
  }
}
