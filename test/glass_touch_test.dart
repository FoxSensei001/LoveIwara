import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/my_app.dart' show buildThemeData;
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// 玻璃件的「按住不放」手感闸门。
///
/// 两条规矩都出过实际问题、也都只有一个出处，所以只在这儿盯：
///   1. 触屏上 tooltip 不许再抢长按（主题里钉死 `TooltipTriggerMode.manual`）；
///   2. 手指按住之后可以在按钮附近挪动，走出容忍圈才作废
///      （`GlassTapArea` / [GlassTokens.touchStaySlop]）。
void main() {
  const double buttonSize = 40;

  Widget host(Widget child, {GlassBackend? backend}) {
    Widget body = Center(
      child: SizedBox(width: buttonSize, height: buttonSize, child: child),
    );
    if (backend != null) {
      body = LiquidGlassScope(backend: backend, child: body);
    }
    return MaterialApp(home: Scaffold(body: body));
  }

  group('tooltip 不许抢长按', () {
    test('buildThemeData 把 triggerMode 钉在 manual', () {
      final ThemeData theme = buildThemeData(
        colorScheme: const ColorScheme.light(),
      );
      expect(
        theme.tooltipTheme.triggerMode,
        TooltipTriggerMode.manual,
        reason:
            '触屏上的 tooltip 会在 500ms 弹出黑条并把同竞技场的 tap 判负，'
            '按住不放的玻璃手感（蠕动 / 跟手形变）全在那之后才开始。',
      );
    });

    testWidgets('长按玻璃钮不再弹出 tooltip 文案', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildThemeData(colorScheme: const ColorScheme.light()),
          home: Scaffold(
            body: Center(
              child: GlassIconButton(
                icon: const Icon(Icons.close),
                tooltip: '关闭',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(GlassIconButton)),
      );
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.text('关闭'), findsNothing);
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('手指挪出按钮之后', () {
    testWidgets('挪一小段（仍在容忍圈里）抬手照样触发', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          GlassPressable(
            onTap: () => taps++,
            builder: (context, pressed) => const ColoredBox(
              color: Color(0xFF000000),
            ),
          ),
        ),
      );
      final Offset center = tester.getCenter(find.byType(GlassPressable));
      final TestGesture gesture = await tester.startGesture(center);
      // 出了按钮（半宽 20），但差一点点还没出容忍圈——两头都钉在 token 上，
      // 改了 touchStaySlop 这两个用例会一起跟着动。
      await gesture.moveBy(
        Offset(buttonSize / 2 + GlassTokens.touchStaySlop - 10, 0),
      );
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('挪得特别远就作废，抬手不再触发', (tester) async {
      var taps = 0;
      final List<bool> pressedLog = <bool>[];
      await tester.pumpWidget(
        host(
          GlassPressable(
            onTap: () => taps++,
            builder: (context, pressed) {
              pressedLog.add(pressed);
              return const ColoredBox(color: Color(0xFF000000));
            },
          ),
        ),
      );
      final Offset center = tester.getCenter(find.byType(GlassPressable));
      final TestGesture gesture = await tester.startGesture(center);
      await tester.pump();
      expect(pressedLog.last, isTrue, reason: '按下那一帧就该点亮按下态');

      await gesture.moveBy(
        const Offset(buttonSize / 2 + GlassTokens.touchStaySlop + 10, 0),
      );
      await tester.pump();
      expect(pressedLog.last, isFalse, reason: '走出容忍圈时按下态要一起撤掉');

      await gesture.up();
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('容忍圈按边界算，宽胶囊顺着长边挪不会误伤', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                height: 44,
                child: GlassPressable(
                  onTap: () => taps++,
                  builder: (context, pressed) =>
                      const ColoredBox(color: Color(0xFF000000)),
                ),
              ),
            ),
          ),
        ),
      );
      final Offset center = tester.getCenter(find.byType(GlassPressable));
      final TestGesture gesture = await tester.startGesture(center);
      // 100px 远远超过 kTouchSlop，但手指从没离开这条胶囊。
      await gesture.moveBy(const Offset(100, 0));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('滚动照样抢得走：按住列表里的玻璃钮往下滑是滚动而不是点击', (tester) async {
      var taps = 0;
      final ScrollController controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              controller: controller,
              children: [
                const SizedBox(height: 400),
                SizedBox(
                  height: buttonSize,
                  child: GlassPressable(
                    onTap: () => taps++,
                    builder: (context, pressed) =>
                        const ColoredBox(color: Color(0xFF000000)),
                  ),
                ),
                const SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      );
      final Offset center = tester.getCenter(find.byType(GlassPressable));
      final TestGesture gesture = await tester.startGesture(center);
      await tester.pump();
      // 一次分多步挪，模拟真实滚动：拖拽识别器会在 kTouchSlop 处宣布胜利。
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(taps, 0, reason: '这一下是滚动，不该变成点击');
      expect(controller.offset, greaterThan(0));
      controller.dispose();
    });

    testWidgets('sticky 关掉时退回框架默认（kTouchSlop 就判负）', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          GlassPressable(
            onTap: () => taps++,
            stickyTouch: false,
            builder: (context, pressed) =>
                const ColoredBox(color: Color(0xFF000000)),
          ),
        ),
      );
      final Offset center = tester.getCenter(find.byType(GlassPressable));
      final TestGesture gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(kTouchSlop + 6, 0));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(taps, 0);
    });
  });

  group('长按打开菜单 + 手指接力', () {
    Widget menuHost({
      required List<GlassMenuEntry> entries,
      required ValueChanged<String?> onPicked,
      bool opensOverlay = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Builder(
              builder: (anchorContext) => SizedBox(
                width: 120,
                height: buttonSize,
                child: GlassPressable(
                  opensOverlay: opensOverlay,
                  onTap: () async {
                    onPicked(
                      await showGlassMenu<String>(
                        anchorContext: anchorContext,
                        entries: entries,
                      ),
                    );
                  },
                  builder: (context, pressed) =>
                      const ColoredBox(color: Color(0xFF000000)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final List<GlassMenuEntry> entries = <GlassMenuEntry>[
      const GlassMenuOption<String>(value: 'a', label: '第一项'),
      const GlassMenuOption<String>(value: 'b', label: '第二项'),
      const GlassMenuOption<String>(value: 'c', label: '第三项'),
    ];

    testWidgets('长按触发钮就把菜单打开（不用等抬手）', (tester) async {
      await tester.pumpWidget(menuHost(entries: entries, onPicked: (_) {}));
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(GlassPressable)),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('第一项'), findsOneWidget, reason: '手指还按着，菜单就该已经在了');
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('没声明 opensOverlay 的钮长按不开菜单', (tester) async {
      await tester.pumpWidget(
        menuHost(entries: entries, onPicked: (_) {}, opensOverlay: false),
      );
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(GlassPressable)),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('第一项'), findsNothing);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('长按打开后手指不抬起，划到第三项松手即选中', (tester) async {
      String? picked;
      var done = false;
      await tester.pumpWidget(
        menuHost(
          entries: entries,
          onPicked: (v) {
            picked = v;
            done = true;
          },
        ),
      );
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(GlassPressable)),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // 手指从没离开过屏幕：菜单收不到这根手指，落点是触发钮转发过来的。
      await gesture.moveTo(tester.getCenter(find.text('第三项')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(done, isTrue);
      expect(picked, 'c');
    });

    testWidgets('长按打开后原地松手：不选中，菜单留着', (tester) async {
      String? picked;
      var done = false;
      await tester.pumpWidget(
        menuHost(
          entries: entries,
          onPicked: (v) {
            picked = v;
            done = true;
          },
        ),
      );
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(GlassPressable)),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(done, isFalse, reason: '没落到任何一条上，不该替用户选');
      expect(picked, isNull);
      expect(find.text('第一项'), findsOneWidget, reason: '退回一张普通打开着的菜单');
    });

    testWidgets('长按开着菜单时页面被换掉，浮层跟着收走', (tester) async {
      final GlobalKey<NavigatorState> nav = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: nav,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: Builder(
                builder: (anchorContext) => SizedBox(
                  width: 120,
                  height: buttonSize,
                  child: GlassPressable(
                    opensOverlay: true,
                    onTap: () => showGlassMenu<String>(
                      anchorContext: anchorContext,
                      entries: entries,
                    ),
                    builder: (context, pressed) =>
                        const ColoredBox(color: Color(0xFF000000)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(GlassPressable)),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('第一项'), findsOneWidget);

      // 浮层不在路由栈上：页面被盖住时它不会自己消失，靠盯着锚点路由收摊。
      nav.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('另一个页面')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('第一项'), findsNothing, reason: '别把菜单落在下一个页面上');
    });

    testWidgets('普通点按打开的菜单不进接力（手指早就抬了）', (tester) async {
      await tester.pumpWidget(menuHost(entries: entries, onPicked: (_) {}));
      await tester.tap(find.byType(GlassPressable));
      await tester.pumpAndSettle();
      expect(find.text('第一项'), findsOneWidget);
      // 菜单照常可以点选。
      await tester.tap(find.text('第二项'));
      await tester.pumpAndSettle();
      expect(find.text('第二项'), findsNothing);
    });
  });

  group('液态档下整只玻璃可按', () {
    for (final backend in GlassBackend.values) {
      testWidgets('$backend：点击能发出去', (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          host(
            GlassSurface(
              circle: true,
              height: buttonSize,
              onTap: () => taps++,
              child: const SizedBox.shrink(),
            ),
            backend: backend,
          ),
        );
        await tester.tap(find.byType(GlassSurface));
        await tester.pump();
        expect(
          taps,
          1,
          reason:
              '「整只玻璃可按」的调用点（身份圆钮一类）在液态档下曾被借来的形变层'
              '整只吃掉点击，见 GlassSurface 里 tapInsideLiquidBox 那段。',
        );
      });

      testWidgets('$backend：挪出按钮一小段仍然触发', (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          host(
            GlassSurface(
              circle: true,
              height: buttonSize,
              onTap: () => taps++,
              child: const SizedBox.shrink(),
            ),
            backend: backend,
          ),
        );
        final Offset center = tester.getCenter(find.byType(GlassSurface));
        final TestGesture gesture = await tester.startGesture(center);
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump();
        await gesture.up();
        await tester.pump();
        expect(taps, 1);
      });
    }
  });
}
