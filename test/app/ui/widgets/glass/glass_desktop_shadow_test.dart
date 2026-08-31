import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show AdaptiveGlass, AdaptiveLiquidGlassLayer;

/// 桌面端（Windows / Linux）的 chrome 必须有影子。
///
/// 背景见 [GlassBlendGroup] 的类注释：那两个平台的画质档钉在 standard，包里
/// 根本不建融合层，而**加入融合组**会把影子整条交给一个不会画影子的层——
/// 2026-08-31 用户报的「macOS 有影子、Windows 跟没有一样」。修法是非 premium
/// 档下融合组整只透传，让每块玻璃回到单块那条路（[GlassOuterShadow]）。
///
/// 所以这里测两件事：接线（透传 + 自己成层）与像素（下缘真的有一段渐变）。
void main() {
  /// 胶囊下缘往外 [span] 个像素，各自相对白底暗多少（0 = 什么都没画）。
  Future<List<int>> shadowProfile(
    WidgetTester tester, {
    required TargetPlatform platform,
    int span = 8,
  }) async {
    debugDefaultTargetPlatformOverride = platform;
    final key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.light),
        home: RepaintBoundary(
          key: key,
          child: SizedBox(
            width: 300,
            height: 200,
            child: ColoredBox(
              color: const Color(0xFFFFFFFF),
              child: Center(
                child: LiquidGlassScope(
                  backend: GlassBackend.liquidWidgets,
                  child: GlassBlendGroup(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        GlassSurface(
                          width: 120,
                          liquidTouch: false,
                          child: SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    final pill = tester.getRect(find.byType(GlassSurface).first);
    final box = tester.getRect(find.byKey(key));
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = boundary.toImageSync();
    late final ByteData data;
    await tester.runAsync(() async {
      data = (await image.toByteData())!;
    });

    final x = (pill.center.dx - box.left).round();
    final bottom = (pill.bottom - box.top).round();
    final profile = <int>[
      for (var dy = 1; dy <= span; dy++)
        255 - data.getUint8(((bottom + dy) * image.width + x) * 4),
    ];
    debugDefaultTargetPlatformOverride = null;
    return profile;
  }

  testWidgets('windows：融合组整只透传，玻璃自己成层', (tester) async {
    // ⚠️ 复位要写在**测试体最后**：`addTearDown` 跑在框架校验 debug 变量之后，
    // 会被判成「测试改了 foundation 的 debug 变量」。
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    bool? joinable;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiquidGlassScope(
              backend: GlassBackend.liquidWidgets,
              child: GlassBlendGroup(
                child: GlassSurface(
                  width: 120,
                  child: Builder(
                    builder: (context) {
                      joinable = GlassBlendGroup.isJoinable(context);
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byType(AdaptiveLiquidGlassLayer),
      findsNothing,
      reason: 'standard 档下建了层也不会融合，只会吃掉影子',
    );
    expect(joinable, isFalse);
    expect(
      tester.widget<AdaptiveGlass>(find.byType(AdaptiveGlass)).useOwnLayer,
      isTrue,
      reason: '回到单块那条路才有 GlassOuterShadow',
    );
    expect(find.byType(GlassOuterShadow), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('windows：胶囊下缘有一段递减的影子，而不是一条发丝', (tester) async {
    final profile = await shadowProfile(
      tester,
      platform: TargetPlatform.windows,
    );

    // 修之前这里是 [18, 0, 0, 0, 0, 0, 0, 0]：贴边一条发丝，2px 外全空。
    expect(profile.first, greaterThan(0));
    expect(
      profile.take(5).where((v) => v > 0).length,
      greaterThanOrEqualTo(4),
      reason: '影子应当摊开好几像素，实测 profile=$profile',
    );
    // 且是递减的（不是一条硬边）。
    expect(profile[1], lessThanOrEqualTo(profile[0]));
    expect(profile[4], lessThan(profile[1]));
  });

  testWidgets('android（premium 档）：融合组照常建层', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiquidGlassScope(
              backend: GlassBackend.liquidWidgets,
              child: const GlassBlendGroup(
                child: GlassSurface(width: 120, child: SizedBox()),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AdaptiveLiquidGlassLayer), findsOneWidget);
    expect(
      tester.widget<AdaptiveGlass>(find.byType(AdaptiveGlass)).useOwnLayer,
      isFalse,
    );
    debugDefaultTargetPlatformOverride = null;
  });
}
