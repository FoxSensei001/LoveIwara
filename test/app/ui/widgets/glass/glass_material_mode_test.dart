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

  testWidgets('假玻璃档：chrome 与面板一起落回 plain', (tester) async {
    expect(
      await sampleChrome(tester, GlassMaterialMode.plain),
      GlassBackend.plain,
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
    expect(panel, GlassBackend.plain);
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

    // 用户在设置页点了「轻量半透明」：只改 notifier，树一动没动。
    glassMaterialMode.value = GlassMaterialMode.plain;
    await tester.pump();
    expect(sampled, [GlassBackend.liquidWidgets, GlassBackend.plain]);

    // 再点回来。
    glassMaterialMode.value = GlassMaterialMode.liquid;
    await tester.pump();
    expect(sampled.last, GlassBackend.liquidWidgets);
  });

  testWidgets('假玻璃档下 GlassSurface 不建液态玻璃体', (tester) async {
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

    await pumpChromeSurface(GlassMaterialMode.plain);
    expect(find.byType(lgw.AdaptiveGlass), findsNothing);
    // 传统档的玻璃体是一只 AnimatedContainer（半透明底色 + 描边 + 投影）。
    expect(find.byType(AnimatedContainer), findsWidgets);
  });

  // ⭐ 2026-08-26 用户拍板：底栏是**唯一**不跟这个开关走的 chrome——假玻璃档下
  // 它照旧是真液态玻璃（果冻指示器 / 磁透镜 / 按住即滑全靠包内部那套手势，换成
  // 自绘版等于把这块的手感整个抽掉）。曾经的自绘版 `_PlainFloatingTabBar` 已删。
  testWidgets('浮动底栏是唯一的例外：两档都用真液态玻璃', (tester) async {
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

    await pumpBar(GlassMaterialMode.plain);
    expect(
      find.byType(lgw.GlassTabBar),
      findsOneWidget,
      reason: '底栏被收进材质开关了：果冻指示器与按住即滑会一起消失',
    );
    // 换项照常（同项也回调，首页的「再点一次 = 回顶」靠它）。
    await tester.tap(find.text('订阅').first);
    await tester.pump(const Duration(milliseconds: 400));
    expect(taps, [2]);
  });

  test('applyGlassMaterialFromConfig 把配置表那个 bool 翻成档位', () {
    applyGlassMaterialFromConfig(false);
    expect(glassMaterialMode.value, GlassMaterialMode.plain);
    applyGlassMaterialFromConfig(true);
    expect(glassMaterialMode.value, GlassMaterialMode.liquid);
  });
}
