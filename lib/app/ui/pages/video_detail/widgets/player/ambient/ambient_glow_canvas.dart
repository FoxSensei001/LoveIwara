import 'dart:async';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import 'ambient_glow_params.dart';

/// 环境光的画布：前后两块小画布 + 一段分级淡入。
///
/// - 前画布 = 底色铺满，再在四周留边的格子里画一帧（模糊、压暗）；
/// - 换帧时先把「此刻看到的样子」（前画布按当前不透明度叠到后画布上）烤进后画布，
///   再重画前画布，让它从 0 淡到 1——所以任何时候打断都不会跳；
/// - 两块画布都只有 (帧宽 + 30) × (帧高 + 30)，放大是显示时双线性拉伸做的。
///
/// ⛔ 淡化不用 AnimationController：Ticker 在跑就会逐 vsync 调度帧，而交叉淡化
/// 5 秒、换帧间隔也是 5 秒，播放期间它几乎一刻不停——整个应用会被拉到满刷新率
/// 出帧，可真正看得见的变化每秒只有 15 次（淡化的级数）。所以用一个按级距
/// 触发的 [Timer]，只在跳级时通知重绘。
class AmbientGlowCanvas extends ChangeNotifier {
  AmbientGlowCanvas();

  /// 驱动阶梯淡化的定时器；null = 没有淡化在跑。
  Timer? _fadeTimer;
  final Stopwatch _fadeClock = Stopwatch();
  Duration _fadeDuration = Duration.zero;

  /// 这段淡化的级数。
  int _steps = 0;
  double _frontOpacity = 1;

  bool get _isFading => _fadeTimer != null;

  ui.Image? _back;
  ui.Image? _front;

  /// 画布尺寸（像素）。null = 还没有画布。
  Size? _canvasSize;

  bool _disposed = false;

  ui.Image? get backImage => _back;
  ui.Image? get frontImage => _front;
  double get frontOpacity => _frontOpacity;

  /// 用帧尺寸定画布尺寸。尺寸变了两块画布都清空成透明，从底色重新淡入。
  void ensureFrameSize(Size frame) {
    final Size canvas = Size(
      frame.width + 2 * kAmbientCanvasPadding,
      frame.height + 2 * kAmbientCanvasPadding,
    );
    if (_canvasSize == canvas) return;
    _canvasSize = canvas;
    _replaceBack(null);
    _replaceFront(null);
    notifyListeners();
  }

  /// 换上一帧（[frame] 为 null 时淡到纯底色）。
  ///
  /// 本方法不接管 [frame] 的所有权，调用方自己 dispose。
  void show(ui.Image? frame) {
    if (_disposed) return;
    final Size? canvas = _canvasSize;
    if (canvas == null) return;

    // 1. 有动画在跑：停在当前不透明度，按它把前画布叠进后画布；没在跑就整块覆盖。
    final double backAlpha = _isFading ? _frontOpacity : 1.0;
    _stopFade();
    _replaceBack(_composeBack(canvas, backAlpha));

    // 2. 重画前画布：填底 + 画帧。
    _replaceFront(_composeFront(canvas, frame));

    // 3. 有帧走交叉淡化时长，清空走淡出时长；都分级推进。
    final Duration duration = frame != null
        ? kAmbientCrossfadeDuration
        : kAmbientFadeOutDuration;
    _steps = ambientTransitionSteps(duration);
    _fadeDuration = duration;
    _frontOpacity = 0;
    if (_steps <= 0) {
      _frontOpacity = 1;
    } else {
      _fadeClock
        ..reset()
        ..start();
      _fadeTimer = Timer.periodic(
        Duration(microseconds: duration.inMicroseconds ~/ _steps),
        (_) => _onFadeTick(),
      );
    }
    notifyListeners();
  }

  void _onFadeTick() {
    final double t =
        _fadeClock.elapsedMicroseconds / _fadeDuration.inMicroseconds;
    // 分级：floor(t·n)/n，到终点取 1。
    final double stepped = t >= 1 ? 1.0 : (t * _steps).floorToDouble() / _steps;
    if (stepped >= 1) _stopFade();
    if (stepped == _frontOpacity) return;
    _frontOpacity = stepped;
    notifyListeners();
  }

  void _stopFade() {
    _fadeTimer?.cancel();
    _fadeTimer = null;
    _fadeClock.stop();
  }

