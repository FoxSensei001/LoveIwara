import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/common/constants.dart';

void main() {
  group('PopularMediaListController header sync', () {
    test('tracks showHeader per tab and restores on setActiveSort', () {
      final controller = PopularMediaListController();

      controller.setActiveSort(SortId.trending);
      expect(controller.showHeader.value, isTrue);

      // Simulate user scrolling up in the active tab enough to collapse header.
      controller.updateScrollInfo(
        sortId: SortId.trending,
        offset: 100,
        direction: ScrollDirection.reverse,
      );
      expect(controller.showHeader.value, isFalse);

      // Switch to another tab that has not been scrolled.
      controller.setActiveSort(SortId.date);
      expect(controller.showHeader.value, isTrue);

      // Switching back should restore the previous state for that tab.
      controller.setActiveSort(SortId.trending);
      expect(controller.showHeader.value, isFalse);
    });
  });
}
