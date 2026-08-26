import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// [GlassAlertDialog] 的液态接线回归。
///
/// 2026-08-24 用户在真机上纠正了一次范围理解错误：面板背景不该跟着接液态
/// （之前误把整块 GlassSurface 一起包进 LiquidGlassScope，背景变成了真的
/// 折射玻璃）——只有标题行的关闭钮、动作行的按钮组该换成新液态玻璃并支持
/// 长按蠕动。这里锁死这条边界，回归就是这批测试要抓的。
void main() {
  const bodyKey = Key('dialog-body-probe');

  Future<void> pump(WidgetTester tester, Widget dialog) async {
    late BuildContext hostContext;
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              hostContext = context;
              return const Scaffold(body: SizedBox.expand());
            },
          ),
        ),
      ),
    );
    showAppDialog(dialog, dialogContext: hostContext, useRootNavigator: false);
    await tester.pumpAndSettle();
  }

  testWidgets('面板背景不接液态：body 里读到的 scope 仍是外层的（默认 plain）', (
    tester,
  ) async {
    await pump(
      tester,
      GlassAlertDialog(
        title: '标题',
        content: Builder(
          builder: (context) =>
              Text(LiquidGlassScope.of(context).name, key: bodyKey),
        ),
      ),
    );

    final text = tester.widget<Text>(find.byKey(bodyKey));
    expect(
      text.data,
      GlassBackend.plain.name,
      reason: 'body 不该被 GlassAlertDialog 强行推上液态档',
    );
  });

  testWidgets('标题行关闭钮读到液态档', (tester) async {
    await pump(
      tester,
      GlassAlertDialog(title: '标题', content: const SizedBox.shrink()),
    );

    // GlassIconButton 内部不暴露 scope，改为在关闭钮的祖先链上找
    // LiquidGlassScope，确认它确实被显式设成了 chromeGlassBackend(context)。
    final closeButtonContext = tester.element(
      find.widgetWithIcon(GlassIconButton, Icons.close),
    );
    expect(LiquidGlassScope.of(closeButtonContext), GlassBackend.liquidWidgets);
  });

  testWidgets('动作行渲染成 GlassButtonGroup + GlassTextActionButton，不是裸 TextButton/FilledButton', (
    tester,
  ) async {
    var cancelTapped = false;
    var confirmTapped = false;

    await pump(
      tester,
      GlassAlertDialog(
        title: '确认',
        content: const Text('要删除吗？'),
        actions: [
          GlassDialogAction(
            label: '取消',
            emphasized: false,
            onPressed: () => cancelTapped = true,
          ),
          GlassDialogAction(
            label: '删除',
            destructive: true,
            onPressed: () => confirmTapped = true,
          ),
        ],
      ),
    );

    expect(find.byType(GlassButtonGroup), findsOneWidget);
    expect(find.byType(GlassTextActionButton), findsNWidgets(2));
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(FilledButton), findsNothing);

    // 按钮组确实接了液态档，长按蠕动才有意义。
    final groupContext = tester.element(find.byType(GlassButtonGroup));
    expect(LiquidGlassScope.of(groupContext), GlassBackend.liquidWidgets);

    await tester.tap(find.text('取消'));
    await tester.pump();
    expect(cancelTapped, isTrue);
    expect(confirmTapped, isFalse);

    await tester.tap(find.text('删除'));
    await tester.pump();
    expect(confirmTapped, isTrue);
  });
}
