import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/oreno3d_video.model.dart';

Oreno3dVideoDetail _detail(String playUrl) {
  return Oreno3dVideoDetail(
    id: '1',
    title: 't',
    thumbnailUrl: '',
    oreno3dUrl: '',
    playUrl: playUrl,
    viewCount: 0,
    favoriteCount: 0,
  );
}

void main() {
  group('Oreno3dVideoDetail.extractIwaraId', () {
    test('parses id from url with title suffix', () {
      expect(
        _detail('https://www.iwara.tv/video/B0hoJzllLDTsvU/furina-im-ill')
            .extractIwaraId(),
        'B0hoJzllLDTsvU',
      );
    });

    test('parses id from url with trailing slash', () {
      expect(
        _detail('https://www.iwara.tv/video/gvYM0sEvhTunDI/').extractIwaraId(),
        'gvYM0sEvhTunDI',
      );
    });

    test('parses id from url without www', () {
      expect(
        _detail('https://iwara.tv/video/abc123').extractIwaraId(),
        'abc123',
      );
    });

    test('returns null for non-iwara url', () {
      expect(_detail('https://example.com/video/x').extractIwaraId(), isNull);
    });

    test('returns null for empty playUrl', () {
      expect(_detail('').extractIwaraId(), isNull);
    });

    test('returns null when path is not a video url', () {
      expect(_detail('https://www.iwara.tv/profile/someone').extractIwaraId(),
          isNull);
    });
  });
}
