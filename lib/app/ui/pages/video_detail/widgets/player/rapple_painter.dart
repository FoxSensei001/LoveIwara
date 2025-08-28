import 'package:flutter/material.dart';

class RipplePainter extends CustomPainter {
  final Color color;
  final double animationValue;
  final Offset origin;
  final double maxRadius;

  RipplePainter({
    required this.color,
    required this.animationValue,
    required this.origin,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double currentRadius = maxRadius * _easeOut(animationValue);
    final double currentOpacity = (1.0 - _easeIn(animationValue)) * 0.3;

    final Paint paint = Paint()
      ..color = color.withValues(alpha: currentOpacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(origin, currentRadius, paint);
  }

  double _easeOut(double t) => t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;

  double _easeIn(double t) => t * t;

  @override
  bool shouldRepaint(RipplePainter oldDelegate) =>
      color != oldDelegate.color ||
          animationValue != oldDelegate.animationValue ||
          origin != oldDelegate.origin ||
          maxRadius != oldDelegate.maxRadius;
}
