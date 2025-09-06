import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// Anime4K 预设分组枚举
enum Anime4KPresetGroup {
  highQuality('高质量', '🎯'),
  fast('快速', '⚡'),
  lite('轻量级', '📱'),
  custom('自定义', '🔧'),
  moreLite('更多轻量级', '💨');

  const Anime4KPresetGroup(this.nameKey, this.icon);

  final String nameKey;
  final String icon;

  // 获取 display name
  String get displayName => switch (this) {
    Anime4KPresetGroup.highQuality => slang.t.anime4k.presetGroups.highQuality,
    Anime4KPresetGroup.fast => slang.t.anime4k.presetGroups.fast,
    Anime4KPresetGroup.lite => slang.t.anime4k.presetGroups.lite,
    Anime4KPresetGroup.custom => slang.t.anime4k.presetGroups.custom,
    Anime4KPresetGroup.moreLite => slang.t.anime4k.presetGroups.moreLite,
  };
}

/// Anime4K Shader 预设配置
class Anime4KPresets {
  Anime4KPresets._internal();

  // 基础路径
  static const String shaderBasePath = 'assets/anime4k_shaders/';

  /// 高质量预设 - 适用于高端GPU
  static List<Anime4KPreset> highQualityPresets = [
    Anime4KPreset(
      id: 'mode_a_hq',
      name: slang.t.anime4k.presetNames.mode_a_hq,
      description: slang.t.anime4k.presetDescriptions.mode_a_hq,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      group: Anime4KPresetGroup.highQuality,
    ),
    Anime4KPreset(
      id: 'mode_b_hq',
      name: slang.t.anime4k.presetNames.mode_b_hq,
      description: slang.t.anime4k.presetDescriptions.mode_b_hq,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_Soft_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      group: Anime4KPresetGroup.highQuality,
    ),
    Anime4KPreset(
      id: 'mode_c_hq',
      name: slang.t.anime4k.presetNames.mode_c_hq,
      description: slang.t.anime4k.presetDescriptions.mode_c_hq,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      group: Anime4KPresetGroup.highQuality,
    ),
    Anime4KPreset(
      id: 'mode_a_a_hq',
      name: slang.t.anime4k.presetNames.mode_a_a_hq,
      description: slang.t.anime4k.presetDescriptions.mode_a_a_hq,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      group: Anime4KPresetGroup.highQuality,
    ),
    Anime4KPreset(
      id: 'mode_b_b_hq',
      name: slang.t.anime4k.presetNames.mode_b_b_hq,
      description: slang.t.anime4k.presetDescriptions.mode_b_b_hq,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_Soft_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Restore_CNN_Soft_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      group: Anime4KPresetGroup.highQuality,
    ),
    Anime4KPreset(
      id: 'mode_c_a_hq',
      name: slang.t.anime4k.presetNames.mode_c_a_hq,
      description: slang.t.anime4k.presetDescriptions.mode_c_a_hq,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      group: Anime4KPresetGroup.highQuality,
    ),
  ];

