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
