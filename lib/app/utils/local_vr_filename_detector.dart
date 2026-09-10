import 'package:i_iwara/app/models/vr_format.model.dart';

/// 线索强度。strong ⇒ 允许自动应用；weak ⇒ 只提示。
enum LocalVrSignalStrength { none, weak, strong }

/// 本地文件名 VR 线索提取结果。纯数据结构，不含业务逻辑。
class LocalVrFileNameSignals {
  /// 线索强度。
  final LocalVrSignalStrength strength;

  /// 投影线索（180 / 360）；无显式线索则为 null。
  final VrProjection? projectionHint;

  /// 立体编排线索（SBS / TB / mono）；无显式线索则为 null。
  final VrStereoLayout? stereoHint;

  const LocalVrFileNameSignals({
    required this.strength,
    this.projectionHint,
    this.stereoHint,
  });

  /// 毫无 VR 迹象的普通文件。
  static const LocalVrFileNameSignals none = LocalVrFileNameSignals(
    strength: LocalVrSignalStrength.none,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalVrFileNameSignals &&
          other.strength == strength &&
          other.projectionHint == projectionHint &&
          other.stereoHint == stereoHint;

  @override
  int get hashCode => Object.hash(strength, projectionHint, stereoHint);

  @override
  String toString() =>
      'LocalVrFileNameSignals(strength=$strength, '
      'projection=$projectionHint, stereo=$stereoHint)';
}

/// 从本地视频文件名推断 VR 片源格式线索的检测器。
///
/// ⛔ 本类只看文件名，不许读文件、不许碰 IO：调用方通常在文件列表扫描或未就绪
/// 阶段触发推断，引入任何 IO 都会严重拖慢列表渲染或阻塞主线程。
class LocalVrFileNameDetector {
  const LocalVrFileNameDetector._();

