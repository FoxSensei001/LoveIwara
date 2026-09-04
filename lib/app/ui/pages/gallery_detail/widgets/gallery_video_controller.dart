import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/mpv_playback_error_classifier.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// 播放失败的分类。
///
/// ⛔ 这张表存在的理由：改造前那份分类只认 `could not open codec` 一个字符串，
/// 而安卓上图库 webm 真正报的是 `Failed to recognize file format.`，一条也没命中，
/// 于是界面顶着一句「不支持的视频格式，请尝试使用其他视频播放器」——把一个**地址
/// 拿错了**的问题说成了设备解码能力不足，用户照着建议做永远修不好。
enum GalleryVideoErrorKind {
  /// 拿到了字节，但那不是能识别的容器格式。绝大多数情况是**地址不对**
  /// （403/404 页面、图片端点、被中间设备改写），而不是缺解码器。
  unrecognized,

  /// 容器认出来了，缺的是解码器。
  codec,

  /// 压根没连上 / 连上了又断。
  network,

  /// 服务端拒绝。
  forbidden,

  other,
}

/// 一条视频的播放失败详情。
@immutable
class GalleryVideoError {
  const GalleryVideoError({required this.kind, required this.raw});

  final GalleryVideoErrorKind kind;

  /// 播放器给的原文，展开「详细错误信息」时原样显示，便于用户回传。
  final String raw;

  /// 把分类器的归因翻成这张表里的一档。
  ///
  /// 返回 null 表示**这条日志不该变成一张错误页**：要么画面根本没受影响
  /// （没声音、hwdec 回落到软解），要么无法归因（连模块都不认识）——那种时候
  /// 断言一个具体症状比不说更糟。
  static GalleryVideoErrorKind? kindOf(PlaybackErrorKind kind) {
    switch (kind) {
      case PlaybackErrorKind.openFailed:
        // cplayer 走到这里的多是 "Failed to recognize file format."：
        // 拿到了字节但不是能识别的容器，绝大多数是**地址不对**。
        return GalleryVideoErrorKind.unrecognized;
      case PlaybackErrorKind.videoDecodeProblem:
        return GalleryVideoErrorKind.codec;
      case PlaybackErrorKind.networkUnreachable:
      case PlaybackErrorKind.networkReconnect:
        return GalleryVideoErrorKind.network;
      case PlaybackErrorKind.audioUnavailable:
      case PlaybackErrorKind.hardwareDecodeFallback:
      case PlaybackErrorKind.decodeGlitch:
      case PlaybackErrorKind.auxFileSkipped:
      case PlaybackErrorKind.duplicateSummary:
      case PlaybackErrorKind.unknown:
        return null;
    }
  }

  static GalleryVideoError from(String raw) {
    final message = raw.toLowerCase();
    // 顺序有讲究：先认最具体的那几句，`format` 这种词太泛，放最后兜。
    if (message.contains('could not open codec') ||
        message.contains('no decoder')) {
      return GalleryVideoError(kind: GalleryVideoErrorKind.codec, raw: raw);
    }
    if (message.contains('failed to recognize file format') ||
        message.contains('unrecognized') ||
        message.contains('failed to open')) {
      return GalleryVideoError(
        kind: GalleryVideoErrorKind.unrecognized,
        raw: raw,
      );
    }
    if (message.contains('403') || message.contains('forbidden')) {
      return GalleryVideoError(kind: GalleryVideoErrorKind.forbidden, raw: raw);
    }
    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timed out') ||
        message.contains('timeout') ||
        message.contains('resolve host')) {
      return GalleryVideoError(kind: GalleryVideoErrorKind.network, raw: raw);
    }
    return GalleryVideoError(kind: GalleryVideoErrorKind.other, raw: raw);
  }
}

/// 图库大图页里**一条**视频的播放状态。
///
/// # 为什么不复用 `MyVideoStateController`
///
/// 那一只是视频详情页的中枢：全屏接力、画中画、DLNA 投屏、播放队列、评论区滚动、
/// 崩溃诊断快照……图库里一条穿插的短视频一样都用不上，接过来等于把整套重状态拖进
/// 一个只需要「播/停/拖进度/静音」的地方。所以这里只留一层薄壳。
///
/// # 谁持有它
///
/// **不是** [GalleryVideoPlayer] 自己。控件条浮在 `PhotoViewGallery` 之上、
/// 不能被缩放变换带着一起放大，所以它挂在大图页的 `Stack` 里；而画面在页内。
/// 两边要看同一份状态，于是状态上提到大图页，按**文件 id**存一张表
/// （不是下标——切画质会整份换掉列表，按下标存会串页）。
class GalleryVideoController extends ChangeNotifier {
  GalleryVideoController({required this.videoUrl, this.headers}) {
    // ⛔ 订阅只挂一次：[retry] 会再走一遍 [_open]，把 _listen 放进去的话每重试
    // 一次就多一份监听，回调次数翻倍、notifyListeners 跟着翻倍。
    _listen();
    _open();
  }

