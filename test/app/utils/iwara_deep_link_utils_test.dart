import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/utils/iwara_deep_link_utils.dart';

void main() {
  group('IwaraDeepLinkUtils', () {
    test('normalizes profile videos deeplink to author profile route', () {
      final location = IwaraDeepLinkUtils.normalizeToAppLocation(
        Uri.parse('https://www.iwara.tv/profile/nomisugi83/videos'),
      );

      expect(location, '/author_profile/nomisugi83');
    });

    test(
      'normalizes profile playlists deeplink to author profile playlist tab',
      () {
        final location = IwaraDeepLinkUtils.normalizeToAppLocation(
          Uri.parse('https://www.iwara.tv/profile/nomisugi83/playlists'),
        );

        expect(location, '/author_profile/nomisugi83?tab=playlists');
      },
    );

    test('resolves author profile tab aliases', () {
      expect(
        IwaraDeepLinkUtils.resolveAuthorProfileInitialTabIndex('videos'),
        0,
      );
      expect(
        IwaraDeepLinkUtils.resolveAuthorProfileInitialTabIndex('images'),
        1,
      );
      expect(
        IwaraDeepLinkUtils.resolveAuthorProfileInitialTabIndex('playlists'),
        2,
      );
      expect(
        IwaraDeepLinkUtils.resolveAuthorProfileInitialTabIndex('posts'),
        3,
      );
    });

    test('normalizes news article deeplink to internal detail route', () {
      final location = IwaraDeepLinkUtils.normalizeToAppLocation(
        Uri.parse('https://news.iwara.tv/12-signing-off/#comment-2579'),
      );

      expect(
        location,
        '/news/12-signing-off?url=https%3A%2F%2Fnews.iwara.tv%2F12-signing-off%2F%23comment-2579',
      );
    });

    test('normalizes news category deeplink with locale prefix', () {
      final location = IwaraDeepLinkUtils.normalizeToAppLocation(
        Uri.parse('https://news.iwara.tv/ja/category/news-updates-ja/'),
      );

      expect(location, '/news?category=newsUpdates&lang=ja');
    });

    test('normalizes news category deeplink without locale prefix', () {
      final location = IwaraDeepLinkUtils.normalizeToAppLocation(
        Uri.parse('https://news.iwara.tv/category/broadcast/'),
      );

      expect(location, '/news?category=broadcast&lang=en');
    });
  });
}
