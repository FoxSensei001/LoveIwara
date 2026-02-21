import 'dart:collection';
import 'log_models.dart';

class LogBuffer {
  final ListQueue<LogEvent> _ringBuffer = ListQueue<LogEvent>();
  final List<String> _writeQueue = [];

  void push(LogEvent event) {
    _pushRing(event);
    _writeQueue.add(event.toJsonLine());
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

  List<String> drain({int? maxItems}) {
    final count = maxItems ?? _writeQueue.length;
    final batch = _writeQueue.take(count).toList();
    _writeQueue.removeRange(0, batch.length);
    return batch;
  }

  void requeueFront(List<String> lines) {
    if (lines.isEmpty) return;
    _writeQueue.insertAll(0, lines);
    _trimWriteQueue();
  }

  List<LogEvent> getRecent({int? count}) {
    final n = count ?? _ringBuffer.length;
    final list = _ringBuffer.toList();
    if (n >= list.length) return list;
    return list.sublist(list.length - n);
  }

  int get writeQueueLength => _writeQueue.length;

  int get ringBufferLength => _ringBuffer.length;

  bool get hasItemsToFlush => _writeQueue.isNotEmpty;

  void clearWriteQueue() => _writeQueue.clear();

  void _trimWriteQueue() {
    if (_writeQueue.length <= LogConstants.highWaterMark) return;

    // 优先删除低优先级日志（DEBUG/INFO）
    var i = 0;
    while (_writeQueue.length > LogConstants.highWaterMark &&
        i < _writeQueue.length) {
      final line = _writeQueue[i];
      final lowPriority =
          line.contains('"level":"DEBUG"') || line.contains('"level":"INFO"');
      if (lowPriority) {
        _writeQueue.removeAt(i);
        continue;
      }
      i++;
    }

    // 兜底硬裁剪：即使全是高优先级日志也必须控制上限，避免内存持续增长。
    if (_writeQueue.length > LogConstants.highWaterMark) {
      _writeQueue.removeRange(0, _writeQueue.length - LogConstants.highWaterMark);
    }
  }
}
