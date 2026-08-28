import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/external_player_service.dart';

void main() {
  group('ExternalPlayerService.chooseSource', () {
    test('纯本地视频优先用它自己的路径', () {
      final source = ExternalPlayerService.chooseSource(
        localVideoPath: '/sdcard/Movies/a.mp4',
        downloadedPath: '/sdcard/Download/b.mp4',
        onlineUrl: 'https://cdn.example.com/a.mp4',
      );

      expect(source!.kind, ExternalPlayerSourceKind.localFile);
      expect(source.value, '/sdcard/Movies/a.mp4');
    });

    test('在线视频若当前清晰度已下载，交本地文件而不是直链', () {
      // 直链有时效，外部播放器放到一半会断；手上有本地副本就必须交本地副本。
      final source = ExternalPlayerService.chooseSource(
        downloadedPath: '/sdcard/Download/b.mp4',
        onlineUrl: 'https://cdn.example.com/a.mp4',
        qualityTag: '1080',
      );

      expect(source!.isLocalFile, isTrue);
      expect(source.value, '/sdcard/Download/b.mp4');
      expect(source.qualityTag, '1080');
    });

    test('没有本地副本才回退在线直链', () {
      final source = ExternalPlayerService.chooseSource(
        onlineUrl: 'https://cdn.example.com/a.mp4',
        qualityTag: '720',
      );

      expect(source!.kind, ExternalPlayerSourceKind.onlineUrl);
      expect(source.value, 'https://cdn.example.com/a.mp4');
      expect(source.qualityTag, '720');
    });

    test('空串等同于没有', () {
      final source = ExternalPlayerService.chooseSource(
        localVideoPath: '',
        downloadedPath: '',
        onlineUrl: 'https://cdn.example.com/a.mp4',
      );
      expect(source!.kind, ExternalPlayerSourceKind.onlineUrl);

      expect(
        ExternalPlayerService.chooseSource(
          localVideoPath: '',
          downloadedPath: '',
          onlineUrl: '',
        ),
        isNull,
      );
    });
  });

  group('ExternalPlayerService.stripFileScheme', () {
    test('剥掉 file:// 并还原百分号编码', () {
      expect(
        ExternalPlayerService.stripFileScheme(
          'file:///storage/emulated/0/Download/%E6%B5%8B%E8%AF%95%20a.mp4',
        ),
        '/storage/emulated/0/Download/测试 a.mp4',
      );
    });

    test('裸路径与 content:// 原样返回', () {
      expect(
        ExternalPlayerService.stripFileScheme('/sdcard/a.mp4'),
        '/sdcard/a.mp4',
      );
      expect(
        ExternalPlayerService.stripFileScheme('content://media/external/video/1'),
        'content://media/external/video/1',
      );
    });
  });
}
