import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/custom_thumbnail.model.dart';
import 'package:i_iwara/app/models/media_file.model.dart';
import 'package:i_iwara/app/models/video.model.dart';

void main() {
  group('Video model external video tests', () {
    const testYtId = '5RaFyvjtcLM';

    final validUrls = <String>[
      'https://youtu.be/$testYtId',
      'https://youtu.be/$testYtId?si=abc123xyz',
      'https://www.youtube.com/watch?v=$testYtId',
      'https://youtube.com/watch?v=$testYtId&feature=emb_title',
      'https://m.youtube.com/watch?feature=share&v=$testYtId',
      'https://www.youtube.com/embed/$testYtId',
      'https://youtube.com/embed/$testYtId?autoplay=1',
      'https://www.youtube-nocookie.com/embed/$testYtId',
      'https://www.youtube.com/shorts/$testYtId',
      'https://www.youtube.com/v/$testYtId',
      'https://www.youtube.com/live/$testYtId?feature=share',
      '//www.youtube.com/watch?v=$testYtId',
      'youtu.be/$testYtId',
    ];

    for (final url in validUrls) {
      test('extractYoutubeVideoId parses $url correctly', () {
        expect(Video.extractYoutubeVideoId(url), equals(testYtId));
      });
    }

    test('extractYoutubeVideoId returns null for invalid or non-youtube URLs', () {
      expect(Video.extractYoutubeVideoId(null), isNull);
      expect(Video.extractYoutubeVideoId(''), isNull);
      expect(Video.extractYoutubeVideoId('https://example.com/test'), isNull);
      expect(Video.extractYoutubeVideoId('https://iwara.tv/video/123'), isNull);
    });

    test('externalVideoThumbnail generates valid YouTube thumbnail URL', () {
      final video = Video(
        id: 'test_vid',
        embedUrl: 'https://youtu.be/$testYtId',
      );
      expect(video.isExternalVideo, isTrue);
      // 封面走 iwara 图片代理，不直连 i.ytimg.com（网络可达性）
      expect(
        video.externalVideoThumbnail,
        equals('https://i.iwara.tv/image/embed/thumbnail/youtube/$testYtId'),
      );
      expect(
        video.thumbnailUrl,
        equals('https://i.iwara.tv/image/embed/thumbnail/youtube/$testYtId'),
      );
      expect(
        video.previewUrl,
        equals('https://i.iwara.tv/image/embed/thumbnail/youtube/$testYtId'),
      );
    });

    test('externalVideoDomain parses domain correctly with and without protocol', () {
      final v1 = Video(id: '1', embedUrl: 'https://www.youtube.com/watch?v=$testYtId');
      expect(v1.externalVideoDomain, equals('www.youtube.com'));

      final v2 = Video(id: '2', embedUrl: 'youtu.be/$testYtId');
      expect(v2.externalVideoDomain, equals('youtu.be'));
    });

    test('customThumbnail takes precedence over external and normal thumbnails', () {
      final custom = CustomThumbnail.fromJson({
        'id': 'ct_123',
        'type': 'image',
        'path': '2026/01/01',
        'name': 'custom.jpg',
        'mime': 'image/jpeg',
      });

      // 站外视频带自定义封面
      final externalWithCustom = Video(
        id: 'ext_custom',
        embedUrl: 'https://youtu.be/$testYtId',
        customThumbnail: custom,
      );
      expect(
        externalWithCustom.thumbnailUrl,
        equals('https://i.iwara.tv/image/thumbnail/ct_123/custom.jpg'),
      );
      expect(
        externalWithCustom.previewUrl,
        equals('https://i.iwara.tv/image/thumbnail/ct_123/custom.jpg'),
      );

      // 普通视频带自定义封面
      final internalWithCustom = Video(
        id: 'int_custom',
        customThumbnail: custom,
        file: MediaFile.fromJson({
          'id': 'file_456',
          'type': 'video',
          'path': '2026/01/01',
          'name': 'test.mp4',
          'mime': 'video/mp4',
          'animatedPreview': false,
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
        }),
        thumbnail: 3,
      );
      expect(
        internalWithCustom.thumbnailUrl,
        equals('https://i.iwara.tv/image/thumbnail/ct_123/custom.jpg'),
      );
    });

    test('normal internal video generates file thumbnail', () {
      final normalVideo = Video(
        id: 'int_normal',
        file: MediaFile.fromJson({
          'id': 'file_789',
          'type': 'video',
          'path': '2026/01/01',
          'name': 'test.mp4',
          'mime': 'video/mp4',
          'animatedPreview': false,
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
        }),
        thumbnail: 5,
      );
      expect(normalVideo.isExternalVideo, isFalse);
      expect(
        normalVideo.thumbnailUrl,
        equals('https://i.iwara.tv/image/thumbnail/file_789/thumbnail-05.jpg'),
      );
      expect(
        normalVideo.previewUrl,
        equals('https://i.iwara.tv/image/original/file_789/preview.webp'),
      );
    });
  });
}
