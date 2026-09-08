import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../../i18n/strings.g.dart' as slang;
import 'quest_gesture_guide_content.dart';

/// One storyboard, in logical illustration coordinates. Separating the screen
/// transform from the picture transform is intentional: they are different
/// operations in the native gallery, and the demonstration must teach that.
@immutable
class QuestGestureFrame {
  const QuestGestureFrame(this.visual, this.seconds);

  final QuestGestureVisual visual;
  final double seconds;

  double get duration => switch (visual) {
    QuestGestureVisual.slideshow => 10.4,
    QuestGestureVisual.navigation => 10.8,
    QuestGestureVisual.galleryPan => 8.4,
    _ => 5.6,
  };

  double get phase => math.max(0, seconds) % duration / duration;
  bool get isTap => switch (visual) {
    QuestGestureVisual.galleryPan => phase > .65,
    QuestGestureVisual.select ||
    QuestGestureVisual.togglePanel ||
    QuestGestureVisual.playPause ||
    QuestGestureVisual.galleryStick ||
    QuestGestureVisual.slideshow ||
    QuestGestureVisual.navigation ||
    QuestGestureVisual.hands => true,
    _ => false,
  };
  bool get held => switch (visual) {
    QuestGestureVisual.togglePanel => phase >= .35 && phase < .4,
    QuestGestureVisual.slideshow => phase >= .075 && phase < .105,
    QuestGestureVisual.navigation =>
      (phase >= .15 && phase < .18) ||
          (phase >= .32 && phase < .35) ||
          (phase >= .49 && phase < .52) ||
          (phase >= .69 && phase < .72),
    QuestGestureVisual.galleryPan =>
      (phase >= .18 && phase < .58) ||
          (phase >= .67 && phase < .69) ||
          (phase >= .73 && phase < .75),
    _ => isTap ? phase >= .21 && phase < .27 : phase >= .18 && phase < .72,
  };
  bool get released => phase >= .72 && phase < .94;
  double get travel => _ease(
    _segment(phase, .30, visual == QuestGestureVisual.galleryPan ? .58 : .65),
  );
  double get movement => travel * (1 - _ease(_segment(phase, .91, 1)));

  int get seekDeltaSeconds =>
      visual == QuestGestureVisual.seek && phase >= .18 && phase < .94
      ? 10 + (travel * 74).round()
      : 0;

  static double _segment(double value, double from, double to) =>
      ((value - from) / (to - from)).clamp(0.0, 1.0);
  static double _ease(double value) => Curves.easeInOutCubic.transform(value);

  double get screenScale => switch (visual) {
    QuestGestureVisual.scale || QuestGestureVisual.resize => 1 + movement * .22,
    QuestGestureVisual.distance => 2 / (2 + movement * 1.2),
    _ => 1,
  };

  Offset get screenOffset => visual == QuestGestureVisual.move
      ? Offset(movement * 42, movement * -20)
      : Offset.zero;

  Rect get screen => Rect.fromCenter(
    center: const Offset(360, 151.5) + screenOffset,
    width: 400 * screenScale,
    height: 225 * screenScale,
  );

  double get imageScale => switch (visual) {
    QuestGestureVisual.galleryZoom => 1 + movement * 1.5,
    QuestGestureVisual.galleryPan => phase < .76 ? 2.5 : 1,
    _ => 1,
  };

  Offset get imageOffset => switch (visual) {
    QuestGestureVisual.galleryZoom => const Offset(12, -20) * (1 - imageScale),
    QuestGestureVisual.galleryPan when phase < .76 => Offset(
      -movement * 68,
      movement * 12,
    ),
    _ => Offset.zero,
  };

  int get galleryIndex => switch (visual) {
    // A native swipe changes the item on release, not while dragging.
    QuestGestureVisual.gallerySwipe => released ? 2 : 1,
    QuestGestureVisual.galleryStick => phase >= .26 && phase < .94 ? 2 : 1,
    QuestGestureVisual.slideshow => seconds % duration >= 6.1 ? 2 : 1,
    _ => 1,
  };

