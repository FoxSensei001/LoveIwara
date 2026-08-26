import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_pill.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required String label,
    IconData? icon,
    bool showArrow = true,
    void Function(BuildContext)? onTap,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassDropdownPill(
              label: label,
              icon: icon,
              showArrow: showArrow,
              opensOverlay: showArrow,
              onTap: onTap ?? (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('胶囊上是「当前选中项 ▾」', (tester) async {
    await pump(tester, label: '未分类 · 3', icon: Icons.folder_outlined);

    expect(find.text('未分类 · 3'), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
  });

  testWidgets('点按把触发位自身的 context 交出去（菜单靠它量落点）', (tester) async {
    BuildContext? anchor;
    await pump(
      tester,
      label: '全部',
      onTap: (context) => anchor = context,
    );

    await tester.tap(find.text('全部'));
    await tester.pumpAndSettle();

    expect(anchor, isNotNull);
    expect(anchor!.findRenderObject(), isNotNull);
  });

  testWidgets('showArrow: false 时不画 ▾（点了是跳页面，不是开菜单）', (tester) async {
    await pump(
      tester,
      label: '管理分类',
      icon: Icons.create_new_folder_outlined,
      showArrow: false,
    );

    expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    expect(find.text('管理分类'), findsOneWidget);
  });

  testWidgets('换标签是同一只胶囊做形变，不是两只硬切', (tester) async {
    await pump(tester, label: '全部', icon: Icons.folder_outlined);
    expect(find.byType(GlassDropdownPill), findsOneWidget);

    await pump(tester, label: '壁纸 · 12', icon: Icons.folder_outlined);
    // AnimatedSwitcher 交接期间新旧两份文案会同时在树里，落位后只剩新的
    expect(find.byType(GlassDropdownPill), findsOneWidget);
    expect(find.text('壁纸 · 12'), findsOneWidget);
    expect(find.text('全部'), findsNothing);
  });
}