  final String videoUrl;
  final Map<String, String>? headers;

  late final Player _player = Player();
  late final VideoController videoController = VideoController(_player);

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  bool _disposed = false;

  bool _ready = false;
  bool get ready => _ready;

  bool _buffering = false;

  /// 此刻该不该显示加载动效。
  ///
  /// ⛔ **不只是「还没就绪」**。改造中期只看 [ready]，于是液体球只在一条视频
  /// **第一次**打开时出现过一次；之后中途卡顿、seek 之后重新起缓冲、翻到一条
  /// 已经预建好的视频，界面上都没有任何"正在等"的表达，看上去就是卡死了。
  /// mpv 的 `buffering` 流覆盖的正是这些后续场景。
  bool get loading => _error == null && (!_ready || _buffering);

  GalleryVideoError? _error;
  GalleryVideoError? get error => _error;

  bool _playing = false;
  bool get playing => _playing;

  bool _muted = false;
  bool get muted => _muted;

  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  Duration _buffer = Duration.zero;
  Duration get buffer => _buffer;

  /// 用户正按着进度条拖动时的落点。非空期间界面显示它而不是 [position]，
  /// 否则手指还没松、画面已经跳过去、进度条又被真实位置拽回来，抖得没法用。
  Duration? _scrubTarget;
  Duration? get scrubTarget => _scrubTarget;

  /// 界面上该显示的时间点：拖动中看落点，否则看真实播放位置。
  Duration get displayPosition => _scrubTarget ?? _position;

  double _aspectRatio = 16 / 9;

  /// 画面宽高比，给 [SeekPreview] 算预览窗口用。拿不到时退回 16:9。
  double get aspectRatio => _aspectRatio;

  /// 静音前的音量，取消静音时原样还回去。
  double _volumeBeforeMute = 100;

  Future<void> _open({Duration? resumeAt}) async {
    _armStallWatchdog();
    try {
      await _player.open(Media(videoUrl, httpHeaders: headers));
      // 图库是「翻到哪张看哪张」，不该一进页面就自己响起来。
      await _player.pause();
      if (resumeAt != null && resumeAt > Duration.zero) {
        await _player.seek(resumeAt);
      }
    } catch (e, s) {
      LogUtils.e(
        '图库视频打开失败: $videoUrl',
        tag: 'GalleryVideoController',
        error: e,
        stackTrace: s,
      );
      _setError(GalleryVideoError.from(e.toString()));
    }
  }