  /// 快速预设 - 适用于中低端GPU
  static List<Anime4KPreset> fastPresets = [
    Anime4KPreset(
      id: 'mode_a_fast',
      name: slang.t.anime4k.presetNames.mode_a_fast,
      description: slang.t.anime4k.presetDescriptions.mode_a_fast,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_S.glsl',
      ],
      group: Anime4KPresetGroup.fast,
    ),
    Anime4KPreset(
      id: 'mode_b_fast',
      name: slang.t.anime4k.presetNames.mode_b_fast,
      description: slang.t.anime4k.presetDescriptions.mode_b_fast,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_Soft_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_S.glsl',
      ],
      group: Anime4KPresetGroup.fast,
    ),
    Anime4KPreset(
      id: 'mode_c_fast',
      name: slang.t.anime4k.presetNames.mode_c_fast,
      description: slang.t.anime4k.presetDescriptions.mode_c_fast,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_M.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_S.glsl',
      ],
      group: Anime4KPresetGroup.fast,
    ),
    Anime4KPreset(
      id: 'mode_a_a_fast',
      name: slang.t.anime4k.presetNames.mode_a_a_fast,
      description: slang.t.anime4k.presetDescriptions.mode_a_a_fast,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
        'Anime4K_Restore_CNN_S.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_S.glsl',
      ],
      group: Anime4KPresetGroup.fast,
    ),
     Anime4KPreset(
      id: 'mode_b_b_fast',
      name: slang.t.anime4k.presetNames.mode_b_b_fast,
      description: slang.t.anime4k.presetDescriptions.mode_b_b_fast,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_Soft_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Restore_CNN_Soft_S.glsl',
        'Anime4K_Upscale_CNN_x2_S.glsl',
      ],
      group: Anime4KPresetGroup.fast,
    ),
    Anime4KPreset(
      id: 'mode_c_a_fast',
      name: slang.t.anime4k.presetNames.mode_c_a_fast,
      description: slang.t.anime4k.presetDescriptions.mode_c_a_fast,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_M.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Restore_CNN_S.glsl',
        'Anime4K_Upscale_CNN_x2_S.glsl',
      ],
      group: Anime4KPresetGroup.fast,
    ),
  ];

  /// 轻量级预设 - 适用于性能较低的设备或移动设备
  static List<Anime4KPreset> litePresets = [
    Anime4KPreset(
      id: 'upscale_only_s',
      name: slang.t.anime4k.presetNames.upscale_only_s,
      description: slang.t.anime4k.presetDescriptions.upscale_only_s,
      shaders: [
        'Anime4K_Upscale_CNN_x2_S.glsl',
      ],
      group: Anime4KPresetGroup.lite,
    ),
    Anime4KPreset(
      id: 'upscale_deblur_fast',
      name: slang.t.anime4k.presetNames.upscale_deblur_fast,
      description: slang.t.anime4k.presetDescriptions.upscale_deblur_fast,
      shaders: [
        'Anime4K_Upscale_Deblur_Original_x2.glsl',
      ],
      group: Anime4KPresetGroup.lite,
    ),
    Anime4KPreset(
      id: 'restore_s_only',
      name: slang.t.anime4k.presetNames.restore_s_only,
      description: slang.t.anime4k.presetDescriptions.restore_s_only,
      shaders: [
        'Anime4K_Restore_CNN_S.glsl',
      ],
      group: Anime4KPresetGroup.lite,
    ),
  ];

  /// 自定义预设 - 用于特殊需求或个人偏好
  /// 基于文档中的高级自定义部分创建的示例
  static List<Anime4KPreset> customPresets = [
    Anime4KPreset(
      id: 'mode_a_fast_darken',
      name: slang.t.anime4k.presetNames.mode_a_fast_darken,
      description: slang.t.anime4k.presetDescriptions.mode_a_fast_darken,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_S.glsl',
        'Anime4K_Darken_Fast.glsl',
      ],
      group: Anime4KPresetGroup.custom,
    ),
    Anime4KPreset(
      id: 'mode_a_hq_thin',
      name: slang.t.anime4k.presetNames.mode_a_hq_thin,
      description: slang.t.anime4k.presetDescriptions.mode_a_hq_thin,
      shaders: [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
        'Anime4K_Thin_Fast.glsl'
      ],
      group: Anime4KPresetGroup.custom,
    ),
  ];


  /// 更多轻量级预设 - 适用于性能较低的设备或移动设备
  static List<Anime4KPreset> moreLitePresets = [
    Anime4KPreset(
      id: 'denoise_bilateral_fast',
      name: slang.t.anime4k.presetNames.denoise_bilateral_fast,
      description: slang.t.anime4k.presetDescriptions.denoise_bilateral_fast,
      shaders: [
        'Anime4K_Denoise_Bilateral_Mode.glsl',
      ],
      group: Anime4KPresetGroup.moreLite,
    ),
    Anime4KPreset(
      id: 'upscale_non_cnn',
      name: slang.t.anime4k.presetNames.upscale_non_cnn,
      description: slang.t.anime4k.presetDescriptions.upscale_non_cnn,
      shaders: [
        'Anime4K_Upscale_Original_x2.glsl',
      ],
      group: Anime4KPresetGroup.moreLite,
    ),
  ];

  /// 获取所有预设
  static List<Anime4KPreset> getAllPresets() {
    return [
      ...highQualityPresets,
      ...fastPresets,
      ...litePresets,
      ...moreLitePresets,     // 补充更多轻量级选项
      ...customPresets,
    ];
  }

  /// 根据ID获取预设
  static Anime4KPreset? getPresetById(String id) {
    try {
      return getAllPresets().firstWhere((preset) => preset.id == id);
    } catch (e) {
      // 如果找不到，返回null或第一个预设作为默认值，这里选择返回null
      return null;
    }
  }

  /// 根据分组获取预设
  static List<Anime4KPreset> getPresetsByGroup(Anime4KPresetGroup group) {
    return getAllPresets().where((preset) => preset.group == group).toList();
  }

  /// 获取预设的完整shader路径列表
  /// 注意：这个静态方法现在无法直接使用，因为preset不是静态的。
  /// 建议使用Anime4KPreset实例的 `shaderPaths` getter。
  /// 如果确实需要一个静态方法，可以这样实现：
  static List<String> getShaderPathsById(String id) {
    final preset = getPresetById(id);
    if (preset == null) {
      return [];
    }
    return preset.shaderPaths;
  }
}

/// Anime4K 预设数据类
class Anime4KPreset {
  final String id;
  final String name;
  final String description;
  final List<String> shaders;
  final Anime4KPresetGroup group;

  const Anime4KPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.shaders,
    required this.group,
  });

  /// 获取完整的shader路径列表
  List<String> get shaderPaths {
    return shaders.map((shader) => '${Anime4KPresets.shaderBasePath}$shader').toList();
  }

  @override
  String toString() {
    return 'Anime4KPreset(id: $id, name: $name, shaders: ${shaders.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Anime4KPreset && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}