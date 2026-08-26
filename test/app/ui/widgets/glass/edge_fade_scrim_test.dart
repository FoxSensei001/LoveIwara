import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 顶部蒙层的曲线契约。
///
/// 2026-08-26 用户报障：选择器弹窗「标题行和搜索行的透明度一模一样，只有超出
/// 第二行那一点点才有渐变」，看着像硬切一刀。根因是那几张弹窗把 `solidExtent`
/// （恒定不透明的平台段）设成了**整个 header 高度**，只留 20px 给渐变。
/// 这里把「一条曲线，页面弹窗通用」钉死成数字。
void main() {
  const double peak = 0.72;

  /// 在距顶部 [y] 逻辑像素处采样蒙层的不透明度（LinearGradient 在相邻 stop
  /// 之间是线性插值，这里照做）。
  double alphaAt({
    required double y,
    required double height,
    required double solidExtent,
  }) {
    final (stops, alphas) = EdgeFadeScrim.buildCurve(
      height: height,
      solidExtent: solidExtent,
      peakAlpha: peak,
    );
    final t = (y / height).clamp(0.0, 1.0);
    for (var i = 1; i < stops.length; i++) {
      if (t <= stops[i]) {
        final span = stops[i] - stops[i - 1];
        final u = span == 0 ? 0.0 : (t - stops[i - 1]) / span;
        return alphas[i - 1] + (alphas[i] - alphas[i - 1]) * u;
      }
    }
    return alphas.last;
  }

  test('页面档的尾巴还是 24（标定比例是从这个既有取值反解出来的）', () {
    const double statusBar = 44;
    const double headerExtent = statusBar + GlassTokens.headerRowHeight;
    expect(
      EdgeFadeScrim.overlayHeight(
        headerExtent: headerExtent,
        plateauExtent: statusBar,
      ),
      closeTo(headerExtent + GlassTokens.headerFadeExtent, 0.001),
    );
  });

  test('header 越高尾巴越长——弹窗多行 header 不再共用 24', () {
    // 三行 header 的收藏夹/播放列表选择器：标题 64 + 搜索 52 + 新建 54 + 8。
    const double plateau = 16 + 44 + 4;
    const double headerExtent = plateau + 52 + 54 + 8;
    final tail =
        EdgeFadeScrim.overlayHeight(
          headerExtent: headerExtent,
          plateauExtent: plateau,
        ) -
        headerExtent;
    expect(tail, greaterThan(GlassTokens.headerFadeExtent * 1.5));
  });

  test('页面 / 单行弹窗 / 多行弹窗在 header 底缘残留同一档透明度', () {
    const cases = <(double, double)>[
      // (headerExtent, plateauExtent)
      (44 + 56, 44), // 标准页面
      (64 + 52 + 8, 64), // 添加 Iwara 标签弹窗（标题 + 搜索）
      (64 + 52 + 54 + 8, 64), // 收藏夹 / 播放列表选择器（三行）
      (64 + 52 + 52 + 8, 64), // oreno3d 选择器（标题 + 分段 + 搜索）
    ];
    for (final (headerExtent, plateau) in cases) {
      final height = EdgeFadeScrim.overlayHeight(
        headerExtent: headerExtent,
        plateauExtent: plateau,
      );
      // 平台段末端仍是满值：标题行 / 状态栏底下的内容盖得住。
      expect(
        alphaAt(y: plateau, height: height, solidExtent: plateau),
        closeTo(peak, 0.02),
        reason: 'headerExtent=$headerExtent 的平台段没盖满',
      );
      // header 底缘：只剩峰值的两成出头（smoothstep(0.7) 的余量），内容是从
      // 渐变里溶出来的，不是被一条硬边切开。
      expect(
        alphaAt(y: headerExtent, height: height, solidExtent: plateau),
        closeTo(peak * 0.216, 0.02),
        reason: 'headerExtent=$headerExtent 在 header 底缘的残留不对',
      );
      // header 中段（平台段与底缘之间）必须真的在变，不是一路平到底。
      final mid = alphaAt(
        y: (plateau + headerExtent) / 2,
        height: height,
        solidExtent: plateau,
      );
      expect(mid, lessThan(peak * 0.85));
      expect(mid, greaterThan(peak * 0.25));
    }
  });

  test('旧写法（平台段盖满整个 header）会被 assert 拦下', () {
    expect(
      () => EdgeFadeScrim.top(height: 124 + 20, solidExtent: 124),
      throwsA(isA<AssertionError>()),
    );
  });
}
