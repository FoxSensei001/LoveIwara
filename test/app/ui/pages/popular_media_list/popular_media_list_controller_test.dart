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
      expect(controller.currentScrollOffset.value, 100);
      expect(controller.lastScrollDirection.value, ScrollDirection.reverse);

      controller.updateScrollInfo(
        sortId: SortId.date,
        offset: 12,
        direction: ScrollDirection.forward,
        delta: -12,
      );
      controller.setActiveSort(SortId.date);
      expect(controller.currentScrollOffset.value, 12);
      expect(controller.lastScrollDirection.value, ScrollDirection.forward);

      controller.setActiveSort(SortId.trending);
      expect(controller.currentScrollOffset.value, 100);
      expect(controller.lastScrollDirection.value, ScrollDirection.reverse);
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
  });
}
