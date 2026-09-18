import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/utils/desktop_window_geometry.dart';

void main() {
  // 一块 1512×982 的屏幕，顶上 33 是菜单栏、底下 70 是程序坞。
  const primary = Rect.fromLTWH(0, 33, 1512, 879);

  test('在屏幕里好好的窗口原样恢复', () {
    const stored = Rect.fromLTWH(100, 100, 900, 600);
    expect(
      fitWindowRect(stored, visibleAreas: [primary], primary: primary),
      stored,
    );
  });

  test('上次全屏时关掉存成了比可见区还大的尺寸：改成可见区八成、居中', () {
    const stored = Rect.fromLTWH(291, 96, 2048, 1152);
    final fitted = fitWindowRect(
      stored,
      visibleAreas: [primary],
      primary: primary,
    );
    expect(fitted.width, closeTo(primary.width * 0.8, 0.01));
    expect(fitted.height, closeTo(primary.height * 0.8, 0.01));
    expect(fitted.center.dx, closeTo(primary.center.dx, 0.01));
    expect(fitted.center.dy, closeTo(primary.center.dy, 0.01));
  });

  test('一半露在屏幕右下外：尺寸不变，推回可见区', () {
    const stored = Rect.fromLTWH(1200, 700, 800, 600);
    final fitted = fitWindowRect(
      stored,
      visibleAreas: [primary],
      primary: primary,
    );
    expect(fitted.size, stored.size);
    expect(fitted.right, primary.right);
    expect(fitted.bottom, primary.bottom);
  });

  test('外接屏拔掉了（完全不在任何屏幕上）：在主屏居中', () {
    const stored = Rect.fromLTWH(3000, 200, 800, 600);
    final fitted = fitWindowRect(
      stored,
      visibleAreas: [primary],
      primary: primary,
    );
    expect(fitted.size, stored.size);
    expect(fitted.center, primary.center);
  });

  test('多屏：跟着重叠最多的那块屏幕走，不被拉回主屏', () {
    const left = Rect.fromLTWH(-1920, 0, 1920, 1040);
    const stored = Rect.fromLTWH(-1500, 100, 1000, 700);
    expect(
      fitWindowRect(stored, visibleAreas: [primary, left], primary: primary),
      stored,
    );
  });
}
