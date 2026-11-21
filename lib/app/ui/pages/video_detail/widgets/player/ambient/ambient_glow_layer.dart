import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'ambient_glow_canvas.dart';
import 'ambient_glow_params.dart';

/// 剧院模式背景：环境光（参数见 [ambient_glow_params.dart]）。
///
/// 放在播放器 Stack 的最底层、视频画面之下：视频盖住的地方看不到，露出来的
/// 黑边里就是放大后的模糊画面，像画面的光漫到了画面外面。
///
/// 换帧调度：
/// - 未起播 / 播完：清空（淡回底色）；
/// - 距上次换帧不足最短间隔：不动；
/// - 否则取一帧，交叉淡化过去。
///
/// 取帧方式：把视频那层（[frameBoundaryKey] 指向的 [RepaintBoundary]）离屏渲染成
/// 一张很小的图。
class AmbientGlowLayer extends StatefulWidget {
  const AmbientGlowLayer({
    super.key,
    required this.controller,
    required this.frameBoundaryKey,
    required this.videoAspectRatio,
  });

  final MyVideoStateController controller;

  /// 视频比例（`controller.aspectRatio`）。由调用方在 `Obx` 里读出来传进来。
  final double videoAspectRatio;

  /// 包住视频画面（不含控制层、缩放变换）的 [RepaintBoundary] 的 key。
  final GlobalKey frameBoundaryKey;

  @override
  State<AmbientGlowLayer> createState() => _AmbientGlowLayerState();
}

class _AmbientGlowLayerState extends State<AmbientGlowLayer> {
  /// 轮询几个现成的状态位，而不是订阅：免得在 GetX Rx 上反复订阅 / 退订
  /// （重新订阅后可能永久收不到推值）。250ms 足够及时，开销可以忽略。
  static const Duration _pollInterval = Duration(milliseconds: 250);

  /// 起播后第一帧近乎全黑时，最多重取这么多次（每次隔一个轮询周期）再接受。
  static const int _maxBlackRetries = 20;

  final AmbientGlowCanvas _effect = AmbientGlowCanvas();
  Timer? _poll;

  /// 当前显示的是不是一帧（false = 纯底色）。
  bool _hasFrame = false;

  /// 上次换帧的时间。null = 还没换过（下一次立刻取）。
  DateTime? _lastUpdateTime;

  bool? _lastPlaying;
  bool _sampling = false;
  bool _tickerEnabled = true;
  int _blackRetries = 0;
  bool _warnedAllBlack = false;

  @override
  void initState() {
    super.initState();
    // 一开始还没有帧：前画布填底并淡入。
    _effect.ensureFrameSize(_frameSizeFor(widget.videoAspectRatio));
    _effect.show(null);
    _poll = Timer.periodic(_pollInterval, (_) => _update());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 路由被盖住 / 离屏时不取样。
    _tickerEnabled = TickerMode.valuesOf(context).enabled;
  }

  Size _frameSizeFor(double aspectRatio) {
    final double ar = aspectRatio > 0 ? aspectRatio : 16 / 9;
    return Size(
      (kAmbientFrameHeight * ar).roundToDouble().clamp(1, 4096),
      kAmbientFrameHeight,
    );
  }

  void _clear() {
    // 回到「没有帧」：淡回底色，下次有画面时立刻取。
    _lastUpdateTime = null;
    _blackRetries = 0;
    if (!_hasFrame) return;
    _hasFrame = false;
    _effect.show(null);
  }

