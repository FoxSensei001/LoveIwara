import 'log_models.dart';

class LogProcessor {
  LogProcessor({int maxLogsPerSecond = LogConstants.defaultMaxLogsPerSecond})
    : _maxLogsPerSecond = maxLogsPerSecond;

  int _logCountInWindow = 0;
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
    _SanitizeRule(
      RegExp(r'\b\+?\d{1,3}[\s-]?1[3-9]\d{9}\b'),
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

    // Rate limiting: sliding window
    if (now.difference(_windowStart).inSeconds >= 1) {
      _windowStart = now;
      _logCountInWindow = 0;
    }
    _logCountInWindow++;

    if (_logCountInWindow > _maxLogsPerSecond) {
      if (event.level.value < LogLevel.warning.value) {
        _rateLimitedCount++;
        return null;
      }
    }

    // Error dedup: 5-second window
    if (event.level.value >= LogLevel.error.value) {
      final fingerprint = _fingerprint(event);
      final lastSeen = _errorFingerprints[fingerprint];
      if (lastSeen != null &&
          now.difference(lastSeen) < LogConstants.dedupWindowDuration) {
        _suppressedCount++;
        return null;
      }
      _errorFingerprints[fingerprint] = now;

      // Clean old fingerprints
      _errorFingerprints.removeWhere(
        (_, ts) => now.difference(ts) > LogConstants.dedupWindowDuration,
      );
    }

    // Sanitize and truncate
    final sanitizedMessage = _truncate(sanitize(event.message), _maxMessageLen);
    final sanitizedError = event.error != null
        ? _truncate(sanitize(event.error!), _maxErrorLen)
        : null;
    final sanitizedStackTrace = event.stackTrace != null
        ? _truncate(sanitize(event.stackTrace!), _maxStackLen)
        : null;

    return LogEvent(
      timestamp: event.timestamp,
      level: event.level,
      tag: event.tag,
      message: sanitizedMessage,
      error: sanitizedError,
      stackTrace: sanitizedStackTrace,
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

  String _fingerprint(LogEvent event) {
    final firstLine = event.message.split('\n').first;
    return '${event.level.label}:${event.tag}:$firstLine';
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
