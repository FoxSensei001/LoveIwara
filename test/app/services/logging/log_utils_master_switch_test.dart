import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' as pkg_logger;
import 'package:i_iwara/app/services/logging/log_models.dart';
import 'package:i_iwara/app/services/logging/log_paths.dart';
import 'package:i_iwara/app/services/logging/log_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 起一个 LogService 并挂到 LogUtils 上，用来驱动日志总开关。
Future<LogService> _attachService({required bool enabled}) async {
  final tempDir = await Directory.systemTemp.createTemp('loveiwara_master_sw_');
  addTearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  final service = await LogService().init(
    paths: LogPaths.forTesting(
      logDir: '${tempDir.path}/logs',
      exportDir: '${tempDir.path}/export',
    ),
    policy: LogPolicy.defaults(
      isProduction: true,
    ).copyWith(enabled: enabled).normalized(),
  );
  addTearDown(service.close);
  LogUtils.attachLogService(service);
  return service;
}

/// 抓住 logger 包真正吐给 output 的每一条，用来证明控制台侧一条都没跑。
List<pkg_logger.OutputEvent> _captureConsoleOutput() {
  final captured = <pkg_logger.OutputEvent>[];
  void listener(pkg_logger.OutputEvent e) => captured.add(e);
  pkg_logger.Logger.addOutputListener(listener);
  addTearDown(() => pkg_logger.Logger.removeOutputListener(listener));
  return captured;
}

void main() {
  group('日志总开关：关闭时必须是真关闭', () {
    test('生产环境关闭后，d/i/w 的控制台 printer 一条都不跑', () async {
      await LogUtils.init(isProduction: true);
      await _attachService(enabled: false);
      final console = _captureConsoleOutput();

      LogUtils.i('不该出现的信息');
      LogUtils.w('不该出现的警告');
      LogUtils.d('不该出现的调试');

      // 关键断言：不是「没落盘」，而是连控制台格式化都没发生。
      // 旧实现只在 LogService.log() 里挡持久化，PrettyPrinter 照跑，
      // 每条要付 33us 的 StackTrace 展开。
      expect(console, isEmpty);
    });

    test('e() 刻意豁免：关闭后仍写控制台，但不落盘', () async {
      await LogUtils.init(isProduction: true);
      final service = await _attachService(enabled: false);
      final console = _captureConsoleOutput();

      LogUtils.e(
        '网络请求失败',
        error: StateError('boom'),
        stackTrace: StackTrace.current,
      );

      // error 是健康应用里唯一有诊断价值又足够稀疏的一类，
      // 全挡掉会让默认配置下的排障彻底断掉。
      expect(console, isNotEmpty);
      // 但持久化那一侧仍受开关约束。
      expect(service.getRecentLogs(), isEmpty);
    });

    test('生产环境关闭后，i/w 连内存环形缓冲也不进', () async {
      await LogUtils.init(isProduction: true);
      final service = await _attachService(enabled: false);

      LogUtils.i('不该出现的信息');
      LogUtils.w('不该出现的警告');

      expect(service.getRecentLogs(), isEmpty);
    });

    test('重新打开后立刻恢复记录', () async {
      await LogUtils.init(isProduction: true);
      final service = await _attachService(enabled: false);
      final console = _captureConsoleOutput();

      LogUtils.i('关闭期间');
      expect(console, isEmpty);

      await service.applyPolicy(
        LogPolicy.defaults(isProduction: true).copyWith(enabled: true),
      );

      LogUtils.i('打开之后');
      expect(console, isNotEmpty);
      expect(service.getRecentLogs(), isNotEmpty);
    });

    test('崩溃路径刻意不受开关约束，仍然写控制台', () async {
      await LogUtils.init(isProduction: true);
      await _attachService(enabled: false);
      final console = _captureConsoleOutput();

      LogUtils.captureUnhandledException(
        source: 'test',
        error: StateError('fatal'),
        stackTrace: StackTrace.current,
      );

      // 一次崩溃只走一次，谈不上开销；挡掉它会让崩溃在 logcat 里也消失。
      expect(console, isNotEmpty);
    });

    test('debug 构建不受开关影响（否则本地开发默认看不到任何日志）', () async {
      await LogUtils.init(isProduction: false);
      await _attachService(enabled: false);
      final console = _captureConsoleOutput();

      LogUtils.i('debug 下仍应打印');

      expect(console, isNotEmpty);
    });
  });
}
