import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/controllers/media_list_controller.dart';

void main() {
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
