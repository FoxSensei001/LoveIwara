import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';

/// 「浮现」原语（[GlassReveal]）与 [GlassSurface.materialize] 的显隐闸门。
///
/// 2026-08-24 用户报障：右下角「回到顶部」浮钮在很多列表里**一进页面就挂在
/// 那儿**，样式还是老的（没有玻璃），点下去直接穿透到列表；要往下滑很远它才
/// 忽然变成液态玻璃、这时点击才有效。
///
/// 根因是「压材质」被当成了「不在场」：`materialize` 压的是玻璃自身的底色 /
/// 描边 / 投影，里头那枚图标不归它管——玻璃没了、图标还在，外面的
/// `IgnorePointer` 又让它点不着。
void main() {
  /// 图标最终画出来的颜色（`Icon` 会把 `IconTheme.opacity` 乘进 alpha 再交给
  /// 一段文字去画，所以量的是那段文字的 style）。
  Color iconColor(WidgetTester tester) {
    final RichText text = tester.widget<RichText>(
      find.descendant(of: find.byType(Icon), matching: find.byType(RichText)),
    );
    return text.text.style!.color!;
  }

  Widget host(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  Widget fab(double m) => GlassIconButton(
    materialize: m,
    standalone: true,
    icon: const Icon(Icons.vertical_align_top),
    onPressed: () {},
  );

  testWidgets('materialize == 0 的玻璃件不许在屏幕上留下可见图标', (tester) async {
    await tester.pumpWidget(host(fab(0)));
    await tester.pumpAndSettle();
    expect(
      iconColor(tester).a,
      0,
      reason: '玻璃没了图标还在＝一枚没穿玻璃的老式图标钮，正是用户看到的那个',
    );
  });

  testWidgets('materialize 过渡途中图标跟着一起淡，不是最后一刻才消失', (tester) async {
    await tester.pumpWidget(host(fab(0.5)));
    await tester.pumpAndSettle();
    final double alpha = iconColor(tester).a;
    expect(alpha, greaterThan(0));
    expect(alpha, lessThan(1));
  });

  testWidgets('materialize == 1 时图标恢复原色', (tester) async {
    await tester.pumpWidget(host(fab(1)));
    await tester.pumpAndSettle();
    expect(iconColor(tester).a, 1);
  });

  testWidgets('GlassReveal(visible: false) 首帧就什么都不建', (tester) async {
    await tester.pumpWidget(
      host(GlassReveal(visible: false, builder: (context, m) => fab(m))),
    );
    await tester.pumpAndSettle();
    expect(
      find.byType(GlassIconButton),
      findsNothing,
      reason: '「还没滚动」时浮钮就不该存在——用户报的「默认就挂在右下角」',
    );
  });

  testWidgets('GlassReveal 退场跑完整只不建，中途仍在树上', (tester) async {
    Widget build(bool visible) =>
        host(GlassReveal(visible: visible, builder: (context, m) => fab(m)));

    await tester.pumpWidget(build(true));
    await tester.pumpAndSettle();
    expect(find.byType(GlassIconButton), findsOneWidget);
    expect(iconColor(tester).a, 1);

    await tester.pumpWidget(build(false));
    await tester.pump(const Duration(milliseconds: 60));
    expect(
      find.byType(GlassIconButton),
      findsOneWidget,
      reason: '退场动画还在跑，这时候整只拆掉会读成「啪地消失」',
    );
    expect(iconColor(tester).a, lessThan(1));

    await tester.pumpAndSettle();
    expect(find.byType(GlassIconButton), findsNothing);
  });
}