  /// 从给定的文件名中提取 VR 投影与立体编排线索。
  static LocalVrFileNameSignals detect(String fileName) {
    if (fileName.isEmpty) return LocalVrFileNameSignals.none;

    // 先剥离路径，只保留纯文件名；再剥离扩展名。
    final lastSeparator = fileName.lastIndexOf(RegExp(r'[/\\]'));
    final baseName = lastSeparator >= 0
        ? fileName.substring(lastSeparator + 1)
        : fileName;
    final lastDot = baseName.lastIndexOf('.');
    final nameWithoutExt = (lastDot > 0)
        ? baseName.substring(0, lastDot)
        : baseName;

    // 先折全角再转小写：日文/中文环境下文件名常含全角字符，若不折成半角，
    // 后面所有 ASCII 规则一条都命中不了——`toLowerCase()` 无法将全角折向 ASCII。
    // 用 runes 逐字遍历，天然避免拆散代理对。
    final normalized = _foldFullWidth(nameWithoutExt).toLowerCase();
    if (normalized.isEmpty) return LocalVrFileNameSignals.none;

    // 整词匹配（在整串上做，不切 token）：
    // 理由：按分隔符切会把 `Side-By-Side` 碎成 `side/by/side`，一个都不命中。
    final hasWholeWordSbs =
        normalized.contains('side-by-side') ||
        normalized.contains('side by side') ||
        normalized.contains('sidebyside');
    final hasWholeWordTb =
        normalized.contains('over-under') ||
        normalized.contains('over under') ||
        normalized.contains('overunder');

    // 用 `_`、`-`、空格、`.`、`[`、`]`、`(`、`)` 切成 token 列表（丢掉空 token）。
    final rawTokens = normalized.split(RegExp(r'[_\-\s.\[\]()]+'));
    final tokenSet = rawTokens.where((t) => t.isNotEmpty).toSet();

    // ── 立体编排 token 判决 ──────────────────────────────────────────────────
    // 强 sbs：lr rl sbs hsbs（外加整词匹配）
    final hasStrongSbs =
        tokenSet.contains('lr') ||
        tokenSet.contains('rl') ||
        tokenSet.contains('sbs') ||
        tokenSet.contains('hsbs') ||
        hasWholeWordSbs;

    // 强 tb：tb bt ou hou（外加整词匹配）
    final hasStrongTb =
        tokenSet.contains('tb') ||
        tokenSet.contains('bt') ||
        tokenSet.contains('ou') ||
        tokenSet.contains('hou') ||
        hasWholeWordTb;

    // `2d`：把立体编排钉死成单目。
    //
    // ⛔ 它**不能单独把强度抬到 strong**。strong 的语义是"敢自动应用"，而
    // `movie_2D.mp4` 这种名字满地都是、跟 VR 毫无关系：抬成 strong 之后，
    // 只要这条片子恰好是 2:1 画幅（2.0:1 是真实存在的电影画幅），上游就会
    // 自动把它套成 equirect180 单目——把一部普通片当场铺到球面上。
    // `2d` 的用处是在**别的信号已经成立时**否掉"默认 SBS"，不是自己当信号。
    final hasMonoToken = tokenSet.contains('2d');

    // 弱 tb：3dv
    final hasWeakTb = tokenSet.contains('3dv');

    // 弱 sbs：3d 3dh
    // ⛔ `3d` 只能是弱信号：本地库里 MMD / 3D 同人片文件名带 `3D` 是常态，
    // 判成 SBS 会把普通片当场拆成两半。
    final hasWeakSbs = tokenSet.contains('3d') || tokenSet.contains('3dh');

    VrStereoLayout? stereoHint;
    bool hasStrongStereo = false;
    bool hasWeakStereo = false;

    // 强立体信号优先于弱立体信号；单目 > 上下 > 左右保持判定稳定。
    if (hasMonoToken) {
      // 只钉编排，不贡献强度——强度由投影或别的强立体 token 决定（见上面那条 ⛔）。
      stereoHint = VrStereoLayout.mono;
    } else if (hasStrongTb) {
      stereoHint = VrStereoLayout.topBottom;
      hasStrongStereo = true;
    } else if (hasStrongSbs) {
      stereoHint = VrStereoLayout.sideBySide;
      hasStrongStereo = true;
    } else if (hasWeakTb) {
      stereoHint = VrStereoLayout.topBottom;
      hasWeakStereo = true;
    } else if (hasWeakSbs) {
      stereoHint = VrStereoLayout.sideBySide;
      hasWeakStereo = true;
    }

    // ── 投影 token 判决 ──────────────────────────────────────────────────────
    // ⛔ 只认独立 token，不要子串包含：`1080`、`3600` 这类不能命中。（`1080p` 会被切成
    // 一个 token `1080p`，不等于 `180`，天然不命中——但仍要保证判据是「token 相等」
    // 而不是 `contains`）。
    final has180x180 = tokenSet.contains('180x180');
    final hasBare180 = tokenSet.contains('180');
    final hasBare360 = tokenSet.contains('360');

    VrProjection? projectionHint;
    // 360 与 180 同时出现时，360 优先（与 `VrFormatDetector` 里的既有约定一致）。
    if (hasBare360) {
      projectionHint = VrProjection.equirect360;
    } else if (has180x180 || hasBare180) {
      projectionHint = VrProjection.equirect180;
    }

    // ── 强度合成 ─────────────────────────────────────────────────────────────
    // 1. 命中任何强立体 token 或 180x180 → strong
    //    （裸 token 180 / 360 若同时命中了强立体 token，也随之升为 strong）。
    // 2. 只命中弱 token（含裸 180/360 未被强立体 token 加持）→ weak。
    // 3. 什么都没有 → none，且两个 hint 都为 null。
    final hasStrongSignal = hasStrongStereo || has180x180;
    final hasWeakSignal =
        hasWeakStereo || (!hasStrongStereo && (hasBare180 || hasBare360));

    if (hasStrongSignal) {
      // ⛔ 立体编排缺省不要在这里填：命中不到就返回 null，让上游走行业缺省。
      return LocalVrFileNameSignals(
        strength: LocalVrSignalStrength.strong,
        projectionHint: projectionHint,
        stereoHint: stereoHint,
      );
    } else if (hasWeakSignal) {
      // ⛔ 立体编排缺省不要在这里填：命中不到就返回 null，让上游走行业缺省。
      return LocalVrFileNameSignals(
        strength: LocalVrSignalStrength.weak,
        projectionHint: projectionHint,
        stereoHint: stereoHint,
      );
    }

    return LocalVrFileNameSignals.none;
  }

  /// 全角 ASCII（U+FF01–U+FF5E）减 0xFEE0 平移回半角，全角空格（U+3000）折成普通半角空格。
  /// 使用 runes 逐字遍历，避免拆断 Unicode 代理对。
  static String _foldFullWidth(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0xFF01 && rune <= 0xFF5E) {
        buffer.writeCharCode(rune - 0xFEE0);
      } else if (rune == 0x3000) {
        buffer.writeCharCode(0x20);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }
}