  /// Match GalleryStageView's 220ms crossfade, while the stage itself stays put.
  double get galleryBlend {
    if (galleryIndex == 1) return 0;
    final changedAt = switch (visual) {
      QuestGestureVisual.gallerySwipe => duration * .72,
      QuestGestureVisual.galleryStick => duration * .26,
      QuestGestureVisual.slideshow => 6.1,
      _ => 0.0,
    };
    return ((seconds % duration - changedAt) / .22).clamp(0.0, 1.0);
  }

  bool get sideView =>
      visual == QuestGestureVisual.move || visual == QuestGestureVisual.scale;

  Rect controllerRect({required bool left}) {
    final spread = visual == QuestGestureVisual.scale ? movement * 36 : 0.0;
    final shift = visual == QuestGestureVisual.move && !left
        ? Offset(movement * 42, movement * -20)
        : Offset.zero;
    final width = sideView ? 166.0 : 118.0;
    final height = sideView ? 177.0 : 207.0;
    return Rect.fromLTWH(
      (left ? 144 - width / 2 - spread : 576 - width / 2 + spread) + shift.dx,
      (sideView ? 274 : 246) + shift.dy,
      width,
      height,
    );
  }

  bool get showPanel => switch (visual) {
    QuestGestureVisual.togglePanel => phase < .4 || phase >= .94,
    QuestGestureVisual.move => !released,
    QuestGestureVisual.scale || QuestGestureVisual.resize => false,
    QuestGestureVisual.navigation => phase < .52 || phase >= .94,
    _ => true,
  };

  bool get showApp =>
      visual == QuestGestureVisual.navigation && phase >= .72 && phase < .94;
}

/// A 2D explanation of native spatial input; this widget never sends XR input.
/// Controller photos are cropped from the user-supplied Touch Plus references.
/// The two handed assets stay separate so X/Y and A/B never get mirrored.
class AnimatedQuestGestureIllustration extends StatelessWidget {
  const AnimatedQuestGestureIllustration({
    super.key,
    required this.visual,
    required this.media,
    required this.clock,
    this.startedAt = 0,
    this.pausedAt,
  });

  final QuestGestureVisual visual;
  final QuestGuideMedia media;
  final ValueListenable<double> clock;
  final double startedAt;
  final double? pausedAt;

