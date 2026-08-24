import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_floating_tab_bar.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;

/// 浮动底栏（`liquid_glass_widgets` 的 `GlassTabBar.bottom` 包装）的行为契约。
///
/// 这里盯的不是观感，而是换实现时最容易悄悄丢掉的四件事：
///   1. 同项重复点击也要回调（首页「再点一次当前栏目 = 回顶 + 重载」靠它）；
///   2. 横向拖动能换项（新实现才有的能力，别被日后调参调没了）；
///   3. 右侧圆钮是独立动作，不能被胶囊的手势吃掉；
///   4. 整条只占一行高度，不自带安全区——底栏是 Stack 覆盖层，外边距由调用方给；
///   5. **换项只在抬手那一刻回调**：按住不放不换页（那段时间是留给拖动的），
///      按住再拖走也绝不能先回调一次按下那一项——包内部是在 `onTapDown`
///      抢跑的，本组件把它压到手势结束才落地；
///   6. **但高亮不推迟**：按住不动时焦点必须当场跟到手指底下那一项（推迟的只有
///      换页）。包里指示器只认外面传进来的 `selectedIndex`，所以这条要盯的是
///      喂给包的那个下标，而不是 `currentIndex`。
void main() {
  const items = [
    GlassTabItem(icon: Icons.video_library, label: '视频'),
    GlassTabItem(icon: Icons.photo_library, label: '图库'),
    GlassTabItem(icon: Icons.subscriptions, label: '订阅'),
    GlassTabItem(icon: Icons.forum, label: '社区'),
  ];

  const double barWidth = 360;

  Future<List<int>> pumpBar(
    WidgetTester tester, {
    int currentIndex = 0,
    VoidCallback? onAction,
  }) async {
    final taps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: barWidth,
              child: GlassFloatingTabBar(
                currentIndex: currentIndex,
                onTap: taps.add,
                items: items,
                action: GlassFloatingBarAction(
                  icon: Icons.search,
                  label: '搜索',
                  onPressed: onAction ?? () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // 包内是弹簧动画，pumpAndSettle 可能一直不静止；固定推几帧就够看结构。
    await tester.pump(const Duration(milliseconds: 400));
    return taps;
  }

  /// 胶囊的可用宽度：整条减去右侧圆钮与它的间距。
  double slotWidth() =>
      (barWidth - GlassTokens.floatingActionSize - 12) / items.length;

  /// 真正喂给包的选中下标——指示器与图标高亮都只认它。
  int visualIndex(WidgetTester tester) =>
      tester.widget<lgw.GlassTabBar>(find.byType(lgw.GlassTabBar)).selectedIndex;

  /// 第 [index] 项中心的全局坐标。
  Offset tabCenter(WidgetTester tester, int index) {
    final Rect bar = tester.getRect(find.byType(GlassFloatingTabBar));
    return Offset(
      bar.left + slotWidth() * (index + 0.5),
      bar.center.dy,
    );
  }

  testWidgets('四项加圆钮都画得出来，且只占一行高度', (tester) async {
    await pumpBar(tester);
    expect(tester.takeException(), isNull);
    for (final item in items) {
      // 选中层与未选中层各画一趟，所以每个标题出现两次。
      expect(find.text(item.label), findsWidgets);
    }
    expect(
      tester.getSize(find.byType(GlassFloatingTabBar)).height,
      GlassTokens.floatingTabBarHeight,
      reason: '底栏自带了额外高度（安全区？），Stack 那边的让位就会算错',
    );
  });

  testWidgets('点别的项 → 回调它的下标', (tester) async {
    final taps = await pumpBar(tester);
    await tester.tapAt(tabCenter(tester, 2));
    await tester.pump(const Duration(milliseconds: 400));
    expect(taps, contains(2));
  });

  testWidgets('点当前项也要回调（同项 = 刷新）', (tester) async {
    final taps = await pumpBar(tester, currentIndex: 1);
    await tester.tapAt(tabCenter(tester, 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      taps,
      contains(1),
      reason: '同项被吞掉的话，「再点一次当前栏目回顶 + 重载」就没了',
    );
  });

  testWidgets('横向拖动能换项', (tester) async {
    final taps = await pumpBar(tester);
    final TestGesture gesture = await tester.startGesture(tabCenter(tester, 0));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.moveTo(tabCenter(tester, 3));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 400));
    expect(taps.last, 3);
  });

  testWidgets('右侧圆钮是独立动作，不算换项', (tester) async {
    int actions = 0;
    final taps = await pumpBar(tester, onAction: () => actions++);
    final Rect bar = tester.getRect(find.byType(GlassFloatingTabBar));
    await tester.tapAt(
      Offset(bar.right - GlassTokens.floatingActionSize / 2, bar.center.dy),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(actions, 1);
    expect(taps, isEmpty, reason: '圆钮的点击漏进了胶囊的手势区');
  });

  testWidgets('按住不放不换页，抬手才回调', (tester) async {
    final taps = await pumpBar(tester);
    final TestGesture gesture = await tester.startGesture(tabCenter(tester, 2));
    // 按下满 kPressTimeout（100ms）——包内部的 tap 识别器就是在这一刻抢跑的。
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      taps,
      isEmpty,
      reason: '手指还按着就换页了，这段时间本该留给拖动',
    );

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 400));
    expect(taps, [2], reason: '抬手要落地，且只落一次');
  });

  testWidgets('按住 → 拖走 → 抬手：只回调终点，不回调按下那一项', (tester) async {
    final taps = await pumpBar(tester, currentIndex: 0);
    final TestGesture gesture = await tester.startGesture(tabCenter(tester, 0));
    await tester.pump(const Duration(milliseconds: 300)); // 先按住超过抢跑窗口
    await gesture.moveTo(tabCenter(tester, 3));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      taps,
      [3],
      reason: '按下那一项被抢跑回调了的话，会先白刷新/白跳一次再换到终点',
    );
  });

  testWidgets('按住不动：焦点当场跟到按下那一项，但还没换页', (tester) async {
    final taps = await pumpBar(tester, currentIndex: 0);
    expect(visualIndex(tester), 0);

    final TestGesture gesture = await tester.startGesture(tabCenter(tester, 2));
    // 按下满 kPressTimeout（100ms）：包在这一刻报出下标，高亮该立刻过去。
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      visualIndex(tester),
      2,
      reason: '按住不动焦点还赖在原来那项——只有手指左右挪动（拖拽接管坐标）才跟过来',
    );
    expect(taps, isEmpty, reason: '高亮可以先走，换页必须等抬手');

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 400));
    expect(taps, [2]);
    expect(visualIndex(tester), 2);
  });

  testWidgets('按住 → 拖走 → 抬手：焦点落在终点那一项', (tester) async {
    await pumpBar(tester, currentIndex: 0);
    final TestGesture gesture = await tester.startGesture(tabCenter(tester, 0));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.moveTo(tabCenter(tester, 3));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 400));
    expect(visualIndex(tester), 3);
  });

  testWidgets('抢先点亮之后，路由换到别处仍以路由为准', (tester) async {
    final taps = <int>[];
    Widget bar(int currentIndex) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: barWidth,
            child: GlassFloatingTabBar(
              currentIndex: currentIndex,
              onTap: taps.add,
              items: items,
              // 与 [pumpBar] 同构：`tabCenter` 是按「带圆钮」的胶囊宽度算的。
              action: GlassFloatingBarAction(
                icon: Icons.search,
                label: '搜索',
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(bar(0));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(tabCenter(tester, 2));
    await tester.pump(const Duration(milliseconds: 400));
    expect(taps, [2]);

    // 外面（路由）最终落到了另一项：本组件不能拿按下时抢先点亮的那份压着它。
    await tester.pumpWidget(bar(1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(visualIndex(tester), 1);
  });
}
