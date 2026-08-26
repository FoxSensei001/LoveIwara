import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';

/// GlassDraggableBottomSheet 只收口「壳」：玻璃材质 + 顶部圆角 + 拖拽把手 +
/// 安全区，内容的滚动交给它透传出来的 `scrollController`。这里只测接线
/// （壳画出来了、把手在、controller 确实接到了内容的可滚动组件上），
/// 不测折射视觉，也不测 DraggableScrollableSheet 自身的吸附手感（那是包的事）。
void main() {
  /// 直接把壳 pump 进一个有界高度的 Scaffold（DraggableScrollableSheet 需要
  /// 有界的父约束）；builder 里接一条能滚动的长 ListView，并把拿到的
  /// scrollController 抛回外面供断言。
  Future<ScrollController> pumpSheet(
    WidgetTester tester, {
    bool snap = false,
  }) async {
    late ScrollController captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassDraggableBottomSheet(
            initialChildSize: 0.6,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            snap: snap,
            builder: (context, scrollController) {
              captured = scrollController;
              return ListView.builder(
                controller: scrollController,
                itemCount: 60,
                itemBuilder: (context, i) => SizedBox(
                  height: 48,
                  child: Center(child: Text('item $i')),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return captured;
  }

  testWidgets('能正常 build：壳 + 内容都画出来了，无异常', (tester) async {
    await pumpSheet(tester);
    expect(tester.takeException(), isNull);
    // 壳使用 Material 保证非透明底色。
    expect(find.byType(Material), findsWidgets);
    // 内容跟着一起渲染。
    expect(find.text('item 0'), findsOneWidget);
  });

  testWidgets('顶部拖拽把手渲染出来了（36x4 圆角横条）', (tester) async {
    await pumpSheet(tester);
    final handle = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.constraints == BoxConstraints.tightFor(width: 36, height: 4),
    );
    expect(handle, findsOneWidget);
  });

  testWidgets('scrollController 确实传给了 builder，并接到了内容的可滚动组件上', (
    tester,
  ) async {
    final controller = await pumpSheet(tester);
    // builder 拿到的是个真正的 ScrollController……
    expect(controller, isA<ScrollController>());
    // ……而且它接到了内容的 ListView 上（有 client 才能驱动滚动/拖拽变高共用
    // 同一条手势链路，这正是不能直接套 GlassBottomSheet 的原因）。
    expect(controller.hasClients, isTrue);

    final listFinder = find.byType(Scrollable);
    expect(listFinder, findsWidgets);
    // 拿这个 controller 真的能滚动内容。
    controller.jumpTo(200);
    await tester.pump();
    expect(controller.offset, 200);
  });

  testWidgets('snap 参数透传给底层 DraggableScrollableSheet', (tester) async {
    await pumpSheet(tester, snap: true);
    final sheet = tester.widget<DraggableScrollableSheet>(
      find.byType(DraggableScrollableSheet),
    );
    expect(sheet.snap, isTrue);
    expect(sheet.initialChildSize, 0.6);
    expect(sheet.minChildSize, 0.2);
    expect(sheet.maxChildSize, 0.9);
  });
}