  @override
  Widget build(BuildContext context) {
    final q = slang.Translations.of(context).videoDetail.gestureGuide.quest;
    final cs = Theme.of(context).colorScheme;
    final accent = Color.lerp(cs.primary, Colors.white, .5)!;
    final reduced = MediaQuery.disableAnimationsOf(context);

    Widget scene(double seconds) {
      final frame = QuestGestureFrame(visual, seconds);
      final actedAt = switch (visual) {
        QuestGestureVisual.navigation => .18,
        QuestGestureVisual.togglePanel => .4,
        QuestGestureVisual.slideshow => .105,
        _ => frame.isTap ? .27 : .72,
      };
      final phaseLabel = frame.held
          ? (visual == QuestGestureVisual.hands
                ? q.pinch
                : frame.isTap
                ? q.press
                : q.hold)
          : frame.phase >= actedAt && frame.phase < .94
          ? q.result
          : q.ready;
      String controllerLabel(bool left) {
        final hand = left ? q.leftController : q.rightController;
        final button = switch (visual) {
          QuestGestureVisual.playPause ||
          QuestGestureVisual.slideshow => left ? 'X' : 'A',
          QuestGestureVisual.move when !left => q.grip,
          QuestGestureVisual.scale => q.grip,
          QuestGestureVisual.seek ||
          QuestGestureVisual.galleryStick ||
          QuestGestureVisual.distance => q.stick,
          QuestGestureVisual.navigation =>
            frame.phase < .28 || frame.phase >= .94
                ? (left ? 'Menu' : null)
                : (left ? 'Y' : 'B'),
          QuestGestureVisual.select ||
          QuestGestureVisual.togglePanel ||
          QuestGestureVisual.gallerySwipe ||
          QuestGestureVisual.galleryZoom ||
          QuestGestureVisual.galleryPan ||
          QuestGestureVisual.resize when !left => q.trigger,
          _ => null,
        };
        return button == null ? hand : '$hand · $button';
      }

      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ColoredBox(
            color: _ScenePainter.background,
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: FittedBox(
                child: SizedBox(
                  width: 720,
                  height: 480,
                  child: ExcludeSemantics(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ScenePainter(frame, media, accent),
                          ),
                        ),
                        if (visual != QuestGestureVisual.hands)
                          for (final left in [true, false])
                            Positioned.fromRect(
                              rect: frame.controllerRect(left: left),
                              child: Image.asset(
                                'assets/images/quest/quest_controller_${left ? 'left' : 'right'}${frame.sideView ? '_grip' : ''}.png',
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                                gaplessPlayback: true,
                              ),
                            ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _InputPainter(frame, accent),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          top: 18,
                          child: Text(
                            media == QuestGuideMedia.video
                                ? q.videoTab
                                : q.galleryTab,
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                              color: _ScenePainter.muted,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        for (final left in [true, false])
                          Positioned(
                            left:
                                (visual == QuestGestureVisual.hands
                                    ? (left ? 106.0 : 604.0)
                                    : frame
                                          .controllerRect(left: left)
                                          .center
                                          .dx) -
                                108,
                            top: 454,
                            width: 216,
                            child: Text(
                              controllerLabel(left),
                              textScaler: TextScaler.noScaling,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _ScenePainter.muted,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        Positioned(
                          left: 230,
                          right: 230,
                          bottom: 36,
                          child: Text(
                            phaseLabel,
                            textScaler: TextScaler.noScaling,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: frame.held ? accent : _ScenePainter.muted,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // No listener or continuous repaint when motion is disabled or paused.
    if (reduced) return scene(QuestGestureFrame(visual, 0).duration * .58);
    if (pausedAt != null) return scene(pausedAt!);
    return ValueListenableBuilder<double>(
      valueListenable: clock,
      builder: (context, time, _) => scene(math.max(0, time - startedAt)),
    );
  }
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter(this.frame, this.media, this.accent);

  final QuestGestureFrame frame;
  final QuestGuideMedia media;
  final Color accent;

  static const background = Color(0xFF171D26);
  static const muted = Color(0xFFB4BFCC);
  static const panel = Color(0xFF26303D);
  static const ink = Color(0xFFE7ECF2);

  @override
  void paint(Canvas canvas, Size size) {
    // A subdued horizon provides depth cues without pretending to be a VR view.
    final grid = Paint()
      ..color = ink.withValues(alpha: .045)
      ..strokeWidth = 1;
    for (var i = -3; i <= 3; i++) {
      canvas.drawLine(
        Offset(360 + i * 52, 290),
        Offset(360 + i * 185, 480),
        grid,
      );
    }
    for (final y in [314.0, 346.0, 399.0, 474.0]) {
      canvas.drawLine(Offset(0, y), Offset(720, y), grid);
    }

    final screen = frame.screen;
    final shape = RRect.fromRectAndRadius(screen, const Radius.circular(2));
    canvas.drawShadow(
      Path()..addRRect(shape),
      Colors.black.withValues(alpha: .5),
      14,
      false,
    );
    canvas.drawRRect(shape, Paint()..color = const Color(0xFF10151C));
    canvas.save();
    canvas.clipRRect(shape);
    if (frame.showApp) {
      _appWindow(canvas, screen);
    } else {
      canvas.translate(screen.center.dx, screen.center.dy);
      canvas.translate(frame.imageOffset.dx, frame.imageOffset.dy);
      canvas.scale(frame.imageScale);
      canvas.translate(-screen.center.dx, -screen.center.dy);
      final imageRect = media == QuestGuideMedia.gallery
          ? Rect.fromCenter(
              center: screen.center,
              width: screen.height * .78,
              height: screen.height,
            )
          : screen;
      final blend = frame.galleryBlend;
      if (blend == 0 || blend == 1) {
        _landscape(canvas, imageRect, frame.galleryIndex);
      } else {
        _landscape(canvas, imageRect, 1);
        canvas.saveLayer(
          imageRect,
          Paint()..color = Colors.white.withValues(alpha: blend),
        );
        _landscape(canvas, imageRect, 2);
        canvas.restore();
      }
    }
    canvas.restore();
    canvas.drawRRect(
      shape,
      Paint()
        ..color = ink.withValues(alpha: .25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (frame.visual == QuestGestureVisual.resize) {
      _corners(canvas, screen.inflate(7));
    }
    if (frame.showPanel) _panel(canvas);
    if (frame.visual == QuestGestureVisual.seek &&
        (frame.held || frame.released)) {
      final delta = frame.seekDeltaSeconds;
      _pill(
        canvas,
        screen.center,
        '${_time(42 + delta)}  +${_time(delta)}',
        icon: Icons.fast_forward_rounded,
        width: 202,
      );
      _progress(
        canvas,
        Rect.fromLTWH(
          screen.left + 36,
          screen.bottom - 23,
          screen.width - 72,
          4,
        ),
        (42 + delta) / 200,
      );
    }
    if (frame.visual == QuestGestureVisual.gallerySwipe && frame.held) {
      _pill(
        canvas,
        screen.center,
        '03 / 06',
        icon: Icons.arrow_forward_rounded,
      );
      _progress(
        canvas,
        Rect.fromLTWH(screen.center.dx - 52, screen.center.dy + 28, 104, 3),
        frame.travel,
      );
    }
    if (frame.visual == QuestGestureVisual.galleryZoom ||
        frame.visual == QuestGestureVisual.galleryPan) {
      _pill(
        canvas,
        Offset(screen.center.dx, screen.bottom - 26),
        '${frame.imageScale.toStringAsFixed(1)}×',
      );
    }
    if (frame.visual == QuestGestureVisual.distance) {
      _pill(
        canvas,
        const Offset(360, 362),
        '${(2 + frame.movement * 1.2).toStringAsFixed(1)} m',
      );
    }
    if (frame.visual == QuestGestureVisual.scale && frame.held) {
      _arrow(
        canvas,
        const Offset(322, 362),
        Offset(285 - frame.movement * 24, 362),
        accent,
      );
      _arrow(
        canvas,
        const Offset(398, 362),
        Offset(435 + frame.movement * 24, 362),
        accent,
      );
    }
  }

  void _landscape(Canvas canvas, Rect r, int index) {
    canvas.save();
    canvas.clipRect(r);
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF829CA8), Color(0xFFE0D4B7)],
        ).createShader(r),
    );
    final shift = index == 2 ? .18 : 0.0;
    canvas.drawCircle(
      Offset(r.left + r.width * (.72 - shift), r.top + r.height * .29),
      r.height * .11,
      Paint()..color = const Color(0xFFF3DFB9),
    );
    for (var layer = 0; layer < 3; layer++) {
      final path = Path()..moveTo(r.left, r.bottom);
      for (var i = 0; i <= 8; i++) {
        final x = r.left + r.width * i / 8;
        final y =
            r.top +
            r.height *
                (.48 +
                    layer * .15 +
                    math.sin(i * 1.3 + layer * 1.5 + shift * 8) * .10);
        if (i == 0) {
          path.lineTo(x, y);
        } else {
          final previousX = r.left + r.width * (i - 1) / 8;
          path.quadraticBezierTo(
            previousX + r.width / 16,
            y - r.height * .035,
            x,
            y,
          );
        }
      }
      path.lineTo(r.right, r.bottom);
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = const [
            Color(0xFF74887F),
            Color(0xFF486B62),
            Color(0xFF284E49),
          ][layer],
      );
    }
    // A few fine trunks make changes in image scale and pan easy to follow.
    for (var i = 0; i < 5; i++) {
      final x = r.left + r.width * (.12 + i * .08);
      final y = r.top + r.height * (.67 + (i % 2) * .035);
      final height = r.height * (.14 + (i % 3) * .024);
      final tree = Path()
        ..moveTo(x, y - height)
        ..lineTo(x - height * .26, y)
        ..lineTo(x + height * .26, y)
        ..close();
      canvas.drawPath(tree, Paint()..color = const Color(0xFF23413E));
    }
    canvas.restore();
  }

  void _panel(Canvas canvas) {
    const rect = Rect.fromLTWH(230, 286, 260, 64);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      Paint()..color = panel,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      Paint()
        ..color = ink.withValues(alpha: .13)
        ..style = PaintingStyle.stroke,
    );
    if (frame.visual == QuestGestureVisual.navigation &&
        frame.phase >= .18 &&
        frame.phase < .35) {
      _icon(canvas, Icons.settings_outlined, const Offset(260, 318), ink, 24);
      for (var i = 0; i < 3; i++) {
        final y = 302.0 + i * 16;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(288, y, 118, 4),
            const Radius.circular(2),
          ),
          Paint()..color = muted.withValues(alpha: .3),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(440, y - 2, 24, 10),
            const Radius.circular(5),
          ),
          Paint()..color = i == 1 ? accent : muted.withValues(alpha: .3),
        );
      }
      return;
    }
    if (media == QuestGuideMedia.gallery) {
      for (var i = 0; i < 5; i++) {
        final item = Rect.fromLTWH(244.0 + i * 40, 299, 33, 34);
        canvas.save();
        canvas.clipRRect(
          RRect.fromRectAndRadius(item, const Radius.circular(3)),
        );
        _landscape(canvas, item, i.isEven ? 1 : 2);
        canvas.restore();
        if (i == frame.galleryIndex) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(item.inflate(2), const Radius.circular(5)),
            Paint()
              ..color = accent
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
      final playing =
          frame.visual == QuestGestureVisual.slideshow && frame.phase >= .1;
      _icon(
        canvas,
        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
        const Offset(463, 315),
        ink,
        23,
      );
      if (frame.visual == QuestGestureVisual.slideshow) {
        _text(canvas, '5 s', const Offset(463, 339), muted, 10);
      }
    } else {
      final playing =
          frame.visual != QuestGestureVisual.playPause || frame.phase < .27;
      _icon(
        canvas,
        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
        const Offset(256, 319),
        ink,
        22,
      );
      final progress = (42 + frame.seekDeltaSeconds) / 200;
      _progress(canvas, const Rect.fromLTWH(283, 311, 135, 4), progress);
      _text(
        canvas,
        '${_time(42 + frame.seekDeltaSeconds)} / 03:20',
        const Offset(350, 332),
        muted,
        11,
      );
      _icon(canvas, Icons.volume_up_outlined, const Offset(440, 316), ink, 18);
      _icon(canvas, Icons.settings_outlined, const Offset(471, 316), ink, 18);
    }
  }

  void _appWindow(Canvas canvas, Rect rect) {
    canvas.drawRect(rect, Paint()..color = panel);
    _text(
      canvas,
      '2i',
      Offset(rect.left + 26, rect.top + 25),
      accent,
      22,
      weight: FontWeight.w700,
    );
    for (var i = 0; i < 6; i++) {
      final tile = Rect.fromLTWH(
        rect.left + 20 + (i % 3) * 122,
        rect.top + 50 + (i ~/ 3) * 78,
        110,
        62,
      );
      _landscape(canvas, tile, i % 2 + 1);
    }
  }

  void _corners(Canvas canvas, Rect r) {
    final paint = Paint()
      ..color = accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final corner in [r.topLeft, r.topRight, r.bottomLeft, r.bottomRight]) {
      final sx = corner.dx < r.center.dx ? 1.0 : -1.0;
      final sy = corner.dy < r.center.dy ? 1.0 : -1.0;
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx + sx * 15, corner.dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx, corner.dy + sy * 15),
        paint,
      );
    }
  }

