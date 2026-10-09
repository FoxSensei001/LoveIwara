import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/glass_appearance_settings.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_appearance_scope.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;

void main() {
  setUp(() => glassAppearance.value = GlassAppearanceSettings.defaults);
  tearDown(() => glassAppearance.value = GlassAppearanceSettings.defaults);

  test('持久化参数兼容旧配置，并限制异常、非有限和越界数值', () {
    expect(
      GlassAppearanceSettings.fromMap(null).toMap(),
      GlassAppearanceSettings.defaults.toMap(),
    );
    final settings = GlassAppearanceSettings.fromMap({
      'quality': 'unknown',
      'opacity': 4,
      'blur': double.nan,
      'thickness': -1,
      'refractiveIndex': double.infinity,
      'shadows': 'false',
      'panelBlur': 100,
    });
    expect(settings.quality, GlassQualityPreference.auto);
    expect(settings.opacity, 0.8);
    expect(settings.blur, 0);
    expect(settings.thickness, 0);
    expect(settings.refractiveIndex, 1.2);
    expect(settings.shadows, isTrue);
    expect(settings.panelBlur, 20);
    final changed = settings
        .withValue('quality', 'premium')
        .withValue('blur', 3.5);
    expect(
      GlassAppearanceSettings.fromMap(changed.toMap()).toMap(),
      changed.toMap(),
    );
  });

  test('用户参数传入真实 shader，底色更实且投影可关闭', () {
    final cs = ColorScheme.fromSeed(seedColor: Colors.blue);
    expect(GlassTokens.widgetsTint(cs).a, closeTo(0.24, 0.001));
    glassAppearance.value = const GlassAppearanceSettings(
      blur: 3,
      opacity: 0.4,
      thickness: 30,
      refractiveIndex: 1.6,
      lightIntensity: 0.8,
      saturation: 1.1,
      chromaticAberration: 0.02,
      shadows: false,
      panelBlur: 7,
      panelOpacity: 0.6,
    );
    final actual = GlassTokens.widgetsGlass(
      cs,
      tint: GlassTokens.widgetsTint(cs),
    );
    expect(actual.blur, 3);
    expect(actual.glassColor.a, closeTo(0.4, 0.001));
    expect(actual.thickness, 30);
    expect(actual.refractiveIndex, 1.6);
    expect(actual.lightIntensity, 0.8);
    expect(actual.saturation, 1.1);
    expect(actual.chromaticAberration, 0.02);
    expect(actual.shadow, isEmpty);
    expect(GlassTokens.liquidTint(cs).a, closeTo(0.6, 0.001));
    expect(GlassTokens.liquidBlur.sigmaX, 7);
  });

  testWidgets('切换固定画质和参数保留 Navigator 与当前路由', (tester) async {
    lgw.GlassQuality? effective;
    await tester.pumpWidget(
      wrapLiquidGlassApplication(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              effective = chromeGlassQuality(context);
              return const Text('home');
            },
          ),
        ),
      ),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      MaterialPageRoute<void>(
        builder: (context) => Builder(
          builder: (context) {
            effective = chromeGlassQuality(context);
            return const Text('retained route');
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    for (final preference in [
      GlassQualityPreference.standard,
      GlassQualityPreference.premium,
    ]) {
      glassAppearance.value = GlassAppearanceSettings(
        quality: preference,
        opacity: 0.4,
      );
      await tester.pump();
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)),
        same(navigator),
      );
      expect(find.text('retained route'), findsOneWidget);
      expect(
        effective,
        preference == GlassQualityPreference.standard
            ? lgw.GlassQuality.standard
            : lgw.GlassQuality.premium,
      );
      final scope = tester.widget<lgw.GlassAdaptiveScope>(
        find.byType(lgw.GlassAdaptiveScope),
      );
      expect(scope.minQuality, effective);
      expect(scope.maxQuality, effective);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Material 明暗优先于系统明暗', (tester) async {
    Brightness? resolved;
    await tester.pumpWidget(
      wrapLiquidGlassApplication(
        adaptiveQuality: false,
        child: MaterialApp(
          theme: ThemeData.light(),
          home: MediaQuery(
            data: const MediaQueryData(platformBrightness: Brightness.dark),
            child: Builder(
              builder: (context) {
                resolved = lgw.GlassTheme.brightnessOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    expect(resolved, Brightness.light);
  });

  testWidgets('高刷屏按 120Hz 配置预算而非库的 60Hz 默认值', (tester) async {
    tester.view.display.refreshRate = 120;
    addTearDown(tester.view.display.resetRefreshRate);
    await tester.pumpWidget(
      wrapLiquidGlassApplication(child: const MaterialApp(home: SizedBox())),
    );
    final scope = tester.widget<lgw.GlassAdaptiveScope>(
      find.byType(lgw.GlassAdaptiveScope),
    );
    expect(scope.targetFrameMs * 1.5, lessThanOrEqualTo(1000 / 120));
    expect(scope.minQuality, lgw.GlassQuality.standard);
    expect(scope.warmupPremiumThresholdMs, scope.targetFrameMs * 1.5);
  });

  for (final quality in [lgw.GlassQuality.standard, lgw.GlassQuality.minimal]) {
    testWidgets('降到 $quality 时融合层和低层玻璃一起降档', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: lgw.GlassAdaptiveScope(
            minQuality: quality,
            maxQuality: quality,
            initialQuality: quality,
            child: LiquidGlassScope(
              backend: GlassBackend.liquidWidgets,
              child: GlassBlendGroup(
                child: const Center(
                  child: GlassSurface(width: 120, child: Text('glass')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(lgw.AdaptiveLiquidGlassLayer), findsNothing);
      final glass = tester.widget<lgw.AdaptiveGlass>(
        find.byType(lgw.AdaptiveGlass),
      );
      expect(glass.quality, quality);
      expect(glass.useOwnLayer, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  test('清玻璃默认保留折射与投影，关闭独立模糊', () {
    final cs = ColorScheme.fromSeed(seedColor: Colors.blue);
    final settings = GlassTokens.widgetsGlass(
      cs,
      tint: GlassTokens.widgetsTint(cs),
    );
    expect(settings.blur, 0);
    expect(settings.thickness, greaterThan(0));
    expect(settings.shadow, isNotEmpty);
  });
}
