/// Persisted material parameters, independent of either rendering package.
enum GlassQualityPreference { standard, premium }

class GlassAppearanceSettings {
  // 液态档的出厂值：完整折射 + 34% 底色（2026-10-17 用户定）+ 0.5 模糊
  // （2026-11-21 用户改，原为 3.5）。
  // 只影响没存过这份配置的人；已存的配置里有的字段照旧用存下的值。
  const GlassAppearanceSettings({
    this.quality = GlassQualityPreference.premium,
    this.opacity = 0.34,
    this.blur = 0.5,
    this.thickness = 20,
    this.refractiveIndex = 1.2,
    this.lightIntensity = 0.5,
    this.saturation = 1.5,
    this.chromaticAberration = 0.01,
    this.shadows = true,
  });

  static const defaults = GlassAppearanceSettings();
  final GlassQualityPreference quality;
  final double opacity, blur, thickness, refractiveIndex;
  final double lightIntensity, saturation, chromaticAberration;
  final bool shadows;
  // 以前还有 panelOpacity / panelBlur（菜单面板参数），是给已删掉的
  // liquid_glass_easy 透镜渲染器用的，换成 liquid_glass_widgets 后再没有消费
  // 方，2026-11-21 删除。存过的配置里多出来的这两个键 fromMap 不读，下次保存
  // 时自然丢掉。

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
  };

  GlassAppearanceSettings withValue(String key, dynamic value) =>
      GlassAppearanceSettings.fromMap({...toMap(), key: value});
}