  void _pill(
    Canvas canvas,
    Offset center,
    String text, {
    IconData? icon,
    double? width,
  }) {
    width ??= icon == null ? 98.0 : 134.0;
    final rect = Rect.fromCenter(center: center, width: width, height: 36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()..color = background.withValues(alpha: .92),
    );
    if (icon != null) {
      _icon(canvas, icon, Offset(rect.left + 21, center.dy), accent, 19);
    }
    _text(
      canvas,
      text,
      center + Offset(icon == null ? 0 : 12, 0),
      ink,
      16,
      weight: FontWeight.w600,
    );
  }

  void _progress(Canvas canvas, Rect rect, double progress) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = muted.withValues(alpha: .28),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rect.left,
          rect.top,
          rect.width * progress.clamp(0, 1),
          rect.height,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = accent,
    );
  }

  static String _time(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) =>
      oldDelegate.frame != frame ||
      oldDelegate.media != media ||
      oldDelegate.accent != accent;
}

class _InputPainter extends CustomPainter {
  const _InputPainter(this.frame, this.accent);
  final QuestGestureFrame frame;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final visual = frame.visual;
    if (visual == QuestGestureVisual.hands) {
      _hand(canvas, const Offset(106, 352), left: true, pinch: 0);
      _hand(
        canvas,
        const Offset(604, 352),
        left: false,
        pinch: frame.held ? 1 : 0,
      );
      _ray(canvas, const Offset(590, 332), const Offset(463, 317));
      return;
    }
    final left = frame.controllerRect(left: true);
    final right = frame.controllerRect(left: false);
    final active = frame.held || frame.released;
    final glow = frame.held ? 1.0 : .65;

