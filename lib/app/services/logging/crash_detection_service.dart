import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'log_models.dart';
import 'log_paths.dart';
import 'native_exit_info.dart';

class CrashDetectionService {
  final LogPaths _paths;
  CrashRecoveryResult? _lastResult;
  List<NativeExitRecord>? _nativeExitRecords;
  List<NativeExitRecord> _archivedOnlyRecords = const [];
  NativeExitFetchResult? _lastFetch;
  Future<List<NativeExitRecord>?>? _loading;
  NativeExitRecord? _matchedNativeExit;

  /// [exitRecordFetcher] 仅供测试注入；生产走 [NativeExitInfoService.fetch]。
  CrashDetectionService(
    this._paths, {
    Future<NativeExitFetchResult> Function(
      int maxCount,
      Iterable<String> skipTraceKeys,
    )?
    exitRecordFetcher,
  }) : _fetchExitRecords =
           exitRecordFetcher ??
           ((maxCount, skipTraceKeys) => NativeExitInfoService.fetch(
             maxCount: maxCount,
             skipTraceKeys: skipTraceKeys,
           ));

  final Future<NativeExitFetchResult> Function(
    int maxCount,
    Iterable<String> skipTraceKeys,
  )
  _fetchExitRecords;

  CrashRecoveryResult? get lastResult => _lastResult;

  /// 系统记录的最近几条进程退出记录（Android API 30+，其余平台为 null）。
  List<NativeExitRecord>? get nativeExitRecords => _nativeExitRecords;

  /// 与上一会话时间窗匹配上的那条退出记录；null 表示未匹配（记录被系统裁剪
  /// 或时间对不上），此时 [nativeExitRecords] 仍可作参考。
  NativeExitRecord? get matchedNativeExit => _matchedNativeExit;

  // 系统每包保留约 16 条历史退出记录，全量拉取：闪退往往难以按需复现，
  // 几天前的死亡记录可能就是仅存的一手证据。
  static const int _nativeExitFetchCount = 16;

  // 本地存档上限。系统账本只有约 16 条，一次原生崩溃就占两条（CRASH_NATIVE +
  // SIGNALED），用户划掉后台、覆盖安装也各占一条——反复重现几次，真正那次崩溃
  // 就被挤出系统账本了。存档按 [NativeExitRecord.archiveKey] 去重累积。
  static const int _archiveMaxRecords = 64;

  // 一份 proto tombstone 能到 2MB（base64 后更大），只给最近几条留 trace 文件，
  // 更早的只留死因摘要。trace 单独成文件、存档本身只放摘要：存档每次启动都要
  // 读，要是把几份 tombstone 塞进去，就成了每次启动读写十几 MB——疑似低内存的
  // 用户最受不了这个。
  static const int _archiveMaxTraces = 4;

  /// 拉取系统侧退出记录（不要求存在异常退出标记），并与本地存档合并。
  /// 并发调用共用同一次拉取；读取报错时不缓存，下次调用（例如导出）会重试。
  /// 必须在 Flutter 引擎附着后调用（MethodChannel 依赖）。失败不抛，原因记在
  /// [exitRecordsExportJson] 的 status / archiveError 里。
  Future<List<NativeExitRecord>?> loadNativeExitRecords() =>
      _loading ??= _loadAndArchive();

