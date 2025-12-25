import 'dart:math';
import 'package:flutter/material.dart';

class LunarNewYearEffect extends StatefulWidget {
  const LunarNewYearEffect({super.key});

  @override
  State<LunarNewYearEffect> createState() => _LunarNewYearEffectState();
}

class _LunarNewYearEffectState extends State<LunarNewYearEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<RedEnvelope> _redEnvelopes = [];
  final List<Lantern> _lanterns = [];
  final List<GoldParticle> _goldParticles = [];
  final Random _random = Random();

  // Configuration
  static const int _envelopeCount = 8;
  static const int _lanternCount = 5;
  static const int _particleCount = 40;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initElements(Size size) {
    if (_lanterns.isEmpty) {
      // Initialize Lanterns (hanging from top)
      final spacing = size.width / (_lanternCount + 1);
      for (int i = 0; i < _lanternCount; i++) {
        _lanterns.add(
          Lantern(
            x: spacing * (i + 1),
            y: -10 + _random.nextDouble() * 20, // Slightly varied heights
            size: 35 + _random.nextDouble() * 15,
            color: const Color(0xFFD32F2F),
            swingSpeed: 0.002 + _random.nextDouble() * 0.003,
            swingAmplitude: 0.05 + _random.nextDouble() * 0.05,
            initialPhase: _random.nextDouble() * 2 * pi,
          ),
        );
      }
    }

    if (_redEnvelopes.isEmpty) {
      // Initialize Red Envelopes
      for (int i = 0; i < _envelopeCount; i++) {
        _redEnvelopes.add(_createRedEnvelope(size, randomY: true));
      }
    }

    if (_goldParticles.isEmpty) {
      // Initialize Gold Particles
      for (int i = 0; i < _particleCount; i++) {
        _goldParticles.add(_createGoldParticle(size, randomY: true));
      }
    }
  }

  RedEnvelope _createRedEnvelope(Size size, {bool randomY = false}) {
    return RedEnvelope(
      x: _random.nextDouble() * size.width,
      y: randomY ? _random.nextDouble() * size.height : -50,
      size: 30 + _random.nextDouble() * 20,
      speed: 1.5 + _random.nextDouble() * 2.0,
      rotation: _random.nextDouble() * 2 * pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
      tilt: _random.nextDouble() * 2 * pi,
      tiltSpeed: 0.02 + _random.nextDouble() * 0.03,
    );
  }

  GoldParticle _createGoldParticle(Size size, {bool randomY = false}) {
    return GoldParticle(
      x: _random.nextDouble() * size.width,
      y: randomY ? _random.nextDouble() * size.height : -10,
      size: 2 + _random.nextDouble() * 4,
      speed: 0.5 + _random.nextDouble() * 1.5,
      opacity: 0.3 + _random.nextDouble() * 0.7,
      twinkleOffset: _random.nextDouble() * 2 * pi,
      twinkleSpeed: 0.05 + _random.nextDouble() * 0.1,
    );
  }

  void _updateElements(Size size) {
    // Update Lanterns
    final time = DateTime.now().millisecondsSinceEpoch;
    for (var lantern in _lanterns) {
      // Simple harmonic motion for swinging
      lantern.swingAngle =
          sin(time * lantern.swingSpeed + lantern.initialPhase) *
          lantern.swingAmplitude;
    }

    // Update Red Envelopes
    for (var envelope in _redEnvelopes) {
      envelope.y += envelope.speed;
      envelope.rotation += envelope.rotationSpeed;
      envelope.tilt += envelope.tiltSpeed;

      // Horizontal drift
      envelope.x += sin(envelope.y * 0.01 + envelope.rotation) * 0.5;

      // Reset if out of view
      if (envelope.y > size.height + 50) {
        final newEnvelope = _createRedEnvelope(size, randomY: false);
        envelope.copyFrom(newEnvelope);
      }
    }

    // Update Particles
    for (var particle in _goldParticles) {
      particle.y += particle.speed;
      particle.twinkleOffset += particle.twinkleSpeed;

      if (particle.y > size.height + 10) {
        final newParticle = _createGoldParticle(size, randomY: false);
        particle.copyFrom(newParticle);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initElements(size);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            _updateElements(size);
            return CustomPaint(
              size: size,
              painter: LunarNewYearPainter(
                lanterns: _lanterns,
                redEnvelopes: _redEnvelopes,
                goldParticles: _goldParticles,
                brightness: Theme.of(context).brightness,
              ),
            );
          },
        );
      },
    );
  }
}

// Model Classes

class Lantern {
  double x;
  double y;
  double size;
  Color color;
  double swingSpeed;
  double swingAmplitude;
  double initialPhase;
  double swingAngle; // Current swing angle

  Lantern({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.swingSpeed,
    required this.swingAmplitude,
    required this.initialPhase,
    this.swingAngle = 0.0,
  });
}

class RedEnvelope {
  double x;
  double y;
  double size;
  double speed;
  double rotation;
  double rotationSpeed;
  double tilt; // For 3D flipping effect
  double tiltSpeed;

  RedEnvelope({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.tilt,
    required this.tiltSpeed,
  });

  void copyFrom(RedEnvelope other) {
    x = other.x;
    y = other.y;
    size = other.size;
    speed = other.speed;
    rotation = other.rotation;
    rotationSpeed = other.rotationSpeed;
    tilt = other.tilt;
    tiltSpeed = other.tiltSpeed;
  }
}

