import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:path/path.dart' as path;

void main() {
  group('DownloadService delete target safety', () {
    test('rejects root directory recursive deletion', () {
      expect(
        DownloadService.isSafeDeleteTarget(
          Platform.pathSeparator,
          FileSystemEntityType.directory,
        ),
        isFalse,
      );
    });

    test(
      'rejects home directory recursive deletion when HOME is available',
      () {
        final home = Platform.environment['HOME'];
        if (home == null || home.isEmpty) {
          return;
        }

        expect(
          DownloadService.isSafeDeleteTarget(
            home,
            FileSystemEntityType.directory,
          ),
          isFalse,
        );
      },
    );

    test('allows ordinary file deletion targets', () {
      expect(
        DownloadService.isSafeDeleteTarget(
          '${Directory.systemTemp.path}${Platform.pathSeparator}clip.mp4',
          FileSystemEntityType.file,
        ),
        isTrue,
      );
    });
  });

  group('DownloadService gallery image path safety', () {
    test('keeps API-provided image ids inside the gallery directory', () {
      final galleryDirectory = path.join(
        Directory.systemTemp.path,
        'iwara-gallery',
      );

      for (final imageId in const ['../evil', '/tmp/evil', r'nested\name']) {
        final savePath = DownloadService.buildGalleryImageSavePath(
          galleryDirectory: galleryDirectory,
          imageId: imageId,
          url: 'https://example.test/images/source.png?download=evil.exe',
        );

        expect(
          DownloadPathService.isPathInsideBase(galleryDirectory, savePath),
          isTrue,
        );
        expect(path.basename(savePath), isNot(contains('..')));
        expect(path.basename(savePath), isNot(contains('/')));
        expect(path.basename(savePath), isNot(contains(r'\')));
        expect(path.basename(savePath), endsWith('.png'));
      }
    });
  });
}
