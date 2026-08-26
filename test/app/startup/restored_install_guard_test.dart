import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/startup/restored_install_guard.dart';
import 'package:i_iwara/utils/logger_utils.dart';

void main() {
  setUpAll(() async {
    // reconcileIn 的失败分支会调用 LogUtils.e，需先初始化其 late logger。
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  group('RestoredInstallGuard.classify', () {
    test('标记还在就是正常启动，不管配置怎么说', () {
      expect(
        RestoredInstallGuard.classify(markerExists: true, markerIssued: true),
        InstallOrigin.normal,
      );
      expect(
        RestoredInstallGuard.classify(markerExists: true, markerIssued: false),
        InstallOrigin.normal,
      );
    });

    test('标记不在、配置也没说写过 → 全新安装或旧版本首次升上来', () {
      expect(
        RestoredInstallGuard.classify(markerExists: false, markerIssued: false),
        InstallOrigin.unmarked,
      );
    });

    test('标记不在、配置却记得写过 → 数据是还原来的', () {
      expect(
        RestoredInstallGuard.classify(markerExists: false, markerIssued: true),
        InstallOrigin.restored,
      );
    });
  });

  group('RestoredInstallGuard.reconcileIn', () {
    late Directory dir;
    late Map<ConfigKey, bool> written;

    Future<void> record(ConfigKey key, bool value) async {
      written[key] = value;
    }

    setUp(() {
      dir = Directory.systemTemp.createTempSync('restored_install_guard_test');
      written = <ConfigKey, bool>{};
    });

    tearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });

    File markerFile() =>
        File('${dir.path}${Platform.pathSeparator}'
            '${RestoredInstallGuard.markerFileName}');

    test('全新安装：只补写标记，一次性引导一个都不碰', () async {
      final origin = await RestoredInstallGuard.reconcileIn(
        markerDir: dir,
        markerIssued: false,
        setFlag: record,
      );

      expect(origin, InstallOrigin.unmarked);
      expect(markerFile().existsSync(), isTrue);
      expect(written, {ConfigKey.INSTALL_MARKER_ISSUED: true});
    });

    test('⛔ 老用户首次升级到本版本，绝不能被重新扔进引导页', () async {
      // 老库里没有 install_marker_issued（默认 false），磁盘上也没有标记文件——
      // 和"备份还原"长得一模一样，只有这个字段能把两者分开。
      final origin = await RestoredInstallGuard.reconcileIn(
        markerDir: dir,
        markerIssued: false,
        setFlag: record,
      );

      expect(origin, InstallOrigin.unmarked);
      expect(written.containsKey(ConfigKey.FIRST_TIME_SETUP_COMPLETED), isFalse);
      expect(written.containsKey(ConfigKey.GLASS_MATERIAL_INTRO_SHOWN), isFalse);
    });

    test('备份还原：复位首次引导和玻璃质感提醒，并补回标记', () async {
      final origin = await RestoredInstallGuard.reconcileIn(
        markerDir: dir,
        markerIssued: true,
        setFlag: record,
      );

      expect(origin, InstallOrigin.restored);
      expect(markerFile().existsSync(), isTrue);
      expect(written[ConfigKey.FIRST_TIME_SETUP_COMPLETED], isFalse);
      expect(written[ConfigKey.GLASS_MATERIAL_INTRO_SHOWN], isFalse);
      // 已经是 true 了，不必重写。
      expect(written.containsKey(ConfigKey.INSTALL_MARKER_ISSUED), isFalse);
    });

    test('标记已经在了：什么都不做', () async {
      markerFile().writeAsStringSync('x');

      final origin = await RestoredInstallGuard.reconcileIn(
        markerDir: dir,
        markerIssued: true,
        setFlag: record,
      );

      expect(origin, InstallOrigin.normal);
      expect(written, isEmpty);
    });

    test('标记在、配置却说没写过（导入了老配置备份）：把账补上，别动引导', () async {
      markerFile().writeAsStringSync('x');

      final origin = await RestoredInstallGuard.reconcileIn(
        markerDir: dir,
        markerIssued: false,
        setFlag: record,
      );

      expect(origin, InstallOrigin.normal);
      expect(written, {ConfigKey.INSTALL_MARKER_ISSUED: true});
    });

    test('复位过一次之后，下次启动不会再复位（标记已落盘）', () async {
      await RestoredInstallGuard.reconcileIn(
        markerDir: dir,
        markerIssued: true,
        setFlag: record,
      );
      written.clear();

      final second = await RestoredInstallGuard.reconcileIn(
        markerDir: dir,
        markerIssued: true,
        setFlag: record,
      );

      expect(second, InstallOrigin.normal);
      expect(written, isEmpty);
    });

    test('⛔ 标记写不进去时不许复位，否则用户会被永远关在引导页里', () async {
      // 指向一个建不出来的目录（父级是文件，不是目录）。
      final File blocker = File(
        '${dir.path}${Platform.pathSeparator}blocker',
      )..writeAsStringSync('not a directory');
      final Directory unusable = Directory(
        '${blocker.path}${Platform.pathSeparator}nested',
      );

      final origin = await RestoredInstallGuard.reconcileIn(
        markerDir: unusable,
        markerIssued: true,
        setFlag: record,
      );

      expect(origin, InstallOrigin.normal);
      expect(written, isEmpty);
    });
  });
}
