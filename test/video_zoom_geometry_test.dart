import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/utils/video_zoom_geometry.dart';

void main() {
  const viewport = Size(360, 240);

  test('continuous sub-one-percent steps can leave default magnification', () {
    final next = VideoZoomGeometry.transform(
      viewport: viewport, aspect: 16 / 9, focal: viewport.center(Offset.zero),
      oldScale: 1, oldOffset: Offset.zero, newScale: 1.004,
      oldRotation: 0, newRotation: 0, snapToDefault: false,
    );
    expect(next.scale, greaterThan(1));
    expect(next.offset, Offset.zero);
  });

  test('zoom limits also bound a previously panned picture; shrinking recenters it', () {
    final next = VideoZoomGeometry.transform(
      viewport: viewport, aspect: 16 / 9, focal: viewport.center(Offset.zero),
      oldScale: 3, oldOffset: const Offset(320, 180), newScale: 0.01,
      oldRotation: 0, newRotation: 0, snapToDefault: false,
    );
    expect(next.scale, 0.5);
    expect(next.offset, Offset.zero);
    expect(VideoZoomGeometry.clampOffset(const Offset(1000, -1000), 2, viewport, 16 / 9), const Offset(180, -101.25));
  });

  test('pinch and wheel preserve the pixel under their focal point', () {
    const focal = Offset(205, 125);
    const oldOffset = Offset(10, 5);
    const oldScale = 1.4;
    final content = (focal - viewport.center(Offset.zero) - oldOffset) / oldScale;
    final next = VideoZoomGeometry.transform(
      viewport: viewport, aspect: 16 / 9, focal: focal,
      oldScale: oldScale, oldOffset: oldOffset, newScale: 1.8,
      oldRotation: 0, newRotation: math.pi / 12,
    );
    final rotated = Offset(
      content.dx * math.cos(next.rotation) - content.dy * math.sin(next.rotation),
      content.dx * math.sin(next.rotation) + content.dy * math.cos(next.rotation),
    );
    final screenPixel = viewport.center(Offset.zero) + next.offset + rotated * next.scale;
    expect((screenPixel - focal).distance, lessThan(1e-8));
  });
}
