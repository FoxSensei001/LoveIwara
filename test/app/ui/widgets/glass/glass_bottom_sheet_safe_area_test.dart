import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 底部弹层的系统安全区（导航条/手势条）必须让在**壳自己的背景里面**。
///
/// 2026-08-27 的回归：两个壳都在最外面套了一层 `Padding(bottom: 安全区)`，
/// 于是不透明的 `Material` 只铺到导航条上沿——导航条那条带露出的是弹层遮罩，
/// 用户看到的是「弹层先隔了一条安全区才出现，导航条那片直接变透明」。
///
/// 这里量的是几何：壳的背景必须一直贴到可用区域底边，同时内容仍然避开导航条。
void main() {
  const double navBar = 48;
  const Size screen = Size(400, 600);

  Widget wrap(Widget child, {double bottomPadding = navBar}) {
    return slang.TranslationProvider(
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: screen,
            padding: EdgeInsets.only(bottom: bottomPadding),
            viewPadding: EdgeInsets.only(bottom: bottomPadding),
          ),
          child: Align(alignment: Alignment.bottomCenter, child: child),
        ),
      ),
    );
  }

  /// 壳的背景（不透明 Material）。
  Finder shellMaterialOf(Type sheetType) => find
      .descendant(of: find.byType(sheetType), matching: find.byType(Material))
      .first;

  testWidgets('GlassBottomSheet：背景铺到屏幕底边，内容避开导航条', (tester) async {
    await tester.pumpWidget(
      wrap(
        const GlassBottomSheet(
          padding: EdgeInsets.zero,
          child: SizedBox(height: 100, child: Text('body')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final screenBottom = tester.getRect(find.byType(MaterialApp)).bottom;
    final shell = tester.getRect(shellMaterialOf(GlassBottomSheet));
    final body = tester.getRect(find.text('body'));

    // 背景没有被抬起来：一直贴到底边。
    expect(shell.bottom, screenBottom);
    // 内容仍然让开了导航条那条带。
    expect(body.bottom, lessThanOrEqualTo(screenBottom - navBar));
  });

  testWidgets('GlassBottomSheet：没有底部安全区时不白留一条', (tester) async {
    await tester.pumpWidget(
      wrap(
        const GlassBottomSheet(
          padding: EdgeInsets.zero,
          child: SizedBox(height: 100, child: Text('body')),
        ),
        bottomPadding: 0,
      ),
    );
    await tester.pumpAndSettle();

    final screenBottom = tester.getRect(find.byType(MaterialApp)).bottom;
    final shell = tester.getRect(shellMaterialOf(GlassBottomSheet));
    final body = tester.getRect(find.text('body'));

    expect(shell.bottom, screenBottom);
    expect(body.bottom, screenBottom);
  });

  testWidgets('GlassDraggableBottomSheet：背景铺到屏幕底边，内容避开导航条', (tester) async {
    await tester.pumpWidget(
      wrap(
        SizedBox(
          height: screen.height,
          child: GlassDraggableBottomSheet(
            initialChildSize: 0.6,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (context, scrollController) => ListView(
              controller: scrollController,
              children: const [SizedBox(height: 600, child: Text('body'))],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final screenBottom = tester.getRect(find.byType(MaterialApp)).bottom;
    final shell = tester.getRect(shellMaterialOf(GlassDraggableBottomSheet));
    final list = tester.getRect(find.byType(ListView));

    expect(shell.bottom, screenBottom);
    expect(list.bottom, lessThanOrEqualTo(screenBottom - navBar));
  });
}
