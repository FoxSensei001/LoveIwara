import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';

/// 装进 [GlassButtonGroup] 的键**不许在按下时自绘暗底**。
///
/// 2026-08-24 用户在「跳转到指定页面」弹窗上指出：长按取消 / 跳转时，键身下
/// 浮出一块深色斑。原因是这两个组内变体各自画了一层 `onSurface 8%` 的
/// 矩形 / 圆形——它们身下已经有一整块玻璃胶囊了，再叠一层读起来不是「按下
/// 去了」而是「玻璃上有块脏印子」，长按停留久尤其明显。
///
/// 反馈并没有丢：点按走 [GlassPressable] 的缩放，长按走整只胶囊的跟手蠕动。
/// 这里就锁两件事——按下时**没有**新的不透明装饰色，以及缩放照旧生效。
void main() {
  Future<void> pumpGroup(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: GlassButtonGroup(children: [child])),
        ),
      ),
    );
  }

  /// 收集 [finder] 子树里所有带**不透明填充色**的 BoxDecoration。
  List<Color> filledDecorationColors(WidgetTester tester, Finder finder) {
    return tester
        .widgetList<Container>(
          find.descendant(of: finder, matching: find.byType(Container)),
        )
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.color)
        .whereType<Color>()
        .where((c) => c.a > 0)
        .toList();
  }

  testWidgets('GlassTextActionButton 按下时不出现新的填充色', (tester) async {
    await pumpGroup(
      tester,
      GlassTextActionButton(label: '取消', onPressed: () {}),
    );
    final finder = find.byType(GlassTextActionButton);
    final before = filledDecorationColors(tester, finder);

    // 按住不放（长按那一档正是暗底最碍眼的时候）
    final gesture = await tester.startGesture(tester.getCenter(finder));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      filledDecorationColors(tester, finder),
      before,
      reason: '按下时多画了一层底色——玻璃胶囊里不该再叠暗斑',
    );

    // 缩放反馈仍在
    final scale = tester
        .widgetList<AnimatedScale>(
          find.descendant(of: finder, matching: find.byType(AnimatedScale)),
        )
        .first
        .scale;
    expect(scale, lessThan(1.0), reason: '按下的缩放反馈丢了');

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('组内 GlassIconButton 按下时不出现新的填充色', (tester) async {
    await pumpGroup(
      tester,
      GlassIconButton(icon: const Icon(Icons.close), onPressed: () {}),
    );
    final finder = find.byType(GlassIconButton);
    final before = filledDecorationColors(tester, finder);

    final gesture = await tester.startGesture(tester.getCenter(finder));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      filledDecorationColors(tester, finder),
      before,
      reason: '按下时多画了一层底色——玻璃胶囊里不该再叠圆形暗斑',
    );

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
