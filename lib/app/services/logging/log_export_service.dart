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
        encoder.addFile(file, 'logs/$name');
      }

      // Meta files
      final deviceMeta = await _writeTempFile(
        tempDir: tempDir,
        fileName: 'device.json',
        content: await _buildDeviceJson(),
      );
      encoder.addFile(deviceMeta, 'meta/device.json');

      final appMeta = await _writeTempFile(
        tempDir: tempDir,
        fileName: 'app.json',
        content: jsonEncode({
          'version': CommonConstants.VERSION,
          'appName': CommonConstants.applicationName,
          'sessionId': _sessionId,
        }),
      );
      encoder.addFile(appMeta, 'meta/app.json');

      final exportMeta = await _writeTempFile(
        tempDir: tempDir,
        fileName: 'export.json',
        content: jsonEncode({
          'exportTime': DateTime.now().toUtc().toIso8601String(),
          'logFileCount': logFiles.length,
          'totalLogLines': totalLines,
        }),
      );
      encoder.addFile(exportMeta, 'meta/export.json');

      final healthMeta = await _writeTempFile(
        tempDir: tempDir,
        fileName: 'health.json',
        content: await _buildHealthMetaJson(),
      );
      encoder.addFile(healthMeta, 'meta/health.json');

      // Add crash info if available
      final crashResult = _crash.lastResult;
      if (crashResult != null && crashResult.hadUncleanExit) {
        final fatalFileExists = await File(_paths.fatalSnapshotFile).exists();
        final hangFileExists = await File(_paths.hangEventsFile).exists();
        final crashMap = <String, dynamic>{
          'hadUncleanExit': true,
          'previousSessionId': crashResult.previousSessionId,
          'previousStartTime': crashResult.previousStartTime?.toIso8601String(),
          'previousVersion': crashResult.previousVersion,
          'fatalError': crashResult.fatalError?.toJson(),
          'lastHangEvent': crashResult.lastHangEvent?.toJson(),
          'analysis': _buildCrashAnalysis(
            crashResult: crashResult,
            fatalFileExists: fatalFileExists,
            hangFileExists: hangFileExists,
          ),
        };
        final crashMeta = await _writeTempFile(
          tempDir: tempDir,
          fileName: 'last_crash.json',
          content: jsonEncode(crashMap),
        );
        encoder.addFile(crashMeta, 'crash/last_crash.json');
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

      encoder.close();
      _lastExportAt = DateTime.now();
      _lastExportBytes = await outputFile.length();
      return outputFile;
    } catch (e) {
      _exportFailCount++;
      debugPrint('[LogExport] Export failed: $e');
      rethrow;
    } finally {
      try {
        encoder.close();
      } catch (_) {}
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  Future<void> _attachFileIfExists({
    required ZipFileEncoder encoder,
    required String sourcePath,
    required String archivePath,
  }) async {
    final file = File(sourcePath);
    if (!await file.exists()) return;
    encoder.addFile(file, archivePath);
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

      info['memoryMB'] = (ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(
        2,
      );
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
  }) {
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
    return {
      'type': 'unclean_exit_without_dart_snapshot',
      'summary': '检测到异常退出标记，但未匹配到 fatal/hang 快照；常见于系统杀进程、强制结束、断电、原生层崩溃',
      'fatalSnapshotFileExists': fatalFileExists,
      'hangEventsFileExists': hangFileExists,
    };
  }
}
