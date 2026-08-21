import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/services/deep_link_service.dart';

void main() {
  group('DeepLinkService.pendingInitialLinkSite', () {
    // 冷启动恒为主站，所以"拉起应用的那条链接属于哪个站点"必须在建树前就问得到，
    // 否则要等页面开出来才切站，代价是重启整棵树。
    IwaraSite? siteOf(String? link) {
      final service = DeepLinkService();
      service.setPendingInitialLinkForTest(
        link == null ? null : Uri.parse(link),
      );
      return service.pendingInitialLinkSite;
    }

    test('AI 站链接以 AI 站起步', () {
      expect(siteOf('https://www.iwara.ai/video/xh6MMHdobHOEi3'), IwaraSite.ai);
      expect(siteOf('https://www.iwara.ai/image/cQkVtyZMOeUFzC'), IwaraSite.ai);
    });

    test('主站链接以主站起步', () {
      expect(
        siteOf('https://www.iwara.tv/video/L2Ts2RZAtjfTCR'),
        IwaraSite.main,
      );
    });

    test('没有启动链接、或链接应用内处理不了时不表态', () {
      expect(siteOf(null), isNull);
      expect(siteOf('https://example.com/video/abc'), isNull);
      // 站内域名但不是可识别的资源路径
      expect(siteOf('https://www.iwara.ai/unknown-section'), isNull);
    });
  });

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
