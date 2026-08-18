/// 把一条 mpv 日志归类成「该不该打扰用户、以及打扰到什么程度」
///
/// 起因是 issue #110：播放器把 `player.stream.error` 直接丢进 SnackBar，
/// 而 media_kit 在转发到 stream.error 之前已经把 prefix / level 丢掉了，
/// 于是 `tcp: ffurl_write returned 0xffffd8ba` 这种**正常关连接**的日志
/// 也会弹一条盖住播放条的提示；更糟的是音频解码器打不开时，
/// 用户看到的却是「请切换视频解码器」。
///
/// 所以这里改读 `player.stream.log`（PlayerLog{prefix, level, text}），
/// 并且**按 prefix 分流**——同一句 "Could not open codec." 在 `vd` 下是
/// 画面问题，在 `ad` 下只是没声音，两者的处置完全不同。
///
/// 关键约束（I1）：[PlaybackErrorTier] 故意没有 fatal 成员。
/// 任何一条日志都不允许把播放器推进「阻塞 / 致命」状态——
/// mpv 的 hwdec 阶梯本来就会先吐 1~3 条 error 再正常播放。
/// 这条不变量由 test/utils/mpv_playback_error_classifier_test.dart 守住，
/// 调整规则时请同步该测试。
library;

/// 处置级别：只有这三档，没有 fatal（见上文 I1）
enum PlaybackErrorTier {
  /// 完全不提示，只进 ledger 供事后排查
  silent,

  /// 短暂问题，播放通常会自行恢复
  transient,

  /// 体验已经降级（没声音 / 画面有问题），值得告知用户
  degraded,
}

/// 归因类型，决定 UI 上最终显示哪一句文案
enum PlaybackErrorKind {
  networkReconnect,
  decodeGlitch,
  auxFileSkipped,
  duplicateSummary,
  networkUnreachable,
  openFailed,
  audioUnavailable,
  hardwareDecodeFallback,
  videoDecodeProblem,
  unknown,
}

/// 分类结果
class PlaybackErrorSignal {
  const PlaybackErrorSignal({
    required this.tier,
    required this.kind,
    required this.signature,
    required this.raw,
  });

  final PlaybackErrorTier tier;
  final PlaybackErrorKind kind;

  /// 归一化后的去重键，见 [MpvPlaybackErrorClassifier.signatureOf]
  final String signature;

  /// 原始 mpv 文案，只进 ledger / 详情面板，绝不直接显示在提示条上
  final String raw;
}

class MpvPlaybackErrorClassifier {
  MpvPlaybackErrorClassifier._();

  /// URL 整体归一，两个不同视频地址不该算两种故障
  static final RegExp _urlPattern = RegExp(r'https?://\S+');

  /// host:port，CDN 换边缘节点时端口/域名都会变
  static final RegExp _hostPattern = RegExp(r'\b[\w.-]+:\d{2,5}\b');

  /// FFmpeg 的错误码有时是十六进制有时是十进制负数
  static final RegExp _hexPattern = RegExp(r'0x[0-9a-fA-F]+');
  static final RegExp _numberPattern = RegExp(r'-?\d+');

  /// 生成去重键：一次网络抖动会刷屏几十条，必须先塌缩成同一个 key
  ///
  /// 注意十六进制和十进制走的是同一个占位符 `<n>`：
  /// `0xffffd8ba` 就是 `-10054`（AVERROR(WSAECONNRESET)）的另一种写法，
  /// mpv/FFmpeg 在不同分支里两种格式都会打。若分成两个 key，
  /// 同一次重连会被当成「多种不同故障」，直接顶穿上层的风暴抑制。
  static String signatureOf(String prefix, String text) {
    final normalized = text
        .replaceAll(_urlPattern, '<url>')
        .replaceAll(_hostPattern, '<host>')
        .replaceAll(_hexPattern, '<n>')
        .replaceAll(_numberPattern, '<n>')
        .toLowerCase()
        .trim();
    return '${prefix.trim().toLowerCase()}|$normalized';
  }

  /// [prefix]、[level]、[text] 直接取自 media_kit 的 PlayerLog
  ///
  /// 返回 null 表示这条日志根本不用管（非 error/fatal 级别）
  static PlaybackErrorSignal? classifyLog({
    required String prefix,
    required String level,
    required String text,
  }) {
    final normalizedLevel = level.trim().toLowerCase();
    if (normalizedLevel != 'error' && normalizedLevel != 'fatal') {
      return null;
    }

    final p = prefix.trim().toLowerCase();
    final t = text.toLowerCase();

    final (PlaybackErrorTier tier, PlaybackErrorKind kind) = _resolve(p, t);
    return PlaybackErrorSignal(
      tier: tier,
      kind: kind,
      signature: signatureOf(prefix, text),
      raw: text,
    );
  }

