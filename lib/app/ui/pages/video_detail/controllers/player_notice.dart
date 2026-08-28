import 'dart:async';
import 'dart:collection';

import 'package:get/get.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/mpv_playback_error_classifier.dart';

/// 提示等级。只影响停留时长与配色，不存在「阻塞」级别 —— 见 issue #110：
/// 任何一条播放日志都不该把用户从视频上赶走。
enum PlayerNoticeLevel { info, warning }

/// 可以展示给用户的提示种类。刻意做成有限枚举而不是自由文本，
/// 这样文案全部走 slang，且 Rx 去重只需比较枚举。
enum PlayerNoticeKind {
  networkUnstable,
  audioUnavailable,
  hardwareDecodeFellBack,
  videoDecodeProblem,
  videoLoadFailed,
  repeatedProblems,
  noVideoSource,
  castNotSupported,
  castUrlUnavailable,
  externalPlayerUnavailable,
}

/// 展示在播放器右上角小胶囊里的一条提示。
class PlayerNotice {
  const PlayerNotice({required this.kind, required this.level, this.detail});

  final PlayerNoticeKind kind;
  final PlayerNoticeLevel level;

  /// mpv 原文，只进台账和详情面板，永远不进胶囊正文 ——
  /// 原文里带地址、端口和错误码，对用户毫无意义且会撑爆布局。
  final String? detail;

  /// detail 刻意不参与相等判断：同一类问题的原文每次都不同（错误码、序号、端口），
  /// 若参与比较会让每条日志都触发一次 Rx 重建，正好是 I4 要防的抖动。
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerNotice && other.kind == kind && other.level == level;

  @override
  int get hashCode => Object.hash(kind, level);

  @override
  String toString() => 'PlayerNotice(${kind.name}, ${level.name})';
}

/// 台账里的一条问题记录。按签名聚合，重复的只累加次数，不新增条目。
class PlaybackIssue {
  PlaybackIssue({
    required this.signature,
    required this.kind,
    required this.tier,
    required this.sampleText,
    required this.firstSeen,
    required this.lastSeen,
    this.occurrences = 1,
    this.positionAtFirst,
  });

  final String signature;
  final PlaybackErrorKind kind;
  final PlaybackErrorTier tier;
  final String sampleText;
  final DateTime firstSeen;
  DateTime lastSeen;
  int occurrences;

  /// 首次出现时的播放进度，方便用户回看「卡在哪一段」。
  final Duration? positionAtFirst;
}

/// 播放提示中枢：把 mpv 的日志流收敛成「最多一条、短暂出现、绝不挡操作」的提示。
///
/// 只依赖 Rxn 与纯 Dart，不碰任何 Widget/BuildContext/ScaffoldMessenger ——
/// 画廊里的小播放器要复用同一套逻辑，而 SnackBar 那条老路正是 issue #110 的根因。
class PlayerNoticeCenter {
  PlayerNoticeCenter({
    required String tag,
    required Duration Function() currentPosition,
    required bool Function() isSuppressed,
  }) : _tag = tag,
       _currentPosition = currentPosition,
       _isSuppressed = isSuppressed;

  /// 台账上限。超出后按 LRU 丢弃最久未出现的签名。
  static const int _ledgerCapacity = 50;

  /// 静默级日志的打印节流，避免风暴时刷屏。
  static const Duration _silentLogCooldown = Duration(seconds: 10);

  /// 同一签名两次提示之间的最小间隔。
  static const Duration _signatureCooldown = Duration(seconds: 30);

  /// 升级判定的滑动窗口长度与阈值（窗口内的「不同」签名数）。
  static const Duration _escalationWindow = Duration(seconds: 60);
  static const int _escalationThreshold = 3;

  /// 两次提示之间的硬下限（I4）。没有例外，也没有排队补发。
  static const Duration _emitFloor = Duration(seconds: 2);

  static const Duration _infoDwell = Duration(seconds: 4);
  static const Duration _warningDwell = Duration(seconds: 6);

  final String _tag;
  final Duration Function() _currentPosition;
  final bool Function() _isSuppressed;

  /// 唯一插槽：赋值即替换。不做队列，否则又会退化成 ScaffoldMessenger 的 FIFO 堆积。
  final Rxn<PlayerNotice> notice = Rxn<PlayerNotice>();

