import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:path/path.dart' as path;

void main() {
  group('DownloadPathService.safeJoinUnderBase', () {
    test('keeps normal generated paths under the base directory', () {
      final base = path.join(Directory.systemTemp.path, 'iwara-downloads');

      final joined = DownloadPathService.safeJoinUnderBase(base, [
        'gallery',
        'image.jpg',
      ]);

      expect(DownloadPathService.isPathInsideBase(base, joined), isTrue);
      expect(joined, path.normalize(path.join(base, 'gallery', 'image.jpg')));
    });

    test('rejects path traversal segments', () {
      final base = path.join(Directory.systemTemp.path, 'iwara-downloads');

      expect(
        () =>
            DownloadPathService.safeJoinUnderBase(base, ['..', 'outside.mp4']),
        throwsArgumentError,
      );
    });
  });

  group('DownloadPathService Android storage classification', () {
    const pkg = 'm.c.g.a.i_iwara';

    test('recognises app-private dirs on every storage volume', () {
      for (final p in [
        // ⛔ 主存储的外部私有目录：旧正则匹配不到它，推荐路径会被误报缺权限
        '/storage/emulated/0/Android/data/$pkg/files/downloads',
        '/storage/self/primary/Android/data/$pkg/files',
        '/sdcard/Android/data/$pkg/files',
        '/storage/1234-5678/Android/data/$pkg/files',
        '/storage/emulated/0/Android/obb/$pkg',
        '/data/data/$pkg/files',
        '/data/user/0/$pkg/files',
        '/data/user/10/$pkg/files', // 工作资料
      ]) {
        expect(
          DownloadPathService.isAndroidAppPrivatePath(p, pkg),
          isTrue,
          reason: p,
        );
        expect(DownloadPathService.isAndroidSharedStoragePath(p, pkg), isFalse);
      }
    });

    test('treats any non-private path on a volume as shared storage', () {
      for (final p in [
        '/storage/emulated/0/Download/iwara',
        '/storage/emulated/0', // 卷根本身
        '/sdcard/Download',
        '/storage/1234-5678/Download', // 外置 SD 卡：旧实现漏判
        '/storage/emulated/0/Iwara', // 用户自建目录：旧实现漏判
        '/storage/emulated/0/Android/data/other.app/files', // 别人的私有目录
      ]) {
        expect(
          DownloadPathService.isAndroidSharedStoragePath(p, pkg),
          isTrue,
          reason: p,
        );
      }
    });

    test('does not confuse sibling directories sharing a name prefix', () {
      // 旧实现 startsWith('/storage/emulated/0/Download') 会把它们一并算进去。
      // 它们**仍然**在共享存储上（所以还是 true），但走的是卷判定而不是前缀。
      expect(
        DownloadPathService.storageVolumeRootOf(
          '/storage/emulated/0/Downloads_old',
        ),
        '/storage/emulated/0',
      );
      // 私有目录的兄弟目录不能被当成私有。
      expect(
        DownloadPathService.isAndroidAppPrivatePath(
          '/storage/emulated/0/Android/data/${pkg}_backup/files',
          pkg,
        ),
        isFalse,
      );
    });

    test('paths outside any storage volume are neither private nor shared', () {
      for (final p in ['/tmp/foo', '/data/local/tmp', '']) {
        expect(DownloadPathService.isAndroidSharedStoragePath(p, pkg), isFalse);
        expect(DownloadPathService.isAndroidAppPrivatePath(p, pkg), isFalse);
      }
    });
  });

  group('DownloadPathService.rebaseSandboxPath', () {
    const oldContainer =
        '/var/mobile/Containers/Data/Application/AAAAAAAA-1111-2222-3333-444444444444';
    const newContainer =
        '/var/mobile/Containers/Data/Application/BBBBBBBB-5555-6666-7777-888888888888';

    test('moves a stale container path onto the current container', () {
      expect(
        DownloadPathService.rebaseSandboxPath(
          '$oldContainer/Documents/LoveIwara/downloads',
          '$newContainer/Documents/LoveIwara',
        ),
        '$newContainer/Documents/LoveIwara/downloads',
      );
    });

    test('returns null when already in the current container', () {
      expect(
        DownloadPathService.rebaseSandboxPath(
          '$newContainer/Documents/LoveIwara/downloads',
          '$newContainer/Documents/LoveIwara',
        ),
        isNull,
      );
    });

    test('leaves non-container paths alone', () {
      expect(
        DownloadPathService.rebaseSandboxPath(
          '/storage/emulated/0/Download/iwara',
          '$newContainer/Documents/LoveIwara',
        ),
        isNull,
      );
      expect(DownloadPathService.rebaseSandboxPath('', ''), isNull);
    });
  });

  group('DownloadPathService.resolveAvailablePath', () {
    test('adds numeric suffix when file exists or path is reserved', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'iwara-download-path-test-',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final desiredPath = path.join(tempDir.path, 'clip.mp4');
      await File(desiredPath).writeAsString('existing');

      final resolved = await DownloadPathService.resolveAvailablePath(
        desiredPath,
        isDirectory: false,
        isReserved: (candidate) => path.basename(candidate) == 'clip (1).mp4',
      );

      expect(resolved, path.join(tempDir.path, 'clip (2).mp4'));
    });

    test(
      'adds numeric suffix to directory names without treating extension specially',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'iwara-download-dir-test-',
        );
        addTearDown(() async {
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });

        final desiredPath = path.join(tempDir.path, 'gallery.v1');
        await Directory(desiredPath).create();

        final resolved = await DownloadPathService.resolveAvailablePath(
          desiredPath,
          isDirectory: true,
        );

        expect(resolved, path.join(tempDir.path, 'gallery.v1 (1)'));
      },
    );
  });
}
