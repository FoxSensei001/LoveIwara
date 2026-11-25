import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/controllers/media_list_controller.dart';

void main() {
  testWidgets('scroll-to-top observers rebuild only at visibility changes', (
    tester,
  ) async {
    final controller = MediaListController();
    var builds = 0;
    await tester.pumpWidget(
      Obx(() {
        builds++;
        return SizedBox(width: controller.canScrollToTop ? 10 : 0);
      }),
    );
    expect(builds, 1);

    controller.notifyListScroll(800, ScrollDirection.reverse);
    await tester.pumpAndSettle();
    expect(builds, 1);

    controller.notifyListScroll(801, ScrollDirection.reverse);
    await tester.pumpAndSettle();
    expect(builds, 2);

    controller.notifyListScroll(900, ScrollDirection.reverse);
    await tester.pumpAndSettle();
    expect(builds, 2);

    controller.resetScrollState();
    await tester.pumpAndSettle();
    expect(builds, 3);
    expect(controller.canScrollToTop, isFalse);
  });

  group('MediaListController site switch invalidation', () {
    test('invalidates only active loaded tab immediately', () {
      final controller = MediaListController();

      controller.markTabLoaded(0);
      controller.markTabLoaded(1);
      controller.setActiveTab(0);

      controller.invalidateLoadedTabs(activeTabIndex: 0);

      expect(controller.reloadVersionForTab(0), 1);
      expect(controller.reloadVersionForTab(1), 0);
      expect(controller.reloadVersionForTab(2), 0);

      controller.setActiveTab(1);

      expect(controller.reloadVersionForTab(1), 1);

      controller.setActiveTab(1);
      expect(controller.reloadVersionForTab(1), 1);
      expect(controller.reloadVersionForTab(2), 0);
    });
  });
}
