import 'package:i_iwara/app/models/vr_format.model.dart';

/// XR 片源格式的两阶段检测器。纯函数、无副作用、不依赖 GetX/IO，方便单测。
///
/// ## 为什么要分两阶段
///
/// 实测 1125 条真实视频里，**起播前只有 38% 拿得到 file.width/height**，另外
/// 62% 要等真正开播后才知道真实宽高比。而信号分工是死的：
///
///   - **文本（标题 + 标签）负责「怀疑」**：召回率能压到 1.000（不漏真 VR），
///     但准确率只有 0.731——因为大量「【VR180】xxx」其实是作者顺手发的**平面
///     版**（同一部作品他同时发了平面和 VR 两个文件），文本根本分不出来。
///   - **宽高比负责「判决」**：≈2:1 才是等距投影的真身，≈16:9 一律平面，哪怕
///     标题喊破喉咙说是 VR 也否决。
///
/// 所以流程是：
///
///   阶段A [suspectFromMetadata]：详情到手，先用文本 + 标签拉出「怀疑」，
///     顺带把文本里显式写出的 180/360、SBS/TB 记下来（这些只是线索，不下结论）。
///   阶段B [decideWithDimensions]：等真实宽高比到手，用比例做最终判决；
///     没尺寸就返回 `null`（决策推迟、必须起播后复判），不硬猜——这条对所有
///     视频成立，因为「≈2:1 纯宽高比」那张召回网要靠真实宽高才张得开。
///
/// ## 几条从数据里烙出来的死规矩
///
///   1. **文件名信号为 0**：816 条是 UUID、74 条空、235 条「时间戳_随机串」。
///      任何基于原始文件名的规则都无效，这里一条都不写。
///   2. **标签必须精确匹配 id，不能子串包含**：`vrchat / vroid / cm3d2 /
///      custom_maid_3d / 3d_custom_girl / chevreuse` 都含 `vr`/`3d` 子串却跟 VR
///      毫无关系，子串匹配会把它们全误报。
///   3. **否定词 ≠ 正向词**：`VRアリ/VRあり/VR DL/Flat&/&VR/VRおまけ` 表示
///      「另有 VR 版」而本文件是平面；但 `VR Version/VR版` 是**正向**信号，早期
///      版本把它们错当否定词，害出 3 条假阴性。两者务必分开。
class VrFormatDetector {
  const VrFormatDetector._();

  // ── 宽高比常量 ───────────────────────────────────────────────────────────

  /// 等距投影的宽高比（2:1）。
  static const double _equirectRatio = 2.0;

  /// 宽高比容差（实测值）。2:1 与 16:9 两个桶用它划边，且互不重叠。
  static const double aspectTolerance = 0.06;

  // ── 置信度档位（仅供 UI 拿主意，未参与判等逻辑） ───────────────────────────

  /// 文本怀疑 + 宽高比坐实：最强。
  static const double _confStrong = 0.95;

  /// 只有宽高比坐实、文本没吭声（那 19 条「无信号」2:1 片就是这种）：中等，
  /// 低到足以让 UI 弹个「看着不像？点一下切回平面」的口子。
  static const double _confDimsOnly = 0.7;

  /// 文本喊 VR 但被 16:9 宽高比否决成平面：中高（89 条假阳性的归宿）。
  static const double _confFlatOverride = 0.85;

  /// 压根没被怀疑、直接判平面：高。
  static const double _confPlain = 0.9;

  // ── 阶段A：文本怀疑 ───────────────────────────────────────────────────────

