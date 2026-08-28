import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/video_zoom_view.dart';

/// 滚轮缩放 / 旋转的步长标定。
///
/// 原来的式子是 `exp(-dy / 200)`，把**平台常数**当成了连续量：鼠标滚轮每拨一格
/// 只发一次事件，dy 是平台自己定的（本项目真机实测安卓 64，桌面端一般 100~120）。
/// 于是安卓一格就放大 1.377 倍、桌面端一格 1.65~1.82 倍——0.5~3.0 的整个缩放
/// 区间只有五到七格宽，「滚一下就到头」；更要命的是倍率永远落不回 1.0，用户
/// 滚出去就再也回不到原始大小。
///
/// 现在离散一格**只看方向不看数值**，连续滚动（触控板）才按 delta 比例走。
void main() {
  const androidNotch = 64.0;
  const desktopNotch = 120.0;

  group('离散滚轮：一格一个固定步长，与平台 delta 无关', () {
    test('安卓与桌面端的一格，缩放量完全一致', () {
      final android = wheelScaleFactorFor(
        scrollDeltaY: -androidNotch,
        discrete: true,
      );
      final desktop = wheelScaleFactorFor(
        scrollDeltaY: -desktopNotch,
        discrete: true,
      );
      expect(android, desktop);
      expect(android, kWheelNotchZoomFactor);
    });

    test('往上滚放大、往下滚缩小，且两者互为倒数——滚回去精确回到原点', () {
      final zoomIn = wheelScaleFactorFor(scrollDeltaY: -androidNotch, discrete: true);
      final zoomOut = wheelScaleFactorFor(scrollDeltaY: androidNotch, discrete: true);
      expect(zoomIn, greaterThan(1.0));
      expect(zoomOut, lessThan(1.0));
      expect(zoomIn * zoomOut, closeTo(1.0, 1e-12));
    });

    test('滚出去再滚回来，恰好落回 1.0（吸附回原始大小的分支才够得着）', () {
      var scale = 1.0;
      for (var i = 0; i < 5; i++) {
        scale *= wheelScaleFactorFor(scrollDeltaY: -androidNotch, discrete: true);
      }
      for (var i = 0; i < 5; i++) {
        scale *= wheelScaleFactorFor(scrollDeltaY: androidNotch, discrete: true);
      }
      // 播放器在 |scale-1| < 0.01 时吸附回原始状态。
      expect((scale - 1.0).abs(), lessThan(0.01));
    });

    test('整个 0.5~3.0 区间要有足够多格可停，不能滚一下就到头', () {
      int notchesFrom(double start, double target, double dy) {
        var scale = start;
        var n = 0;
        while (dy < 0 ? scale < target : scale > target) {
          scale *= wheelScaleFactorFor(scrollDeltaY: dy, discrete: true);
          n++;
          if (n > 1000) break;
        }
        return n;
      }

      // 旧行为：安卓 4 格到顶、3 格到底；桌面端更少。
      expect(notchesFrom(1.0, 3.0, -androidNotch), greaterThanOrEqualTo(8));
      expect(notchesFrom(1.0, 0.5, androidNotch), greaterThanOrEqualTo(5));
    });

    test('旋转：一格固定角度，9 格转过 90 度', () {
      final step = wheelRotationDeltaFor(
        scrollDeltaY: androidNotch,
        discrete: true,
      );
      expect(step, kWheelNotchRotation);
      expect(step * 9, closeTo(math.pi / 2, 1e-9));
      expect(
        wheelRotationDeltaFor(scrollDeltaY: -androidNotch, discrete: true),
        -step,
      );
    });

    test('delta 为 0 时不动', () {
      expect(wheelScaleFactorFor(scrollDeltaY: 0, discrete: true), 1.0);
      expect(wheelRotationDeltaFor(scrollDeltaY: 0, discrete: true), 0.0);
    });
  });

  group('连续滚动（触控板）仍按 delta 比例', () {
    test('delta 越大变化越大', () {
      final small = wheelScaleFactorFor(scrollDeltaY: -5, discrete: false);
      final large = wheelScaleFactorFor(scrollDeltaY: -20, discrete: false);
      expect(large, greaterThan(small));
      expect(small, greaterThan(1.0));
    });

    test('公式与历史一致，触控板手感不因这次改动而变', () {
      expect(
        wheelScaleFactorFor(scrollDeltaY: -12, discrete: false),
        math.exp(12 / kContinuousScrollScaleFactor),
      );
      expect(
        wheelRotationDeltaFor(scrollDeltaY: 12, discrete: false),
        12 / kContinuousScrollRotateFactor,
      );
    });
  });

  group('设备类别判定', () {
    test('触控板算连续，鼠标算离散', () {
      expect(isDiscreteScrollNotch(PointerDeviceKind.trackpad), isFalse);
      expect(isDiscreteScrollNotch(PointerDeviceKind.mouse), isTrue);
    });
  });
}
