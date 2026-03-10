import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/deep_link_service.dart';

void main() {
  group('DeepLinkService.isTabRootAppLocation', () {
    test('returns true for tab-root locations', () {
      expect(DeepLinkService.isTabRootAppLocation('/'), isTrue);
      expect(DeepLinkService.isTabRootAppLocation('/gallery'), isTrue);
      expect(DeepLinkService.isTabRootAppLocation('/subscriptions'), isTrue);
      expect(DeepLinkService.isTabRootAppLocation('/forum'), isTrue);
      expect(
        DeepLinkService.isTabRootAppLocation(
          '/news?category=broadcast&lang=en',
        ),
        isTrue,
      );
    });

    test('returns false for detail locations', () {
      expect(
        DeepLinkService.isTabRootAppLocation(
          '/news/12-signing-off?url=https%3A%2F%2Fnews.iwara.tv%2F12-signing-off%2F',
        ),
        isFalse,
      );
      expect(
        DeepLinkService.isTabRootAppLocation('/video_detail/abc'),
        isFalse,
      );
    });
  });
}
