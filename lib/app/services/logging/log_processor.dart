import 'log_models.dart';

class LogProcessor {
  LogProcessor({int maxLogsPerSecond = LogConstants.defaultMaxLogsPerSecond})
    : _maxLogsPerSecond = maxLogsPerSecond;

  int _logCountInWindow = 0;
  int _highSeverityCountInWindow = 0;
  DateTime _windowStart = DateTime.now();
  final Map<String, DateTime> _errorFingerprints = {};
  int _suppressedCount = 0;
  int _rateLimitedCount = 0;
  int _maxLogsPerSecond;

  static const int _maxMessageLen = 2000;
  static const int _maxErrorLen = 1000;
  static const int _maxStackLen = 2000;

  static final List<_SanitizeRule> _sanitizeRules = [
    _SanitizeRule(
      RegExp(r'(authorization\s*[:=]\s*bearer\s+)\S+', caseSensitive: false),
      (m) => '${m.group(1)}***',
    ),
    _SanitizeRule(
      RegExp(
        r'(access_token|refresh_token|token|api[_\-]?key|secret|password|passwd|cookie|set-cookie)\s*[:=]\s*\S+',
        caseSensitive: false,
      ),
      (m) => '${m.group(1)}=***',
    ),
    _SanitizeRule(
      RegExp(r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}'),
      (_) => '***@***',
    ),
    _SanitizeRule(
      RegExp(r'(https?://)([^/\s:@]+):([^@/\s]+)@', caseSensitive: false),
      (m) => '${m.group(1)}***:***@',
    ),
    _SanitizeRule(
      RegExp(r'(https?://[^\s?]+)\?[^\s]+'),
      (m) => '${m.group(1)}?<redacted>',
    ),
    // 中国大陆手机号：以 11 位号码本身为主体（1 + [3-9] + 9 位数字），
    // 国家码/分隔符为可选前缀；用前后向断言避免吞掉更长数字串，
    // 也避免依赖 \b（对中文上下文如「手机13912345678号」不可靠）。
    _SanitizeRule(
      RegExp(r'(?<!\d)(?:\+?\d{1,3}[\s-]?)?1[3-9]\d{9}(?!\d)'),
      (_) => '<phone_redacted>',
    ),
  ];

  String sanitize(String text) {
    var result = text;
    for (final rule in _sanitizeRules) {
      result = result.replaceAllMapped(rule.pattern, rule.replacer);
    }
    return result;
  }

  LogEvent? process(LogEvent event) {
    final now = DateTime.now();

    // 限流窗口：固定窗口（tumbling），不是滑动窗口。
    if (now.difference(_windowStart).inSeconds >= 1) {
      _windowStart = now;
      _logCountInWindow = 0;
      _highSeverityCountInWindow = 0;
    }

    // 去重的**查询**排在限流之前：否则同一个 error 的风暴会先吃光整个窗口配额，
    // 把本该留下的其它日志挤掉，而它们自己随后又被去重丢弃——两头落空。
    //
    // ⚠️ 但**登记**绝不能跟着一起前移。若一条 error 登记了指纹、随后又被限流
    // 丢弃，接下来 5 秒内同类 error 会全部命中这个「从未落盘」的指纹被去重掉，
    // 结果是这类错误一条都不见，只剩两个聚合计数在涨。登记必须放在所有丢弃
    // 判定都通过之后。
    final fingerprint = event.level.value >= LogLevel.error.value
        ? _fingerprint(event)
        : null;
    if (fingerprint != null) {
      final lastSeen = _errorFingerprints[fingerprint];
      if (lastSeen != null &&
          now.difference(lastSeen) < LogConstants.dedupWindowDuration) {
        _suppressedCount++;
        return null;
      }
    }

    _logCountInWindow++;

    if (_logCountInWindow > _maxLogsPerSecond) {
      if (event.level.value < LogLevel.warning.value) {
        _rateLimitedCount++;
        return null;
      }
      // 限流超限后，warn/error 走独立配额，避免不同内容的 error 风暴
      // 完全绕过限流而放大落盘 I/O；fatal 永不丢弃。
      if (event.level.value < LogLevel.fatal.value) {
        _highSeverityCountInWindow++;
        if (_highSeverityCountInWindow > _maxLogsPerSecond) {
          _rateLimitedCount++;
          return null;
        }
      }
    }

    // 事件确定会被保留，此时才登记指纹，让 5 秒窗口从「真正落盘的那一条」起算。
    if (fingerprint != null) {
      _errorFingerprints[fingerprint] = now;
      _errorFingerprints.removeWhere(
        (_, ts) => now.difference(ts) > LogConstants.dedupWindowDuration,
      );
    }

    return sanitizeEvent(event);
  }

  /// 仅做脱敏+截断，不参与限流/去重。
  /// 用于 fatal 等「必须落盘、但绝不能绕过脱敏」的旁路场景
  /// （process() 因去重返回 null 时的回退）。
  LogEvent sanitizeEvent(LogEvent event) {
    return LogEvent(
      timestamp: event.timestamp,
      level: event.level,
      tag: event.tag,
      message: _truncate(sanitize(event.message), _maxMessageLen),
      error: event.error != null
          ? _truncate(sanitize(event.error!), _maxErrorLen)
          : null,
      stackTrace: event.stackTrace != null
          ? _truncate(sanitize(event.stackTrace!), _maxStackLen)
          : null,
      sessionId: event.sessionId,
    );
  }