class GoldParticle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  double twinkleOffset;
  double twinkleSpeed;

  GoldParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.twinkleOffset,
    required this.twinkleSpeed,
  });

  void copyFrom(GoldParticle other) {
    x = other.x;
    y = other.y;
    size = other.size;
    speed = other.speed;
    opacity = other.opacity;
    twinkleOffset = other.twinkleOffset;
    twinkleSpeed = other.twinkleSpeed;
  }
}

// Painter

class LunarNewYearPainter extends CustomPainter {
  final List<Lantern> lanterns;
  final List<RedEnvelope> redEnvelopes;
  final List<GoldParticle> goldParticles;
  final Brightness brightness;

  LunarNewYearPainter({
    required this.lanterns,
    required this.redEnvelopes,
    required this.goldParticles,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Gold Particles (Background)
    _drawParticles(canvas);

    // 2. Draw Lanterns (Top Layer, behind envelopes partially)
    _drawLanterns(canvas);

    // 3. Draw Red Envelopes (Foreground)
    _drawRedEnvelopes(canvas);
  }

  void _drawParticles(Canvas canvas) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in goldParticles) {
      final opacity =
          (sin(particle.twinkleOffset) + 1) / 2 * 0.5 + 0.5; // 0.5 - 1.0 based
      paint.color = const Color(
        0xFFFFD700,
      ).withValues(alpha: particle.opacity * opacity);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size / 2,
        paint,
      );

      // Add a glow/sparkle cross
      paint.strokeWidth = 1;
      canvas.drawLine(
        Offset(particle.x - particle.size, particle.y),
        Offset(particle.x + particle.size, particle.y),
        paint,
      );
      canvas.drawLine(
        Offset(particle.x, particle.y - particle.size),
        Offset(particle.x, particle.y + particle.size),
        paint,
      );
    }
  }

  void _drawLanterns(Canvas canvas) {
    final ropePaint = Paint()
      ..color =
          const Color(0xFFD4AF37) // Antique Gold
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var lantern in lanterns) {
      canvas.save();
      // Apply swing pivot at the top of the rope
      canvas.translate(lantern.x, 0);
      canvas.rotate(lantern.swingAngle);
      canvas.translate(0, lantern.y);

      // Draw rope
      canvas.drawLine(Offset.zero, const Offset(0, 15), ropePaint);

      // Move to lantern body top
      canvas.translate(0, 15);

      final w = lantern.size * 0.8;
      final h = lantern.size;

      // Draw Lantern Body
      final bodyRect = Rect.fromCenter(
        center: Offset(0, h / 2),
        width: w,
        height: h,
      );

      // Glow effect (behind)
      final glowPaint = Paint()
        ..color = const Color(0xFFFFCC00).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawOval(bodyRect.inflate(5), glowPaint);

      // Main Gradient
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: const [
          Color(0xFFFF5252), // Inner light red
          Color(0xFFB71C1C), // Outer dark red
        ],
        stops: const [0.3, 1.0],
      );

      final bodyPaint = Paint()..shader = gradient.createShader(bodyRect);
      canvas.drawOval(bodyRect, bodyPaint);

      // Decor lines (ribs)
      final ribPaint = Paint()
        ..color = const Color(0xFF8E0000).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawArc(
        bodyRect,
        -pi / 2,
        pi,
        false,
        ribPaint,
      ); // Center vertical line approx
      canvas.drawOval(
        bodyRect.deflate(w * 0.2),
        ribPaint,
      ); // Inner rib approximation

      // Top and Bottom Gold Caps
      final capPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(0, 0), width: w * 0.4, height: 4),
        capPaint,
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(0, h), width: w * 0.4, height: 4),
        capPaint,
      );

      // Tassel
      final tasselStart = Offset(0, h + 2);
      canvas.drawLine(
        tasselStart,
        tasselStart + const Offset(0, 20),
        ropePaint,
      );

      // Tassel bristles
      final tasselColor = const Color(0xFFE53935);
      final tasselPaint = Paint()
        ..color = tasselColor
        ..strokeWidth = 1.5;

      for (int i = -2; i <= 2; i++) {
        canvas.drawLine(
          tasselStart + const Offset(0, 20),
          tasselStart + Offset(i.toDouble() * 3, 40),
          tasselPaint,
        );
      }

      canvas.restore();
    }
  }

  void _drawRedEnvelopes(Canvas canvas) {
    for (var envelope in redEnvelopes) {
      canvas.save();
      canvas.translate(envelope.x, envelope.y);
      canvas.rotate(envelope.rotation);

      // Simulate 3D flip by scaling X
      final scaleX = cos(envelope.tilt).abs();
      // If scale is too small, don't draw or draw thin line
      if (scaleX < 0.05) {
        canvas.restore();
        continue;
      }

      canvas.scale(scaleX, 1.0);

      final w = envelope.size;
      final h = envelope.size * 1.5;
      final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);

      final paint = Paint()
        ..color = const Color(0xFFD32F2F)
        ..style = PaintingStyle.fill;

      // Draw rounded rect
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(rrect, paint);

      // Draw Flap line (arc)
      final linePaint = Paint()
        ..color = const Color(0xFFB71C1C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final curvePath = Path()
        ..moveTo(-w / 2 + 2, -h / 4)
        ..quadraticBezierTo(0, 0, w / 2 - 2, -h / 4);
      canvas.drawPath(curvePath, linePaint);

      // Gold accent (Seal or character)
      final goldPaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(0, -h / 5), w * 0.15, goldPaint);

      // Inner square in gold circle (simplified "Fu" or coin)
      final holePaint = Paint()..color = const Color(0xFFD32F2F);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(0, -h / 5),
          width: w * 0.08,
          height: w * 0.08,
        ),
        holePaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant LunarNewYearPainter oldDelegate) => true;
}
