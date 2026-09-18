import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/services/download_path_service.dart';

void main() {
  const pkg = 'm.c.g.a.i_iwara';

  DownloadLocation android(String path, {int sdkInt = 33}) =>
      DownloadLocation.describeAndroid(
        path,
        sdkInt: sdkInt,
        isAppPrivate: DownloadPathService.isAndroidAppPrivatePath(path, pkg),
        volumeRoot: DownloadPathService.storageVolumeRootOf(path),
      );

  group('Android 存储权限三态', () {
    test('API 30+：主存储 Download 及其子目录免授权', () {
      expect(
        android('/storage/emulated/0/Download/LoveIwara').access,
        StorageAccessNeed.none,
      );
      expect(
        android('/storage/emulated/10/Download').access,
        StorageAccessNeed.none,
      );
      expect(android('/sdcard/Download/a/b').access, StorageAccessNeed.none);
    });

    test('API 30+：Download 以外的共享存储要所有文件访问', () {
      expect(
        android('/storage/emulated/0/Movies').access,
        StorageAccessNeed.allFilesAccess,
      );
      // 名字像但不是 Download
      expect(
        android('/storage/emulated/0/Downloads_old').access,
        StorageAccessNeed.allFilesAccess,
      );
      // SD 卡上的 Download 也不算（只放行主存储）
      expect(
        android('/storage/1234-ABCD/Download/LoveIwara').access,
        StorageAccessNeed.allFilesAccess,
      );
    });

    test('API 29 及以下：共享存储一律普通存储权限', () {
      expect(
        android('/storage/emulated/0/Download/LoveIwara', sdkInt: 29).access,
        StorageAccessNeed.legacyStorage,
      );
      expect(
        android('/storage/emulated/0/Movies', sdkInt: 28).access,
        StorageAccessNeed.legacyStorage,
      );
    });

    test('App 专属目录永远免授权', () {
      expect(
        android('/storage/emulated/0/Android/data/$pkg/files/i_iwara').access,
        StorageAccessNeed.none,
      );
      expect(
        android('/data/user/0/$pkg/app_flutter', sdkInt: 28).access,
        StorageAccessNeed.none,
      );
    });
  });

  group('Android 友好名', () {
    test('公共下载目录', () {
      final loc = android('/storage/emulated/0/Download/LoveIwara');
      expect(loc.kind, DownloadLocationKind.publicDownloads);
      expect(loc.volume, DownloadVolumeKind.internal);
      expect(loc.startsWithDownloads, isTrue);
      expect(loc.segments, ['Download', 'LoveIwara']);
    });

    test('SD 卡带卷标', () {
      final loc = android('/storage/1234-ABCD/LoveIwara');
      expect(loc.kind, DownloadLocationKind.removableVolume);
      expect(loc.volume, DownloadVolumeKind.sdCard);
      expect(loc.volumeLabel, '1234-ABCD');
      expect(loc.segments, ['LoveIwara']);
    });

    test('App 专属空间不列路径段', () {
      final loc = android(
        '/storage/emulated/0/Android/data/$pkg/files/i_iwara/downloads',
      );
      expect(loc.kind, DownloadLocationKind.appPrivate);
      expect(loc.volume, DownloadVolumeKind.appSpace);
      expect(loc.segments, isEmpty);
    });

    test('太深的路径只留尾巴，保住「下载」', () {
      final loc = android('/storage/emulated/0/Download/a/b/c/d');
      expect(loc.truncated, isTrue);
      expect(loc.segments, ['Download', 'c', 'd']);
    });
  });

  group('桌面友好名', () {
    test('系统下载文件夹之下', () {
      final loc = DownloadLocation.describeDesktop(
        '/Users/me/Downloads/LoveIwara',
        context: p.posix,
        downloadsDir: '/Users/me/Downloads',
        isMacOS: true,
        isLinux: false,
        isWindows: false,
      );
      expect(loc.kind, DownloadLocationKind.desktopDownloads);
      expect(loc.startsWithDownloads, isTrue);
      expect(loc.segments, ['Downloads', 'LoveIwara']);
    });

    test('macOS 外置盘', () {
      final loc = DownloadLocation.describeDesktop(
        '/Volumes/Backup/Iwara',
        context: p.posix,
        downloadsDir: '/Users/me/Downloads',
        isMacOS: true,
        isLinux: false,
        isWindows: false,
      );
      expect(loc.volume, DownloadVolumeKind.externalDrive);
      expect(loc.volumeLabel, 'Backup');
      expect(loc.segments, ['Iwara']);
    });

    test('Windows 盘符当卷名', () {
      final loc = DownloadLocation.describeDesktop(
        r'D:\Media\Iwara',
        context: p.windows,
        downloadsDir: r'C:\Users\me\Downloads',
        isMacOS: false,
        isLinux: false,
        isWindows: true,
      );
      expect(loc.kind, DownloadLocationKind.desktopOther);
      expect(loc.volumeLabel, 'D:');
      expect(loc.segments, ['Media', 'Iwara']);
    });
  });

  test('df -Pk 输出解析', () {
    const out =
        'Filesystem     1024-blocks      Used Available Capacity Mounted on\n'
        '/dev/disk3s5   482797652 381234567  90000000    81% /System/Volumes/Data\n';
    expect(DownloadPathService.parseDfAvailableBytes(out), 90000000 * 1024);
    expect(DownloadPathService.parseDfAvailableBytes('garbage'), isNull);
  });
}
