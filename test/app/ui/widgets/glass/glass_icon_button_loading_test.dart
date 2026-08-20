import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';

/// 统一的「按钮级 loading」：图标原位换沙漏 + 置灰不可按 + 收起小红点。
void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Align(child: child))),
    );
  }

  group('GlassIconButton.loading', () {
    testWidgets('图标换成沙漏并挡住点击', (tester) async {
      int taps = 0;
      await pump(
        tester,
        GlassIconButton(
          icon: const Icon(Icons.refresh),
          loading: true,
          onPressed: () => taps++,
        ),
      );
      // 沙漏是交叉过渡进来的，等动画走完再断言
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);

      await tester.tap(find.byType(GlassIconButton));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('loading 期间收起小红点', (tester) async {
      await pump(
        tester,
        const GlassIconButton(
          icon: Icon(Icons.save_outlined),
          loading: true,
          showBadge: true,
          onPressed: null,
        ),
      );
      await tester.pumpAndSettle();

      // GlassAnimatedDot 用缩放做显隐，收起时缩到 0
      final AnimatedScale dot = tester.widget<AnimatedScale>(
        find.descendant(
          of: find.byType(GlassAnimatedDot),
          matching: find.byType(AnimatedScale),
        ),
      );
      expect(dot.scale, 0);
    });
  });

  group('GlassAsyncIconButton', () {
    testWidgets('点击后进沙漏态，Future 落定后恢复', (tester) async {
      final completer = Completer<void>();
      await pump(
        tester,
        GlassAsyncIconButton(
          icon: const Icon(Icons.refresh),
          minLoadingDuration: const Duration(milliseconds: 100),
          onPressed: () => completer.future,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.byType(GlassAsyncIconButton));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);

      completer.complete();
      // 动作已经结束，但最短停留时间还没到——沙漏必须还在
      await tester.pump();
      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('沙漏期间不会重复触发动作', (tester) async {
      int runs = 0;
      final completer = Completer<void>();
      await pump(
        tester,
        GlassAsyncIconButton(
          icon: const Icon(Icons.refresh),
          minLoadingDuration: Duration.zero,
          onPressed: () {
            runs++;
            return completer.future;
          },
        ),
      );

      await tester.tap(find.byType(GlassAsyncIconButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GlassAsyncIconButton));
      await tester.pumpAndSettle();
      expect(runs, 1);

      completer.complete();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GlassAsyncIconButton));
      await tester.pumpAndSettle();
      expect(runs, 2);
    });

    testWidgets('动作抛错也要复位，不能永远卡在沙漏上', (tester) async {
      await pump(
        tester,
        GlassAsyncIconButton(
          icon: const Icon(Icons.refresh),
          minLoadingDuration: Duration.zero,
          onPressed: () async => throw StateError('boom'),
        ),
      );

      await tester.tap(find.byType(GlassAsyncIconButton));
      await tester.pumpAndSettle();
      // 异常照常上报（不被按钮吞掉），同时按钮已经回到可点状态
      expect(tester.takeException(), isStateError);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top), findsNothing);
    });

    testWidgets('外部 loading 为真时同样进沙漏态', (tester) async {
      await pump(
        tester,
        GlassAsyncIconButton(
          icon: const Icon(Icons.refresh),
          loading: true,
          onPressed: () async {},
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
    });
  });
}
