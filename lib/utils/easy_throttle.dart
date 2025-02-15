import 'dart:async';

typedef EasyThrottleCallback = void Function();

class _EasyThrottleOperation {
  EasyThrottleCallback callback;
  EasyThrottleCallback? onAfter;
  Timer timer;

  _EasyThrottleOperation(
    this.callback,
    this.timer, {
    this.onAfter,
  });
}

class EasyThrottle {
  static final Map<String, _EasyThrottleOperation> _operations = {};

  /// 将立即执行 [onExecute] ，并在给定的 [duration] 内忽略其他相同 [tag] 的节流调用。
  ///
  /// [tag] 可以是任意字符串，用于在后续调用 [throttle()] 或 [cancel()] 时标识该特定的节流操作。
  ///
  /// [duration] 表示在这段时间内忽略后续的调用。
  ///
  /// 返回该操作是否被节流
  static bool throttle(
    String tag,
    Duration duration,
    EasyThrottleCallback onExecute, {
    EasyThrottleCallback? onAfter,
  }) {
    var throttled = _operations.containsKey(tag);
    if (throttled) {
      return true;
    }

    _operations[tag] = _EasyThrottleOperation(
      onExecute,
      Timer(duration, () {
        _operations[tag]?.timer.cancel();
        _EasyThrottleOperation? removed = _operations.remove(tag);
        removed?.onAfter?.call();
      }),
      onAfter: onAfter,
    );

    onExecute();
    return false;
  }

  /// 取消指定 [tag] 的活动节流操作。
  static void cancel(String tag) {
    _operations[tag]?.timer.cancel();
    _operations.remove(tag);
  }

  /// 取消所有活动的节流操作。
  static void cancelAll() {
    for (final operation in _operations.values) {
      operation.timer.cancel();
    }
    _operations.clear();
  }

  /// 返回活动节流操作的数量。
  static int count() {
    return _operations.length;
  }
} 