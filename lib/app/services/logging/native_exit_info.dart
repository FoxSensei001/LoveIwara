import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' show GetPlatform;

/// Android `ApplicationExitInfo` 的单条进程退出记录。
///
/// Dart 层崩溃检测（runZonedGuarded / FlutterError.onError）只能覆盖 Dart 异常；
/// 系统低内存杀进程（LMK/OOM）、原生层崩溃、ANR、用户手动清理对 Flutter 完全不可见，
/// 只会留下「异常退出标记存在但无 fatal/hang 快照」。本记录来自系统侧账本，是这类
/// 退出唯一的一手死因。
class NativeExitRecord {
  final int timestampMs;
  final int pid;
  final String? processName;
  final int reasonCode;
  final String reason;
  final int status;
  final int importanceCode;
  final String importance;
  final int pssKb;
  final int rssKb;
  final String? description;

  /// 原生崩溃 tombstone / ANR 线程栈，仅 CRASH_NATIVE / ANR 存在。格式见
  /// [traceFormat]：`text`（ANR、API 30 的 tombstone，截断至头部 96KB）或
  /// `tombstone_proto_base64`（API 31+ 的 protobuf tombstone，上限 2MB）。
  final String? trace;
  final String? traceFormat;
  final bool traceTruncated;

  NativeExitRecord({
    required this.timestampMs,
    required this.pid,
    required this.processName,
    required this.reasonCode,
    required this.reason,
    required this.status,
    required this.importanceCode,
    required this.importance,
    required this.pssKb,
    required this.rssKb,
    required this.description,
    required this.trace,
    this.traceFormat,
    this.traceTruncated = false,
  });

  // ApplicationExitInfo.REASON_* 常量值，与 Android SDK 对齐。
  static const int reasonSignaled = 2;
  static const int reasonLowMemory = 3;
  static const int reasonCrash = 4;
  static const int reasonCrashNative = 5;
  static const int reasonAnr = 6;
  static const int reasonExcessiveResourceUsage = 9;
  static const int reasonUserRequested = 10;
  static const int reasonUserStopped = 11;

  static NativeExitRecord? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    int asInt(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
    final reasonCode = raw['reasonCode'];
    if (reasonCode == null) return null;
    return NativeExitRecord(
      timestampMs: asInt(raw['timestampMs']),
      pid: asInt(raw['pid']),
      processName: raw['processName'] as String?,
      reasonCode: asInt(reasonCode),
      reason: raw['reason'] as String? ?? 'UNKNOWN',
      status: asInt(raw['status']),
      importanceCode: asInt(raw['importanceCode']),
      importance: raw['importance'] as String? ?? 'OTHER',
      pssKb: asInt(raw['pssKb']),
      rssKb: asInt(raw['rssKb']),
      description: raw['description'] as String?,
      trace: raw['trace'] as String?,
      traceFormat: raw['traceFormat'] as String?,
      traceTruncated: raw['traceTruncated'] == true,
    );
  }

  DateTime get timestamp =>
      DateTime.fromMillisecondsSinceEpoch(timestampMs, isUtc: false);

  /// 单行摘要，用于落 app.log；trace 太大，只进导出的 JSON。
  String toSummaryLine() {
    final rssMb = (rssKb / 1024).toStringAsFixed(1);
    final pssMb = (pssKb / 1024).toStringAsFixed(1);
    final desc = (description == null || description!.isEmpty)
        ? ''
        : ', desc=$description';
    return 'reason=$reason($reasonCode), status=$status, '
        'importance=$importance($importanceCode), rss=${rssMb}MB, pss=${pssMb}MB, '
        'time=${timestamp.toUtc().toIso8601String()}'
        '${trace != null ? ', trace=已捕获(${traceFormat ?? 'text'})' : ''}$desc';
  }

  Map<String, dynamic> toJson({bool includeTrace = true}) {
    return {
      'timestamp': timestamp.toUtc().toIso8601String(),
      'pid': pid,
      'processName': processName,
      'reasonCode': reasonCode,
      'reason': reason,
      'status': status,
      'importanceCode': importanceCode,
      'importance': importance,
      'pssKb': pssKb,
      'rssKb': rssKb,
      'description': description,
      if (trace != null) 'traceFormat': traceFormat ?? 'text',
      if (trace != null) 'traceTruncated': traceTruncated,
      if (includeTrace && trace != null) 'trace': trace,
    };
  }
}

/// 通过 MethodChannel 读取 Android 系统记录的历史进程退出原因。
/// 非 Android 平台或 API < 30 返回 null；任何失败都吞掉并返回 null，
/// 诊断通道绝不能反过来影响启动。
class NativeExitInfoService {
  static const MethodChannel _channel = MethodChannel('i_iwara/exit_info');

  static Future<List<NativeExitRecord>?> fetch({int maxCount = 5}) async {
    if (!GetPlatform.isAndroid) return null;
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>(
        'getHistoricalExitReasons',
        {'maxCount': maxCount},
      );
      if (raw == null) return null;
      final records = raw
          .map(NativeExitRecord.fromMap)
          .whereType<NativeExitRecord>()
          .toList();
      return records.isEmpty ? null : records;
    } catch (e) {
      debugPrint('[NativeExitInfo] 读取历史退出原因失败: $e');
      return null;
    }
  }
}
