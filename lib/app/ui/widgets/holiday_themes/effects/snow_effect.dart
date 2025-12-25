import 'dart:math';
import 'package:flutter/material.dart';

class SnowEffect extends StatefulWidget {
  const SnowEffect({super.key});

  @override
  State<SnowEffect> createState() => _SnowEffectState();
}

class _SnowEffectState extends State<SnowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Snowflake> _snowflakes = [];
  final Random _random = Random();

  // 分层雪花数量，创建景深效果
  static const int _nearFlakes = 15; // 近景大雪花
  static const int _midFlakes = 20; // 中景中雪花
  static const int _farFlakes = 25; // 远景小雪花

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initSnowflakes(Size size) {
    if (_snowflakes.isEmpty) {
      // 近景层 - 大而快的雪花
      for (int i = 0; i < _nearFlakes; i++) {
        _snowflakes.add(_createSnowflake(size, true, SnowLayer.near));
      }
      // 中景层 - 中等大小和速度
      for (int i = 0; i < _midFlakes; i++) {
        _snowflakes.add(_createSnowflake(size, true, SnowLayer.mid));
      }
      // 远景层 - 小而慢的雪花
      for (int i = 0; i < _farFlakes; i++) {
        _snowflakes.add(_createSnowflake(size, true, SnowLayer.far));
      }
    }
  }

  Snowflake _createSnowflake(Size size, bool randomY, SnowLayer layer) {
    double sizeRange, speedRange, opacityRange;

    switch (layer) {
      case SnowLayer.near:
        sizeRange = _random.nextDouble() * 2 + 4; // 4-6
        speedRange = _random.nextDouble() * 1.5 + 2; // 2-3.5
        opacityRange = _random.nextDouble() * 0.3 + 0.6; // 0.6-0.9
        break;
      case SnowLayer.mid:
        sizeRange = _random.nextDouble() * 1.5 + 2.5; // 2.5-4
        speedRange = _random.nextDouble() * 1 + 1; // 1-2
        opacityRange = _random.nextDouble() * 0.3 + 0.3; // 0.3-0.6
        break;
      case SnowLayer.far:
        sizeRange = _random.nextDouble() * 1 + 1.5; // 1.5-2.5
        speedRange = _random.nextDouble() * 0.8 + 0.3; // 0.3-1.1
        opacityRange = _random.nextDouble() * 0.2 + 0.1; // 0.1-0.3
        break;
    }

    return Snowflake(
      x: _random.nextDouble() * size.width,
      y: randomY ? _random.nextDouble() * size.height : -20,
      size: sizeRange,
      speed: speedRange,
      opacity: opacityRange,
      rotation: _random.nextDouble() * 2 * pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.02, // -0.01 到 0.01
      swingOffset: _random.nextDouble() * 2 * pi, // 摆动相位偏移
      swingAmplitude: _random.nextDouble() * 0.5 + 0.3, // 摆动幅度
      layer: layer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _initSnowflakes(Size(constraints.maxWidth, constraints.maxHeight));
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            _updateSnowflakes(
              Size(constraints.maxWidth, constraints.maxHeight),
            );
            final brightness = Theme.of(context).brightness;
            return CustomPaint(
              painter: SnowPainter(_snowflakes, brightness),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            );
          },
        );
      },
    );
  }

  void _updateSnowflakes(Size size) {
    for (var flake in _snowflakes) {
      // 垂直下落
      flake.y += flake.speed;

      // 旋转
      flake.rotation += flake.rotationSpeed;

      // 更自然的水平摆动（正弦波）
      flake.x += sin(flake.y / 30 + flake.swingOffset) * flake.swingAmplitude;

      // 重置超出屏幕的雪花
      if (flake.y > size.height + 20) {
        flake.y = -20;
        flake.x = _random.nextDouble() * size.width;
        flake.rotation = _random.nextDouble() * 2 * pi;
      }

      // 边界循环
      if (flake.x < -20) flake.x = size.width + 20;
      if (flake.x > size.width + 20) flake.x = -20;
    }
  }
}

enum SnowLayer {
  near, // 近景
  mid, // 中景
  far, // 远景
}

class Snowflake {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  double rotation;
  double rotationSpeed;
  double swingOffset;
  double swingAmplitude;
  SnowLayer layer;

  Snowflake({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.rotation,
    required this.rotationSpeed,
    required this.swingOffset,
    required this.swingAmplitude,
    required this.layer,
  });
}

class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;
  final Brightness brightness;

  // 缓存雪花形状路径以提高性能
  static final Map<double, Path> _snowflakePathCache = {};

  SnowPainter(this.snowflakes, this.brightness);

  @override
  void paint(Canvas canvas, Size size) {
    // 根据亮度决定雪花颜色
    final baseColor = brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF90CAF9); // 浅蓝色，在亮色模式下更明显

    // 按层级排序，先绘制远景（小的），后绘制近景（大的）
    final sortedFlakes = List<Snowflake>.from(snowflakes)
      ..sort((a, b) => a.layer.index.compareTo(b.layer.index));

    for (var flake in sortedFlakes) {
      final paint = Paint()
        ..color = baseColor.withValues(alpha: flake.opacity)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      canvas.save();
      canvas.translate(flake.x, flake.y);
      canvas.rotate(flake.rotation);

      // 根据大小决定雪花形状
      if (flake.size > 3.5) {
        // 大雪花：绘制六角星形
        _drawSnowflake(canvas, paint, flake.size);
      } else if (flake.size > 2) {
        // 中等雪花：绘制六边形
        _drawHexagon(canvas, paint, flake.size);
      } else {
        // 小雪花：简单圆形（性能优化）
        canvas.drawCircle(Offset.zero, flake.size, paint);
      }

      canvas.restore();
    }
  }

  // 绘制六角星形雪花
  void _drawSnowflake(Canvas canvas, Paint paint, double size) {
    final path = _getOrCreateSnowflakePath(size);
    canvas.drawPath(path, paint);
  }

  // 获取或创建缓存的雪花路径
  Path _getOrCreateSnowflakePath(double size) {
    final key = (size * 10).round() / 10; // 精度到0.1

    if (!_snowflakePathCache.containsKey(key)) {
      final path = Path();

      // 绘制六个主分支
      for (int i = 0; i < 6; i++) {
        final angle = i * pi / 3;
        final cosVal = size * 0.8 * cos(angle);
        final sinVal = size * 0.8 * sin(angle);

        // 主分支
        path.moveTo(0, 0);
        path.lineTo(cosVal, sinVal);

        // 小分支
        final branchSize = size * 0.3;
        final branchAngle1 = angle - pi / 6;
        final branchAngle2 = angle + pi / 6;

        path.moveTo(cosVal * 0.6, sinVal * 0.6);
        path.lineTo(
          cosVal * 0.6 + branchSize * cos(branchAngle1),
          sinVal * 0.6 + branchSize * sin(branchAngle1),
        );

        path.moveTo(cosVal * 0.6, sinVal * 0.6);
        path.lineTo(
          cosVal * 0.6 + branchSize * cos(branchAngle2),
          sinVal * 0.6 + branchSize * sin(branchAngle2),
        );
      }

      _snowflakePathCache[key] = path;
    }

    return _snowflakePathCache[key]!;
  }

  // 绘制六边形
  void _drawHexagon(Canvas canvas, Paint paint, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final x = size * cos(angle);
      final y = size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SnowPainter oldDelegate) => true;
}
