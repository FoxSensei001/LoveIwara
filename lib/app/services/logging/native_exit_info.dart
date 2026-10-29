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

  /// 系统记过 trace，但这个对象里没带：原生侧因为已存过档而跳过读取（见
  /// [NativeExitInfoService.fetch] 的 skipTraceKeys），或者存档只放摘要、
  /// trace 在单独的文件里（也可能已超出保留份数被删）。
  final bool traceSkipped;

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
    this.traceSkipped = false,
  });

  /// 存档去重键。pid 会被复用，所以要和死亡时间一起才唯一。
  String get archiveKey => '$pid:$timestampMs';

  /// 系统记过 trace（不管这个对象里带没带）。
  bool get hasTrace => trace != null || traceSkipped;

  /// 接上存档里的 trace 信息（原生侧跳过了读取时用）。
  NativeExitRecord withTraceInfoFrom(NativeExitRecord archived) =>
      NativeExitRecord(
        timestampMs: timestampMs,
        pid: pid,
        processName: processName,
        reasonCode: reasonCode,
        reason: reason,
        status: status,
        importanceCode: importanceCode,
        importance: importance,
        pssKb: pssKb,
        rssKb: rssKb,
        description: description,
        trace: archived.trace,
        traceFormat: archived.traceFormat,
        traceTruncated: archived.traceTruncated,
        traceSkipped: archived.trace == null && archived.traceSkipped,
      );

  /// 去掉 trace，只留摘要（存档里的形态；trace 另存文件）。
  NativeExitRecord withoutTrace() => NativeExitRecord(
    timestampMs: timestampMs,
    pid: pid,
    processName: processName,
    reasonCode: reasonCode,
    reason: reason,
    status: status,
    importanceCode: importanceCode,
    importance: importance,
    pssKb: pssKb,
    rssKb: rssKb,
    description: description,
    trace: null,
    traceFormat: traceFormat,
    traceTruncated: traceTruncated,
    traceSkipped: trace != null || traceSkipped,
  );

  // ApplicationExitInfo.REASON_* 常量值，与 Android SDK 对齐。
  static const int reasonSignaled = 2;
  static const int reasonLowMemory = 3;
  static const int reasonCrash = 4;
  static const int reasonCrashNative = 5;
  static const int reasonAnr = 6;
  static const int reasonExcessiveResourceUsage = 9;
  static const int reasonUserRequested = 10;
  static const int reasonUserStopped = 11;

  static const Map<int, String> _crashSignalNames = {
    4: 'SIGILL',
    5: 'SIGTRAP',
    6: 'SIGABRT',
    7: 'SIGBUS',
    8: 'SIGFPE',
    11: 'SIGSEGV',
  };

  /// 被崩溃类信号终止时的信号名（SIGSEGV 等），否则 null。
  ///
  /// 真机实测（Android 14）：一次原生崩溃系统会记两条——先 CRASH_NATIVE（带
  /// tombstone），几百毫秒后再记一条同 pid 的 SIGNALED(status=11)。CRASH_NATIVE 那条
  /// 被裁掉或没匹配上时，SIGNALED 不能一概当成「被杀」。
  String? get crashSignalName =>
      reasonCode == reasonSignaled ? _crashSignalNames[status] : null;

  /// 原生层崩溃：系统记为 CRASH_NATIVE，或以崩溃类信号终止。
  bool get isNativeCrash =>
      reasonCode == reasonCrashNative || crashSignalName != null;

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
      traceSkipped: raw['traceSkipped'] == true,
    );
  }

  /// 读回 [toJson] 写出的存档条目（时间是 ISO 字符串，不是毫秒）。
  static NativeExitRecord? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final time = DateTime.tryParse(raw['timestamp'] as String? ?? '');
    if (time == null) return null;
    return fromMap({...raw, 'timestampMs': time.millisecondsSinceEpoch});
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
    final signal = crashSignalName;
    return 'reason=$reason($reasonCode), '
        'status=$status${signal != null ? '($signal)' : ''}, '
        'importance=$importance($importanceCode), rss=${rssMb}MB, pss=${pssMb}MB, '
        'time=${timestamp.toUtc().toIso8601String()}'
        '${hasTrace ? ', trace=已捕获(${traceFormat ?? 'text'})' : ''}$desc';
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
      // 跳过读取的记录可能不知道格式，不能想当然标成 text（proto 会被误读）。
      if (trace != null)
        'traceFormat': traceFormat ?? 'text'
      else if (traceFormat != null)
        'traceFormat': traceFormat,
      if (hasTrace) 'traceTruncated': traceTruncated,
      if (traceSkipped && trace == null) 'traceSkipped': true,
      if (includeTrace && trace != null) 'trace': trace,
    };
  }
}

