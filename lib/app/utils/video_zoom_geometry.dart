import 'dart:math' as math;
import 'dart:ui';

/// The same bounded transform is used by pinch and wheel zooming.
abstract final class VideoZoomGeometry {
  static const minScale = 0.5;
  static const maxScale = 3.0;

  static Offset clampOffset(
    Offset offset,
    double scale,
    Size viewport,
    double aspect,
  ) {
    if (viewport.isEmpty) return Offset.zero;
    final fitted = aspect <= 0 || !aspect.isFinite
        ? viewport
        : viewport.aspectRatio > aspect
        ? Size(viewport.height * aspect, viewport.height)
        : Size(viewport.width, viewport.width / aspect);
    final dx = math.max(0.0, fitted.width * (scale - 1) / 2);
    final dy = math.max(0.0, fitted.height * (scale - 1) / 2);
    return Offset(offset.dx.clamp(-dx, dx), offset.dy.clamp(-dy, dy));
  }

  static ({double scale, Offset offset, double rotation}) transform({
    required Size viewport,
    required double aspect,
    required Offset focal,
    required double oldScale,
    required Offset oldOffset,
    required double newScale,
    required double oldRotation,
    required double newRotation,
    Offset panDelta = Offset.zero,
    double minimum = minScale,
    double maximum = maxScale,
  }) {
    final scale = newScale.clamp(minimum, maximum);
    final center = viewport.center(Offset.zero);
    final v = focal - center - oldOffset;
    final angle = newRotation - oldRotation;
    final rotated = Offset(
      v.dx * math.cos(angle) - v.dy * math.sin(angle),
      v.dx * math.sin(angle) + v.dy * math.cos(angle),
    );
    final offset = clampOffset(
      focal - center + panDelta - rotated * (scale / oldScale),
      scale,
      viewport,
      aspect,
    );
    // 接近原始大小且未旋转时吸附到初始状态，干净退出
    if ((scale - 1).abs() < 0.01 && newRotation.abs() < 0.01) {
      return (scale: 1, offset: Offset.zero, rotation: 0);
    }
    return (scale: scale, offset: offset, rotation: newRotation);
  }
}