  void _listen() {
    void bind<T>(Stream<T> stream, void Function(T value) onData) {
      _subscriptions.add(stream.listen(onData));
    }

    // ⛔ **读 log 而不是 error，而且只在「还没就绪」时才当真。**
    //
    // 两个坑叠在一起，任何一个都会把一条**正在好好播放**的视频换成红色错误卡：
    //
    //   1. mpv 会为一堆无害的事发 error 级日志——正常关连接的
    //      `tcp: ffurl_write returned 0xffffd8ba`（issue #110 那条）、
    //      `Error while decoding frame`、hwdec 阶梯回落、外挂文件打不开。
    //      本项目为此早就有一份 [MpvPlaybackErrorClassifier]，它按 **prefix**
    //      分流（同一句 "Could not open codec." 在 vd 下是画面问题、在 ad 下
    //      只是没声音），而 `stream.error` 到手时 prefix / level 已经被
    //      media_kit 丢掉了，压根分不了。
    //   2. 就算分对了，也不能中途掀桌子：[_setError] 会把 `_ready` 打回 false，
    //      而复位只发生在 `duration` / `width` / `height` 三条流上——它们播放
    //      途中不会再吐值，于是那张错误卡会一直赖着，只能靠用户点重试。
    //
    // 所以：**已经就绪的视频，日志只落日志**。首帧都没解出来的才谈得上"这条
    // 视频放不了"，而那种情况另有 [_armStallWatchdog] 兜底。
    bind(_player.stream.log, (log) {
      final signal = MpvPlaybackErrorClassifier.classifyLog(
        prefix: log.prefix,
        level: log.level,
        text: log.text,
      );
      // null = 非 error/fatal 级别，连记都不用记。
      if (signal == null) return;
      LogUtils.w(
        '图库视频日志[${signal.tier.name}/${signal.kind.name}]: ${log.prefix} ${log.text}',
        'GalleryVideoController',
      );
      if (_disposed || _ready || _error != null) return;
      switch (signal.tier) {
        case PlaybackErrorTier.silent:
          return;
        case PlaybackErrorTier.transient:
          // 短暂问题通常自己会好（重连、首次连接被拒后重试），不该当场糊一张
          // 错误卡；真的一直不好由 [_armStallWatchdog] 兜。
          //
          // ⛔ 唯一的例外是 **403**：mpv 把它记在 ffmpeg/stream 前缀下，分类器
          // 只能看出"网络层出事"而归成 transient，可它不会自己好——Iwara 的播放
          // 地址带时效，403 就是这条链接已经作废了，重试多少次都一样。这种要
          // 立刻说清楚，不然用户面对的是转 20 秒圈之后一句"网络连接问题"。
          if (GalleryVideoError.from(signal.raw).kind !=
              GalleryVideoErrorKind.forbidden) {
            return;
          }
          _setError(
            GalleryVideoError(
              kind: GalleryVideoErrorKind.forbidden,
              raw: signal.raw,
            ),
          );
          return;
        case PlaybackErrorTier.degraded:
          final kind = GalleryVideoError.kindOf(signal.kind);
          if (kind == null) return;
          _setError(GalleryVideoError(kind: kind, raw: signal.raw));
      }
    });
    // ⛔ 就绪判据不能用「buffering 落回 false」：那在**打不开**的时候也会落回
    // false（mpv 放弃了也算不再缓冲），于是错误页背后其实已经被标成「初始化
    // 完成」，退出重进就成了一个空的黑屏播放器。
    //
    // ⛔ 也不能**只**看时长。有些 webm 的头里就没有时长（用户 2026-09-04 报的
    // 那本图库里第 2 个 item 正是如此：黑屏 + 永远转圈，而同一本里第 3 个视频
    // 好好的）。真正说明「容器解开了」的还有一条：**画面尺寸出来了**。两者取
    // 其一即可，而失败的那条路两样都拿不到。
    bind(_player.stream.duration, (value) {
      _duration = value;
      _markReadyIfDecoded();
      _notify();
    });
    bind(_player.stream.buffering, (value) {
      if (_buffering == value) return;
      _buffering = value;
      _notify();
    });
    bind(_player.stream.position, (value) {
      _position = value;
      _notify();
    });
    bind(_player.stream.buffer, (value) {
      _buffer = value;
      _notify();
    });
    bind(_player.stream.playing, (value) {
      _playing = value;
      _notify();
    });
    bind(_player.stream.volume, (value) {
      if (value > 0) _volumeBeforeMute = value;
      final muted = value <= 0;
      if (muted != _muted) {
        _muted = muted;
        _notify();
      }
    });
    bind(_player.stream.width, (_) => _updateAspectRatio());
    bind(_player.stream.height, (_) => _updateAspectRatio());
  }

  void _updateAspectRatio() {
    final width = _player.state.width;
    final height = _player.state.height;
    if (width == null || height == null || width <= 0 || height <= 0) return;
    _markReadyIfDecoded();
    final ratio = width / height;
    if ((ratio - _aspectRatio).abs() < 0.001) return;
    _aspectRatio = ratio;
    _notify();
  }

  /// 容器解开了吗：拿到时长、或拿到画面尺寸，两者取其一。
  void _markReadyIfDecoded() {
    if (_ready) return;
    final hasDuration = _duration > Duration.zero;
    final width = _player.state.width;
    final height = _player.state.height;
    final hasFrame = width != null && height != null && width > 0 && height > 0;
    if (!hasDuration && !hasFrame) return;
    _ready = true;
    _error = null;
    _stallWatchdog?.cancel();
    _stallWatchdog = null;
    _notify();
  }

  /// 打开之后一直没动静的看门狗。
  ///
  /// ⛔ 没有它的话，一条服务端半死不活的视频就是**永远转圈**：既没有错误事件，
  /// 也没有时长和画面，用户面前只有一块黑屏，连"它到底在干嘛"都不知道。到点了
  /// 就把它转成一条能看、能重试、能回传的错误。
  Timer? _stallWatchdog;
  static const Duration _stallTimeout = Duration(seconds: 20);

