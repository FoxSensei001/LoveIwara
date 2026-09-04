import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_floating_tab_bar.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;

/// 全局玻璃材质开关（主题设置里的「玻璃质感」）的闸门。
///
/// 盯三件事：
///   1. 两个供档函数（[chromeGlassBackend] / [panelGlassBackend]）都跟着开关走；
///   2. 切档**立刻生效**——读过档位的 Element 会被标脏重建，不用重启、也不用
///      退出去重进页面（这正是把开关做成 [GlassMaterialScope] 而不是一个普通
///      全局变量的唯一理由）；
///   3. 假玻璃档下真的**一块 lens 都不建**（不是画得淡一点，是整只不在场）。
void main() {
  tearDown(() {
    // 全局 notifier 是跨用例共享的，用完必须还原成出厂档，否则会污染同一批次
    // 里其他按液态档写的用例。
    glassMaterialMode.value = GlassMaterialMode.liquid;
  });

  Future<GlassBackend> sampleChrome(
    WidgetTester tester,
    GlassMaterialMode mode,
  ) async {
    glassMaterialMode.value = mode;
    late GlassBackend sampled;
    await tester.pumpWidget(
      GlassMaterialScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              sampled = chromeGlassBackend(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    return sampled;
  }

  testWidgets('真玻璃档：chrome 走 liquidWidgets，面板走 easyLens', (tester) async {
    expect(
      await sampleChrome(tester, GlassMaterialMode.liquid),
      GlassBackend.liquidWidgets,
    );

    late GlassBackend panel;
    await tester.pumpWidget(
      GlassMaterialScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              panel = panelGlassBackend(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(panel, GlassBackend.easyLens);
  });

  testWidgets('Material 档：chrome 与面板一起落到 material', (tester) async {
    expect(
      await sampleChrome(tester, GlassMaterialMode.material),
      GlassBackend.material,
    );

    late GlassBackend panel;
    await tester.pumpWidget(
      GlassMaterialScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              panel = panelGlassBackend(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(panel, GlassBackend.material);
  });

  testWidgets('切档立刻重建：同一棵树不重新 pumpWidget 也会拿到新档位', (tester) async {
    glassMaterialMode.value = GlassMaterialMode.liquid;
    final sampled = <GlassBackend>[];
    await tester.pumpWidget(
      GlassMaterialScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              sampled.add(chromeGlassBackend(context));
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(sampled, [GlassBackend.liquidWidgets]);

    // 用户在设置页点了「Material」：只改 notifier，树一动没动。
    glassMaterialMode.value = GlassMaterialMode.material;
    await tester.pump();
    expect(sampled, [GlassBackend.liquidWidgets, GlassBackend.material]);

    // 再点回来。
    glassMaterialMode.value = GlassMaterialMode.liquid;
    await tester.pump();
    expect(sampled.last, GlassBackend.liquidWidgets);
  });

  testWidgets('Material 档下 GlassSurface 不建液态玻璃体', (tester) async {
    Future<void> pumpChromeSurface(GlassMaterialMode mode) async {
      glassMaterialMode.value = mode;
      await tester.pumpWidget(
        GlassMaterialScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Builder(
                  builder: (context) => LiquidGlassScope(
                    backend: chromeGlassBackend(context),
                    child: GlassSurface(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      onTap: () {},
                      child: const Center(child: Text('1 / 5')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpChromeSurface(GlassMaterialMode.liquid);
    expect(find.byType(lgw.AdaptiveGlass), findsOneWidget);

    await pumpChromeSurface(GlassMaterialMode.material);
    expect(find.byType(lgw.AdaptiveGlass), findsNothing);
    // Material 档的「玻璃体」是一只不透明的 AnimatedContainer（见
    // [MaterialSurfaceBox]），跟手形变那层 `GlassButton` 也不该在场。
    expect(find.byType(MaterialSurfaceBox), findsOneWidget);
    expect(find.byType(lgw.GlassButton), findsNothing);
  });

  // ⭐ 2026-09-04 用户拍板：底栏**跟着**全局材质开关走了（旧结论「底栏是唯一
  // 的例外、两档都是真液态玻璃」已作废）。Material 档下它整只换成 M3 的
  // `NavigationBar`，果冻指示器 / 磁透镜 / 按住即滑是液态档专有的。
  testWidgets('浮动底栏跟着开关走：液态档是玻璃栏，Material 档是 M3 导航栏', (
    tester,
  ) async {
    final taps = <int>[];
    Future<void> pumpBar(GlassMaterialMode mode) async {
      glassMaterialMode.value = mode;
      await tester.pumpWidget(
        GlassMaterialScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  child: GlassFloatingTabBar(
                    currentIndex: 0,
                    onTap: taps.add,
                    items: const [
                      GlassTabItem(icon: Icons.video_library, label: '视频'),
                      GlassTabItem(icon: Icons.photo_library, label: '图库'),
                      GlassTabItem(icon: Icons.subscriptions, label: '订阅'),
                    ],
                    action: GlassFloatingBarAction(
                      icon: Icons.search,
                      label: '搜索',
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      // 液态档里是弹簧动画，pumpAndSettle 可能一直不静止；推几帧够看结构。
      await tester.pump(const Duration(milliseconds: 400));
    }

    await pumpBar(GlassMaterialMode.liquid);
    expect(find.byType(lgw.GlassTabBar), findsOneWidget);
    expect(find.byType(NavigationIndicator), findsNothing);

    await pumpBar(GlassMaterialMode.material);
    expect(
      find.byType(lgw.GlassTabBar),
      findsNothing,
      reason: 'Material 档下底栏还在采样背景：这一档本该一块玻璃都不建',
    );
    // M3 那颗选中药丸（框架公开的 [NavigationIndicator]）一格一只。
    expect(find.byType(NavigationIndicator), findsNWidgets(3));
    // 换项照常（同项也回调，首页的「再点一次 = 回顶」靠它）。
    // 点图标而不是文字：标签只在选中项在场，未选中那格的 `Text` 高度是 0。
    await tester.tap(find.byIcon(Icons.subscriptions).first);
    await tester.pump(const Duration(milliseconds: 400));
    expect(taps, [2]);
  });

  test('applyGlassMaterialFromConfig 把配置表那个 bool 翻成档位', () {
    applyGlassMaterialFromConfig(false);
    expect(glassMaterialMode.value, GlassMaterialMode.material);
    applyGlassMaterialFromConfig(true);
    expect(glassMaterialMode.value, GlassMaterialMode.liquid);
  });
}
