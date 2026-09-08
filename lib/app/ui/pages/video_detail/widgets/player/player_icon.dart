import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Player symbols, drawn on a 24 pt grid with rounded terminals and solid
/// transport controls. Keep these independent of platform fonts so the same
/// silhouettes are available on every platform supported by the player.
///
/// [PlayerQualityIcon] outgrew the player: the download picker and the video
/// info menu show the same badge, so quality reads identically wherever it is
/// offered.
enum PlayerSymbol {
  play,
  pause,
  next,
  back,
  chevronLeft,
  chevronRight,
  close,
  home,
  more,
  cast,
  castConnected,
  pictureInPicture,
  externalPlayer,
  fullscreen,
  exitFullscreen,
  windowFullscreen,
  exitWindowFullscreen,
  theater,
  vr,
  enhance,
  volumeOff,
  volumeLow,
  volumeHigh,
  sunLow,
  sun,
  sunrise,
  moon,
  speed,
  lock,
  lockOpen,
  history,
  retry,
  zoomIn,
  zoomOut,
  error,
  info,
  warning,
  chip,
  videoOff,
  wifi,
  wifiOff,
  cellular,
  ethernet,
}

class PlayerIcon extends StatelessWidget {
  const PlayerIcon(
    this.symbol, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  final PlayerSymbol symbol;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? IconTheme.of(context).size ?? 24;
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: dimension,
          // A button can impose a larger tight box. The inner box preserves
          // the requested glyph size while still shrinking in compact HUDs.
          child: Center(
            child: SizedBox.square(
              dimension: dimension,
              child: CustomPaint(
                painter: _PlayerSymbolPainter(
                  symbol,
                  _foreground(context, color),
                  mirror: symbol == PlayerSymbol.back &&
                      Directionality.maybeOf(context) == TextDirection.rtl,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A compact quality badge. The source label remains in the resolution menu;
/// this badge only supplies its short, language-independent identifier.
class PlayerQualityIcon extends StatelessWidget {
  const PlayerQualityIcon({
    super.key,
    required this.quality,
    this.size = 24,
    this.color,
  });

  final String? quality;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = _foreground(context, color);
    final label = switch (quality?.toLowerCase()) {
      'source' => 'SRC',
      'preview' => 'PRE',
      null || '' => '?',
      final value => value.toUpperCase(),
    };
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: Container(
            width: size,
            height: size * .72,
            padding: EdgeInsets.symmetric(horizontal: size * .08),
            decoration: BoxDecoration(
              border: Border.all(color: foreground, width: size * .075),
              borderRadius: BorderRadius.circular(size * .17),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: foreground,
                    fontSize: size * .36,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: -.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerBatteryIcon extends StatelessWidget {
  const PlayerBatteryIcon({
    super.key,
    required this.level,
    required this.charging,
    required this.color,
  });

  final int level;
  final bool charging;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    height: 14,
    child: CustomPaint(
      painter: _BatteryPainter(level.clamp(0, 100) / 100, charging, color),
    ),
  );
}

/// Volume thresholds live here so the on-video HUD and the toolbar slider
/// never disagree about when a level counts as "low".
PlayerSymbol volumeSymbolFor(double volume) {
  if (volume <= 0) return PlayerSymbol.volumeOff;
  return volume <= 0.5 ? PlayerSymbol.volumeLow : PlayerSymbol.volumeHigh;
}

PlayerSymbol brightnessSymbolFor(double brightness) =>
    brightness <= 0.5 ? PlayerSymbol.sunLow : PlayerSymbol.sun;

/// The gesture HUD readout: one symbol, one line of text. Volume, brightness
/// and speed all report through this so they share metrics and colour.
class PlayerHudMessage extends StatelessWidget {
  const PlayerHudMessage({super.key, required this.symbol, required this.text});

  final PlayerSymbol symbol;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      PlayerIcon(symbol, color: Colors.white),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
    ],
  );
}

Color _foreground(BuildContext context, Color? color) {
  final theme = IconTheme.of(context);
  final foreground = color ?? theme.color ?? Colors.black;
  return foreground.withValues(alpha: foreground.a * (theme.opacity ?? 1));
}

class _PlayerSymbolPainter extends CustomPainter {
  const _PlayerSymbolPainter(this.symbol, this.color, {required this.mirror});

  final PlayerSymbol symbol;
  final Color color;
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final scale = size.shortestSide / 24;
    canvas.save();
    canvas.translate((size.width - 24 * scale) / 2, (size.height - 24 * scale) / 2);
    canvas.scale(scale);
    if (mirror) {
      canvas.translate(24, 0);
      canvas.scale(-1, 1);
    }
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (symbol) {
      case PlayerSymbol.play:
        canvas.drawPath(_play, fill);
      case PlayerSymbol.pause:
        _pill(canvas, const Rect.fromLTWH(5, 3.5, 5, 17), 1.6, fill);
        _pill(canvas, const Rect.fromLTWH(14, 3.5, 5, 17), 1.6, fill);
      case PlayerSymbol.next:
        canvas.save();
        canvas.translate(-1.2, 0);
        canvas.scale(.88, 1);
        canvas.drawPath(_play, fill);
        canvas.restore();
        _pill(canvas, const Rect.fromLTWH(18, 3.5, 3.3, 17), 1.1, fill);
      case PlayerSymbol.back:
      case PlayerSymbol.chevronLeft:
      case PlayerSymbol.chevronRight:
        final right = symbol == PlayerSymbol.chevronRight;
        canvas.drawPath(
          Path()
            ..moveTo(right ? 9 : 15, 4.5)
            ..lineTo(right ? 16.5 : 7.5, 12)
            ..lineTo(right ? 9 : 15, 19.5),
          stroke..strokeWidth = 2.6,
        );
      case PlayerSymbol.close:
        _line(canvas, stroke, 6, 6, 18, 18);
        _line(canvas, stroke, 18, 6, 6, 18);
      case PlayerSymbol.home:
        canvas.drawPath(
          Path()
            ..moveTo(2.6, 10.4)
            ..lineTo(10.9, 3.1)
            ..quadraticBezierTo(12, 2.1, 13.1, 3.1)
            ..lineTo(21.4, 10.4)
            ..quadraticBezierTo(22.4, 11.5, 20.9, 12)
            ..lineTo(19.7, 12)
            ..lineTo(19.7, 19)
            ..quadraticBezierTo(19.7, 21, 17.7, 21)
            ..lineTo(14.4, 21)
            ..lineTo(14.4, 14.5)
            ..lineTo(9.6, 14.5)
            ..lineTo(9.6, 21)
            ..lineTo(6.3, 21)
            ..quadraticBezierTo(4.3, 21, 4.3, 19)
            ..lineTo(4.3, 12)
            ..lineTo(3.1, 12)
            ..quadraticBezierTo(1.6, 11.5, 2.6, 10.4)
            ..close(),
          fill,
        );
      case PlayerSymbol.more:
        for (final x in [5.0, 12.0, 19.0]) {
          canvas.drawCircle(Offset(x, 12), 1.9, fill);
        }
      case PlayerSymbol.cast:
      case PlayerSymbol.castConnected:
        canvas.drawPath(
          Path()
            ..moveTo(6.5, 17)
            ..lineTo(4.5, 17)
            ..quadraticBezierTo(2.5, 17, 2.5, 15)
            ..lineTo(2.5, 6)
            ..quadraticBezierTo(2.5, 4, 4.5, 4)
            ..lineTo(19.5, 4)
            ..quadraticBezierTo(21.5, 4, 21.5, 6)
            ..lineTo(21.5, 15)
            ..quadraticBezierTo(21.5, 17, 19.5, 17)
            ..lineTo(17.5, 17),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(11.2, 14.2)
            ..quadraticBezierTo(12, 13.2, 12.8, 14.2)
            ..lineTo(17.1, 19.8)
            ..quadraticBezierTo(17.8, 21, 16.4, 21)
            ..lineTo(7.6, 21)
            ..quadraticBezierTo(6.2, 21, 6.9, 19.8)
            ..close(),
          fill,
        );
        if (symbol == PlayerSymbol.castConnected) {
          _pill(canvas, const Rect.fromLTWH(5.5, 7, 13, 5.5), 1, fill);
        }
      case PlayerSymbol.pictureInPicture:
        _pill(canvas, const Rect.fromLTWH(2.5, 4.5, 19, 15), 2.6, stroke);
        _pill(canvas, const Rect.fromLTWH(11, 11, 8, 6), 1.2, fill);
        _line(canvas, stroke, 6, 8, 8.5, 10.5);
      case PlayerSymbol.externalPlayer:
        canvas.drawPath(
          Path()
            ..moveTo(11, 4.5)
            ..lineTo(5.5, 4.5)
            ..quadraticBezierTo(3.5, 4.5, 3.5, 6.5)
            ..lineTo(3.5, 18.5)
            ..quadraticBezierTo(3.5, 20.5, 5.5, 20.5)
            ..lineTo(17.5, 20.5)
            ..quadraticBezierTo(19.5, 20.5, 19.5, 18.5)
            ..lineTo(19.5, 13),
          stroke,
        );
        _line(canvas, stroke, 11, 13, 21, 3);
        canvas.drawPath(Path()..moveTo(14.5, 3)..lineTo(21, 3)..lineTo(21, 9.5), stroke);
      case PlayerSymbol.fullscreen:
      case PlayerSymbol.exitFullscreen:
        final exiting = symbol == PlayerSymbol.exitFullscreen;
        _line(canvas, stroke, 4, 20, 9.5, 14.5);
        _line(canvas, stroke, 14.5, 9.5, 20, 4);
        canvas.drawPath(
          exiting
              ? (Path()..moveTo(3.5, 14.5)..lineTo(9.5, 14.5)..lineTo(9.5, 20.5)
                ..moveTo(14.5, 3.5)..lineTo(14.5, 9.5)..lineTo(20.5, 9.5))
              : (Path()..moveTo(4, 13.5)..lineTo(4, 20)..lineTo(10.5, 20)
                ..moveTo(13.5, 4)..lineTo(20, 4)..lineTo(20, 10.5)),
          stroke..strokeWidth = 2.3,
        );
      case PlayerSymbol.windowFullscreen:
      case PlayerSymbol.exitWindowFullscreen:
        _pill(canvas, const Rect.fromLTWH(2.5, 4.5, 19, 15), 2.6, stroke);
        if (symbol == PlayerSymbol.windowFullscreen) {
          _line(canvas, stroke, 3.5, 8.5, 20.5, 8.5);
        } else {
          _pill(canvas, const Rect.fromLTWH(6.5, 8.5, 11, 7), 1, stroke);
        }
      case PlayerSymbol.theater:
        _pill(canvas, const Rect.fromLTWH(2.5, 3.5, 19, 14), 2.5, stroke);
        canvas.save();
        canvas.translate(6.2, 4.5);
        canvas.scale(.48);
        canvas.drawPath(_play, fill);
        canvas.restore();
        _line(canvas, stroke, 12, 17.5, 12, 21);
        _line(canvas, stroke, 7, 21, 17, 21);
      case PlayerSymbol.vr:
        final headset = Path()
          ..moveTo(6, 5.5)
          ..lineTo(18, 5.5)
          ..cubicTo(21, 5.5, 22, 8, 22, 11.5)
          ..lineTo(22, 15)
          ..quadraticBezierTo(22, 18.5, 18.5, 18.5)
          ..lineTo(16, 18.5)
          ..quadraticBezierTo(14.5, 18.5, 13.6, 16.9)
          ..quadraticBezierTo(12, 14.1, 10.4, 16.9)
          ..quadraticBezierTo(9.5, 18.5, 8, 18.5)
          ..lineTo(5.5, 18.5)
          ..quadraticBezierTo(2, 18.5, 2, 15)
          ..lineTo(2, 11.5)
          ..cubicTo(2, 8, 3, 5.5, 6, 5.5)
          ..close()
          ..addOval(const Rect.fromLTWH(5, 9, 5, 5))
          ..addOval(const Rect.fromLTWH(14, 9, 5, 5))
          ..fillType = PathFillType.evenOdd;
        canvas.drawPath(headset, fill);
      case PlayerSymbol.enhance:
        _sparkle(canvas, fill, const Offset(10, 13.5), 8);
        _sparkle(canvas, fill, const Offset(18.5, 5), 3.5);
        _sparkle(canvas, fill, const Offset(20, 19.5), 2.1);
      case PlayerSymbol.volumeOff:
      case PlayerSymbol.volumeLow:
      case PlayerSymbol.volumeHigh:
        _speaker(canvas, fill, stroke);
      case PlayerSymbol.sunLow:
      case PlayerSymbol.sun:
        final low = symbol == PlayerSymbol.sunLow;
        canvas.drawCircle(const Offset(12, 12), low ? 3.5 : 4.5, fill);
        for (var i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          final inner = low ? 6.6 : 7.7;
          final outer = low ? 8.1 : 10.1;
          _line(canvas, stroke,
              12 + math.cos(angle) * inner, 12 + math.sin(angle) * inner,
              12 + math.cos(angle) * outer, 12 + math.sin(angle) * outer);
        }
      case PlayerSymbol.sunrise:
        canvas.drawArc(const Rect.fromLTWH(6.5, 10, 11, 11), math.pi, math.pi, true, fill);
        _line(canvas, stroke, 2.5, 16, 21.5, 16);
        _line(canvas, stroke, 5.5, 20, 18.5, 20);
        _line(canvas, stroke, 12, 4, 12, 6);
        _line(canvas, stroke, 4.5, 7.5, 6, 9);
        _line(canvas, stroke, 18, 9, 19.5, 7.5);
      case PlayerSymbol.moon:
        canvas.drawPath(
          Path.combine(PathOperation.difference,
            Path()..addOval(const Rect.fromLTWH(3, 3, 18, 18)),
            Path()..addOval(const Rect.fromLTWH(9, -.5, 17, 17))),
          fill,
        );
      case PlayerSymbol.speed:
        canvas.drawArc(const Rect.fromLTWH(3, 3.5, 18, 18), math.pi * .75, math.pi * 1.5, false, stroke);
        for (final angle in [math.pi, math.pi * 1.5, math.pi * 2]) {
          _line(canvas, stroke, 12 + math.cos(angle) * 6.6, 12.5 + math.sin(angle) * 6.6,
              12 + math.cos(angle) * 7.2, 12.5 + math.sin(angle) * 7.2);
        }
        canvas.drawPath(Path()..moveTo(10.6, 11.6)..lineTo(16.8, 7.2)
          ..quadraticBezierTo(17.2, 6.9, 17, 7.6)..lineTo(13.6, 13.7)..close(), fill);
        canvas.drawCircle(const Offset(12, 12.5), 2.1, fill);
      case PlayerSymbol.lock:
      case PlayerSymbol.lockOpen:
        canvas.drawPath(
          Path()..moveTo(7.5, 11)..lineTo(7.5, 7)
            ..cubicTo(7.5, 1.8, 16.5, 1.8, 16.5, 7)
            ..lineTo(16.5, symbol == PlayerSymbol.lock ? 11 : 7.8),
          stroke..strokeWidth = 2.4,
        );
        canvas.drawPath(
          Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(5, 10, 14, 11), const Radius.circular(2.8)))
            ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(11.2, 13.5, 1.6, 4.1), const Radius.circular(.8)))
            ..fillType = PathFillType.evenOdd,
          fill,
        );
      case PlayerSymbol.history:
      case PlayerSymbol.retry:
        canvas.drawArc(const Rect.fromLTWH(3.5, 3.5, 17, 17), math.pi * 1.13, math.pi * 1.82, false, stroke);
        canvas.drawPath(Path()..moveTo(3.4, 3.3)..lineTo(3.4, 8.5)..lineTo(8.6, 8.5), stroke);
        if (symbol == PlayerSymbol.history) {
          canvas.drawPath(Path()..moveTo(12, 7.5)..lineTo(12, 12.5)..lineTo(15.5, 14.5), stroke);
        }
      case PlayerSymbol.zoomIn:
      case PlayerSymbol.zoomOut:
        canvas.drawCircle(const Offset(10.5, 10.5), 7, stroke);
        _line(canvas, stroke, 15.8, 15.8, 21, 21);
        _line(canvas, stroke, 7.3, 10.5, 13.7, 10.5);
        if (symbol == PlayerSymbol.zoomIn) _line(canvas, stroke, 10.5, 7.3, 10.5, 13.7);
      case PlayerSymbol.error:
      case PlayerSymbol.info:
        final info = symbol == PlayerSymbol.info;
        canvas.drawPath(
          Path()..addOval(const Rect.fromLTWH(2, 2, 20, 20))
            ..addOval(Rect.fromCircle(center: Offset(12, info ? 7.4 : 16.6), radius: 1.15))
            ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(11, info ? 10.3 : 6, 2, 7.4), const Radius.circular(1)))
            ..fillType = PathFillType.evenOdd,
          fill,
        );
      case PlayerSymbol.warning:
        canvas.drawPath(
          Path()..moveTo(10.2, 3.6)..quadraticBezierTo(12, .7, 13.8, 3.6)
            ..lineTo(22, 18.3)..quadraticBezierTo(23.3, 21, 20.3, 21)
            ..lineTo(3.7, 21)..quadraticBezierTo(.7, 21, 2, 18.3)..close()
            ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(11, 7.4, 2, 6.6), const Radius.circular(1)))
            ..addOval(Rect.fromCircle(center: const Offset(12, 17.3), radius: 1.15))
            ..fillType = PathFillType.evenOdd,
          fill,
        );
      case PlayerSymbol.chip:
        _pill(canvas, const Rect.fromLTWH(6, 6, 12, 12), 2.5, stroke);
        _pill(canvas, const Rect.fromLTWH(9.5, 9.5, 5, 5), 1, fill);
        for (final p in [8.0, 12.0, 16.0]) {
          _line(canvas, stroke, p, 2.5, p, 5.5);
          _line(canvas, stroke, p, 18.5, p, 21.5);
          _line(canvas, stroke, 2.5, p, 5.5, p);
          _line(canvas, stroke, 18.5, p, 21.5, p);
        }
      case PlayerSymbol.videoOff:
        _pill(canvas, const Rect.fromLTWH(2, 6, 14, 13), 3, fill..color = color.withValues(alpha: color.a * .45));
        canvas.drawPath(Path()..moveTo(18, 10)..lineTo(22, 7)..lineTo(22, 18)..lineTo(18, 15)..close(), fill);
        _line(canvas, stroke, 3, 3, 21, 21);
      case PlayerSymbol.wifi:
      case PlayerSymbol.wifiOff:
        if (symbol == PlayerSymbol.wifiOff) {
          stroke.color = color.withValues(alpha: color.a * .4);
          fill.color = stroke.color;
        }
        stroke.strokeWidth = 2.5;
        for (final radius in [6.3, 10.5]) {
          canvas.drawArc(Rect.fromCircle(center: const Offset(12, 18), radius: radius), math.pi * 1.23, math.pi * .54, false, stroke);
        }
        canvas.drawCircle(const Offset(12, 18), 1.8, fill);
        if (symbol == PlayerSymbol.wifiOff) _line(canvas, stroke..color = color, 3, 3, 21, 21);
      case PlayerSymbol.cellular:
        for (var i = 0; i < 4; i++) {
          final height = 5.0 + 4 * i;
          _pill(canvas, Rect.fromLTWH(2.5 + i * 5.2, 21 - height, 3.4, height), 1.3, fill);
        }
      case PlayerSymbol.ethernet:
        _pill(canvas, const Rect.fromLTWH(5, 3, 14, 13), 2.5, stroke);
        for (final x in [9.0, 12.0, 15.0]) {
          _line(canvas, stroke, x, 6.5, x, 9.5);
        }
        _line(canvas, stroke, 12, 16, 12, 21);
        _line(canvas, stroke, 8, 21, 16, 21);
    }
    canvas.restore();
  }

  static final Path _play = Path()
    ..moveTo(6, 4.6)
    ..cubicTo(6, 3.1, 7.1, 2.6, 8.4, 3.4)
    ..lineTo(19.2, 10.3)
    ..cubicTo(20.8, 11.3, 20.8, 12.7, 19.2, 13.7)
    ..lineTo(8.4, 20.6)
    ..cubicTo(7.1, 21.4, 6, 20.9, 6, 19.4)
    ..close();

  void _speaker(Canvas canvas, Paint fill, Paint stroke) {
    canvas.drawPath(
      Path()..moveTo(3.5, 8.5)..lineTo(6.5, 8.5)..lineTo(11, 4.4)
        ..quadraticBezierTo(12.5, 3.1, 12.5, 5.2)..lineTo(12.5, 18.8)
        ..quadraticBezierTo(12.5, 20.9, 11, 19.6)..lineTo(6.5, 15.5)
        ..lineTo(3.5, 15.5)..quadraticBezierTo(2, 15.5, 2, 14)
        ..lineTo(2, 10)..quadraticBezierTo(2, 8.5, 3.5, 8.5)..close(),
      fill,
    );
    if (symbol == PlayerSymbol.volumeOff) {
      _line(canvas, stroke, 16.3, 9.2, 21.3, 14.8);
      _line(canvas, stroke, 21.3, 9.2, 16.3, 14.8);
    } else {
      canvas.drawPath(Path()..moveTo(16, 8.7)..quadraticBezierTo(19.1, 12, 16, 15.3), stroke);
      if (symbol == PlayerSymbol.volumeHigh) {
        canvas.drawPath(Path()..moveTo(19.1, 5.6)..quadraticBezierTo(24.2, 12, 19.1, 18.4), stroke);
      }
    }
  }

  static void _line(Canvas canvas, Paint paint, double x1, double y1, double x2, double y2) =>
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);

  static void _pill(Canvas canvas, Rect rect, double radius, Paint paint) =>
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), paint);

  static void _sparkle(Canvas canvas, Paint paint, Offset center, double radius) {
    final x = center.dx;
    final y = center.dy;
    canvas.drawPath(
      Path()..moveTo(x, y - radius)
        ..quadraticBezierTo(x + radius * .2, y - radius * .2, x + radius, y)
        ..quadraticBezierTo(x + radius * .2, y + radius * .2, x, y + radius)
        ..quadraticBezierTo(x - radius * .2, y + radius * .2, x - radius, y)
        ..quadraticBezierTo(x - radius * .2, y - radius * .2, x, y - radius)..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PlayerSymbolPainter oldDelegate) =>
      symbol != oldDelegate.symbol || color != oldDelegate.color || mirror != oldDelegate.mirror;
}

class _BatteryPainter extends CustomPainter {
  const _BatteryPainter(this.level, this.charging, this.color);

  final double level;
  final bool charging;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 14);
    final stroke = Paint()..color = color.withValues(alpha: color.a * .55)
      ..style = PaintingStyle.stroke..strokeWidth = 1.4;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(.8, 2, 20, 10), const Radius.circular(2.6)), stroke);
    final fill = Paint()..color = color;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(22, 5, 1.8, 4), const Radius.circular(.8)), fill);
    final charge = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2.8, 4, 16 * level, 6), const Radius.circular(1.2)));
    if (charging) {
      final bolt = Path()..moveTo(12.5, 2.8)..lineTo(8.4, 7.5)..lineTo(11.2, 7.5)
        ..lineTo(10.1, 11.2)..lineTo(14.5, 6.1)..lineTo(11.7, 6.1)..close();
      // Knock out the bolt instead of painting a background-colored patch.
      canvas.drawPath(Path.combine(PathOperation.difference, charge, bolt), fill);
      canvas.drawPath(bolt, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = .7);
    } else {
      canvas.drawPath(charge, fill);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BatteryPainter oldDelegate) =>
      level != oldDelegate.level || charging != oldDelegate.charging || color != oldDelegate.color;
}
