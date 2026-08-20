import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';

void main() {
  late BuildContext ctx;

  Future<void> pumpProbe(WidgetTester tester, {TextScaler? scaler}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final child = Builder(
              builder: (inner) {
                ctx = inner;
                return const SizedBox.shrink();
              },
            );
            if (scaler == null) return child;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: scaler),
              child: child,
            );
          },
        ),
      ),
    );
  }

  testWidgets('宽度按真实文案量：标签越长要求越宽', (tester) async {
    await pumpProbe(tester);

    final short = GlassSegmentedControl.minWidthFor(ctx, const [
      GlassSegmentItem(label: '视频'),
      GlassSegmentItem(label: '图库'),
      GlassSegmentItem(label: '投稿'),
    ]);
    final long = GlassSegmentedControl.minWidthFor(ctx, const [
      GlassSegmentItem(label: 'Video'),
      GlassSegmentItem(label: 'Gallery'),
      GlassSegmentItem(label: 'Posts'),
    ]);
    expect(long, greaterThan(short));
  });

  testWidgets('取最宽的两段：不管横向滚到哪儿都保证两段完整', (tester) async {
    await pumpProbe(tester);

    // 只有最宽的两段参与计算，第三段再短也不影响
    final a = GlassSegmentedControl.minWidthFor(ctx, const [
      GlassSegmentItem(label: 'Gallery'),
      GlassSegmentItem(label: 'Trending'),
      GlassSegmentItem(label: 'A'),
    ]);
    final b = GlassSegmentedControl.minWidthFor(ctx, const [
      GlassSegmentItem(label: 'Gallery'),
      GlassSegmentItem(label: 'Trending'),
      GlassSegmentItem(label: 'AAAAAAAAAAAA'),
    ]);
    expect(b, greaterThan(a), reason: '第三段变得比前两段还宽时，要求也要跟着涨');

    // 段数不足 minVisibleItems 时按实际段数算，不虚报
    final single = GlassSegmentedControl.minWidthFor(ctx, const [
      GlassSegmentItem(label: 'Only'),
    ]);
    final pair = GlassSegmentedControl.minWidthFor(ctx, const [
      GlassSegmentItem(label: 'Only'),
      GlassSegmentItem(label: 'Only'),
    ]);
    expect(single, lessThan(pair));
    expect(GlassSegmentedControl.minWidthFor(ctx, const []), 0);
  });

  testWidgets('带图标的段要多留出图标宽度', (tester) async {
    await pumpProbe(tester);

    final plain = GlassSegmentedControl.minWidthFor(ctx, const [
      GlassSegmentItem(label: 'Latest'),
      GlassSegmentItem(label: 'Popular'),
    ]);
    final withIcons = GlassSegmentedControl.minWidthFor(ctx, const [
      GlassSegmentItem(label: 'Latest', icon: Icon(Icons.schedule)),
      GlassSegmentItem(label: 'Popular', icon: Icon(Icons.star)),
    ]);
    expect(
      withIcons - plain,
      moreOrLessEquals(
        (GlassSegmentedControl.itemIconSize +
                GlassSegmentedControl.itemIconGap) *
            2,
        epsilon: 0.01,
      ),
    );
  });

  testWidgets('放大字号时要求同步变宽（阈值不再是写死的魔法数字）', (tester) async {
    const items = [
      GlassSegmentItem(label: 'Video'),
      GlassSegmentItem(label: 'Gallery'),
    ];
    await pumpProbe(tester);
    final normal = GlassSegmentedControl.minWidthFor(ctx, items);

    await pumpProbe(tester, scaler: const TextScaler.linear(1.6));
    final scaled = GlassSegmentedControl.minWidthFor(ctx, items);

    expect(scaled, greaterThan(normal));
  });

  testWidgets('量出来的宽度真的够摆下两段（拿真实布局对账）', (tester) async {
    const items = [
      GlassSegmentItem(label: 'Trending'),
      GlassSegmentItem(label: 'Gallery'),
    ];
    await pumpProbe(tester);
    final required = GlassSegmentedControl.minWidthFor(ctx, items);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: required,
              child: GlassSegmentedControl(
                items: items,
                selectedIndex: 0,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 两段都完整落在胶囊里（没有被横向裁掉）
    final capsule = tester.getRect(find.byType(GlassSegmentedControl));
    for (final label in ['Trending', 'Gallery']) {
      final rect = tester.getRect(find.text(label));
      expect(rect.left, greaterThanOrEqualTo(capsule.left - 0.5), reason: label);
      expect(
        rect.right,
        lessThanOrEqualTo(capsule.right + 0.5),
        reason: label,
      );
    }
  });
}
