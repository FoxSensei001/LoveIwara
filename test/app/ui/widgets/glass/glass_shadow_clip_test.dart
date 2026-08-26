import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// 玻璃投影 vs 裁剪外扩的配对闸门。
///
/// 液态档的投影是画在**玻璃自己那层 RepaintBoundary / 融合层**里的，纹理只有
/// 布局尺寸加上 `clipExpansion` 那么大。影子伸出去的那圈一旦超过外扩，就会被
/// 合成器整段切掉——看到的结果不是「影子被切了一角」，而是**整块玻璃根本没有
/// 影子**（2026-08-26 报障「液态玻璃的按钮、分组、按钮组都没加阴影」的真因：
/// 单块玻璃那条路上 clipExpansion 是 0）。
///
/// 这两个量必须成对改：调大 blur 就得同步调大外扩，而外扩是按纹理面积收 GPU
/// 内存的，所以更常见的做法是**把影子收窄**。
void main() {
  /// 高斯模糊的可见伸展：Flutter 的 `convertRadiusToSigma` 是 radius×0.57735，
  /// 3σ 之外基本看不见，即 ≈ blurRadius×1.732。
  double reachOf(BoxShadow shadow) =>
      shadow.blurRadius * 1.7321 + shadow.spreadRadius;

  void expectCovers(EdgeInsets expansion, String what) {
    for (final shadow in GlassTokens.widgetsShadow()) {
      final double reach = reachOf(shadow);
      expect(
        expansion.bottom,
        greaterThanOrEqualTo(reach + shadow.offset.dy),
        reason: '$what 的下沿装不下投影（blur ${shadow.blurRadius}）',
      );
      expect(
        expansion.top,
        greaterThanOrEqualTo(reach - shadow.offset.dy),
        reason: '$what 的上沿装不下投影（blur ${shadow.blurRadius}）',
      );
      expect(
        expansion.left,
        greaterThanOrEqualTo(reach),
        reason: '$what 的左沿装不下投影（blur ${shadow.blurRadius}）',
      );
      expect(
        expansion.right,
        greaterThanOrEqualTo(reach),
        reason: '$what 的右沿装不下投影（blur ${shadow.blurRadius}）',
      );
    }
  }

  test('单块玻璃的裁剪外扩装得下它自己的投影', () {
    expectCovers(GlassTokens.glassClipExpansion, 'glassClipExpansion');
  });

  test('融合层的裁剪外扩同样装得下', () {
    expectCovers(
      GlassTokens.chromeBlendClipExpansion,
      'chromeBlendClipExpansion',
    );
  });

  test('投影随 materialize 一起淡入，0 端是真的没有', () {
    final full = GlassTokens.widgetsShadow();
    final half = GlassTokens.widgetsShadow(alphaScale: 0.5);
    final none = GlassTokens.widgetsShadow(alphaScale: 0);

    expect(half.length, full.length);
    for (var i = 0; i < full.length; i++) {
      expect(half[i].color.a, closeTo(full[i].color.a / 2, 0.001));
      expect(none[i].color.a, 0);
      // 只压不透明度：blur / 偏移不动，免得淡入途中影子还在缩
      expect(half[i].blurRadius, full[i].blurRadius);
      expect(half[i].offset, full[i].offset);
    }
  });

  test('投影是「贴着玻璃」那一档，不是浮起来的卡片', () {
    for (final shadow in GlassTokens.widgetsShadow()) {
      // 用户 2026-08-26 的原话：扩散不要太大，避免被截断
      expect(shadow.blurRadius, lessThanOrEqualTo(8));
      expect(shadow.offset.dy, lessThanOrEqualTo(3));
      expect(shadow.color.a, lessThanOrEqualTo(0.10));
    }
  });

  // ---- 单块玻璃的投影必须画在形变层外面 ----

  Future<GlassOuterShadow> pumpStandaloneGlass(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    bool elevated = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Scaffold(
          body: Center(
            child: LiquidGlassScope(
              backend: GlassBackend.liquidWidgets,
              child: GlassSurface(
                height: GlassTokens.pillHeight,
                elevated: elevated,
                child: const Text('x'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return tester.widget<GlassOuterShadow>(find.byType(GlassOuterShadow));
  }

  testWidgets('单块玻璃的投影由 GlassOuterShadow 画（浅色下非空）', (tester) async {
    final shadow = await pumpStandaloneGlass(tester);
    expect(
      shadow.shadows,
      isNotEmpty,
      reason:
          '真玻璃档的单块玻璃不能指望包自己画投影：跟手形变层借的 '
          'GlassButton(transparent) 会 ClipPath 把 child 裁到形状里，'
          '画在形状外的影子整圈被切光（2026-08-26 真机实锤）。',
    );
  });

  testWidgets('elevated: false 的玻璃不画投影', (tester) async {
    final shadow = await pumpStandaloneGlass(tester, elevated: false);
    expect(shadow.shadows, isEmpty);
  });

  testWidgets('深色下不画投影（与包内两条路同一口径）', (tester) async {
    final shadow = await pumpStandaloneGlass(
      tester,
      brightness: Brightness.dark,
    );
    expect(
      shadow.shadows,
      isEmpty,
      reason:
          '深色背景本来就吃掉投影，包自己也按 iOS 26 的口径跳过——'
          '两条路必须一致，否则同一屏上成组的和单块的深浅不一样。',
    );
  });
}