  Future<List<NativeExitRecord>?> _loadAndArchive() async {
    final archived = await _readArchive();
    final archivedByKey = {for (final r in archived) r.archiveKey: r};
    NativeExitFetchResult fetch;
    try {
      fetch = await _fetchExitRecords(_nativeExitFetchCount, [
        // 只跳过存档里确实记过 trace 的；上次没读到 tombstone 的下次再读。
        for (final r in archived)
          if (r.traceSkipped) r.archiveKey,
      ]);
    } catch (e) {
      fetch = NativeExitFetchResult.error(e.toString());
    }
    _lastFetch = fetch;
    if (fetch.status == 'error') _loading = null;

    // 原生侧没读 tombstone 的（已存过档），把存档里的 trace 信息接回来。
    final system = [
      for (final r in fetch.records)
        if (r.traceSkipped && archivedByKey[r.archiveKey] != null)
          r.withTraceInfoFrom(archivedByKey[r.archiveKey]!)
        else
          r,
    ];
    // 先赋值再写存档：写存档失败（磁盘满）不能连带丢掉本次读到的死因。
    _nativeExitRecords = system.isEmpty ? null : system;
    final systemKeys = {for (final r in system) r.archiveKey};
    _archivedOnlyRecords = [
      for (final r in archived)
        if (!systemKeys.contains(r.archiveKey)) r,
    ];

    // 没有新记录、也没有新读到的 tombstone 就不写，免得每次启动都重写存档。
    final needsWrite = system.any((r) {
      final old = archivedByKey[r.archiveKey];
      return old == null || (r.trace != null && !old.traceSkipped);
    });
    if (needsWrite) {
      try {
        await _writeArchive(system, archived);
        _archiveError = null;
      } catch (e) {
        debugPrint('[CrashDetection] 写退出记录存档失败: $e');
        _archiveError = e.toString();
      }
    }
    return _nativeExitRecords;
  }

  String? _archiveError;

  /// 导出包里的 `crash/exit_records.json`。**总是**写出，靠 status 区分
  /// ok / empty / unsupported / error / not_loaded——文件缺失只说明导出它的是
  /// 没有这套代码的旧版本。
  ///
  /// trace 字段：本次读到的直接带上；存过档的从 trace 文件读回；`traceSkipped`
  /// 为 true 而没有 trace，表示系统记过 tombstone，但它已超出本地保留份数。
  Future<Map<String, dynamic>> exitRecordsExportJson() async {
    Future<Map<String, dynamic>> withTrace(NativeExitRecord r) async {
      final json = r.toJson();
      if (r.trace == null && r.traceSkipped) {
        try {
          final file = File(_traceFilePath(r));
          if (await file.exists()) json['trace'] = await file.readAsString();
        } catch (e) {
          debugPrint('[CrashDetection] 读取 trace 文件失败: $e');
        }
      }
      return json;
    }

    final fetch = _lastFetch;
    return {
      'schema': 2,
      'status': fetch?.status ?? 'not_loaded',
      if (fetch?.error != null) 'error': fetch!.error,
      if (_archiveError != null) 'archiveError': _archiveError,
      // 本次从系统账本读到的（最新在前）。
      'systemRecords': [
        for (final r in _nativeExitRecords ?? const <NativeExitRecord>[])
          await withTrace(r),
      ],
      // 已经被挤出系统账本、只剩本地存档的更早记录。
      'archivedRecords': [
        for (final r in _archivedOnlyRecords) await withTrace(r),
      ],
    };
  }

  String _traceFilePath(NativeExitRecord r) =>
      p.join(_paths.exitTraceDir, '${r.pid}_${r.timestampMs}');

  Future<List<NativeExitRecord>> _readArchive() async {
    try {
      final file = File(_paths.exitArchiveFile);
      if (!await file.exists()) return const [];
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return const [];
      return decoded
          .map(NativeExitRecord.fromJson)
          .whereType<NativeExitRecord>()
          .toList();
    } catch (e) {
      // 存档坏了就当没有：下次写回时会整份重建。
      debugPrint('[CrashDetection] 读取退出记录存档失败: $e');
      return const [];
    }
  }

