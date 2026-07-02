import 'dart:ui';

/// 色觉辅助滤镜类型（面向色觉障碍用户的画面色彩矫正）
enum ColorVisionFilterType {
  none(''),
  protanopia('protanopia'),
  deuteranopia('deuteranopia'),
  tritanopia('tritanopia');

  const ColorVisionFilterType(this.id);

  /// 持久化用 ID，空字符串表示关闭（与 ANIME4K_PRESET_ID 的空串=禁用惯例一致）
  final String id;

  static ColorVisionFilterType fromId(String id) {
    return ColorVisionFilterType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => ColorVisionFilterType.none,
    );
  }
}

/// 色觉辅助矫正矩阵（daltonization）。
///
/// 矩阵由标准 daltonize 算法（colorjack / joergdietrich-daltonize 同源）预计算：
/// RGB→LMS（Hunt-Pointer-Estevez），在 LMS 空间应用对应类型的色盲模拟矩阵，
/// 模拟误差经再分配矩阵 [[0,0,0],[0.7,1,0],[0.7,0,1]] 移入可辨别通道，
/// 全流程均为线性变换，合成 C = I + E·(I − T⁻¹·S·T) 后即为下列 4×5 颜色矩阵；
/// 超出 [0,255] 的分量由渲染管线钳制。
/// 该滤镜作用于 mpv 渲染完成后的 Flutter 纹理，与 Anime4K(glsl-shaders) 互不影响。
class ColorVisionFilters {
  ColorVisionFilters._();

  /// 红色觉异常（Protanopia）矫正
  static const List<double> _protanopiaMatrix = <double>[
    1.0, 0.0, 0.0, 0.0, 0.0, //
    0.508949, 0.491054, 0.0, 0.0, 0.0, //
    0.617327, -0.617323, 1.0, 0.0, 0.0, //
    0.0, 0.0, 0.0, 1.0, 0.0, //
  ];

  /// 绿色觉异常（Deuteranopia）矫正
  static const List<double> _deuteranopiaMatrix = <double>[
    1.0, 0.0, 0.0, 0.0, 0.0, //
    0.202325, 0.797674, 0.0, 0.0, 0.0, //
    0.517411, -0.517413, 1.0, 0.0, 0.0, //
    0.0, 0.0, 0.0, 1.0, 0.0, //
  ];

  /// 蓝色觉异常（Tritanopia）矫正
  static const List<double> _tritanopiaMatrix = <double>[
    1.0, 0.0, 0.0, 0.0, 0.0, //
    -0.138536, 1.138538, 0.0, 0.0, 0.0, //
    3.365585, -3.365629, 1.0, 0.0, 0.0, //
    0.0, 0.0, 0.0, 1.0, 0.0, //
  ];

  /// 返回对应类型的颜色滤镜；[ColorVisionFilterType.none] 返回 null（不加滤镜）
  static ColorFilter? colorFilterOf(ColorVisionFilterType type) {
    switch (type) {
      case ColorVisionFilterType.none:
        return null;
      case ColorVisionFilterType.protanopia:
        return const ColorFilter.matrix(_protanopiaMatrix);
      case ColorVisionFilterType.deuteranopia:
        return const ColorFilter.matrix(_deuteranopiaMatrix);
      case ColorVisionFilterType.tritanopia:
        return const ColorFilter.matrix(_tritanopiaMatrix);
    }
  }
}