/// 一次读取系统退出记录的结果。
///
/// 存在的理由：导出包里「没有退出记录」必须能区分是哪一种——旧版本根本没这套代码、
/// 读取报错、系统确实没有记录、平台不支持——否则排障时只能猜（2026-10-29 一份闪退
/// 日志就因为分不清而误判了用户装的是哪个包）。
class NativeExitFetchResult {
  /// `ok` / `empty` / `unsupported` / `error`
  final String status;
  final List<NativeExitRecord> records;
  final String? error;

  const NativeExitFetchResult._(this.status, this.records, this.error);

  factory NativeExitFetchResult.ok(List<NativeExitRecord> records) =>
      records.isEmpty
      ? const NativeExitFetchResult._('empty', [], null)
      : NativeExitFetchResult._('ok', records, null);

  /// 非 Android，或 Android API < 30（没有 ApplicationExitInfo）。
  factory NativeExitFetchResult.unsupported(String why) =>
      NativeExitFetchResult._('unsupported', const [], why);

  factory NativeExitFetchResult.error(String error) =>
      NativeExitFetchResult._('error', const [], error);
}

/// 通过 MethodChannel 读取 Android 系统记录的历史进程退出原因。
/// 任何失败都吞掉并体现在 [NativeExitFetchResult.status] 里，诊断通道绝不能
/// 反过来影响启动。
class NativeExitInfoService {
  static const MethodChannel _channel = MethodChannel('i_iwara/exit_info');

  /// [skipTraceKeys]：已经存过档的记录（[NativeExitRecord.archiveKey]），原生侧
  /// 不再读它们的 tombstone。每次启动都要同步存档，而一份 proto tombstone 能有
  /// 上 MB，重复读既费 IO 又白白占内存。
  static Future<NativeExitFetchResult> fetch({
    int maxCount = 5,
    Iterable<String> skipTraceKeys = const [],
  }) async {
    if (!GetPlatform.isAndroid) {
      return NativeExitFetchResult.unsupported('not_android');
    }
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>(
        'getHistoricalExitReasons',
        {'maxCount': maxCount, 'skipTraceKeys': skipTraceKeys.toList()},
      );
      // 原生侧只在 API < 30 时回 null（见 MainActivity 的 EXIT_INFO_CHANNEL）。
      if (raw == null) return NativeExitFetchResult.unsupported('api_below_30');
      return NativeExitFetchResult.ok(
        raw
            .map(NativeExitRecord.fromMap)
            .whereType<NativeExitRecord>()
            .toList(),
      );
    } catch (e) {
      debugPrint('[NativeExitInfo] 读取历史退出原因失败: $e');
      return NativeExitFetchResult.error(e.toString());
    }
  }
}

/// 系统内存信息（Android），与退出记录共用 `i_iwara/exit_info` 通道。
///
/// 存在的理由：判断一次「无快照的异常退出」是不是低内存被杀，需要死前的内存
/// 走势；进程 RSS 只说明自己吃了多少，系统还剩多少只有原生侧知道。
abstract final class NativeMemoryInfo {
  static const MethodChannel _channel = NativeExitInfoService._channel;

  /// 例：`可用 812/3712MB（阈值 216MB）`，低水位时追加 `，系统低内存`。
  /// 非 Android 或读取失败返回 null。
  static Future<String?> describe() async {
    if (!GetPlatform.isAndroid) return null;
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getMemoryInfo',
      );
      return raw == null ? null : _format(raw);
    } catch (e) {
      debugPrint('[NativeMemoryInfo] 读取系统内存失败: $e');
      return null;
    }
  }

  /// 监听原生侧转来的 onTrimMemory。[onTrim] 拿到回收级别和格式化好的内存描述。
  static void listenTrimMemory(void Function(int level, String memory) onTrim) {
    if (!GetPlatform.isAndroid) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'onTrimMemory') return null;
      final raw = call.arguments;
      if (raw is! Map) return null;
      final level = raw['level'];
      onTrim(level is int ? level : -1, _format(raw));
      return null;
    });
  }

  /// ComponentCallbacks2.TRIM_MEMORY_* 的名字。
  static String trimLevelName(int level) => switch (level) {
    5 => 'RUNNING_MODERATE',
    10 => 'RUNNING_LOW',
    15 => 'RUNNING_CRITICAL',
    20 => 'UI_HIDDEN',
    40 => 'BACKGROUND',
    60 => 'MODERATE',
    80 => 'COMPLETE',
    _ => 'UNKNOWN',
  };

  static String _format(Map<dynamic, dynamic> raw) {
    final low = raw['lowMemory'] == true ? '，系统低内存' : '';
    return '可用 ${raw['availMemMb']}/${raw['totalMemMb']}MB'
        '（阈值 ${raw['thresholdMb']}MB）$low';
  }
}
