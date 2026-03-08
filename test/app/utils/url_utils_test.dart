import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/utils/url_utils.dart';

void main() {
  group('UrlUtils', () {
    test('recognizes and resolves relative iwara forum links', () {
      const relativeUrl =
          '/forum/announcements/cb9ca2ac-9093-456a-afab-20a086eaec35';

      expect(UrlUtils.isRelativeIwaraPath(relativeUrl), isTrue);
      expect(
        UrlUtils.resolveRelativeIwaraUrl(relativeUrl, IwaraSite.ai),
        'https://www.iwara.ai/forum/announcements/cb9ca2ac-9093-456a-afab-20a086eaec35',
      );

      final parsed = UrlUtils.parseUrl(
        relativeUrl,
        siteForRelativeUrl: IwaraSite.ai,
      );
      expect(parsed.site, IwaraSite.ai);
      expect(parsed.type, IwaraUrlType.forumThread);
      expect(parsed.id, 'announcements');
      expect(parsed.secondaryId, 'cb9ca2ac-9093-456a-afab-20a086eaec35');
    });

    test('keeps explicit ai profile links on ai site', () {
      final parsed = UrlUtils.parseUrl(
        'https://www.iwara.ai/profile/sos8622459',
      );

      expect(parsed.site, IwaraSite.ai);
      expect(parsed.type, IwaraUrlType.profile);
      expect(parsed.id, 'sos8622459');
    });

    test('does not treat arbitrary relative paths as iwara links', () {
      expect(UrlUtils.isRelativeIwaraPath('/news/latest'), isFalse);
      expect(
        UrlUtils.resolveRelativeIwaraUrl('/news/latest', IwaraSite.main),
        isNull,
      );
    });
  });
}
