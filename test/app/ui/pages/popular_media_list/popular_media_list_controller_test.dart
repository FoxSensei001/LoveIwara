import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/common/constants.dart';

void main() {
  group('PopularMediaListController header sync', () {
    test('tracks scroll snapshot per tab and restores on setActiveSort', () {
      final controller = PopularMediaListController();
      controller.configureHeaderExtent(48);

      controller.setActiveSort(SortId.trending);

      controller.updateScrollInfo(
        sortId: SortId.trending,
        offset: 100,
        direction: ScrollDirection.reverse,
        delta: 100,
      );
      expect(controller.currentScrollOffset, 100);
      expect(controller.lastScrollDirection, ScrollDirection.reverse);

      controller.updateScrollInfo(
        sortId: SortId.date,
        offset: 12,
        direction: ScrollDirection.forward,
        delta: -12,
      );
      controller.setActiveSort(SortId.date);
      expect(controller.currentScrollOffset, 12);
      expect(controller.lastScrollDirection, ScrollDirection.forward);

      controller.setActiveSort(SortId.trending);
      expect(controller.currentScrollOffset, 100);
      expect(controller.lastScrollDirection, ScrollDirection.reverse);
    });

    test('invalidates only active loaded sort immediately', () {
      final controller = PopularMediaListController();

      controller.markSortLoaded(SortId.trending);
      controller.markSortLoaded(SortId.date);
      controller.setActiveSort(SortId.trending);

      controller.invalidateLoadedSorts(activeSortId: SortId.trending);

      expect(controller.reloadVersionFor(SortId.trending), 1);
      expect(controller.reloadVersionFor(SortId.date), 0);

      controller.setActiveSort(SortId.date);

      expect(controller.reloadVersionFor(SortId.date), 1);

      controller.setActiveSort(SortId.date);
      expect(controller.reloadVersionFor(SortId.date), 1);
    });

    // 「回到顶部」浮钮以前直接读每帧都在变的 currentScrollOffset，于是滚动期间
    // 每帧都要重建一次浮钮子树。现在偏移量走普通字段，响应式的只有阈值化之后的
    // canScrollToTop —— 这条测试盯的就是「阈值以内继续滚动，一次通知都不发」。
    test('canScrollToTop flips only when crossing the threshold', () async {
      final controller = PopularMediaListController();
      controller.setActiveSort(SortId.trending);
      expect(controller.canScrollToTop.value, isFalse);

      controller.updateScrollInfo(
        sortId: SortId.trending,
        offset: PopularMediaListController.scrollToTopThreshold - 1,
        direction: ScrollDirection.reverse,
      );
      expect(controller.canScrollToTop.value, isFalse);

      controller.updateScrollInfo(
        sortId: SortId.trending,
        offset: PopularMediaListController.scrollToTopThreshold + 1,
        direction: ScrollDirection.reverse,
      );
      expect(controller.canScrollToTop.value, isTrue);

      var notifications = 0;
      final sub = controller.canScrollToTop.listen((_) => notifications++);

      // 已经在阈值以上，继续往下滚：值没变，就不该有任何通知。
      controller.updateScrollInfo(
        sortId: SortId.trending,
        offset: 1200,
        direction: ScrollDirection.reverse,
      );
      controller.updateScrollInfo(
        sortId: SortId.trending,
        offset: 1500,
        direction: ScrollDirection.reverse,
      );
      await Future<void>.delayed(Duration.zero);
      expect(notifications, 0, reason: '阈值以内继续滚动不该发通知');

      // 翻回阈值以下：恰好一次。
      controller.updateScrollInfo(
        sortId: SortId.trending,
        offset: 400,
        direction: ScrollDirection.forward,
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.canScrollToTop.value, isFalse);
      expect(notifications, 1);

      await sub.cancel();

      // 回到顶部后偏移量与浮钮状态一起归零。
      controller.scrollToTop();
      expect(controller.currentScrollOffset, 0);
      expect(controller.canScrollToTop.value, isFalse);
    });

    // 非激活 tab 的滚动只进快照，不该驱动 UI（浮钮 / header 都只认当前 tab）。
    test('inactive tab scroll does not drive canScrollToTop', () {
      final controller = PopularMediaListController();
      controller.setActiveSort(SortId.trending);

      controller.updateScrollInfo(
        sortId: SortId.date,
        offset: 5000,
        direction: ScrollDirection.reverse,
      );

      expect(controller.canScrollToTop.value, isFalse);
    });
  });
}