  /// 阶段A：只看文本（标题 + 简介）与标签，拉出「怀疑」。
  ///
  /// 必须保持召回率 1.0——宁可多怀疑，绝不漏真 VR，因为漏掉的代价（该立体的
  /// 没立体）远小于误判的代价（不该拆的被拆两半）留给阶段B 的宽高比去否决。
  ///
  /// [width]/[height] 可选：38% 的详情当场就有尺寸，传进来会被原样记进
  /// [VrSuspicion]，阶段B 可以直接复用，省得再查一遍。
  static VrSuspicion suspectFromMetadata({
    String? title,
    String? body,
    List<String>? tags,
    int? width,
    int? height,
  }) {
    // 先折全角再转小写：日文输入法默认全角，标题里的「ＶＲ」「１８０」「［］」
    // 若不折成半角，后面所有 ASCII 规则（正向标记 / 裸 vr 正则）一条都命中不了
    // ——`toLowerCase()` 只会把全角 Ｖ(U+FF36) 折成全角 ｖ(U+FF56)，永远到不了
    // ASCII 的 'vr'。这是纯文本召回的真实漏洞，收口在归一化这一步。
    final text = _foldFullWidth('${title ?? ''}\n${body ?? ''}').toLowerCase();
    final tagIds = (tags ?? const <String>[])
        .map((e) => _foldFullWidth(e).trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();

    // 否定词：命中即「本文件是平面，VR 另有其文件」。它压过一切正向信号。
    final negated = _negationPhrases.any(text.contains);

    // 投影线索：360 一旦出现就压过 180（实测两者冲突为 0，360 优先最安全）。
    final has360 = _has360Text(text);
    final has180 = _has180Text(text) || tagIds.contains('vr180');
    VrProjection? projectionHint;
    if (has360) {
      projectionHint = VrProjection.equirect360;
    } else if (has180) {
      projectionHint = VrProjection.equirect180;
    }

    // 立体编排线索：文本里几乎不写（SBS 38 条 / TB 6 条），写了就记下来。
    final stereoHint = _stereoHintFromText(text);

    // 正向信号：文本命中 / 白名单标签命中 / 显式投影或编排词命中。
    final positiveTag = tagIds.any(_positiveTagIds.contains);
    final positiveText = _hasPositiveText(text) ||
        projectionHint != null ||
        stereoHint != null;

    final suspected = !negated && (positiveText || positiveTag);

    return VrSuspicion(
      suspected: suspected,
      negated: negated,
      projectionHint: projectionHint,
      stereoHint: stereoHint,
      width: (width != null && width > 0) ? width : null,
      height: (height != null && height > 0) ? height : null,
    );
  }

  // ── 阶段B：宽高比判决 ─────────────────────────────────────────────────────

  /// 阶段B：拿到真实宽高比后下最终判决。
  ///
  /// **返回值契约（null ⟺ 缺尺寸，与是否被怀疑无关）：**
  ///   - 返回 `null`：手上没有可用宽高，**决策推迟**。调用方必须在真实宽高到手
  ///     （通常是起播后）时再调一遍本函数。这条对**所有**视频成立，不管阶段A
  ///     怀疑没怀疑过——因为「≈2:1 纯宽高比」这张召回网要靠真实宽高才能张开，
  ///     那 19 条「无文本信号」的 2:1 片全靠它兜底；若在无尺寸时就先给未被怀疑
  ///     的片返回一个非 null 的平面终判，遵循「非 null 即终判」的调用方会就此
  ///     停手、起播期再也不复检，这批 VR 就被永久判平面了。
  ///   - 返回**非 null**：宽高已到手，这就是**终判**，无需再调。
  ///
  /// 判决规则（有尺寸时，宽高比是唯一裁判）：
  ///   - ≈2:1 → 等距投影（VR）。180 还是 360 由 [VrSuspicion.projectionHint]
  ///     决定，没线索就缺省 180（实测压倒性正确）。**注意：这一步不要求文本
  ///     怀疑过**——那 19 条「无信号」2:1 片就是靠纯宽高比认出来的。
  ///   - ≈16:9 → 平面。哪怕文本/标签喊 VR 也否决（89 条假阳性的真相）。
  ///   - 其余任何比例 → 安全兜底平面。
  static VrFormatVerdict? decideWithDimensions(
    VrSuspicion suspicion, {
    int? width,
    int? height,
  }) {
    // 允许阶段B 复用阶段A 当时就拿到的尺寸。
    final w = (width != null && width > 0) ? width : suspicion.width;
    final h = (height != null && height > 0) ? height : suspicion.height;

    if (w == null || h == null || w <= 0 || h <= 0) {
      // 缺尺寸一律推迟到起播后复判，不下终判——哪怕这条片没被文本怀疑过。
      // 否则「≈2:1 纯宽高比」这张召回网张不开：未被怀疑却其实是 2:1 的 VR，
      // 若此刻先返回非 null 的平面终判，会诱导调用方停止复检而被永久漏判。
      return null;
    }

    final ratio = w / h;

    // ≈2:1：等距投影。
    if ((ratio - _equirectRatio).abs() <= aspectTolerance) {
      final projection = suspicion.projectionHint == VrProjection.equirect360
          ? VrProjection.equirect360
          : VrProjection.equirect180;
      final stereoLayout = suspicion.stereoHint ?? _defaultStereoFor(projection);
      // 关于否定词：这里**故意**不因为 `suspicion.negated` 就把判决翻成平面——
      // 宽高比是唯一终审，像素说了算。作者写「另有 VR 版」是旁注，若这个文件
      // 本身就是 2:1，那它就是等距投影。
      //
      // 而「让用户看见这处矛盾」的事已经自动做到了：阶段A 的
      // `suspected = !negated && (...)`（见上）已把否定过的片压成
      // `suspected == false`，于是这里自然落到 [_confDimsOnly]，
      // 「看着不像？切回平面」的口子本来就是开着的。不必也不该再判一次 negated，
      // 那只会写出一行永远为真的死条件。
      // （实测 1125 条样本里 65 条命中否定词，无一是 2:1，这条路径现实中走不到。）
      return VrFormatVerdict.inferred(
        VrSourceFormat(projection: projection, stereoLayout: stereoLayout),
        confidence: suspicion.suspected ? _confStrong : _confDimsOnly,
      );
    }

    // ≈16:9 或其余任何比例：一律平面。
    return VrFormatVerdict.inferred(
      const VrSourceFormat(
        projection: VrProjection.flat,
        stereoLayout: VrStereoLayout.mono,
      ),
      confidence: suspicion.suspected ? _confFlatOverride : _confPlain,
    );
  }

  /// 立体编排的行业缺省：180 走左右并排，360 走单目。
  static VrStereoLayout _defaultStereoFor(VrProjection projection) {
    return projection == VrProjection.equirect360
        ? VrStereoLayout.mono
        : VrStereoLayout.sideBySide;
  }

  // ── 文本信号词表与匹配 ────────────────────────────────────────────────────

  /// 否定词（小写形态）：命中即「另有 VR 版、本文件是平面」。
  ///
  /// ⚠️ 这里**不含** `vr version` / `vr版`——它们是正向信号，别混进来。
  static const List<String> _negationPhrases = <String>[
    'vrアリ', // VRアリ（片假名）
    'vrあり', // VRあり（平假名）
    'vr dl', // VR DL
    'flat&', // Flat&…
    '&vr', // …&VR
    'vrおまけ', // VRおまけ（VR 附赠）
  ];

  /// 正向文本信号（小写）。命中任意一个即「怀疑」。
  static const List<String> _positiveTextMarkers = <String>[
    'vr180',
    'vr 180',
    'vr360',
    'vr 360',
    '【vr】',
    '[vr]',
    'vr版',
    'vr version',
    'equirect',
    '180°',
    '360°',
  ];

  /// 正向标签白名单（精确 id 匹配）。实测词库里真实存在且高频：
  /// `vr180`(479) / `vr`(441) / `panorama`(2)。
  static const Set<String> _positiveTagIds = <String>{
    'vr180',
    'vr',
    'panorama',
  };

  /// 会误伤的排除标签（仅作留档说明）：这些含 `vr`/`3d` 子串却与 VR 无关。
  /// 因为上面走的是**精确 id 白名单**，它们天然不会命中，无需额外过滤——留在
  /// 这里是提醒：一旦有人手贱把匹配改成子串包含，请先回来看这条。
  // ignore: unused_field
  static const Set<String> _excludedTagIds = <String>{
    'vrchat',
    'vroid',
    'cm3d2',
    'custom_maid_3d',
    '3d_custom_girl',
    'chevreuse',
  };

  /// 裸 `vr` 词：独立单词才算，`vrchat`/`vroid` 这类词尾带字母的一律不算。
  static final RegExp _bareVr = RegExp(r'(?<![a-z0-9])vr(?![a-z0-9])');

  /// 分辨率/格式后缀紧贴 `vr` 的形态：`VR8K`/`VR4K`/`VR3D`/`VR60fps`、以及前缀式
  /// `8KVR`/`4KVR`/`3DVR`。8K/4K 正是本领域旗舰 VR 分辨率（样本众数含
  /// 3840x1920/4320x2160），这类标题常无标签，纯文本一漏就没了。
  ///
  /// 关键是不能误伤 `vrchat`/`vroid`：这里两支都要求 `vr` 紧挨**数字**（后缀支
  /// `vr\d`、前缀支 `\d[kd]vr`），而 `vrchat`/`vroid` 的 `vr` 后面跟的是字母，
  /// 天然落不进来。左右两侧再用 `(?<![a-z])`/`(?![a-z])` 挡住把 `vr` 嵌进别的
  /// 单词里的情况。裸 `vr` 后紧跟数字被 [_bareVr] 的数字边界拒掉，正好由这条补上。
  static final RegExp _vrResolution =
      RegExp(r'(?<![a-z])(\d{1,2}[kd]vr|vr\d{1,4}(k|d|p|fps)?)(?![a-z])');

  /// 显式 SBS / 左右并排。带词界，避免 `tb`/`sbs` 撞进别的单词里。
  static final RegExp _sideBySide =
      RegExp(r'(?<![a-z0-9])(sbs|side[\s-]?by[\s-]?side|3dh)(?![a-z0-9])');

  /// 显式 TB / 上下堆叠。
  static final RegExp _topBottom =
      RegExp(r'(?<![a-z0-9])(tb|top[\s-]?bottom|3dv)(?![a-z0-9])');

  /// 语义反转短语：这些写法里的 `vr` 恰恰在说「**不是** VR」。
  ///
  /// 实测 1125 条样本命中 25 条（2.2%），形如 `Non VR MMD …`、`NonVR MMD …`。
  /// 不处理的话，`Non VR` 里的裸 `vr` 会被 [_bareVr] 命中 → 判为「怀疑是 VR」，
  /// 而 62% 的视频在详情期拿不到尺寸、阶段B 无从否决，用户就会在一条明确写着
  /// 「非 VR」的普通视频上看到「疑似 VR」的默认档。
  ///
  /// ⚠️ 与 [_negationPhrases] 是两回事，别合并：那批（`VRアリ` 等）说的是
  /// 「另有 VR 版，本文件是平面」，属于作者的**旁注**；这批说的是
  /// 「这东西根本不是 VR」，属于对 `vr` 这个词本身的**否定**。
  static const List<String> _semanticNegationPhrases = <String>[
    'non vr',
    'non-vr',
    'nonvr',
    'no vr',
    'vr未対応',
    'vr非対応',
    'vrなし',
    'vr不可',
    '非vr',
  ];

  /// 把语义反转短语整段抹掉后再找正向信号。
  ///
  /// 收口在「抹掉」而不是「命中即一票否决」：一条标题完全可能同时写着
  /// 「Non VR 版本」和「VR180 另发」，抹掉前者不影响后者被认出来，
  /// 而一票否决会把后者一起误杀，伤到硬指标召回率。
  static String _stripSemanticNegations(String text) {
    var out = text;
    for (final phrase in _semanticNegationPhrases) {
      if (out.contains(phrase)) out = out.replaceAll(phrase, ' ');
    }
    return out;
  }

  static bool _hasPositiveText(String text) {
    final scanned = _stripSemanticNegations(text);
    for (final marker in _positiveTextMarkers) {
      if (scanned.contains(marker)) return true;
    }
    return _bareVr.hasMatch(scanned) || _vrResolution.hasMatch(scanned);
  }

  /// 全角→半角折叠：全角 ASCII 区（U+FF01–U+FF5E）整体平移回半角，全角空格
  /// （U+3000）折成普通空格。这是文本召回的收口点——不折叠，`ＶＲ８Ｋ`/`［ＶＲ１８０］`
  /// 这类全角标题会在归一化前就漏掉，后续任何 ASCII 规则都救不回来。用 runes
  /// 逐字遍历，天然不碰 emoji 之类的代理对。
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

  static bool _has180Text(String text) =>
      text.contains('vr180') ||
      text.contains('vr 180') ||
      text.contains('180°');

  static bool _has360Text(String text) =>
      text.contains('vr360') ||
      text.contains('vr 360') ||
      text.contains('360°');

  static VrStereoLayout? _stereoHintFromText(String text) {
    // 先判上下再判左右：两者同现时（几乎不会）以显式 TB 为准无所谓，这里保持稳定。
    if (_topBottom.hasMatch(text)) return VrStereoLayout.topBottom;
    if (_sideBySide.hasMatch(text)) return VrStereoLayout.sideBySide;
    return null;
  }
}

/// 阶段A（文本怀疑）的产出：只是「线索袋」，不是判决。
class VrSuspicion {
  /// 文本/标签是否让人怀疑这是 VR（且未被否定词否决）。
  final bool suspected;

  /// 是否命中否定词表（另有 VR 版、本文件是平面）。
  final bool negated;

  /// 文本里显式写出的投影线索（180/360）；没写就是 null，阶段B 缺省 180。
  final VrProjection? projectionHint;

  /// 文本里显式写出的立体编排线索（SBS/TB）；没写就是 null，走行业缺省。
  final VrStereoLayout? stereoHint;

  /// 阶段A 当场就有的尺寸（若有），供阶段B 复用；无则为 null。
  final int? width;
  final int? height;

  const VrSuspicion({
    required this.suspected,
    required this.negated,
    this.projectionHint,
    this.stereoHint,
    this.width,
    this.height,
  });

  /// 毫无 VR 迹象的普通视频。
  static const VrSuspicion none =
      VrSuspicion(suspected: false, negated: false);

  @override
  String toString() =>
      'VrSuspicion(suspected=$suspected, negated=$negated, '
      'projection=$projectionHint, stereo=$stereoHint, ${width}x$height)';
}