  Future<void> _writeArchive(
    List<NativeExitRecord> system,
    List<NativeExitRecord> archived,
  ) async {
    final traceDir = Directory(_paths.exitTraceDir);
    await traceDir.create(recursive: true);
    for (final r in system) {
      if (r.trace == null) continue;
      final file = File(_traceFilePath(r));
      if (!await file.exists()) await file.writeAsString(r.trace!);
    }

    final unique = <String, NativeExitRecord>{};
    for (final r in [...system, ...archived]) {
      unique.putIfAbsent(r.archiveKey, r.withoutTrace);
    }
    final kept = unique.values.toList()
      ..sort((a, b) => b.timestampMs.compareTo(a.timestampMs));
    if (kept.length > _archiveMaxRecords) {
      kept.removeRange(_archiveMaxRecords, kept.length);
    }

    // 只留最近几份 trace 文件；更早的删掉，摘要里的 traceSkipped 仍记着
    // 「系统当时有 tombstone」。
    final keepTraceFiles = {
      for (final r in kept.where((r) => r.traceSkipped).take(_archiveMaxTraces))
        '${r.pid}_${r.timestampMs}',
    };
    await for (final entity in traceDir.list()) {
      if (entity is File && !keepTraceFiles.contains(p.basename(entity.path))) {
        await entity.delete();
      }
    }

    // 先写临时文件再改名：写到一半被杀也不会留下半截存档。
    final tmp = File('${_paths.exitArchiveFile}.tmp');
    await tmp.writeAsString(
      jsonEncode([for (final r in kept) r.toJson()]),
      flush: true,
    );
    await tmp.rename(_paths.exitArchiveFile);
  }