  /// 签名 -> 记录，插入顺序即 LRU 顺序（命中时先 remove 再 put 到末尾）。
  final LinkedHashMap<String, PlaybackIssue> _ledger =
      LinkedHashMap<String, PlaybackIssue>();

  final Map<String, DateTime> _silentLoggedAt = <String, DateTime>{};
  final Map<String, DateTime> _noticedAt = <String, DateTime>{};
  final Map<String, DateTime> _window = <String, DateTime>{};

  Timer? _dwellTimer;
  DateTime? _lastEmitAt;
  PlayerNotice? _pending;
  bool _surfaceAvailable = true;
  bool _disposed = false;

  /// 值得摆给用户看的问题，最新的在前；静默级只留在台账里不进这个列表。
  List<PlaybackIssue> get notableIssues => _ledger.values
      .where((issue) => issue.tier != PlaybackErrorTier.silent)
      .toList(growable: false)
      .reversed
      .toList(growable: false);

  /// 消费一条 `player.stream.log`。prefix/level 必须原样传入 ——
  /// media_kit 到 stream.error 时已经把它们丢了，而分类规则全靠 prefix。
  void reportLog({
    required String prefix,
    required String level,
    required String text,
  }) {
    if (_disposed) return;
    final signal = MpvPlaybackErrorClassifier.classifyLog(
      prefix: prefix,
      level: level,
      text: text,
    );
    if (signal == null) return;

    final now = DateTime.now();
    // 先记台账：静默级也要能事后翻出来，LogUtils.d 在生产包里不落盘。
    _touchLedger(signal, now);

    if (signal.tier == PlaybackErrorTier.silent) {
      _logSilent(signal, now);
      return;
    }

    // 未归因的问题不弹提示，只进台账。
    //
    // 分类器有四条路径会产出 unknown（vd 未匹配、file 前缀、cplayer 未匹配，
    // 以及「任何未识别模块」的全局兜底），而这里原本会把它一路兜到
    // videoDecodeProblem，也就是对用户断言「画面可能花屏」——一个我们并没有
    // 确认过的症状。mpv 的 ao/vo/demux/af/vf/cache 等模块只要吐一条 error 级
    // 日志就会命中，于是几乎每个视频都会弹一次这句吓人的提示。
    //
    // 真正能归因的问题（找不到解码器、没有音频设备、网络不通等）不受影响，
    // 照常提示；未归因的原文仍可在「播放问题」详情面板里查到。
    if (signal.kind == PlaybackErrorKind.unknown) {
      _logSilent(signal, now);
      return;
    }

    final lastNoticed = _noticedAt[signal.signature];
    if (lastNoticed != null &&
        now.difference(lastNoticed) < _signatureCooldown) {
      return;
    }
    _noticedAt[signal.signature] = now;

    if (_touchWindow(signal.signature, now)) {
      // 短时间内冒出多种不同问题，逐条报名词只会让人更慌，统一收敛成一条。
      _emit(
        const PlayerNotice(
          kind: PlayerNoticeKind.repeatedProblems,
          level: PlayerNoticeLevel.warning,
        ),
      );
      return;
    }

    _emit(
      PlayerNotice(
        kind: _noticeKindOf(signal.kind),
        level: signal.tier == PlaybackErrorTier.transient
            ? PlayerNoticeLevel.info
            : PlayerNoticeLevel.warning,
        detail: signal.raw,
      ),
    );
  }

  /// 应用层自己发现的问题（没有源、投屏不支持等），不经分类器也不进台账。
  void reportApp(PlayerNoticeKind kind) {
    if (_disposed) return;
    _emit(PlayerNotice(kind: kind, level: _appLevelOf(kind)));
  }

  /// 播放面可见性。折叠成 56px 或进小窗时置 false。
  void setSurfaceAvailable(bool available) {
    if (_disposed || _surfaceAvailable == available) return;
    _surfaceAvailable = available;
    if (!available) return;
    final pending = _pending;
    if (pending == null) return;
    _pending = null;
    // 挂起期间不计时，恢复可见时才开始它的停留时间，否则这条提示等于没出现过。
    _publish(pending);
  }

  /// 播放进度确实往前走了：之前那一串报错已被证明无害，清窗口并收起提示。
  void onPlaybackAdvanced() {
    if (_disposed) return;
    _window.clear();
    _pending = null;
    _dismiss();
  }

