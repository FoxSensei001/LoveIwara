/// Persisted material parameters, independent of either rendering package.
enum GlassQualityPreference { auto, standard, premium }

class GlassAppearanceSettings {
  const GlassAppearanceSettings({
    this.quality = GlassQualityPreference.auto,
    this.opacity = 0.24,
    this.blur = 0,
    this.thickness = 20,
    this.refractiveIndex = 1.2,
    this.lightIntensity = 0.5,
    this.saturation = 1.5,
    this.chromaticAberration = 0.01,
    this.shadows = true,
    this.panelOpacity = 0.45,
    this.panelBlur = 14,
  });

  static const defaults = GlassAppearanceSettings();
  final GlassQualityPreference quality;
  final double opacity, blur, thickness, refractiveIndex;
  final double lightIntensity, saturation, chromaticAberration;
  final bool shadows;
  final double panelOpacity, panelBlur;

  factory GlassAppearanceSettings.fromMap(dynamic value) {
    final map = value is Map ? value : const <String, dynamic>{};
    double number(String key, double fallback, double min, double max) {
      final raw = map[key];
      return raw is num && raw.isFinite
          ? raw.toDouble().clamp(min, max)
          : fallback;
    }

    return GlassAppearanceSettings(
      quality: GlassQualityPreference.values.firstWhere(
        (quality) => quality.name == map['quality'],
        orElse: () => defaults.quality,
      ),
      opacity: number('opacity', defaults.opacity, 0, 0.8),
      blur: number('blur', defaults.blur, 0, 12),
      thickness: number('thickness', defaults.thickness, 0, 40),
      refractiveIndex: number(
        'refractiveIndex',
        defaults.refractiveIndex,
        1,
        2,
      ),
      lightIntensity: number('lightIntensity', defaults.lightIntensity, 0, 2),
      saturation: number('saturation', defaults.saturation, 0, 2),
      chromaticAberration: number(
        'chromaticAberration',
        defaults.chromaticAberration,
        0,
        0.03,
      ),
      shadows: map['shadows'] is bool
          ? map['shadows'] as bool
          : defaults.shadows,
      panelOpacity: number('panelOpacity', defaults.panelOpacity, 0, 0.8),
      panelBlur: number('panelBlur', defaults.panelBlur, 0, 20),
    );
  }

  Map<String, dynamic> toMap() => {
    'quality': quality.name,
    'opacity': opacity,
    'blur': blur,
    'thickness': thickness,
    'refractiveIndex': refractiveIndex,
    'lightIntensity': lightIntensity,
    'saturation': saturation,
    'chromaticAberration': chromaticAberration,
    'shadows': shadows,
    'panelOpacity': panelOpacity,
    'panelBlur': panelBlur,
  };

  GlassAppearanceSettings withValue(String key, dynamic value) =>
      GlassAppearanceSettings.fromMap({...toMap(), key: value});
}
