import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dialog_motion.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

void main() {
  const dialogKey = Key('app-dialog-content');

  /// 挂一个最小宿主，返回可用于推弹窗的 context（位于 MaterialApp 的 Navigator 之下）。
  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext hostContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            hostContext = context;
            return const Scaffold(body: SizedBox.expand());
          },
        ),
      ),
    );
    return hostContext;
  }

  /// 取包住弹窗内容的那层过渡（弹窗自身内部也可能有同类 widget，只认最外层）。
  T transitionAbove<T extends Widget>(WidgetTester tester) {
    return tester.widget<T>(
      find
          .ancestor(of: find.byKey(dialogKey), matching: find.byType(T))
          .last, // ancestor 由近及远，最后一个是最外层
    );
  }

  /// 形变通道（缩放/位移）的当前进度。
  double motionValue(WidgetTester tester) {
    final content = tester.element(find.byKey(dialogKey));
    return GlassDialogMotionScope.maybeOf(content)!.value;
  }

  /// 淡入淡出通道的当前不透明度。
  ///
  /// ⛔ 这条断言是 2026-09-04 补的，盯着一次真实回归：在那之前整段过渡
  /// **一点透明度变化都没有**（只有 8% 缩放），用户读到的是「动画走着走着
  /// 卡片瞬间出现/消失」。谁要是又把这层 FadeTransition 拿掉，这里会红。
  double fadeValue(WidgetTester tester) {
    return transitionAbove<FadeTransition>(tester).opacity.value;
  }

  testWidgets('弹窗入场是渐进的，不是瞬间出现', (tester) async {
    final context = await pumpHost(tester);

    showAppDialog(
      const Text('dialog', key: dialogKey),
      dialogContext: context,
      useRootNavigator: false,
    );

    await tester.pump(); // 推入路由，动画从 0 起步
    expect(motionValue(tester), 0);
    expect(fadeValue(tester), 0, reason: '首帧必须是完全透明的，不能已经是一张实心卡片');

    await tester.pump(GlassTokens.dialogEnterDuration ~/ 2);
    final midway = motionValue(tester);
    expect(midway, greaterThan(0));
    expect(midway, lessThan(1));
    expect(fadeValue(tester), greaterThan(0));
    expect(fadeValue(tester), lessThan(1));

    await tester.pumpAndSettle();
    expect(motionValue(tester), 1);
    expect(fadeValue(tester), 1);
  });

  testWidgets('弹窗出场同样有过渡，而不是直接消失', (tester) async {
    final context = await pumpHost(tester);

    showAppDialog(
      const Text('dialog', key: dialogKey),
      dialogContext: context,
      useRootNavigator: false,
    );
    await tester.pumpAndSettle();

    Navigator.of(context).pop();
    await tester.pump();
    await tester.pump(GlassTokens.dialogExitDuration ~/ 2);

    final midway = motionValue(tester);
    expect(midway, greaterThan(0));
    expect(midway, lessThan(1));
    // 出场过半时卡片已经淡掉一大截，不该还是一张实心卡片撑到最后一帧。
    expect(fadeValue(tester), lessThan(0.7));
    expect(fadeValue(tester), greaterThan(0));

    await tester.pumpAndSettle();
    expect(find.byKey(dialogKey), findsNothing);
  });

  testWidgets('宽屏走缩放、窄屏走上移，分界与响应式弹窗一致', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;

    // 宽屏：居中卡片，缩放入场
    tester.view.physicalSize = const Size(
      GlassTokens.dialogWideBreakpoint + 200,
      800,
    );
    var context = await pumpHost(tester);
    showAppDialog(
      const Text('dialog', key: dialogKey),
      dialogContext: context,
      useRootNavigator: false,
    );
    await tester.pump();
    expect(transitionAbove<ScaleTransition>(tester).scale.value, lessThan(1));
    await tester.pumpAndSettle();
    expect(transitionAbove<ScaleTransition>(tester).scale.value, 1);
    expect(
      find.ancestor(
        of: find.byKey(dialogKey),
        matching: find.byType(SlideTransition),
      ),
      findsNothing,
    );

    // 窄屏：整页承载，上移入场（缩放会把四边从屏幕外拽进来）
    tester.view.physicalSize = const Size(
      GlassTokens.dialogWideBreakpoint - 200,
      800,
    );
    context = await pumpHost(tester);
    showAppDialog(
      const Text('dialog', key: dialogKey),
      dialogContext: context,
      useRootNavigator: false,
    );
    await tester.pump();
    expect(
      transitionAbove<SlideTransition>(tester).position.value.dy,
      greaterThan(0),
    );
    await tester.pumpAndSettle();
    expect(
      transitionAbove<SlideTransition>(tester).position.value,
      Offset.zero,
    );
    expect(
      find.ancestor(
        of: find.byKey(dialogKey),
        matching: find.byType(ScaleTransition),
      ),
      findsNothing,
    );
  });

  testWidgets('可显式指定动画风格，不受屏幕宽度影响', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(
      GlassTokens.dialogWideBreakpoint + 200,
      800,
    );

    final context = await pumpHost(tester);
    showAppDialog(
      const Text('dialog', key: dialogKey),
      dialogContext: context,
      useRootNavigator: false,
      motion: GlassDialogMotion.page,
    );
    await tester.pump();

    expect(
      transitionAbove<SlideTransition>(tester).position.value.dy,
      greaterThan(0),
    );
    expect(
      find.ancestor(
        of: find.byKey(dialogKey),
        matching: find.byType(ScaleTransition),
      ),
      findsNothing,
    );
  });

  testWidgets('弹窗返回值仍能正常回传', (tester) async {
    final context = await pumpHost(tester);

    final future = showAppDialog<String>(
      const Text('dialog', key: dialogKey),
      dialogContext: context,
      useRootNavigator: false,
    );
    await tester.pumpAndSettle();

    Navigator.of(context).pop('ok');
    await tester.pumpAndSettle();

    expect(await future, 'ok');
  });
}