    switch (visual) {
      case QuestGestureVisual.playPause:
      case QuestGestureVisual.slideshow:
        _ring(canvas, _point(left, .496, .328), 10, glow);
        _ring(canvas, _point(right, .509, .328), 10, glow);
        break;
      case QuestGestureVisual.seek:
      case QuestGestureVisual.galleryStick:
        for (final (rect, x) in [(left, .304), (right, .705)]) {
          final p = _point(rect, x, .206);
          _ring(canvas, p, 14, glow);
          _arrow(
            canvas,
            p + const Offset(-25, -29),
            p + const Offset(25, -29),
            accent,
          );
          _arrow(
            canvas,
            p + const Offset(25, -29),
            p + const Offset(-25, -29),
            accent,
          );
        }
        break;
      case QuestGestureVisual.distance:
      case QuestGestureVisual.galleryZoom:
        final p = _point(right, .705, .206);
        _ring(canvas, p, 14, glow);
        _arrow(
          canvas,
          p + const Offset(30, 20),
          p + const Offset(30, -24),
          accent,
        );
        if (visual == QuestGestureVisual.galleryZoom) {
          _trigger(canvas, right, glow);
          _ray(
            canvas,
            right.topCenter,
            frame.screen.center + const Offset(12, -20),
          );
        }
        break;
      case QuestGestureVisual.move:
      case QuestGestureVisual.scale:
        _ring(canvas, _point(right, .48, .51), 17, glow);
        if (visual == QuestGestureVisual.scale) {
          _ring(canvas, _point(left, .53, .51), 17, glow);
        }
        if (visual == QuestGestureVisual.move && active) {
          _arrow(
            canvas,
            const Offset(614, 258),
            const Offset(646, 236),
            accent,
          );
        }
        break;
      case QuestGestureVisual.navigation:
        if (frame.phase < .28 || frame.phase >= .94) {
          _ring(canvas, _point(left, .277, .361), 9, glow);
        } else {
          _ring(canvas, _point(left, .634, .219), 10, glow);
          _ring(canvas, _point(right, .388, .219), 10, glow);
        }
        break;
      case QuestGestureVisual.select:
      case QuestGestureVisual.togglePanel:
      case QuestGestureVisual.gallerySwipe:
      case QuestGestureVisual.galleryPan:
      case QuestGestureVisual.resize:
        _trigger(canvas, right, glow);
        final target = switch (visual) {
          QuestGestureVisual.togglePanel => const Offset(559, 222),
          QuestGestureVisual.gallerySwipe => Offset(
            450 - frame.travel * 175,
            157,
          ),
          QuestGestureVisual.galleryPan => Offset(
            425 - frame.travel * 100,
            150 + frame.travel * 16,
          ),
          QuestGestureVisual.resize =>
            frame.screen.bottomRight + const Offset(6, 6),
          _ => const Offset(471, 316),
        };
        _ray(canvas, right.topCenter, target);
        if (visual == QuestGestureVisual.galleryPan &&
            frame.phase > .67 &&
            frame.phase < .79) {
          _ring(canvas, target, 17 + (frame.phase * 60 % 1) * 13, .8);
        }
        break;
      case QuestGestureVisual.hands:
        break;
    }
  }

  Offset _point(Rect rect, double x, double y) =>
      Offset(rect.left + rect.width * x, rect.top + rect.height * y);

  void _ring(Canvas canvas, Offset p, double radius, double strength) {
    canvas.drawCircle(
      p,
      radius + 7,
      Paint()..color = accent.withValues(alpha: .09 * strength),
    );
    canvas.drawCircle(
      p,
      radius,
      Paint()..color = accent.withValues(alpha: .18 * strength),
    );
    canvas.drawCircle(
      p,
      radius,
      Paint()
        ..color = accent.withValues(alpha: strength)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _trigger(Canvas canvas, Rect rect, double strength) {
    // The index trigger is behind the face plate, not the visible grip button.
    // An offset outline / leader denotes that hidden control rather than
    // painting over a face button and teaching the wrong physical location.
    final back = Offset(rect.left - 10, rect.top + 50);
    canvas.drawArc(
      Rect.fromCenter(
        center: rect.topCenter + const Offset(0, 46),
        width: rect.width + 16,
        height: 104,
      ),
      2.7,
      .9,
      false,
      Paint()
        ..color = accent.withValues(alpha: strength)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      back,
      back + const Offset(-18, -12),
      Paint()
        ..color = accent
        ..strokeWidth = 1.5,
    );
    _icon(
      canvas,
      Icons.touch_app_outlined,
      back + const Offset(-26, -22),
      accent,
      21,
    );
  }

  void _ray(Canvas canvas, Offset from, Offset to) {
    final ray = Paint()
      ..shader = LinearGradient(
        colors: [accent.withValues(alpha: .12), accent.withValues(alpha: .85)],
      ).createShader(Rect.fromPoints(from, to).inflate(1))
      ..strokeWidth = 1.6;
    canvas.drawLine(from, to, ray);
    _ring(canvas, to, frame.held ? 10 : 7, frame.held ? 1 : .6);
    canvas.drawCircle(to, 3, Paint()..color = Colors.white);
  }

  void _hand(
    Canvas canvas,
    Offset origin, {
    required bool left,
    required double pinch,
  }) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(left ? -1.1 : 1.1, 1.1);
    canvas.rotate(left ? -.2 : .2);
    final hand = Path()
      ..moveTo(-24, 87)
      ..cubicTo(-25, 69, -41, 48, -43, 29)
      ..cubicTo(-45, 15, -39, 7, -32, 12)
      ..lineTo(-20, 29)
      ..cubicTo(-23, 11, -33, -7, -26, -17)
      ..cubicTo(-21, -24, -14, -19, -10, -10)
      ..lineTo(0, 14)
      ..cubicTo(5, 6, 15, 7, 20, 15)
      ..cubicTo(29, 10, 38, 20, 38, 32)
      ..cubicTo(48, 36, 42, 52, 37, 65)
      ..lineTo(30, 87)
      ..close();
    canvas.drawShadow(hand, Colors.black.withValues(alpha: .4), 5, false);
    canvas.drawPath(
      hand,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFBAAC9C), Color(0xFFE4D6C4)],
        ).createShader(const Rect.fromLTWH(-45, -25, 90, 115)),
    );
    final finger = Path()
      ..moveTo(-22, 30)
      ..cubicTo(-31, 4, -27, -34, -12, -40 + pinch * 16)
      ..cubicTo(1, -44 + pinch * 22, 11, -27 + pinch * 10, 2, -18 + pinch * 5)
      ..cubicTo(-8, -25 + pinch * 22, -7, -3, -4, 10);
    canvas.drawPath(
      finger,
      Paint()
        ..color = const Color(0xFFDCCBB5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    final thumb = Path()
      ..moveTo(31, 48)
      ..cubicTo(33, 25, 23, 8, 4, -2 - pinch * 8);
    canvas.drawPath(
      thumb,
      Paint()
        ..color = const Color(0xFFE6D6C0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 17
        ..strokeCap = StrokeCap.round,
    );
    if (pinch > 0) _ring(canvas, const Offset(1, -10), 12, .9);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InputPainter oldDelegate) =>
      oldDelegate.frame != frame || oldDelegate.accent != accent;
}

void _text(
  Canvas canvas,
  String text,
  Offset center,
  Color color,
  double size, {
  FontWeight weight = FontWeight.w400,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontFamilyFallback: const ['Arial'],
        fontSize: size,
        fontWeight: weight,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  painter.dispose();
}

void _icon(
  Canvas canvas,
  IconData icon,
  Offset center,
  Color color,
  double size,
) {
  final painter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        color: color,
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  painter.dispose();
}

void _arrow(Canvas canvas, Offset from, Offset to, Color color) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(from, to, paint);
  final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
  for (final delta in [-.65, .65]) {
    canvas.drawLine(
      to,
      to - Offset(math.cos(angle + delta), math.sin(angle + delta)) * 8,
      paint,
    );
  }
}