  /// 每次 player.open 都要调，避免上一个视频的问题算到下一个头上。
  void reset() {
    if (_disposed) return;
    _ledger.clear();
    _silentLoggedAt.clear();
    _noticedAt.clear();
    _window.clear();
    _pending = null;
    _lastEmitAt = null;
    _dismiss();
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _dwellTimer?.cancel();
    _dwellTimer = null;
    _pending = null;
    notice.value = null;
    notice.close();
  }

  // ---------------------------------------------------------------------------

  void _touchLedger(PlaybackErrorSignal signal, DateTime now) {
    final existing = _ledger.remove(signal.signature);
    if (existing != null) {
      existing.lastSeen = now;
      existing.occurrences += 1;
      // remove + put 把它挪到末尾，末尾即最近使用。
      _ledger[signal.signature] = existing;
      return;
    }

    _ledger[signal.signature] = PlaybackIssue(
      signature: signal.signature,
      kind: signal.kind,
      tier: signal.tier,
      sampleText: signal.raw,
      firstSeen: now,
      lastSeen: now,
      positionAtFirst: _readPosition(),
    );
    while (_ledger.length > _ledgerCapacity) {
      _ledger.remove(_ledger.keys.first);
    }
  }

  void _logSilent(PlaybackErrorSignal signal, DateTime now) {
    final loggedAt = _silentLoggedAt[signal.signature];
    if (loggedAt != null && now.difference(loggedAt) < _silentLogCooldown) {
      return;
    }
    _silentLoggedAt[signal.signature] = now;
    LogUtils.d('忽略无害播放日志[${signal.kind.name}]: ${signal.raw}', _tag);
  }

  /// 维护 60s 滑动窗口，返回窗口内不同签名数是否已达升级阈值。
  bool _touchWindow(String signature, DateTime now) {
    _window.removeWhere(
      (_, seenAt) => now.difference(seenAt) > _escalationWindow,
    );
    _window[signature] = now;
    return _window.length >= _escalationThreshold;
  }

  void _emit(PlayerNotice next) {
    if (_disposed) return;
    // 已销毁或处于画中画时不打扰用户。
    if (_isSuppressed()) return;

    final now = DateTime.now();
    final lastEmitAt = _lastEmitAt;
    if (lastEmitAt != null && now.difference(lastEmitAt) < _emitFloor) return;
    _lastEmitAt = now;

    if (!_surfaceAvailable) {
      // 挂起而不是丢弃，也不启动停留计时。
      _pending = next;
      return;
    }
    _publish(next);
  }

  void _publish(PlayerNotice next) {
    _dwellTimer?.cancel();
    notice.value = next;
    final dwell = next.level == PlayerNoticeLevel.warning
        ? _warningDwell
        : _infoDwell;
    _dwellTimer = Timer(dwell, () {
      _dwellTimer = null;
      if (_disposed) return;
      notice.value = null;
    });
  }

  void _dismiss() {
    _dwellTimer?.cancel();
    _dwellTimer = null;
    notice.value = null;
  }

  Duration? _readPosition() {
    try {
      return _currentPosition();
    } catch (_) {
      // 取进度要碰 player，播放器可能已经被释放，取不到就不记。
      return null;
    }
  }

  PlayerNoticeKind _noticeKindOf(PlaybackErrorKind kind) => switch (kind) {
    PlaybackErrorKind.audioUnavailable => PlayerNoticeKind.audioUnavailable,
    PlaybackErrorKind.hardwareDecodeFallback =>
      PlayerNoticeKind.hardwareDecodeFellBack,
    PlaybackErrorKind.networkUnreachable => PlayerNoticeKind.networkUnstable,
    // cplayer open failures include malformed/unsupported local files; they
    // are load failures, not evidence of a network or decode problem.
    PlaybackErrorKind.openFailed => PlayerNoticeKind.videoLoadFailed,
    // 只有真正归因到「视频解码」的才说解码有问题。
    // unknown 不会走到这里（reportLog 已提前拦掉），静默级同理。
    _ => PlayerNoticeKind.videoDecodeProblem,
  };

  PlayerNoticeLevel _appLevelOf(PlayerNoticeKind kind) => switch (kind) {
    PlayerNoticeKind.networkUnstable ||
    PlayerNoticeKind.hardwareDecodeFellBack => PlayerNoticeLevel.info,
    _ => PlayerNoticeLevel.warning,
  };
}