  /// 拉取系统侧退出记录并与上一会话匹配。幂等：成功拿到记录后重复调用直接
  /// 返回缓存。必须在 Flutter 引擎附着后调用（MethodChannel 依赖），失败静默。
  Future<NativeExitRecord?> enrichWithNativeExitInfo() async {
    final result = _lastResult;
    if (result == null || !result.hadUncleanExit) return null;
    if (_matchedNativeExit != null) return _matchedNativeExit;

    final records = await loadNativeExitRecords();
    if (records == null) return null;

    // 优先按 pid 精确匹配：上一会话之后本包可能还有别的进程（被广播或
    // FileProvider 拉起、没跑 Dart）死过，时间窗会认错人。pid 会被复用，
    // 所以仍要求死亡时间晚于启动标记。
    final startMs = result.previousStartTime?.millisecondsSinceEpoch;
    bool afterStart(NativeExitRecord r) =>
        startMs == null || r.timestampMs >= startMs;

    // 旧版标记没有 pid 时按时间兜底：记录按时间倒序，上一进程必然晚于其启动标记
    // 死去（同一墙钟），取启动之后**最早**那条的 pid。
    var pid = result.previousPid;
    if (pid == null && startMs != null) {
      for (final record in records.reversed) {
        if (record.timestampMs >= startMs) {
          pid = record.pid;
          break;
        }
      }
    }
    if (pid == null) return null;

    // 同一进程可能有多条：真机上一次原生崩溃会先记 CRASH_NATIVE（带 tombstone），
    // 再记一条 SIGNALED(11)。取信息量最大的那条，而不是最新的。
    final candidates = records
        .where((r) => r.pid == pid && afterStart(r))
        .toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => _informativeness(b) - _informativeness(a));
    _matchedNativeExit = candidates.first;
    return _matchedNativeExit;
  }

  /// 同一进程多条退出记录时的取舍：带 trace > 有明确死因 > 其他。
  static int _informativeness(NativeExitRecord r) {
    if (r.hasTrace) return 3;
    switch (r.reasonCode) {
      case NativeExitRecord.reasonCrashNative:
      case NativeExitRecord.reasonAnr:
      case NativeExitRecord.reasonLowMemory:
      case NativeExitRecord.reasonCrash:
        return 2;
      case NativeExitRecord.reasonSignaled:
        return 0;
      default:
        return 1;
    }
  }

  Future<void> markAppStart({
    required String sessionId,
    required String version,
    required String platform,
  }) async {
    try {
      final marker = File(_paths.crashMarkerFile);
      final data = jsonEncode({
        'sessionId': sessionId,
        'startTime': DateTime.now().toUtc().toIso8601String(),
        'version': version,
        'platform': platform,
        'pid': pid,
      });
      await marker.writeAsString(data, flush: true);
    } catch (e) {
      debugPrint('[CrashDetection] Failed to write marker: $e');
    }
  }

  void recordFatalErrorSync({
    required String sessionId,
    required String source,
    required String message,
    String? error,
    String? stackTrace,
  }) {
    try {
      final snapshot = FatalErrorSnapshot(
        timestamp: DateTime.now().toUtc(),
        sessionId: sessionId,
        source: source,
        message: message,
        error: error,
        stackTrace: stackTrace,
      );
      final file = File(_paths.fatalSnapshotFile);
      file.writeAsStringSync(jsonEncode(snapshot.toJson()), flush: true);
    } catch (e) {
      debugPrint('[CrashDetection] Failed to persist fatal snapshot: $e');
    }
  }

  Future<void> markCleanExit() async {
    try {
      final marker = File(_paths.crashMarkerFile);
      if (await marker.exists()) {
        await marker.delete();
      }
    } catch (e) {
      debugPrint('[CrashDetection] Failed to delete marker: $e');
    }
  }

  /// 同步删除崩溃标记。退出路径应在任何「慢且可被打断」的清理（flush、停
  /// watchdog、关库）之前调用：删除标记只是一次小文件操作，能在进程被杀或
  /// 超时退出前完成；而 [checkAndRecover] 仅在标记仍存在时才读取 fatal /
  /// hang 快照——删掉标记即让整个崩溃检测对本次关闭窗口失效，从而避免「正常
  /// 关闭但清理太慢/被杀」被误报为崩溃。与 [recordFatalErrorSync] 同样采用
  /// 同步 IO，理由一致：必须在临近退出时可靠落地。
  void markCleanExitSync() {
    try {
      final marker = File(_paths.crashMarkerFile);
      if (marker.existsSync()) {
        marker.deleteSync();
      }
    } catch (e) {
      debugPrint('[CrashDetection] Failed to delete marker (sync): $e');
    }
  }

  Future<CrashRecoveryResult> checkAndRecover() async {
    try {
      final marker = File(_paths.crashMarkerFile);
      if (!await marker.exists()) {
        _lastResult = CrashRecoveryResult.clean();
        return _lastResult!;
      }

      final content = await marker.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final previousSessionId = data['sessionId'] as String?;

      _lastResult = CrashRecoveryResult(
        hadUncleanExit: true,
        previousSessionId: previousSessionId,
        previousStartTime: data['startTime'] != null
            ? DateTime.tryParse(data['startTime'] as String)
            : null,
        previousVersion: data['version'] as String?,
        previousPid: data['pid'] as int?,
        fatalError: await _readFatalSnapshot(previousSessionId),
        lastHangEvent: await _readLastHangEvent(previousSessionId),
      );

      return _lastResult!;
    } catch (e) {
      debugPrint('[CrashDetection] Recovery check failed: $e');
      _lastResult = CrashRecoveryResult.clean();
      return _lastResult!;
    }
  }

  Future<FatalErrorSnapshot?> _readFatalSnapshot(
    String? previousSessionId,
  ) async {
    try {
      final file = File(_paths.fatalSnapshotFile);
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      final snapshot = FatalErrorSnapshot.fromJson(decoded);
      if (snapshot == null) return null;
      if (previousSessionId != null &&
          snapshot.sessionId != previousSessionId) {
        return null;
      }
      return snapshot;
    } catch (e) {
      debugPrint('[CrashDetection] Failed to read fatal snapshot: $e');
      return null;
    }
  }

  Future<HangEventSnapshot?> _readLastHangEvent(
    String? previousSessionId,
  ) async {
    try {
      final files = <File>[File(_paths.hangEventsFile)];
      for (int i = 1; i <= 20; i++) {
        final rotated = File('${_paths.hangEventsFile}.$i');
        if (!await rotated.exists()) break;
        files.add(rotated);
      }

      for (final file in files) {
        if (!await file.exists()) continue;
        final lines = await file.readAsLines();
        for (var i = lines.length - 1; i >= 0; i--) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          final decoded = jsonDecode(line);
          final snapshot = HangEventSnapshot.fromJson(decoded);
          if (snapshot == null) continue;
          if (previousSessionId != null &&
              snapshot.sessionId != previousSessionId) {
            continue;
          }
          return snapshot;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[CrashDetection] Failed to read hang snapshot: $e');
      return null;
    }
  }
}
