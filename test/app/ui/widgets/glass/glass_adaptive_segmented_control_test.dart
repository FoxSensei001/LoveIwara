import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';

/// 作者页那一行排序：五段，中文标签。窄屏上摆不下 2.5 段是常态。
const _sortItems = <GlassSegmentItem>[
  GlassSegmentItem(label: '最新', icon: Icon(Icons.calendar_today)),
  GlassSegmentItem(label: '点赞数', icon: Icon(Icons.favorite)),
  GlassSegmentItem(label: '观看次数', icon: Icon(Icons.remove_red_eye)),
  GlassSegmentItem(label: '受欢迎', icon: Icon(Icons.star)),
  GlassSegmentItem(label: '趋势', icon: Icon(Icons.trending_up)),
];

void main() {
  late int changedTo;

  Future<void> pump(
    WidgetTester tester, {
    required double width,
    int selectedIndex = 0,
    Widget? replacement,
    List<GlassSegmentItem> items = _sortItems,
  }) async {
    changedTo = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: Row(
                children: [
                  Expanded(
                    child: GlassAdaptiveSegmentedControl(
                      items: items,
                      selectedIndex: selectedIndex,
                      onChanged: (i) => changedTo = i,
                      replacement: replacement,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('宽度够：平铺分段胶囊', (tester) async {
    await pump(tester, width: 900);

    expect(find.byType(GlassSegmentedControl), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    // 五段都在
    for (final item in _sortItems) {
      expect(find.text(item.label), findsOneWidget);
    }
  });

  testWidgets('宽度不够：退化成下拉钮，只剩当前项 + 箭头', (tester) async {
    await pump(tester, width: 140, selectedIndex: 2);

    expect(find.byType(GlassSegmentedControl), findsNothing);
    expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    // 触发位上是当前项（GlassFlipLabel 把每一档都建出来，靠不透明度显隐，
    // 所以别的档也在树里——这里只断言当前项确实在）
    expect(find.text('观看次数'), findsWidgets);
  });

  testWidgets('露不出 2.5 段就翻档：断点与 minWidthFor 一致', (tester) async {
    late double threshold;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            threshold = GlassSegmentedControl.minWidthFor(context, _sortItems);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    // 刚够：平铺（+1 抵掉 Row/Expanded 的取整误差）
    await pump(tester, width: threshold + 1);
    expect(find.byType(GlassSegmentedControl), findsOneWidget);

    // 差一点：下拉
    await pump(tester, width: threshold - 1);
    expect(find.byType(GlassSegmentedControl), findsNothing);
    expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
  });

  testWidgets('段数少于 2.5 时按段数判定，不会平白退化', (tester) async {
    const two = <GlassSegmentItem>[
      GlassSegmentItem(label: '登录'),
      GlassSegmentItem(label: '注册'),
    ];
    late double threshold;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            threshold = GlassSegmentedControl.minWidthFor(context, two);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    await pump(tester, width: threshold + 1, items: two);
    expect(find.byType(GlassSegmentedControl), findsOneWidget);
  });

  testWidgets('下拉钮点开是玻璃菜单，选中回调原样发出', (tester) async {
    await pump(tester, width: 140, selectedIndex: 0);

    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();

    // 菜单里五条都在（触发位自己也顶着一份文案，所以用 findsWidgets）
    expect(find.text('趋势'), findsWidgets);

    await tester.tap(find.text('趋势').last);
    await tester.pumpAndSettle();
    expect(changedTo, 4);
  });

  testWidgets('replacement 顶掉分段/下拉两支，壳还是同一只', (tester) async {
    await pump(
      tester,
      width: 900,
      replacement: const SizedBox(
        key: ValueKey('selection'),
        width: 168,
        child: Text('已选 3 项'),
      ),
    );

    expect(find.byType(GlassSegmentedControl), findsNothing);
    expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    expect(find.text('已选 3 项'), findsOneWidget);
  });
}
