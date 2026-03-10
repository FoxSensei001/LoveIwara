import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';

void main() {
  group('MyVideoStateController.shouldRevealToolbarsOnMouseHover', () {
    test('returns false when hover reveal feature is disabled', () {
      expect(
        MyVideoStateController.shouldRevealToolbarsOnMouseHover(
          hoverFeatureEnabled: false,
          isToolbarsLocked: false,
          isSuppressed: false,
        ),
        isFalse,
      );
    });

    test('returns false when toolbars are locked', () {
      expect(
        MyVideoStateController.shouldRevealToolbarsOnMouseHover(
          hoverFeatureEnabled: true,
          isToolbarsLocked: true,
          isSuppressed: false,
        ),
        isFalse,
      );
    });

    test('returns false when reveal is suppressed by overlay state', () {
      expect(
        MyVideoStateController.shouldRevealToolbarsOnMouseHover(
          hoverFeatureEnabled: true,
          isToolbarsLocked: false,
          isSuppressed: true,
        ),
        isFalse,
      );
    });

    test('returns true only when feature is enabled and unsuppressed', () {
      expect(
        MyVideoStateController.shouldRevealToolbarsOnMouseHover(
          hoverFeatureEnabled: true,
          isToolbarsLocked: false,
          isSuppressed: false,
        ),
        isTrue,
      );
    });
  });
}
