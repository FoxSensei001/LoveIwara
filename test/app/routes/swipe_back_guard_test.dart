import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/routes/swipe_back_guard.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

/// 「整页跟手侧滑返回」抢掉页内横向手势的回归闸门。
///
/// 报障原文：iOS 上在可以横向滑动的 tabs 里横滑，页面被直接弹掉了（搜索结果页、
/// 视频详情点 iwara 标签进的标签页…）。根因是 `SwipeablePageRoute` 的手势层盖在
/// 整页之上、恒先进竞技场，逐页传 `canOnlySwipeFromEdge` 只能一页一页补。
///
/// 这里锁住 [SwipeBackScrollGuard] 的三条契约：
///   1. 横向控件还能朝返回方向滚 → 让位，页面不许被弹掉；
///   2. 已经滑到头（TabBarView 停在第一个 tab）→ 照常返回，整页跟手不打折；
///   3. 纯竖向内容 → 一如既往地整页跟手返回。
/// 外加一条源码闸门：新加的页面不许绕过这层守卫。
void main() {
  group('SwipeBackScrollGuard', () {
    testWidgets('停在中间 tab 时右滑只换 tab，不返回上一页', (tester) async {
      final controller = TabController(
        length: 3,
        vsync: const TestVSync(),
        initialIndex: 1,
      );
      addTearDown(controller.dispose);

      await _pushGuardedPage(tester, _tabBarViewPage(controller));

      await _swipeBack(tester);

      expect(find.byKey(_pageKey), findsOneWidget, reason: '页面不该被弹掉');
      expect(controller.index, 0, reason: '手势该落到 TabBarView 上');
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('已经停在第一个 tab 时右滑照常返回上一页', (tester) async {
      final controller = TabController(length: 3, vsync: const TestVSync());
      addTearDown(controller.dispose);

      await _pushGuardedPage(tester, _tabBarViewPage(controller));

      await _swipeBack(tester);

      expect(find.byKey(_pageKey), findsNothing, reason: '滑到头就该让给侧滑返回');
      expect(controller.index, 0);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('横向 tab 条滑到最左时右滑照常返回，滑开后不返回', (tester) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await _pushGuardedPage(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 48,
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < 20; i++)
                    SizedBox(width: 120, child: Center(child: Text('tab $i'))),
                ],
              ),
            ),
          ),
        ),
      );

      // 滑到最左（起点）：横向条吃不下右滑，让给侧滑返回。
      await _swipeBack(tester, y: 24);
      expect(find.byKey(_pageKey), findsNothing);

      await _pushGuardedPage(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 48,
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < 20; i++)
                    SizedBox(width: 120, child: Center(child: Text('tab $i'))),
                ],
              ),
            ),
          ),
        ),
      );
      scrollController.jumpTo(300);
      await tester.pump();

      await _swipeBack(tester, y: 24);
      expect(find.byKey(_pageKey), findsOneWidget, reason: '还能往回滚就该让位');
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('纯竖向内容仍然整页跟手返回', (tester) async {
      await _pushGuardedPage(
        tester,
        ListView(
          children: [
            for (int i = 0; i < 40; i++) SizedBox(height: 60, child: Text('$i')),
          ],
        ),
      );

      await _swipeBack(tester);

      expect(find.byKey(_pageKey), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('GestureDetector 的横向拖拽区域也会让位', (tester) async {
      await _pushGuardedPage(
        tester,
        GestureDetector(
          onHorizontalDragUpdate: (_) {},
          child: const SizedBox.expand(child: ColoredBox(color: Colors.grey)),
        ),
      );

      await _swipeBack(tester);

      expect(find.byKey(_pageKey), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  });

  group('SwipeBackAbsorber', () {
    testWidgets('显式声明的区域按下期间关掉侧滑返回', (tester) async {
      await _pushGuardedPage(
        tester,
        const SwipeBackAbsorber(
          child: SizedBox.expand(child: ColoredBox(color: Colors.grey)),
        ),
      );

      await _swipeBack(tester);

      expect(find.byKey(_pageKey), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('抬手后还原，下一次侧滑照常返回', (tester) async {
      await _pushGuardedPage(
        tester,
        const Column(
          children: [
            SizedBox(
              height: 100,
              child: SwipeBackAbsorber(
                child: SizedBox.expand(child: ColoredBox(color: Colors.grey)),
              ),
            ),
            Expanded(child: ColoredBox(color: Colors.white)),
          ],
        ),
      );

      await _swipeBack(tester, y: 50);
      expect(find.byKey(_pageKey), findsOneWidget);

      await _swipeBack(tester, y: 400);
      expect(find.byKey(_pageKey), findsNothing, reason: '抬手后必须还原 canSwipe');
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  });

  test('闸门：跟手侧滑页只有一处入口，且必须过 SwipeBackScrollGuard', () {
    final router = File('lib/app/routes/app_router.dart').readAsStringSync();
    expect(
      RegExp(r'SwipeablePage<').allMatches(router).length,
      1,
      reason: '新页面请走 buildAdaptiveSwipeablePage，别自己 new SwipeablePage',
    );
    expect(
      router.contains('builder: (context) => SwipeBackScrollGuard(child: child)'),
      isTrue,
      reason: 'buildAdaptiveSwipeablePage 必须把页面包进 SwipeBackScrollGuard',
    );

    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('app_router.dart')) continue;
      final source = entity.readAsStringSync();
      if (source.contains('SwipeablePage<') ||
          source.contains('SwipeablePageRoute(')) {
        offenders.add(entity.path);
      }
    }
    expect(offenders, isEmpty, reason: '跟手侧滑页的构造点只许有 app_router 一处');
  });
}

const Key _pageKey = Key('guarded-page');

/// 推入一张「整页跟手侧滑返回」的页面（等价 `buildAdaptiveSwipeablePage` 在
/// iOS 分支上做的事）。
Future<void> _pushGuardedPage(WidgetTester tester, Widget body) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                SwipeablePageRoute<void>(
                  builder: (_) => SwipeBackScrollGuard(
                    child: Scaffold(key: _pageKey, body: body),
                  ),
                ),
              ),
              child: const Text('push'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('push'));
  await tester.pumpAndSettle();
  expect(find.byKey(_pageKey), findsOneWidget);
}

/// 从页面中部向右拖过半屏——足以触发跟手返回。
Future<void> _swipeBack(WidgetTester tester, {double y = 300}) async {
  await tester.dragFrom(Offset(120, y), const Offset(520, 0));
  await tester.pumpAndSettle();
}

Widget _tabBarViewPage(TabController controller) {
  return TabBarView(
    controller: controller,
    children: [
      for (int i = 0; i < controller.length; i++)
        ColoredBox(
          color: Colors.primaries[i].shade100,
          child: Center(child: Text('tab body $i')),
        ),
    ],
  );
}
