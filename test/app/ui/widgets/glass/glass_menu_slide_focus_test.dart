import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// 玻璃菜单的「滑动取焦」：按住不放上下划，焦点底板跟着手指换条，松手即选中。
/// 内容长到能滚起来时这套整只让位（拖拽还给滚动）。
void main() {
  // 面板钉回传统档：液态面板在手指按住期间会一直跑跟手形变，
  // `pumpAndSettle` 永远等不到静止（见 [debugPanelGlassBackendOverride]）。
  // 本文件测的是焦点逻辑，与材质无关。
  setUp(() => debugPanelGlassBackendOverride = GlassBackend.plain);
  tearDown(() => debugPanelGlassBackendOverride = null);

  /// 弹出一张菜单，返回它最终选中的值（可选中项标题即 value）。
  Future<Future<String?>> openMenu(
    WidgetTester tester, {
    required List<GlassMenuEntry> entries,
    Alignment anchorAlign = Alignment.topLeft,
  }) async {
    late Future<String?> result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: anchorAlign,
            child: Builder(
              builder: (context) => SizedBox(
                width: 48,
                height: 44,
                child: GestureDetector(
                  key: const ValueKey('trigger'),
                  onTap: () {
                    result = showGlassMenu<String>(
                      anchorContext: context,
                      entries: entries,
                    );
                  },
                  child: const ColoredBox(color: Color(0xFF000000)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('trigger')));
    await tester.pumpAndSettle();
    return result;
  }

  List<GlassMenuEntry> options(int count) => <GlassMenuEntry>[
    for (var i = 0; i < count; i++)
      GlassMenuOption<String>(value: 'opt$i', label: 'Option $i'),
  ];

  /// 焦点底板：面板里唯一一块 AnimatedPositioned。
  Finder pill() => find.byType(AnimatedPositioned);

  group('内容摆得下：滑动取焦生效', () {
    testWidgets('按下就有焦点底板，且贴在手指那一条上', (tester) async {
      await openMenu(tester, entries: options(4));
      expect(pill(), findsNothing);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Option 1')),
      );
      await tester.pumpAndSettle();

      expect(pill(), findsOneWidget);
      final Rect pillRect = tester.getRect(pill());
      final Rect rowRect = tester.getRect(find.text('Option 1'));
      expect(pillRect.top, lessThanOrEqualTo(rowRect.top));
      expect(pillRect.bottom, greaterThanOrEqualTo(rowRect.bottom));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('按住不放上下划，底板换到手指所在的那一条', (tester) async {
      await openMenu(tester, entries: options(4));
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Option 0')),
      );
      await tester.pumpAndSettle();
      final double firstTop = tester.getRect(pill()).top;

      await gesture.moveTo(tester.getCenter(find.text('Option 3')));
      await tester.pumpAndSettle();

      final Rect pillRect = tester.getRect(pill());
      final Rect rowRect = tester.getRect(find.text('Option 3'));
      expect(pillRect.top, greaterThan(firstTop));
      expect(pillRect.top, lessThanOrEqualTo(rowRect.top));
      expect(pillRect.bottom, greaterThanOrEqualTo(rowRect.bottom));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('松手选中的是底板停住的那一条，不是按下的那一条', (tester) async {
      final result = await openMenu(tester, entries: options(4));
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Option 0')),
      );
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(find.text('Option 2')));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(await result, 'opt2');
    });

    testWidgets('划到末条再往下越一点，焦点仍咬着末条', (tester) async {
      final result = await openMenu(tester, entries: options(4));
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Option 0')),
      );
      await tester.pumpAndSettle();
      final Rect last = tester.getRect(find.text('Option 3'));
      await gesture.moveTo(Offset(last.center.dx, last.bottom + 8));
      await tester.pumpAndSettle();
      expect(pill(), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(await result, 'opt3');
    });

    // 2026-08-24 用户报障：「长按第一条松开没反应，第二条却可以」。
    // 死区是两条叠出来的——位移一过 kTouchSlop，行自己的点按就被判负（那是
    // 滑动取焦故意要的），此时若焦点又丢了，松手两条路都不出手，这一下整个被
    // 吞掉。首条上方只剩面板 6px 留白，长按时手指自然飘一下就出界；末条下方
    // 有的是余量，所以只有首条中招。
    testWidgets('按住首条、手指往上飘出面板一点再松手：仍然选中首条', (tester) async {
      final result = await openMenu(tester, entries: options(3));
      final Rect first = tester.getRect(find.text('Option 0'));
      final gesture = await tester.startGesture(first.center);
      await tester.pumpAndSettle();
      await gesture.moveTo(Offset(first.center.dx, first.center.dy - 30));
      await tester.pumpAndSettle();
      expect(pill(), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(await result, 'opt0');
    });

    // 分隔线是条 11px 的发丝线，不是落点，但从它上面**路过**不该丢焦点
    // ——丢了同样落进上面那个死区（关注按钮那张菜单正好在两条之间夹了一条）。
    testWidgets('手指飘到分隔线上再松手：焦点粘着原来那一条', (tester) async {
      final result = await openMenu(
        tester,
        entries: <GlassMenuEntry>[
          const GlassMenuOption<String>(value: 'opt0', label: 'Option 0'),
          const GlassMenuSeparator(),
          const GlassMenuOption<String>(value: 'opt1', label: 'Option 1'),
        ],
      );
      final Rect first = tester.getRect(find.text('Option 0'));
      final gesture = await tester.startGesture(first.center);
      await tester.pumpAndSettle();
      // 往下 25px：跨出首条、落在分隔线上（首条 44 高，分隔线 11 高）
      await gesture.moveTo(Offset(first.center.dx, first.center.dy + 25));
      await tester.pumpAndSettle();
      expect(pill(), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(await result, 'opt0');
    });

    testWidgets('划出面板再松手＝取消，什么也不选', (tester) async {
      final result = await openMenu(tester, entries: options(4));
      final Offset from = tester.getCenter(find.text('Option 1'));
      final gesture = await tester.startGesture(from);
      await tester.pumpAndSettle();
      // 横向荡出去很远：超出容差，焦点应当撤掉。
      await gesture.moveTo(from + const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(pill(), findsNothing);

      await gesture.up();
      await tester.pumpAndSettle();
      // 菜单还开着（点空白关闭走的是 barrier，不是这条路）。
      expect(find.text('Option 1'), findsOneWidget);

      // 收尾：从 barrier 关掉，免得 result 永远悬着。
      await tester.tapAt(const Offset(700, 560));
      await tester.pumpAndSettle();
      expect(await result, isNull);
    });

    testWidgets('普通点按只选中一次，页面不会被多 pop 一层', (tester) async {
      final result = await openMenu(tester, entries: options(4));
      await tester.tap(find.text('Option 1'));
      await tester.pumpAndSettle();

      expect(await result, 'opt1');
      // 触发件还在：说明只 pop 掉了菜单这一层。
      expect(find.byKey(const ValueKey('trigger')), findsOneWidget);
    });

    testWidgets('分隔线上按下去不亮底板', (tester) async {
      await openMenu(
        tester,
        entries: <GlassMenuEntry>[
          const GlassMenuOption<String>(value: 'a', label: 'Option 0'),
          const GlassMenuSeparator(),
          const GlassMenuOption<String>(value: 'b', label: 'Option 1'),
        ],
      );
      final Rect first = tester.getRect(find.text('Option 0'));
      final Rect second = tester.getRect(find.text('Option 1'));
      final gesture = await tester.startGesture(
        Offset(first.center.dx, (first.bottom + second.top) / 2),
      );
      await tester.pumpAndSettle();
      expect(pill(), findsNothing);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('禁用行上按下去不亮底板，划过去也选不中', (tester) async {
      final result = await openMenu(
        tester,
        entries: const <GlassMenuEntry>[
          GlassMenuOption<String>(value: 'a', label: 'Option 0'),
          GlassMenuOption<String>(
            value: 'b',
            label: 'Option 1',
            enabled: false,
          ),
        ],
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Option 0')),
      );
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(find.text('Option 1')));
      await tester.pumpAndSettle();
      expect(pill(), findsNothing);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Option 0'), findsOneWidget);

      await tester.tapAt(const Offset(700, 560));
      await tester.pumpAndSettle();
      expect(await result, isNull);
    });
  });

  group('内容滚得动：滑动取焦整只让位', () {
    testWidgets('按住上下划只滚列表，不亮底板也不选中', (tester) async {
      final result = await openMenu(tester, entries: options(24));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      final ScrollPosition position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      expect(position.maxScrollExtent, greaterThan(0));

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Option 1')),
      );
      await tester.pumpAndSettle();
      expect(pill(), findsNothing);

      // 分两步走：第一步先把拖拽识别器的 slop 顶破（`tester.drag` 内部也是
      // 这么拆的），第二步才是真正滚起来的那一段。
      await gesture.moveBy(const Offset(0, -40));
      await tester.pump();
      await gesture.moveBy(const Offset(0, -120));
      await tester.pumpAndSettle();
      expect(pill(), findsNothing);
      expect(position.pixels, greaterThan(0));

      await gesture.up();
      await tester.pumpAndSettle();
      // 拖拽被滚动吃掉，没有任何选中。
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      await tester.tapAt(const Offset(700, 560));
      await tester.pumpAndSettle();
      expect(await result, isNull);
    });

    testWidgets('滚得动时普通点按照常选中', (tester) async {
      final result = await openMenu(tester, entries: options(24));
      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();
      expect(await result, 'opt2');
    });
  });
}
