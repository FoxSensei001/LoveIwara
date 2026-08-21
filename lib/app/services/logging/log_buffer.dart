import 'dart:collection';
import 'log_models.dart';

/// 待落盘的一行。**必须带上结构化的 [level]**：早先的实现只存序列化后的字符串，
/// 裁剪时靠 `line.contains('"level":"DEBUG"')` 猜等级——对每条最长 5KB 的 JSON
/// 做子串搜索，而裁剪在高水位下每次 push 都要跑一遍整个队列。
///
/// （注：正文若含 `"level":"DEBUG"` 字面量并不会被误判——`jsonEncode` 会把引号
/// 转义成 `\"level\":\"DEBUG\"`，匹配不上。所以这次改的理由只是性能和类型安全，
/// 不是修正确性 bug。）
class PendingLogLine {
  PendingLogLine(this.level, this.line);

  final LogLevel level;
  final String line;

  bool get isLowPriority => level.value < LogLevel.warning.value;
}

class LogBuffer {
  final ListQueue<LogEvent> _ringBuffer = ListQueue<LogEvent>();
  final ListQueue<PendingLogLine> _writeQueue = ListQueue<PendingLogLine>();

  /// 写队列中所有 line 的长度之和，增量维护，避免裁剪时重新遍历求和。
  ///
  /// 单位是 **UTF-16 码元**（`String.length`），不是字节。中文日志走
  /// TwoByteString，实际堆占用约为本值 ×2。刻意不换算成 UTF-8 字节：
  /// 详见 [LogConstants.maxWriteQueueChars]。
  int _writeQueueChars = 0;

  void push(LogEvent event) {
    _pushRing(event);
    final line = event.toJsonLine();
    _writeQueue.addLast(PendingLogLine(event.level, line));
    _writeQueueChars += line.length;
    _trimWriteQueue();
  }

  void pushToRingOnly(LogEvent event) {
    _pushRing(event);
  }

  void _pushRing(LogEvent event) {
    _ringBuffer.addLast(event);
    while (_ringBuffer.length > LogConstants.ringBufferCapacity) {
      _ringBuffer.removeFirst();
    }
  }

  List<PendingLogLine> drain({int? maxItems}) {
    final count = maxItems == null
        ? _writeQueue.length
        : (maxItems < _writeQueue.length ? maxItems : _writeQueue.length);
    if (count <= 0) return const [];

    final batch = <PendingLogLine>[];
    for (var i = 0; i < count; i++) {
      final item = _writeQueue.removeFirst();
      _writeQueueChars -= item.line.length;
      batch.add(item);
    }
    return batch;
  }

  /// 落盘失败时把整批塞回队首，保持原有顺序。
  void requeueFront(List<PendingLogLine> batch) {
    if (batch.isEmpty) return;
    for (var i = batch.length - 1; i >= 0; i--) {
      final item = batch[i];
      _writeQueue.addFirst(item);
      _writeQueueChars += item.line.length;
    }
    _trimWriteQueue();
  }

  List<LogEvent> getRecent({int? count}) {
    final n = count ?? _ringBuffer.length;
    final list = _ringBuffer.toList();
    if (n >= list.length) return list;
    return list.sublist(list.length - n);
  }

  int get writeQueueLength => _writeQueue.length;

  int get writeQueueChars => _writeQueueChars;

  int get ringBufferLength => _ringBuffer.length;

  bool get hasItemsToFlush => _writeQueue.isNotEmpty;

  void clearWriteQueue() {
    _writeQueue.clear();
    _writeQueueChars = 0;
  }

  bool get _isOverLimit =>
      _writeQueue.length > LogConstants.highWaterMark ||
      _writeQueueChars > LogConstants.maxWriteQueueChars;

  /// 越限时**一次性**压回到目标水位（而不是每次 push 都削掉一条），
  /// 让整轮 O(n) 重建摊薄到常数级。优先丢弃最旧的 DEBUG/INFO，
  /// 全是高优先级时再从队首硬裁。
  void _trimWriteQueue() {
    if (!_isOverLimit) return;

    var dropEntries = _writeQueue.length - LogConstants.writeQueueTrimTarget;
    var dropChars =
        _writeQueueChars - LogConstants.writeQueueCharsTrimTarget;

    if (dropEntries > 0 || dropChars > 0) {
      final kept = ListQueue<PendingLogLine>(_writeQueue.length);
      for (final item in _writeQueue) {
        if ((dropEntries > 0 || dropChars > 0) && item.isLowPriority) {
          dropEntries--;
          dropChars -= item.line.length;
          _writeQueueChars -= item.line.length;
          continue;
        }
        kept.addLast(item);
      }
      _writeQueue
        ..clear()
        ..addAll(kept);
    }

    // 兜底硬裁剪：低优先级不够丢时，从最旧开始砍，无视等级。
    while (_writeQueue.length > LogConstants.writeQueueTrimTarget ||
        _writeQueueChars > LogConstants.writeQueueCharsTrimTarget) {
      if (_writeQueue.isEmpty) break;
      final removed = _writeQueue.removeFirst();
      _writeQueueChars -= removed.line.length;
    }
  }
}
