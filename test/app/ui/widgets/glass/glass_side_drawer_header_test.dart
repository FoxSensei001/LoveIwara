import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_side_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 侧边抽屉 header 的让位闸门。
///
/// 2026-08-29 报障：「接着看」抽屉里，列表**一开局**就压在池切换胶囊和标题
/// 底下。要的从来不是"别重叠"——header 是浮在内容之上的一层，卡片往上滑时
/// 本来就该从它背后穿过去；错的是**起始位置**：常驻控制行被当成 body 的第一
/// 个孩子，只有标题那一段被让开了。
///
/// 所以这里锁的是机制：控制行走 [GlassSideDrawerShell.headerBottom] 就一定
/// 会被量进 header 高度，`contentPadding.top` 自动把它一起让开。
void main() {
  setUp(() {
    // 液态档的玻璃挂着一条按帧抓背景的 ticker，pumpAndSettle 不会停。
    glassMaterialMode.value = GlassMaterialMode.material;
  });
  tearDown(() {
    glassMaterialMode.value = GlassMaterialMode.liquid;
  });

  /// 搭一只抽屉，返回它下发给 body 的 contentPadding。
  Future<EdgeInsets> pumpDrawer(
    WidgetTester tester, {
    Widget? headerBottom,
  }) async {
    late EdgeInsets reported;
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 380,
              child: GlassSideDrawerShell(
                title: '接着看',
                headerBottom: headerBottom,
                bodyBuilder: (context, contentPadding) {
                  reported = contentPadding;
                  return ListView(
                    padding: contentPadding,
                    children: [
                      const SizedBox(key: ValueKey('first'), height: 84),
                      // 够长才滚得动——第三条用例要真的把列表往上拖。
                      for (var i = 0; i < 12; i++) const SizedBox(height: 84),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    // header 的真实高度是量出来的，量完那一帧才是最终值。
    await tester.pumpAndSettle();
    return reported;
  }

  testWidgets('常驻控制行被量进 header：列表的起始位置落在它下缘', (tester) async {
    await pumpDrawer(
      tester,
      headerBottom: const SizedBox(key: ValueKey('control'), height: 44),
    );

    final controlBottom = tester
        .getRect(find.byKey(const ValueKey('control')))
        .bottom;
    final firstTop = tester.getRect(find.byKey(const ValueKey('first'))).top;

    expect(
      firstTop,
      greaterThanOrEqualTo(controlBottom),
      reason:
          '首屏第一条压在控制行底下了。控制行要走 headerBottom（进 header 那一块），'
          '不能当成 bodyBuilder 的第一个孩子——否则 contentPadding.top 只让开标题行。',
    );
  });

  testWidgets('没有控制行时照旧只让开标题行', (tester) async {
    final withoutControl = await pumpDrawer(tester);
    final withControl = await pumpDrawer(
      tester,
      headerBottom: const SizedBox(height: 44),
    );

    expect(
      withControl.top,
      greaterThan(withoutControl.top),
      reason: 'headerBottom 的高度必须体现在下发的 contentPadding.top 里。',
    );
  });

  testWidgets('内容是从 header 背后滚过去的（不是被推到下面）', (tester) async {
    await pumpDrawer(
      tester,
      headerBottom: const SizedBox(key: ValueKey('control'), height: 44),
    );

    final controlBottom = tester
        .getRect(find.byKey(const ValueKey('control')))
        .bottom;
    await tester.drag(find.byType(ListView), const Offset(0, -60));
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byKey(const ValueKey('first'))).top,
      lessThan(controlBottom),
      reason: '往上滑之后第一条应当滑进控制行背后——header 是浮层，不是占位。',
    );
  });
}
