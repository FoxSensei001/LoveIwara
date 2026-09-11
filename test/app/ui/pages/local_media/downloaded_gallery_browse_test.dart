import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/downloaded_gallery_card.dart';

void main() {
  group('DownloadedGalleryRow 解析与安全守卫', () {
    test('完整数据正确提取 savePath, galleryId, coverPath 与 imageCount', () {
      final task = DownloadTask(
        id: 'task_123',
        url: 'https://example.com/gallery/abc',
        savePath: '/tmp/downloads/my_gallery',
        fileName: 'my_gallery_dir',
        extData: DownloadTaskExtData(
          type: DownloadTaskExtDataType.gallery,
          data: {
            'id': 'online_gal_456',
            'title': '精选画册',
            'total_images': 15,
            'image_list': {
              'img_1': 'https://example.com/1.jpg',
              'img_2': 'https://example.com/2.jpg',
            },
            'local_paths': {
              'img_1': '/tmp/downloads/my_gallery/1.jpg',
              'img_2': '/tmp/downloads/my_gallery/2.jpg',
            },
          },
        ),
      );

      final row = DownloadedGalleryRow.of(task);
      expect(row, isNotNull);
      expect(row!.taskId, 'task_123');
      expect(row.title, '精选画册');
      expect(row.coverPath, '/tmp/downloads/my_gallery/1.jpg');
      expect(row.imageCount, 15);
      expect(row.savePath, '/tmp/downloads/my_gallery');
      expect(row.galleryId, 'online_gal_456');
    });

    test('当 title 为空时退化使用 task.fileName', () {
      final task = DownloadTask(
        id: 'task_fallback',
        url: 'https://example.com',
        savePath: '/tmp/downloads/fallback',
        fileName: 'fallback_folder',
        extData: DownloadTaskExtData(
          type: DownloadTaskExtDataType.gallery,
          data: {
            'title': '   ',
            'total_images': 5,
            'image_list': {'1': 'u1'},
            'local_paths': {'1': '/tmp/downloads/fallback/1.jpg'},
          },
        ),
      );

      final row = DownloadedGalleryRow.of(task);
      expect(row, isNotNull);
      expect(row!.title, 'fallback_folder');
      expect(row.imageCount, 5);
      expect(row.savePath, '/tmp/downloads/fallback');
    });

    test('脏 ext_data（非图库类型或 JSON 解析异常）安全返回 null 而不抛出异常', () {
      final nonGalleryTask = DownloadTask(
        id: 'task_video',
        url: 'https://example.com/video.mp4',
        savePath: '/tmp/downloads/video.mp4',
        fileName: 'video.mp4',
        extData: DownloadTaskExtData(
          type: DownloadTaskExtDataType.video,
          data: {'video_id': 'vid_1'},
        ),
      );
      expect(DownloadedGalleryRow.of(nonGalleryTask), isNull);

      final corruptTask = DownloadTask(
        id: 'task_corrupt',
        url: 'https://example.com',
        savePath: '/tmp/downloads/corrupt',
        fileName: 'corrupt',
        extData: DownloadTaskExtData(
          type: DownloadTaskExtDataType.gallery,
          data: {'total_images': 'not_an_int_and_broken'},
        ),
      );
      expect(DownloadedGalleryRow.of(corruptTask), isNull);
    });
  });
}
