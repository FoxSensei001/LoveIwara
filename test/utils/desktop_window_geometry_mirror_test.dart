import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/utils/desktop_window_geometry_mirror.dart';

void main() {
  setUp(() => DesktopWindowGeometryMirror.appliedByRunner = null);
  tearDown(() => DesktopWindowGeometryMirror.appliedByRunner = null);

  test('认出 runner 的回执', () {
    DesktopWindowGeometryMirror.adoptRunnerGeometry([
      'video.mp4',
      '--startup-entry-ms=40000',
      '--startup-window-geometry=159,125,1638,883',
    ]);
    expect(
      DesktopWindowGeometryMirror.appliedByRunner,
      const Rect.fromLTWH(159, 125, 1638, 883),
    );
  });

  test('没有这条参数时保持 null——非 Windows 平台就是这样', () {
    DesktopWindowGeometryMirror.adoptRunnerGeometry(['--startup-entry-ms=1']);
    expect(DesktopWindowGeometryMirror.appliedByRunner, isNull);
  });

  test('字段数不对就整条丢掉，不要半个矩形', () {
    DesktopWindowGeometryMirror.adoptRunnerGeometry([
      '--startup-window-geometry=159,125,1638',
    ]);
    expect(DesktopWindowGeometryMirror.appliedByRunner, isNull);
  });

  test('有一个字段解析不出来就整条丢掉', () {
    DesktopWindowGeometryMirror.adoptRunnerGeometry([
      '--startup-window-geometry=159,125,wide,883',
    ]);
    expect(DesktopWindowGeometryMirror.appliedByRunner, isNull);
  });

  test('负坐标要留住——窗口可以摆在主屏左边的那块屏上', () {
    DesktopWindowGeometryMirror.adoptRunnerGeometry([
      '--startup-window-geometry=-1920,-80,1280,720',
    ]);
    expect(
      DesktopWindowGeometryMirror.appliedByRunner,
      const Rect.fromLTWH(-1920, -80, 1280, 720),
    );
  });
}
