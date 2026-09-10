import 'dart:convert';

import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/app/utils/local_vr_filename_detector.dart';

/// 本地片源 VR 线索的**持久化形态**。存进 `local_media_items.vr_format_json`。
/// ⛔ 它是「线索」不是「判决」：最终判决要等真实解码宽高到手（宽高比有一票否决权），
///    那一步在播放页做，不在这里。
class LocalVrHints {
  final LocalVrSignalStrength strength; // none / weak / strong
  final VrProjection? projection;
  final VrStereoLayout? stereo;
  final List<String> origins; // 'filename' / 'box' / 'text'，按命中顺序

  const LocalVrHints({
    required this.strength,
    this.projection,
    this.stereo,
    this.origins = const <String>[],
  });

  static const LocalVrHints none = LocalVrHints(
    strength: LocalVrSignalStrength.none,
    projection: null,
    stereo: null,
    origins: <String>[],
  );

  /// 序列化为 JSON 字符串。
  /// projection 与 stereo 键即使为 null 也显式写出。
  String toJson() => jsonEncode(<String, dynamic>{
    'v': 1,
    'strength': strength.name,
    'projection': projection?.name,
    'stereo': stereo?.name,
    'origins': origins,
  });

  /// 解析 JSON 字符串。
  /// 解析失败/为空一律返回 null，绝不抛出。
  /// 版本号 `v` 不等于 1 时返回 null（当作没探测过）。
  /// 枚举采用容错解析（认不出的值当 null/none）。
  static LocalVrHints? fromJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      if (decoded['v'] != 1) return null;

      final strengthStr = decoded['strength'];
      final strength = LocalVrSignalStrength.values.firstWhere(
        (e) => e.name == strengthStr,
        orElse: () => LocalVrSignalStrength.none,
      );

      final projectionStr = decoded['projection'];
      final projection = VrProjection.values.cast<VrProjection?>().firstWhere(
        (e) => e?.name == projectionStr,
        orElse: () => null,
      );

      final stereoStr = decoded['stereo'];
      final stereo = VrStereoLayout.values.cast<VrStereoLayout?>().firstWhere(
        (e) => e?.name == stereoStr,
        orElse: () => null,
      );

      final rawOrigins = decoded['origins'];
      final origins = rawOrigins is List
          ? rawOrigins.whereType<String>().toList()
          : const <String>[];

      return LocalVrHints(
        strength: strength,
        projection: projection,
        stereo: stereo,
        origins: origins,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalVrHints &&
          other.strength == strength &&
          other.projection == projection &&
          other.stereo == stereo &&
          _listEquals(other.origins, origins);

  @override
  int get hashCode =>
      Object.hash(strength, projection, stereo, Object.hashAll(origins));

  @override
  String toString() =>
      'LocalVrHints(strength=$strength, projection=$projection, stereo=$stereo, origins=$origins)';

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
