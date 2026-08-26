import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show AdaptiveGlass, AdaptiveLiquidGlassLayer, AnimatedGlassIndicator;

/// 融合组（[GlassBlendGroup]）的契约。
///
/// 单测跑在 Skia 上（`ImageFilter.isShaderFilterSupported == false`），真正的
/// metaball 平滑并集是 Impeller 的 shader 干的，这里看不见——所以测的是**接线**
/// 而不是像素：
///   - 只在 liquidWidgets 档才建层，另外两档纯透传；
///   - 层里的玻璃走 grouped（`useOwnLayer: false`）；
///   - 融合只吃最外一层，嵌套玻璃被挡在组外；
///   - 换不换融合都不动尺寸（与三档材质同一条硬契约）。
/// 真机上的观感（拖头像→与胶囊融成一坨）只能上机看。
void main() {
  /// 从 [GlassSurface] 的 child 里读「我在不在一个可加入的融合组里」。
  Widget probe(void Function(bool joinable) sink) {
    return Builder(
      builder: (context) {
        sink(GlassBlendGroup.isJoinable(context));
        return const SizedBox(width: 20, height: 20);
      },
    );
  }

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: child))),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('传统档 / easy 档：纯透传，一层玻璃都不多建', (tester) async {
    for (final backend in [GlassBackend.plain, GlassBackend.easyLens]) {
      bool? joinable;
      await pump(
        tester,
        LiquidGlassScope(
          backend: backend,
          child: GlassBlendGroup(
            child: GlassSurface(
              width: 120,
              child: probe((v) => joinable = v),
            ),
          ),
        ),
      );
      expect(
        find.byType(AdaptiveLiquidGlassLayer),
        findsNothing,
        reason: '$backend 不该建融合层',
      );
      expect(joinable, isFalse, reason: '$backend 下不该有可加入的融合组');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('liquidWidgets 档：建一层融合层，里头的玻璃走 grouped', (tester) async {
    bool? joinable;
    await pump(
      tester,
      LiquidGlassScope(
        backend: GlassBackend.liquidWidgets,
        child: GlassBlendGroup(
          child: GlassSurface(width: 120, child: probe((v) => joinable = v)),
        ),
      ),
    );

    expect(find.byType(AdaptiveLiquidGlassLayer), findsOneWidget);
    // 融合只吃最外一层：玻璃自己加入了组，就要把标记从 child 那儿摘掉。
    expect(joinable, isFalse);

    final layer = tester.widget<AdaptiveLiquidGlassLayer>(
      find.byType(AdaptiveLiquidGlassLayer),
    );
    expect(layer.blendAmount, GlassTokens.chromeBlend);
    expect(layer.clipExpansion, GlassTokens.chromeBlendClipExpansion);

    // 这块玻璃必须挂进祖先那一层，而不是自己再开一层。
    final glass = tester.widget<AdaptiveGlass>(find.byType(AdaptiveGlass));
    expect(glass.useOwnLayer, isFalse);
  });

  testWidgets('组外的同一块玻璃仍旧自己成层', (tester) async {
    await pump(
      tester,
      LiquidGlassScope(
        backend: GlassBackend.liquidWidgets,
        child: const GlassSurface(width: 120, child: SizedBox()),
      ),
    );
    final glass = tester.widget<AdaptiveGlass>(find.byType(AdaptiveGlass));
    expect(glass.useOwnLayer, isTrue);
  });

  testWidgets('嵌套玻璃不参与融合：胶囊里头的那块自己成层', (tester) async {
    await pump(
      tester,
      LiquidGlassScope(
        backend: GlassBackend.liquidWidgets,
        child: GlassBlendGroup(
          child: GlassSurface(
            width: 160,
            child: Center(
              child: GlassSurface(
                circle: true,
                height: 24,
                child: const SizedBox(),
              ),
            ),
          ),
        ),
      ),
    );

    final glasses = tester
        .widgetList<AdaptiveGlass>(find.byType(AdaptiveGlass))
        .toList();
    expect(glasses, hasLength(2));
    // 外壳加入融合组，内层（分段控件的果冻指示器就是这个位置）不加入。
    expect(glasses.first.useOwnLayer, isFalse);
    expect(glasses.last.useOwnLayer, isTrue);
  });

  testWidgets('挡在组外 ≠ 不受影响：exclude 的子树仍算「在融合层底下」', (tester) async {
    bool? joinable;
    bool? inside;
    await pump(
      tester,
      LiquidGlassScope(
        backend: GlassBackend.liquidWidgets,
        child: GlassBlendGroup(
          child: GlassSurface(
            width: 120,
            child: Builder(
              builder: (context) {
                joinable = GlassBlendGroup.isJoinable(context);
                inside = GlassBlendGroup.isInside(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    // 不参与吞并（否则滑块会把自己的外壳吃掉）……
    expect(joinable, isFalse);
    // ……但身下的像素确实变了，嵌套的折射镜头要据此收手。
    expect(inside, isTrue);
  });

  testWidgets('组外的子树 isInside 为假', (tester) async {
    bool? inside;
    await pump(
      tester,
      LiquidGlassScope(
        backend: GlassBackend.liquidWidgets,
        child: GlassSurface(
          width: 120,
          child: Builder(
            builder: (context) {
              inside = GlassBlendGroup.isInside(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(inside, isFalse);
  });

  testWidgets('分段控件：融合层底下只画实心药丸，不再画果冻透镜', (tester) async {
    Future<int> indicatorTrips({required bool blend}) async {
      await pump(
        tester,
        LiquidGlassScope(
          backend: GlassBackend.liquidWidgets,
          child: GlassBlendGroup(
            enabled: blend,
            child: SizedBox(
              width: 300,
              child: GlassSegmentedControl(
                flat: true,
                selectedIndex: 0,
                onChanged: (_) {},
                items: const [
                  GlassSegmentItem(label: '视频'),
                  GlassSegmentItem(label: '图库'),
                  GlassSegmentItem(label: '投稿'),
                ],
              ),
            ),
          ),
        ),
      );
      return tester.widgetList(find.byType(AnimatedGlassIndicator)).length;
    }

    // 组外：实心药丸 + 果冻透镜两趟，一如既往。
    expect(await indicatorTrips(blend: false), 2);
    // 融合层底下：透镜整只不画（它会被融合层「照亮」，切 tab 时从药丸底下透出
    // 一层多余的玻璃），只剩那枚不透明药丸。
    expect(await indicatorTrips(blend: true), 1);
  });

  testWidgets('enabled: false 时整只关掉', (tester) async {
    bool? joinable;
    await pump(
      tester,
      LiquidGlassScope(
        backend: GlassBackend.liquidWidgets,
        child: GlassBlendGroup(
          enabled: false,
          child: GlassSurface(width: 120, child: probe((v) => joinable = v)),
        ),
      ),
    );
    expect(find.byType(AdaptiveLiquidGlassLayer), findsNothing);
    expect(joinable, isFalse);
  });

  testWidgets('融合不动尺寸（与三档材质同一条硬契约）', (tester) async {
    Future<Size> sizeOf({required bool blend}) async {
      await pump(
        tester,
        LiquidGlassScope(
          backend: GlassBackend.liquidWidgets,
          child: GlassBlendGroup(
            enabled: blend,
            child: const GlassSurface(
              width: 200,
              child: Center(child: Text('hi')),
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(GlassSurface));
    }

    expect(await sizeOf(blend: false), const Size(200, GlassTokens.pillHeight));
    expect(await sizeOf(blend: true), const Size(200, GlassTokens.pillHeight));
  });

  testWidgets('materialize 撞上融合组：debug 下当场报错，别静默失效', (tester) async {
    await pump(
      tester,
      LiquidGlassScope(
        backend: GlassBackend.liquidWidgets,
        child: GlassBlendGroup(
          child: const GlassSurface(
            width: 120,
            materialize: 0.4,
            child: SizedBox(),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isAssertionError);
  });

  group('GlassHeaderOverlay', () {
    Future<void> pumpHeader(
      WidgetTester tester, {
      required bool liquid,
      bool blendHeader = true,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassHeaderOverlay(
              liquid: liquid,
              blendHeader: blendHeader,
              headerExtent: 56,
              body: const SizedBox(),
              header: const Row(
                children: [
                  GlassSurface(circle: true, height: 44, child: SizedBox()),
                  SizedBox(width: 8),
                  GlassSurface(width: 120, child: SizedBox()),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('liquid: true 的 header 行自动收进融合组', (tester) async {
      await pumpHeader(tester, liquid: true);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AdaptiveLiquidGlassLayer), findsOneWidget);
      // 两块 chrome 都挂进同一层。
      final glasses = tester.widgetList<AdaptiveGlass>(
        find.byType(AdaptiveGlass),
      );
      expect(glasses, hasLength(2));
      expect(glasses.every((g) => !g.useOwnLayer), isTrue);
    });

    testWidgets('liquid: false 的 header 不建层', (tester) async {
      await pumpHeader(tester, liquid: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AdaptiveLiquidGlassLayer), findsNothing);
    });

    testWidgets('blendHeader: false 是逃生口', (tester) async {
      await pumpHeader(tester, liquid: true, blendHeader: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AdaptiveLiquidGlassLayer), findsNothing);
    });
  });
}