  void _armStallWatchdog() {
    _stallWatchdog?.cancel();
    _stallWatchdog = Timer(_stallTimeout, () {
      if (_disposed || _ready || _error != null) return;
      _setError(
        GalleryVideoError(
          kind: GalleryVideoErrorKind.network,
          raw:
              'Timed out after ${_stallTimeout.inSeconds}s with no duration and '
              'no video frame. url=$videoUrl',
        ),
      );
    });
  }

  void _setError(GalleryVideoError error) {
    _stallWatchdog?.cancel();
    _stallWatchdog = null;
    _error = error;
    _ready = false;
    _buffering = false;
    _boosting = false;
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  // ---- 外部操作 -------------------------------------------------------------

  void togglePlayPause() {
    if (_error != null) return;
    if (_playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void pause() {
    // 按住加速中被外部暂停（翻页、被别的页面盖住）时，倍速必须一起收——
    // 否则下次播放会莫名其妙地以 2× 起步。
    endBoost();
    if (!_playing) return;
    _player.pause();
  }

  /// 相对当前位置跳一段。够不着的一端直接夹住，不做环绕。
  void seekBy(Duration delta) {
    if (!_ready) return;
    seekTo(_position + delta);
  }

  void seekTo(Duration target) {
    if (!_ready) return;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (_duration > Duration.zero && target > _duration
              ? _duration
              : target);
    _player.seek(clamped);
    // 立刻把界面挪过去，别等 position 流回一帧——按住快进键连点时那一帧的
    // 延迟会读成「按了没反应」。
    _position = clamped;
    _notify();
  }

  /// 进度条拖动中：只更新界面落点，不真的 seek（拖一次 seek 几十回，
  /// 网络视频会被拖成幻灯片）。
  void beginScrub(Duration target) {
    _scrubTarget = target;
    _notify();
  }

  void updateScrub(Duration target) {
    _scrubTarget = target;
    _notify();
  }

  void endScrub() {
    final target = _scrubTarget;
    _scrubTarget = null;
    if (target != null) {
      seekTo(target);
    } else {
      _notify();
    }
  }

  // ---- 长按加速 -------------------------------------------------------------
  //
  // 与主播放器同一条手感：按住画面进入倍速，手指横向拖动调档，松手回 1×。
  // 状态放在这里而不是手势层，是因为倍速指示牌浮在 chrome 上（不能跟着画面缩放），
  // 与发出手势的那一层不在同一棵子树里。

  double _rate = 1.0;
  double get rate => _rate;

  bool _boosting = false;

  /// 此刻是不是正被按住加速。指示牌据此显隐。
  bool get boosting => _boosting;

  void setRate(double value) {
    final clamped = value.clamp(0.1, 4.0);
    if ((clamped - _rate).abs() < 0.001) return;
    _rate = clamped;
    _player.setRate(clamped);
    _notify();
  }

  void beginBoost(double value) {
    if (!_ready) return;
    _boosting = true;
    setRate(value);
    _notify();
  }

  void endBoost() {
    if (!_boosting) return;
    _boosting = false;
    setRate(1.0);
    _notify();
  }

  void toggleMute() {
    if (_muted) {
      _player.setVolume(_volumeBeforeMute <= 0 ? 100 : _volumeBeforeMute);
    } else {
      _player.setVolume(0);
    }
  }

  /// 重试：**不重建播放器实例**，只是让它再打开一次同一个地址。
  ///
  /// 改造前的重试会 `dispose()` 掉 libmpv 再新建一只，而本项目已经有一份
  /// 「播放器 dispose 后几秒原生闪退」的悬案（见 libmpv 野指针那条记录）。
  /// 同一只播放器重新 open 既够用又不碰那条路。
  ///
  /// ⛔ **回到出错前的位置**。中途断流（`Connection closed while receiving
  /// data` 这类）是最常见的失败，看到一半被丢回第 0 秒比报错本身还难受。
  Future<void> retry() async {
    final resumeAt = _position;
    _error = null;
    _ready = false;
    _buffering = true;
    _position = Duration.zero;
    _duration = Duration.zero;
    _notify();
    await _open(resumeAt: resumeAt);
  }

  @override
  void dispose() {
    _disposed = true;
    _stallWatchdog?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _player.dispose();
    super.dispose();
  }
}