  static (PlaybackErrorTier, PlaybackErrorKind) _resolve(
    String prefix,
    String text,
  ) {
    // ffmpeg 层：mpv 有时把 prefix 记成 ffmpeg/network，有时正文自带 "tcp:"
    if (_hasPrefix(prefix, 'ffmpeg') || text.trimLeft().startsWith('tcp:')) {
      // ★ issue #110 就停在这一行：ffurl_write/ffurl_read 的返回码来自
      // FFmpeg「无法归类此返回码」的兜底分支，mpv 主动关连接时也会打，
      // 播放从未中断，绝不能弹提示。
      if (text.contains('ffurl_write returned') ||
          text.contains('ffurl_read returned')) {
        return (PlaybackErrorTier.silent, PlaybackErrorKind.networkReconnect);
      }
      return (
        PlaybackErrorTier.transient,
        PlaybackErrorKind.networkUnreachable,
      );
    }

    if (_hasPrefix(prefix, 'vd')) {
      if (text.contains('error while decoding frame')) {
        return (PlaybackErrorTier.silent, PlaybackErrorKind.decodeGlitch);
      }
      // hwdec 阶梯的正常现象：连吐几条再回落到软解，之后播放正常
      if (text.contains('falling back to software decoding') ||
          text.contains('hardware decoding')) {
        return (
          PlaybackErrorTier.degraded,
          PlaybackErrorKind.hardwareDecodeFallback,
        );
      }
      if (text.contains('could not open codec') ||
          text.contains('could not find decoder')) {
        return (
          PlaybackErrorTier.degraded,
          PlaybackErrorKind.videoDecodeProblem,
        );
      }
      // vd 前缀本身已经说明是「视频解码器」，即使正文没匹配上已知规则，
      // 归因到视频解码也是成立的——不该退化成 unknown 而被静音。
      return (PlaybackErrorTier.degraded, PlaybackErrorKind.videoDecodeProblem);
    }

    // ao = audio output（音频输出设备），与 ad(audio decoder) 不同。
    // 例如 "Failed to initialize audio driver"：结果就是没声音。
    // 原先没有这条分支，它会掉进最后的全局兜底。
    if (_hasPrefix(prefix, 'ao')) {
      return (PlaybackErrorTier.degraded, PlaybackErrorKind.audioUnavailable);
    }

    if (_hasPrefix(prefix, 'ad')) {
      if (text.contains('error decoding audio')) {
        return (PlaybackErrorTier.silent, PlaybackErrorKind.decodeGlitch);
      }
      // 音频解码器出事只是没声音，画面是好的——绝不能提示用户改视频解码器
      return (PlaybackErrorTier.degraded, PlaybackErrorKind.audioUnavailable);
    }

    // file 前缀保持 unknown（由 mpv_playback_error_classifier_test.dart 锁定）。
    // 它的语义有歧义：既可能是「本地文件根本打不开」，也可能是播放途中的
    // 一次性读失败（"Read error."）。前者值得提示、后者不值得，仅凭前缀分不开，
    // 因此不归因，交给上层静音只记台账。若将来发现「已下载视频打不开」确实
    // 会走这里且无其它反馈，再单独按正文细分。
    if (_hasPrefix(prefix, 'file')) {
      return (PlaybackErrorTier.degraded, PlaybackErrorKind.unknown);
    }

    if (_hasPrefix(prefix, 'stream')) {
      return (
        PlaybackErrorTier.transient,
        PlaybackErrorKind.networkUnreachable,
      );
    }

    if (_hasPrefix(prefix, 'cplayer')) {
      // "Errors when loading file ..." 只是 mpv 对前面若干条错误的汇总，
      // 单独提示等于把同一个问题说两遍
      if (text.contains('errors when loading file')) {
        return (PlaybackErrorTier.silent, PlaybackErrorKind.duplicateSummary);
      }
      // 必须排在任何裸 "can not open" 规则之前：
      // 外挂字幕/音轨加载不到完全不影响正片播放
      if (text.contains('can not open external file')) {
        return (PlaybackErrorTier.silent, PlaybackErrorKind.auxFileSkipped);
      }
      if (text.contains('no sound') || text.contains('audio device')) {
        return (PlaybackErrorTier.degraded, PlaybackErrorKind.audioUnavailable);
      }
      if (text.contains('failed to open')) {
        return (PlaybackErrorTier.transient, PlaybackErrorKind.openFailed);
      }
      // cplayer 是 mpv 的核心播放器层，走到这里的 error 级日志基本都意味着
      // 这个文件根本放不了，例如 "Failed to recognize file format."、
      // "No video or audio streams selected."——注意它们都不含 "failed to open"，
      // 所以命不中上面那条。原先退化成 unknown，被静音后用户会「点了没反应、
      // 也没有任何提示」，这是最严重的一档，必须提示。
      return (PlaybackErrorTier.degraded, PlaybackErrorKind.openFailed);
    }

    // 真正的全局兜底：走到这里说明连模块都不认识（vo / demux / af / vf /
    // cache 等）。此时无法归因，保持 unknown —— 上层会静音只记台账，
    // 绝不对用户断言某个具体症状。
    return (PlaybackErrorTier.degraded, PlaybackErrorKind.unknown);
  }

  /// mpv 的日志器名可能带子模块（ffmpeg/network、vd/lavc），
  /// 但不能让 `vdpau`、`streamcache` 这类同前缀开头的模块误命中
  static bool _hasPrefix(String normalizedPrefix, String name) =>
      normalizedPrefix == name || normalizedPrefix.startsWith('$name/');
}