  ui.Image _composeBack(Size canvas, double frontAlpha) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas c = Canvas(recorder);
    final Rect bounds = Offset.zero & canvas;
    final ui.Image? oldBack = _back;
    if (oldBack != null) {
      c.drawImage(oldBack, Offset.zero, Paint());
    }
    final ui.Image? front = _front;
    if (front != null) {
      c.drawImageRect(
        front,
        Offset.zero & Size(front.width.toDouble(), front.height.toDouble()),
        bounds,
        Paint()..color = Color.fromRGBO(0, 0, 0, frontAlpha),
      );
    }
    return _finish(recorder, canvas);
  }

  ui.Image _composeFront(Size canvas, ui.Image? frame) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas c = Canvas(recorder);
    // 整块填底（不模糊）。
    c.drawRect(
      Offset.zero & canvas,
      Paint()..color = const Color(kAmbientFillColor),
    );
    if (frame != null) {
      // 帧画进四周留边的格子，整层模糊后按 [kAmbientGlowOpacity] 叠到底色上。
      // 模糊时画布外按透明处理（decal），边缘才会柔和地衰减到底色。
      final Rect cell = Rect.fromLTWH(
        kAmbientCanvasPadding,
        kAmbientCanvasPadding,
        canvas.width - 2 * kAmbientCanvasPadding,
        canvas.height - 2 * kAmbientCanvasPadding,
      );
      c.saveLayer(
        Offset.zero & canvas,
        Paint()
          ..color = const Color.fromRGBO(0, 0, 0, kAmbientGlowOpacity)
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: kAmbientBlurSigma,
            sigmaY: kAmbientBlurSigma,
            tileMode: TileMode.decal,
          ),
      );
      c.drawImageRect(
        frame,
        Offset.zero & Size(frame.width.toDouble(), frame.height.toDouble()),
        cell,
        Paint()..filterQuality = FilterQuality.low,
      );
      c.restore();
    }
    return _finish(recorder, canvas);
  }

  ui.Image _finish(ui.PictureRecorder recorder, Size canvas) {
    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = picture.toImageSync(
      canvas.width.round(),
      canvas.height.round(),
    );
    picture.dispose();
    return image;
  }

  void _replaceBack(ui.Image? next) {
    _back?.dispose();
    _back = next;
  }

  void _replaceFront(ui.Image? next) {
    _front?.dispose();
    _front = next;
  }

  @override
  void dispose() {
    _disposed = true;
    _stopFade();
    _replaceBack(null);
    _replaceFront(null);
    super.dispose();
  }
}

/// 显示两块画布：先算出视频在盒子里 contain 后的矩形，以中心放大
/// [kAmbientScaleX] × [kAmbientScaleY]，两块画布双线性拉伸进去，超出盒子的部分裁掉。
class AmbientGlowPainter extends CustomPainter {
  AmbientGlowPainter({required this.effect, required this.videoAspectRatio})
    : super(repaint: effect);

  final AmbientGlowCanvas effect;
  final double videoAspectRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final ui.Image? back = effect.backImage;
    final ui.Image? front = effect.frontImage;
    if (back == null && front == null) return;
    if (size.isEmpty || !(videoAspectRatio > 0)) return;

    double w = size.height * videoAspectRatio;
    double h = size.height;
    if (w > size.width) {
      w = size.width;
      h = w / videoAspectRatio;
    }
    final Offset center = size.center(Offset.zero);
    final Rect dst = Rect.fromCenter(
      center: center,
      width: w * kAmbientScaleX,
      height: h * kAmbientScaleY,
    );

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (back != null) {
      canvas.drawImageRect(
        back,
        Offset.zero & Size(back.width.toDouble(), back.height.toDouble()),
        dst,
        Paint()..filterQuality = FilterQuality.low,
      );
    }
    final double opacity = effect.frontOpacity;
    if (front != null && opacity > 0) {
      canvas.drawImageRect(
        front,
        Offset.zero & Size(front.width.toDouble(), front.height.toDouble()),
        dst,
        Paint()
          ..filterQuality = FilterQuality.low
          ..color = Color.fromRGBO(0, 0, 0, opacity),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(AmbientGlowPainter oldDelegate) =>
      oldDelegate.effect != effect ||
      oldDelegate.videoAspectRatio != videoAspectRatio;
}
