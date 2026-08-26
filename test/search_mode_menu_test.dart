import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_floating_tab_bar.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/ui/widgets/search_mode_menu.dart';
import 'package:i_iwara/common/enums/media_enums.dart';

/// 长按搜索钮弹「搜索模式」菜单这条链上，三件换实现时最容易悄悄丢掉的事：
///
///   1. **优先级高的永远贴着触发件**——底部圆钮的菜单朝上开，第一优先级要落在
///      **最下面**；顶部 header 的菜单朝下开，落在**最上面**。这条不由调用点
///      各自判断，靠 [showGlassMenu] 的 `priorityNearAnchor`（见
///      `showSearchModeMenu`）。
///   2. **长按不能顺带把点按也跑了**——搜索钮点按是「进搜索页」，长按弹菜单那
///      一下要是把跳页也带出去，人一松手就落在了默认模式的搜索页上。
///   3. **浮动底栏那枚圆钮也得有长按**——它由 `liquid_glass_widgets` 自己画，
///      包里的 `GlassTabBarExtraButton` 只有 `onTap`，长按是本仓库盖了一层手势
///      区补出来的（两个材质档都要有）。
void main() {
  const List<String> labels = ['第一优先', '第二优先', '第三优先'];

  List<GlassMenuEntry> priorityEntries() => [
    for (final label in labels)
      GlassMenuOption<String>(value: label, label: label),
  ];

  /// 菜单里各条按**从上到下**的排列。
  List<String> renderedOrder(WidgetTester tester) {
    final rows =
        labels
            .where((l) => find.text(l).evaluate().isNotEmpty)
            .map((l) => (l, tester.getCenter(find.text(l)).dy))
            .toList()
          ..sort((a, b) => a.$2.compareTo(b.$2));
    return [for (final row in rows) row.$1];
  }

  Widget anchorHost({required Alignment alignment}) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: alignment,
          child: Builder(
            builder: (anchorContext) => GlassIconButton(
              standalone: true,
              icon: const Icon(Icons.search),
              onPressed: () {},
              longPressOpensOverlay: true,
              onLongPressed: () => showGlassMenu<String>(
                anchorContext: anchorContext,
                entries: priorityEntries(),
                priorityNearAnchor: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<TestGesture> longPress(WidgetTester tester, Finder target) async {
    final gesture = await tester.startGesture(tester.getCenter(target));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    return gesture;
  }

  group('优先级顺序跟着开口方向走', () {
    testWidgets('触发件在顶部：菜单朝下开，第一优先在最上面', (tester) async {
      await tester.pumpWidget(anchorHost(alignment: Alignment.topLeft));
      final gesture = await longPress(tester, find.byType(GlassIconButton));
      expect(renderedOrder(tester), labels);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('触发件在底部：菜单朝上开，第一优先落到最下面（贴着手指）', (tester) async {
      await tester.pumpWidget(anchorHost(alignment: Alignment.bottomRight));
      final gesture = await longPress(tester, find.byType(GlassIconButton));
      expect(renderedOrder(tester), labels.reversed.toList());
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  testWidgets('长按弹菜单不会顺带把点按那件事也跑掉', (tester) async {
    var taps = 0;
    var menus = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Builder(
              builder: (anchorContext) => GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.search),
                onPressed: () => taps++,
                longPressOpensOverlay: true,
                onLongPressed: () {
                  menus++;
                  showGlassMenu<String>(
                    anchorContext: anchorContext,
                    entries: priorityEntries(),
                    priorityNearAnchor: true,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await longPress(tester, find.byType(GlassIconButton));
    expect(menus, 1);
    expect(taps, 0, reason: '长按到点时点按就该被判负了');
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 0, reason: '抬手更不该补一次跳页');

    // 点空白关掉菜单（不关的话下面那一下会落在遮罩上）。
    await tester.tapAt(const Offset(780, 580));
    await tester.pumpAndSettle();
    expect(taps, 0);

    // 短按照旧是点按。
    await tester.tap(find.byType(GlassIconButton));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(menus, 1);
  });

  group('浮动底栏右侧圆钮的长按（两档都要有）', () {
    Future<void> pumpBar(
      WidgetTester tester, {
      required GlassMaterialMode mode,
      required VoidCallback onPressed,
      required void Function(BuildContext) onLongPress,
    }) async {
      glassMaterialMode.value = mode;
      await tester.pumpWidget(
        GlassMaterialScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  child: GlassFloatingTabBar(
                    currentIndex: 0,
                    onTap: (_) {},
                    items: const [
                      GlassTabItem(icon: Icons.video_library, label: '视频'),
                      GlassTabItem(icon: Icons.photo_library, label: '图库'),
                    ],
                    action: GlassFloatingBarAction(
                      icon: Icons.search,
                      label: '搜索',
                      onPressed: onPressed,
                      onLongPress: onLongPress,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      // 液态档是弹簧动画，pumpAndSettle 可能一直不静止；推几帧够看结构。
      await tester.pump(const Duration(milliseconds: 400));
    }

    /// 圆钮的中心：整条最右边那个 `栏高 × 栏高` 的方块（几何契约见
    /// `GlassFloatingTabBar._withActionLongPress`）。
    Offset actionCenter(WidgetTester tester) {
      final Rect bar = tester.getRect(find.byType(GlassFloatingTabBar));
      return Offset(bar.right - bar.height / 2, bar.center.dy);
    }

    for (final mode in GlassMaterialMode.values) {
      testWidgets('$mode：长按圆钮拿到落点，且不触发点按', (tester) async {
        var taps = 0;
        BuildContext? anchor;
        await pumpBar(
          tester,
          mode: mode,
          onPressed: () => taps++,
          onLongPress: (context) => anchor = context,
        );

        final gesture = await tester.startGesture(actionCenter(tester));
        await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 400));
        expect(anchor, isNotNull, reason: '长按没落到圆钮上（几何约定变了？）');
        // 落点必须量得出来——showGlassMenu 就是从这只 RenderBox 上取的。
        final box = anchor!.findRenderObject();
        expect(box, isA<RenderBox>());
        expect(
          (box as RenderBox).localToGlobal(Offset.zero).dx +
              box.size.width / 2,
          moreOrLessEquals(actionCenter(tester).dx, epsilon: 1),
        );
        expect(taps, 0);

        await gesture.up();
        await tester.pump(const Duration(milliseconds: 400));
        expect(taps, 0, reason: '抬手也不该再补一次搜索页');
      });

      testWidgets('$mode：短按圆钮照旧是搜索', (tester) async {
        var taps = 0;
        var longPresses = 0;
        await pumpBar(
          tester,
          mode: mode,
          onPressed: () => taps++,
          onLongPress: (_) => longPresses++,
        );
        await tester.tapAt(actionCenter(tester));
        await tester.pump(const Duration(milliseconds: 400));
        expect(taps, 1);
        expect(longPresses, 0);
      });
    }
  });

  test('搜索模式菜单列全了所有模式（新增一档别忘了排优先级）', () {
    expect(
      kSearchSegmentsByPriority.toSet(),
      SearchSegment.values.toSet(),
    );
    expect(kSearchSegmentsByPriority.length, SearchSegment.values.length);
  });
}
