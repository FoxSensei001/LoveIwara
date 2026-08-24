import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;

/// 「三档尺寸语义完全一致」这条约定的闸门（见 [GlassSurface] 的类注释）。
///
/// 液态档的跟手形变是借 `GlassButton.custom(transparent)` 实现的，而那只
/// widget 内部用 `Align(widthFactor: 1)` 抱内容——`RenderPositionedBox` 拿
/// `constraints.loosen()` 量孩子，父级给的 min / tight 尺寸传不进玻璃。
/// 2026-08-24 真机报的「宽屏分页栏中间那条页码长条变成了圆的、加载光环还留在
/// 原来那条长条上」就是这一条：占位 68 宽，玻璃只有文字那么宽。
///
/// 所以这里盯的不是「像素好不好看」，而是**换档不许改布局**：同一棵树在传统档
/// 与液态档下，玻璃体本身量出来必须一样大。
void main() {
  /// 玻璃体（真正画出材质的那一层）的尺寸。两档的实现不同，量的东西也不同：
  /// 传统档是 `AnimatedContainer`，液态档是包里的 `AdaptiveGlass`。
  Size glassBodySize(WidgetTester tester, GlassBackend backend) {
    final Finder finder = backend == GlassBackend.liquidWidgets
        ? find.byType(lgw.AdaptiveGlass)
        : find.byType(AnimatedContainer);
    return tester.getSize(finder.first);
  }

  Future<void> pumpBoth(
    WidgetTester tester,
    Widget Function(Widget pill) frame, {
    required void Function(Size plain, Size liquid) expectSizes,
    Widget? pill,
  }) async {
    final Map<GlassBackend, Size> sizes = <GlassBackend, Size>{};
    for (final GlassBackend backend in <GlassBackend>[
      GlassBackend.plain,
      GlassBackend.liquidWidgets,
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LiquidGlassScope(
                backend: backend,
                child: frame(
                  pill ??
                      GlassSurface(
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
      );
      // 材质有一段 pressDuration 的隐式过渡，量之前先跑完。
      await tester.pumpAndSettle();
      sizes[backend] = glassBodySize(tester, backend);
    }
    expectSizes(sizes[GlassBackend.plain]!, sizes[GlassBackend.liquidWidgets]!);
  }

  testWidgets('父级给的 minWidth 要落在玻璃身上，不只是占位', (tester) async {
    await pumpBoth(
      tester,
      (pill) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 180),
            child: pill,
          ),
        ],
      ),
      expectSizes: (plain, liquid) {
        expect(plain.width, 180, reason: '传统档一直是老实吃 min 的，这条先兜住基准');
        expect(
          liquid.width,
          plain.width,
          reason:
              '液态档的玻璃缩回了内容宽度：占位是长条、画出来的玻璃短一截'
              '（分页栏页码长条变成圆的就是这个）',
        );
      },
    );
  });

  testWidgets('父级钉死的宽高要落在玻璃身上', (tester) async {
    await pumpBoth(
      tester,
      (pill) => SizedBox(width: 200, height: 60, child: pill),
      expectSizes: (plain, liquid) {
        expect(plain, const Size(200, 60));
        expect(liquid, plain);
      },
    );
  });

  testWidgets('父级没给尺寸时仍然贴着内容，不许被撑开', (tester) async {
    await pumpBoth(
      tester,
      (pill) => Row(mainAxisSize: MainAxisSize.min, children: <Widget>[pill]),
      expectSizes: (plain, liquid) {
        // 传统档的描边是画在盒子外沿的（`Border.all`），自然宽比液态档多出
        // 两条描边——只差这一点，不是布局差异。
        expect(liquid.width, closeTo(plain.width, 2));
        expect(liquid.width, lessThan(120));
        expect(liquid.height, 36);
      },
    );
  });

  testWidgets('长在 IntrinsicHeight 底下不许抛（所以没用 LayoutBuilder）', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiquidGlassScope(
              backend: GlassBackend.liquidWidgets,
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GlassSurface(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      onTap: () {},
                      child: const Center(child: Text('1 / 5')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
