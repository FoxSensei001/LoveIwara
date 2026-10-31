import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/common/constants.dart';
import 'log_paths.dart';
import 'log_file_sink.dart';
import 'crash_detection_service.dart';
import 'log_models.dart';
import 'native_exit_info.dart';

class LogExportService {
  final LogPaths _paths;
  final LogFileSink _sink;
  final CrashDetectionService _crash;
  final String _sessionId;
  final Future<Map<String, dynamic>> Function()? _healthMetaProvider;
  int _exportFailCount = 0;
  DateTime? _lastExportAt;
  int _lastExportBytes = 0;

  int get exportFailCount => _exportFailCount;
  DateTime? get lastExportAt => _lastExportAt;
  int get lastExportBytes => _lastExportBytes;

  LogExportService({
    required LogPaths paths,
    required LogFileSink sink,
    required CrashDetectionService crash,
    required String sessionId,
    Future<Map<String, dynamic>> Function()? healthMetaProvider,
  }) : _paths = paths,
       _sink = sink,
       _crash = crash,
       _sessionId = sessionId,
       _healthMetaProvider = healthMetaProvider;

  Future<File> exportLogs() async {
    // 清理上一轮导出残留（zip 与中断遗留的临时目录），避免临时目录无限累积。
    await _cleanupStaleExports();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = p.join(
      _paths.exportDir,
      'loveiwara_logs_$timestamp.zip',
    );
    final outputFile = File(outputPath);
    final encoder = ZipFileEncoder();
    final tempDir = Directory(
      p.join(_paths.exportDir, '_tmp_export_$timestamp'),
    );

    try {
      await tempDir.create(recursive: true);
      encoder.create(outputPath);

      // Add log files (streamed file copy)
      final logFiles = await _sink.listLogFiles();
      int totalLines = 0;
      for (final file in logFiles) {
        final name = p.basename(file.path);
        totalLines += await _countLines(file);
        encoder.addFileSync(file, 'logs/$name');
      }

      // Meta files
      final deviceMeta = await _writeTempFile(
        tempDir: tempDir,
        fileName: 'device.json',
        content: await _buildDeviceJson(),
      );
      encoder.addFileSync(deviceMeta, 'meta/device.json');

      final appMeta = await _writeTempFile(
        tempDir: tempDir,
        fileName: 'app.json',
        content: jsonEncode({
          'version': CommonConstants.VERSION,
          'fullVersion': CommonConstants.FULL_VERSION,
          // 本地构建为空串；CI 包能据此精确定位到提交与 run。
          'buildCommit': CommonConstants.BUILD_COMMIT,
          'buildRunId': CommonConstants.BUILD_RUN_ID,
          'appName': CommonConstants.applicationName,
          'sessionId': _sessionId,
        }),
      );
      encoder.addFileSync(appMeta, 'meta/app.json');

      final exportMeta = await _writeTempFile(
        tempDir: tempDir,
        fileName: 'export.json',
        content: jsonEncode({
          'exportTime': DateTime.now().toUtc().toIso8601String(),
          'logFileCount': logFiles.length,
          'totalLogLines': totalLines,
        }),
      );
      encoder.addFileSync(exportMeta, 'meta/export.json');

      final healthMeta = await _writeTempFile(
        tempDir: tempDir,
        fileName: 'health.json',
        content: await _buildHealthMetaJson(),
      );
      encoder.addFileSync(healthMeta, 'meta/health.json');

      // 系统退出记录无条件随包导出：不依赖本次启动的异常退出标记。闪退
      // 常常无法按需复现，系统账本里几天前的死亡记录（跨版本升级不清空）
      // 可能就是仅存的一手死因。⛔ 这个文件**总是**写出，读取失败、系统没
      // 记录、平台不支持都靠里面的 status 区分；导出包里没有它，只说明导出
      // 的是没有这套代码的旧版本。
      try {
        await _crash.loadNativeExitRecords();
        final exitRecordsMeta = await _writeTempFile(
          tempDir: tempDir,
          fileName: 'exit_records.json',
          content: jsonEncode(await _crash.exitRecordsExportJson()),
        );
        encoder.addFileSync(exitRecordsMeta, 'crash/exit_records.json');
      } catch (e) {
        debugPrint('[LogExport] 导出系统退出记录失败: $e');
      }

      // Add crash info if available
      final crashResult = _crash.lastResult;
      if (crashResult != null && crashResult.hadUncleanExit) {
        // 启动时的异步富化可能没跑完或失败，导出前兜底再拉一次（幂等）。
        NativeExitRecord? matchedExit;
        try {
          matchedExit = await _crash.enrichWithNativeExitInfo();
        } catch (e) {
          debugPrint('[LogExport] 拉取系统退出记录失败: $e');
        }
        final fatalFileExists = await File(_paths.fatalSnapshotFile).exists();
        final hangFileExists = await File(_paths.hangEventsFile).exists();
        final crashMap = <String, dynamic>{
          'hadUncleanExit': true,
          'previousSessionId': crashResult.previousSessionId,
          'previousStartTime': crashResult.previousStartTime?.toIso8601String(),
          'previousVersion': crashResult.previousVersion,
          // 用来去 exit_records.json 里按 pid 对上一会话的系统死因。
          'previousPid': crashResult.previousPid,
          'fatalError': crashResult.fatalError?.toJson(),
          'lastHangEvent': crashResult.lastHangEvent?.toJson(),
          'nativeExitInfo': {
            // trace 全量在 crash/exit_records.json；这里只留摘要防重复膨胀。
            'matched': matchedExit?.toJson(includeTrace: false),
            'recent': _crash.nativeExitRecords
                ?.map((r) => r.toJson(includeTrace: false))
                .toList(),
          },
          'analysis': _buildCrashAnalysis(
            crashResult: crashResult,
            fatalFileExists: fatalFileExists,
            hangFileExists: hangFileExists,
            matchedExit: matchedExit,
          ),
        };
        final crashMeta = await _writeTempFile(
          tempDir: tempDir,
          fileName: 'last_crash.json',
          content: jsonEncode(crashMap),
        );
        encoder.addFileSync(crashMeta, 'crash/last_crash.json');
      }

      // Add raw crash artifacts if available
      await _attachFileIfExists(
        encoder: encoder,
        sourcePath: _paths.fatalSnapshotFile,
        archivePath: 'crash/last_fatal_raw.json',
      );
      for (int i = 0; i <= 20; i++) {
        final suffix = i == 0 ? '' : '.$i';
        await _attachFileIfExists(
          encoder: encoder,
          sourcePath: '${_paths.hangEventsFile}$suffix',
          archivePath: 'crash/hang_events.jsonl$suffix',
        );
        if (i > 0) {
          final f = File('${_paths.hangEventsFile}.$i');
          if (!await f.exists()) break;
        }
      }

      encoder.closeSync();
      _lastExportAt = DateTime.now();
      _lastExportBytes = await outputFile.length();
      return outputFile;
    } catch (e) {
      _exportFailCount++;
      debugPrint('[LogExport] Export failed: $e');
      // 失败路径下补关，避免句柄泄漏；正常路径已在上面关闭。
      try {
        encoder.closeSync();
      } catch (_) {}
      rethrow;
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  /// 删除导出目录下历史导出产物（`loveiwara_logs_*.zip`）与中断遗留的
  /// `_tmp_export_*` 临时目录。在生成新 zip 之前调用，故不会误删本次产物。
  Future<void> _cleanupStaleExports() async {
    try {
      final dir = Directory(_paths.exportDir);
      if (!await dir.exists()) return;
      await for (final entity in dir.list(followLinks: false)) {
        final name = p.basename(entity.path);
        try {
          if (entity is File &&
              name.startsWith('loveiwara_logs_') &&
              name.endsWith('.zip')) {
            await entity.delete();
          } else if (entity is Directory && name.startsWith('_tmp_export_')) {
            await entity.delete(recursive: true);
          }
        } catch (_) {
          // 单个文件删除失败不影响整体导出
        }
      }
    } catch (e) {
      debugPrint('[LogExport] Cleanup stale exports failed: $e');
    }
  }

  Future<void> _attachFileIfExists({
    required ZipFileEncoder encoder,
    required String sourcePath,
    required String archivePath,
  }) async {
    final file = File(sourcePath);
    if (!await file.exists()) return;
    encoder.addFileSync(file, archivePath);
  }

  Future<int> _countLines(File file) async {
    try {
      int lines = 0;
      final stream = file
          .openRead()
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const LineSplitter());
      await for (final _ in stream) {
        lines++;
      }
      return lines;
    } catch (_) {
      return 0;
    }
  }

  Future<File> _writeTempFile({
    required Directory tempDir,
    required String fileName,
    required String content,
  }) async {
    final file = File(p.join(tempDir.path, fileName));
    await file.writeAsString(content);
    return file;
  }

  Future<String> _buildDeviceJson() async {
    final info = <String, dynamic>{};

    try {
      final deviceInfo = DeviceInfoPlugin();

      if (GetPlatform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        info['platform'] = 'Android';
        info['brand'] = android.brand;
        info['model'] = android.model;
        info['osVersion'] =
            '${android.version.release} (SDK ${android.version.sdkInt})';
      } else if (GetPlatform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        info['platform'] = 'iOS';
        info['model'] = ios.model;
        info['osVersion'] = ios.systemVersion;
      } else if (GetPlatform.isWindows) {
        final windows = await deviceInfo.windowsInfo;
        info['platform'] = 'Windows';
        info['osVersion'] =
            '${windows.displayVersion} (${windows.buildNumber})';
      } else if (GetPlatform.isMacOS) {
        final mac = await deviceInfo.macOsInfo;
        info['platform'] = 'macOS';
        info['osVersion'] = mac.osRelease;
      } else if (GetPlatform.isLinux) {
        final linux = await deviceInfo.linuxInfo;
        info['platform'] = 'Linux';
        info['name'] = linux.name;
        info['osVersion'] = linux.version;
      }

      // 曾命名为 memoryMB，实际是当前进程 RSS 而非设备内存，改名消歧。
      info['processRssMB'] = (ProcessInfo.currentRss / 1024 / 1024)
          .toStringAsFixed(2);
    } catch (e) {
      debugPrint('[LogExport] Failed to get device info: $e');
      info['error'] = 'Failed to collect device info';
    }

    return jsonEncode(info);
  }

  Future<String> _buildHealthMetaJson() async {
    final map = <String, dynamic>{
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'available': _healthMetaProvider != null,
    };

    if (_healthMetaProvider == null) {
      return jsonEncode(map);
    }

    try {
      map['snapshot'] = await _healthMetaProvider();
    } catch (e) {
      debugPrint('[LogExport] Failed to collect health meta: $e');
      map['available'] = false;
      map['error'] = e.toString();
    }
    return jsonEncode(map);
  }

  Map<String, dynamic> _buildCrashAnalysis({
    required CrashRecoveryResult crashResult,
    required bool fatalFileExists,
    required bool hangFileExists,
    NativeExitRecord? matchedExit,
  }) {
    // 卡死后再没恢复、且在最后一条 fatal 之后：进程是卡死期间被结束的（用户强关、
    // 系统结束未响应程序）。fatal 快照只记「最后一次」被全局处理器接住的错误，
    // 那可能是一条每次都报、应用照常跑的错误——2026-10-31 一份 Windows 报告就把
    // 每开一次视频页都报的 NetworkManager::StartListen 当成了死因，真凶是点「下载」
    // 时系统保存对话框卡死了整个线程。
    final hang = crashResult.lastHangEvent;
    final fatal = crashResult.fatalError;
    if (hang != null &&
        !hang.recovered &&
        (fatal == null || hang.detectedAt.isAfter(fatal.timestamp))) {
      final lastBeat = hang.lastHeartbeatAt?.toUtc().toIso8601String() ?? '未知';
      return {
        'type': 'ui_hang_unrecovered',
        'summary':
            '主 isolate 卡死后再未恢复（最后心跳 $lastBeat），进程随后结束，'
            '多半是用户强关或系统结束了未响应的程序'
            '${fatal != null ? '；更早的那条 fatal 不是死因' : ''}',
        'fatalSnapshotFileExists': fatalFileExists,
        'hangEventsFileExists': hangFileExists,
      };
    }
    if (crashResult.fatalError != null) {
      return {
        'type': 'fatal_exception',
        'summary': '检测到上一会话的 fatal 错误快照',
        'fatalSnapshotFileExists': fatalFileExists,
        'hangEventsFileExists': hangFileExists,
      };
    }
    if (crashResult.lastHangEvent != null) {
      return {
        'type': 'ui_hang_or_stall',
        'summary': '检测到上一会话的卡顿事件快照',
        'fatalSnapshotFileExists': fatalFileExists,
        'hangEventsFileExists': hangFileExists,
      };
    }
    // Dart 侧无快照时，系统记录的退出原因是唯一一手结论，按它细分。
    if (matchedExit != null) {
      final (type, summary) = switch (matchedExit.reasonCode) {
        NativeExitRecord.reasonLowMemory => (
          'system_low_memory_kill',
          '系统低内存杀进程（LMK/OOM），死亡时 RSS ${(matchedExit.rssKb / 1024).toStringAsFixed(1)}MB',
        ),
        NativeExitRecord.reasonCrashNative => (
          'native_crash',
          '原生层崩溃，tombstone 见 crash/exit_records.json 中 pid=${matchedExit.pid} 的 trace',
        ),
        NativeExitRecord.reasonAnr => (
          'anr_kill',
          'ANR 被系统终止，线程栈见 crash/exit_records.json 中 pid=${matchedExit.pid} 的 trace',
        ),
        NativeExitRecord.reasonSignaled when matchedExit.isNativeCrash => (
          'native_crash',
          '原生层崩溃（${matchedExit.crashSignalName}，系统按信号终止记账）'
              '${matchedExit.hasTrace ? '，tombstone 见 crash/exit_records.json 中 pid=${matchedExit.pid} 的 trace' : '，系统未提供 tombstone'}',
        ),
        NativeExitRecord.reasonSignaled => (
          'signaled_kill',
          '进程被信号终止（signal=${matchedExit.status}；9=SIGKILL，部分厂商 ROM 的清理也走此路径）',
        ),
        NativeExitRecord.reasonUserRequested ||
        NativeExitRecord.reasonUserStopped => (
          'user_or_system_manager_kill',
          '用户或系统管理器主动结束（上滑清理/一键加速等）',
        ),
        NativeExitRecord.reasonExcessiveResourceUsage => (
          'excessive_resource_kill',
          '系统因资源占用过高终止进程',
        ),
        _ => (
          'unclean_exit_native_reason_${matchedExit.reason.toLowerCase()}',
          '系统记录的退出原因: ${matchedExit.reason}',
        ),
      };
      return {
        'type': type,
        'summary': summary,
        'nativeReason': matchedExit.reason,
        'fatalSnapshotFileExists': fatalFileExists,
        'hangEventsFileExists': hangFileExists,
      };
    }
    return {
      'type': 'unclean_exit_without_dart_snapshot',
      'summary': '检测到异常退出标记，但未匹配到 fatal/hang 快照；常见于系统杀进程、强制结束、断电、原生层崩溃',
      'fatalSnapshotFileExists': fatalFileExists,
      'hangEventsFileExists': hangFileExists,
    };
  }
}