  int get suppressedCount => _suppressedCount;
  int get rateLimitedCount => _rateLimitedCount;

  void resetSuppressedCount() {
    _suppressedCount = 0;
    _rateLimitedCount = 0;
  }

  void updateRateLimit(int maxLogsPerSecond) {
    if (maxLogsPerSecond <= 0) return;
    _maxLogsPerSecond = maxLogsPerSecond;
  }

  /// 指纹里必须抹掉「每次都不一样的可变量」，否则去重形同虚设：
  /// 本仓的 error 消息普遍内嵌 requestId / UUID / 路径 / 数字（如
  /// `'$_tag[$requestId] 等待 token 刷新时出错'`），原样取首行会让同一类错误
  /// 每次都生成新指纹，5 秒窗口一次都命中不了——于是每条 error 都触发一次
  /// 强制 fsync 落盘。
  /// ⚠️ 只抹长数字（≥4 位）。用 `\d+` 会连**本身就是错误身份**的短数字一起抹掉：
  /// `响应状态码: 404` 和 `500` 会归一成同一条指纹，`errno = 111`（SYN 被拒）
  /// 和 `errno = 110`（超时）也会被合并——而这俩正是网络诊断赖以定性的信号。
  /// requestId 是 `microsecondsSinceEpoch`（16 位）、UUID 分段也远超 4 位，
  /// 用 `\d{4,}` 足够覆盖真正易变的那部分。
  static final RegExp _fingerprintVolatile = RegExp(
    r'[0-9a-fA-F]{8,}|\d{4,}',
  );

  /// 指纹取首行，超长截断，避免把 map 的 key 撑成几 KB。
  static const int _maxFingerprintLen = 200;

  String _fingerprint(LogEvent event) {
    final message = event.message;
    // 不用 split('\n').first：那会把整条消息切成 List 再丢掉。
    final newline = message.indexOf('\n');
    var firstLine = newline < 0 ? message : message.substring(0, newline);
    if (firstLine.length > _maxFingerprintLen) {
      firstLine = firstLine.substring(0, _maxFingerprintLen);
    }
    final normalized = firstLine.replaceAll(_fingerprintVolatile, '#');
    // 带上异常类型：本仓大量 `LogUtils.e('xxx失败', error: e)` 消息文案完全相同，
    // 只有 error 的类型不同（SocketException / FormatException / ...）。
    // 只取类型名，不含内容，不会引入 PII。
    final errorKind = event.error == null
        ? ''
        : ':${_errorKind(event.error!)}';
    return '${event.level.label}:${event.tag}:$normalized$errorKind';
  }

  /// 提到静态字段：这是 error 路径上每条都要跑的，内联 RegExp 字面量会
  /// 每次新建一个正则对象。
  static final RegExp _errorKindSeparator = RegExp(r'[:(]');

  /// 无分隔符时的回退长度。取短一点：这种情况下拿到的是**内容**而不是类型名，
  /// 越长越容易把可变量带进指纹。
  static const int _errorKindFallbackLen = 24;
  static const int _errorKindMaxLen = 60;

  /// 从已字符串化的 error 里取出类型标识。Dart 的 `Object.toString()` 对异常
  /// 惯例是 `TypeName: detail` 或 `TypeName (detail)`，取首个分隔符之前的部分
  /// （`StateError` → `Bad state`、`SocketException: ... (OS Error: ...)` →
  /// `SocketException`、`DioException [DioExceptionType.xxx]` 还顺带保留了子类型）。
  ///
  /// ⚠️ 结果必须**同样**跑一遍 [_fingerprintVolatile]。没有分隔符时（`throw '刷新失败
  /// $requestId'` 这类直接抛字符串的调用点，或变量出现在首个分隔符之前的 toString）
  /// 这里拿到的是带可变量的内容，不归一化的话指纹每次都新——H2 修的那个病会原样
  /// 在这里复发。而且后果不止「多留几条日志」：去重失效后每条重复 error 都会
  /// 吃掉限流窗口配额，把同窗口内的其它日志挤掉。
  static String _errorKind(String error) {
    final cut = error.indexOf(_errorKindSeparator);
    final hasSeparator = cut >= 0;
    final kind = hasSeparator ? error.substring(0, cut) : error;
    var trimmed = kind.trim();
    final maxLen = hasSeparator ? _errorKindMaxLen : _errorKindFallbackLen;
    if (trimmed.length > maxLen) {
      trimmed = trimmed.substring(0, maxLen);
    }
    return trimmed.replaceAll(_fingerprintVolatile, '#');
  }

  static String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen)}...[truncated ${text.length - maxLen} chars]';
  }
}

class _SanitizeRule {
  final RegExp pattern;
  final String Function(Match m) replacer;

  _SanitizeRule(this.pattern, this.replacer);
}
