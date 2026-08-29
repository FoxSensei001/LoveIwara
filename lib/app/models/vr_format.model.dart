/// XR 视频「片源格式层」的值对象与枚举。
///
/// 这一层只回答一个问题：**这段视频该按什么几何来铺**——投影是平面还是
/// 等距（180/360），左右眼是怎么排的（单目 / 左右 / 上下）。它不碰渲染、
/// 不碰播放器、不依赖 GetX，纯数据，方便被检测器 [VrFormatDetector] 和
/// 配置持久化两头复用。
///
/// ⚠️ 兜底方向是刻意的：把普通视频误判成 VR（画面被强行拆成两半、完全没法
/// 看）的代价，远大于把 VR 误判成平面（顶多不立体、但画面完整）。所以一切
/// 认不出来的场合，缺省一律回到 [VrSourceFormat.flatMono]。
library;

/// 投影方式：画面在球面/平面上的展开几何。
enum VrProjection {
  /// 平面（普通视频，不做任何球面重投影）。
  flat,

  /// 等距柱状 180°（半球，最常见的 VR 片源）。
  equirect180,

  /// 等距柱状 360°（全景）。
  equirect360,

  /// 鱼眼（MKX / fisheye 类）。首版不渲染，但保留取值以免以后要迁数据。
  fisheye,
}

/// 立体编排：左右眼画面在同一帧里怎么摆。
enum VrStereoLayout {
  /// 单目：整帧一只眼（360 的行业缺省）。
  mono,

  /// 左右并排 Side-by-Side（180 的行业缺省）。
  sideBySide,

  /// 上下堆叠 Top-Bottom。
  topBottom,
}

/// 判决来源：这个格式是「机器推断」还是「用户手动指定」。
enum VrVerdictSource {
  /// 检测器根据文本 + 宽高比推断出来的。
  inferred,

  /// 用户在播放器里手动选定的（应当压过一切推断）。
  userSpecified,
}

/// 片源格式值对象：投影 + 立体编排两个维度。可判等、可序列化。
class VrSourceFormat {
  /// 投影方式。
  final VrProjection projection;

  /// 立体编排。
  final VrStereoLayout stereoLayout;

  const VrSourceFormat({
    required this.projection,
    required this.stereoLayout,
  });

  /// 安全兜底：平面 + 单目。所有「认不出来」的路径都回到这里。
  static const VrSourceFormat flatMono = VrSourceFormat(
    projection: VrProjection.flat,
    stereoLayout: VrStereoLayout.mono,
  );

  /// 是不是需要按 VR 几何来铺（投影不是平面）。
  bool get isVr => projection != VrProjection.flat;

  VrSourceFormat copyWith({
    VrProjection? projection,
    VrStereoLayout? stereoLayout,
  }) {
    return VrSourceFormat(
      projection: projection ?? this.projection,
      stereoLayout: stereoLayout ?? this.stereoLayout,
    );
  }

  /// 序列化成配置字符串，形如 `equirect180:sideBySide`。
  String toConfigString() => '${projection.name}:${stereoLayout.name}';

  /// 从配置字符串还原。解析失败一律容错回退到 [flatMono]——参考
  /// `playerScreenFitModeFromConfig` 的 firstWhere/orElse 写法，认不出来的
  /// 每个字段各自退回到自己的安全缺省（投影退 flat、编排退 mono）。
  factory VrSourceFormat.fromConfigString(dynamic value) {
    if (value is! String) return flatMono;
    final parts = value.split(':');
    if (parts.length != 2) return flatMono;
    final projection = VrProjection.values.firstWhere(
      (p) => p.name == parts[0],
      orElse: () => VrProjection.flat,
    );
    final stereoLayout = VrStereoLayout.values.firstWhere(
      (s) => s.name == parts[1],
      orElse: () => VrStereoLayout.mono,
    );
    return VrSourceFormat(projection: projection, stereoLayout: stereoLayout);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VrSourceFormat &&
          other.projection == projection &&
          other.stereoLayout == stereoLayout;

  @override
  int get hashCode => Object.hash(projection, stereoLayout);

  @override
  String toString() => 'VrSourceFormat($projection, $stereoLayout)';
}

/// 一次判决的完整结果：格式 + 来源 + 置信度。
///
/// [confidence] 只用来给 UI 拿主意——高置信直接套用，低置信可以弹个提示
/// 让用户确认，避免机器一口咬定。取值范围 0..1。
class VrFormatVerdict {
  final VrSourceFormat format;
  final VrVerdictSource source;
  final double confidence;

  const VrFormatVerdict({
    required this.format,
    required this.source,
    required this.confidence,
  });

  /// 机器推断出来的判决。
  const VrFormatVerdict.inferred(
    this.format, {
    required this.confidence,
  }) : source = VrVerdictSource.inferred;

  /// 用户手动指定的判决：来源确定、置信度拉满。
  const VrFormatVerdict.userSpecified(this.format)
      : source = VrVerdictSource.userSpecified,
        confidence = 1.0;

  bool get isVr => format.isVr;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VrFormatVerdict &&
          other.format == format &&
          other.source == source &&
          other.confidence == confidence;

  @override
  int get hashCode => Object.hash(format, source, confidence);

  @override
  String toString() =>
      'VrFormatVerdict($format, $source, confidence=$confidence)';
}