  Future<void> _update() async {
    if (!mounted || _sampling || !_tickerEnabled) return;
    // 只在真看不见时停：桌面窗口失焦是 inactive，画面还在播、还看得见。
    final AppLifecycleState? life = WidgetsBinding.instance.lifecycleState;
    if (life == AppLifecycleState.hidden ||
        life == AppLifecycleState.paused ||
        life == AppLifecycleState.detached) {
      return;
    }
    final MyVideoStateController c = widget.controller;

    // 未起播 / 播完 → 清空。
    if (!c.videoPlayerReady.value || c.player.state.completed) {
      _lastPlaying = null;
      _clear();
      return;
    }

    // 暂停：只在进入暂停那一下再取一次（仍受最短间隔限制），之后不再换帧。
    final bool playing = c.videoPlaying.value;
    final bool stateChanged = playing != _lastPlaying;
    _lastPlaying = playing;
    if (!playing && !stateChanged) return;

    final DateTime now = DateTime.now();
    final DateTime? last = _lastUpdateTime;
    if (last != null && now.isBefore(last.add(kAmbientMinUpdateInterval))) {
      return;
    }

    // 画面把播放区整个盖住（16:9 盒放 16:9 片、填充 / 拉伸模式）时背景一点
    // 都露不出来，取帧和淡化都是白做。
    if (!_hasExposedArea()) return;

    _sampling = true;
    try {
      final ui.Image? frame = await _sampleFrame(widget.videoAspectRatio);
      if (frame == null || !mounted) {
        frame?.dispose();
        return;
      }
      // 起播那一刻纹理可能还没送上帧（或片头就是黑场），取到黑帧会让背景黑上
      // 5～10 秒。只对「起播后第一帧」重试；片中真黑场照常显示。
      if (_lastUpdateTime == null && await _isNearlyBlack(frame)) {
        if (_blackRetries < _maxBlackRetries) {
          _blackRetries++;
          frame.dispose();
          return;
        }
        if (!_warnedAllBlack) {
          _warnedAllBlack = true;
          // 一直全黑多半是这个平台的离屏渲染拿不到视频纹理。
          LogUtils.w(
            '环境光：起播后连续 $_maxBlackRetries 次取到全黑帧，'
                '可能取不到视频纹理',
            'AmbientGlowLayer',
          );
        }
      }
      if (!mounted) {
        frame.dispose();
        return;
      }
      _effect.ensureFrameSize(
        Size(frame.width.toDouble(), frame.height.toDouble()),
      );
      _effect.show(frame);
      frame.dispose();
      _hasFrame = true;
      _lastUpdateTime = DateTime.now();
    } finally {
      _sampling = false;
    }
  }

  /// 背景有没有露出来的地方：视频画面（含缩放 / 平移变换）是否盖满本层。
  bool _hasExposedArea() {
    final RenderObject? self = context.findRenderObject();
    final RenderObject? video = widget.frameBoundaryKey.currentContext
        ?.findRenderObject();
    if (self is! RenderBox || !self.hasSize) return false;
    if (video is! RenderBox || !video.hasSize || !video.attached) return true;
    final Rect videoRect = MatrixUtils.transformRect(
      video.getTransformTo(self),
      Offset.zero & video.size,
    ).inflate(0.5);
    final Rect box = Offset.zero & self.size;
    return !(videoRect.contains(box.topLeft) &&
        videoRect.contains(box.bottomRight - const Offset(0.01, 0.01)));
  }

  /// 小图平均亮度是否接近 0（< 2/255）。
  Future<bool> _isNearlyBlack(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) return false;
    int sum = 0;
    final int n = data.lengthInBytes ~/ 4;
    for (int i = 0; i < n; i++) {
      final int o = i * 4;
      sum += data.getUint8(o) + data.getUint8(o + 1) + data.getUint8(o + 2);
    }
    return n == 0 || sum / (n * 3) < 2;
  }

  /// 取一帧，缩到 [kAmbientFrameHeight] 高。
  ///
  /// 先按 4 倍目标尺寸离屏渲染视频层，再用 mipmap 缩下去——直接按目标尺寸渲染
  /// 只会对纹理做一次双线性取点，噪点多，放大后颜色会一跳一跳。
  Future<ui.Image?> _sampleFrame(double aspectRatio) async {
    final RenderObject? ro = widget.frameBoundaryKey.currentContext
        ?.findRenderObject();
    if (ro is! RenderRepaintBoundary || !ro.attached || !ro.hasSize) {
      return null;
    }
    final Size box = ro.size;
    if (box.isEmpty) return null;

    final Size target = _frameSizeFor(aspectRatio);
    ui.Image? big;
    try {
      big = await ro.toImage(
        pixelRatio: (target.height * 4 / box.height).clamp(0.01, 1.0),
      );
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      Canvas(recorder).drawImageRect(
        big,
        Offset.zero & Size(big.width.toDouble(), big.height.toDouble()),
        Offset.zero & target,
        Paint()..filterQuality = FilterQuality.medium,
      );
      final ui.Picture picture = recorder.endRecording();
      final ui.Image small = picture.toImageSync(
        target.width.round(),
        target.height.round(),
      );
      picture.dispose();
      return small;
    } catch (e) {
      LogUtils.w('环境光取帧失败: $e', 'AmbientGlowLayer');
      return null;
    } finally {
      big?.dispose();
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _effect.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: AmbientGlowPainter(
          effect: _effect,
          videoAspectRatio: widget.videoAspectRatio,
        ),
        size: Size.infinite,
      ),
    );
  }
}
