import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'log_models.dart';
import 'log_paths.dart';

class LogFileSink {
  final LogPaths _paths;
  bool _degraded = false;
  DateTime? _lastFailureAt;
  static const Duration _retryBackoff = Duration(seconds: 5);
  int _maxFileBytes = LogConstants.defaultMaxFileBytes;
  int _maxRotatedFiles = LogConstants.defaultMaxRotatedFiles;

  /// 当前日志文件大小，内存内增量维护。-1 表示未知（启动后首次写入 / 写失败后）
  /// 需要 stat 一次重新对齐。这样轮转判定不必在**每次** append 之后都
  /// exists() + length() 两次系统调用。
  int _currentBytes = -1;

  /// `_currentBytes` 处于未知(-1)状态期间累计写出的字节数。
  ///
  /// 光靠「未知就跳过轮转判定」是不够的：只要 stat 是**稳定**失败而非瞬时失败，
  /// 轮转就永不发生、文件无上限增长——比它要修的那个「涨到上限两倍」还糟。
  /// 轮转本身并不需要知道当前大小，所以这里只要自己数够一个 maxFileBytes
  /// 就无条件轮转一次，让两种失败模式都有上界。
  int _bytesWrittenWhileUnknown = 0;

  LogFileSink(this._paths);

  bool get isDegraded => _degraded;

  void applyPolicy({required int maxFileBytes, required int maxRotatedFiles}) {
    if (maxFileBytes > 0) {
      _maxFileBytes = maxFileBytes;
    }
    if (maxRotatedFiles > 0) {
      _maxRotatedFiles = maxRotatedFiles;
    }
  }

  Future<bool> appendBatch(
    Iterable<String> lines, {
    bool forceFlush = false,
  }) async {
    if (lines.isEmpty) return true;

    if (_degraded &&
        _lastFailureAt != null &&
        DateTime.now().difference(_lastFailureAt!) < _retryBackoff) {
      return false;
    }

    if (_degraded) {
      _degraded = false;
    }

    try {
      final file = File(_paths.currentLogFile);
      // 直接编码成字节：既拿到精确的落盘长度（UTF-8 下中文一个字符 3 字节，
      // 按 String.length 算大小会严重低估），也省掉 writeAsString 内部的再编码。
      final bytes = utf8.encode('${lines.join('\n')}\n');

      final known = await _ensureCurrentBytes();
      await file.writeAsBytes(
        bytes,
        mode: FileMode.append,
        flush: forceFlush,
      );
      // known < 0 表示这轮没能拿到真实大小：写入照常，但轮转判定跳过，
      // 并保持「未知」让下次 append 重新 stat，绝不拿假值往上累加。
      //
      // 用 `+=` 而不是 `known + bytes.length`：上面那次 await 期间，
      // appendEmergencySync（同步）或 getHealthSnapshot 的 stat 可能已经动过
      // _currentBytes（甚至触发过一次轮转把它清零）。`known` 是过期快照，
      // 拿它做基数会把别处的增量整个覆盖掉；`+=` 则自动跟上。
      // 再查一次 -1 是因为间隙里别处的写入可能失败并把它置成了未知。
      if (known >= 0 && _currentBytes >= 0) {
        _currentBytes += bytes.length;
        _bytesWrittenWhileUnknown = 0;
        await _checkRotation();
      } else {
        _currentBytes = -1;
        _bytesWrittenWhileUnknown += bytes.length;
        if (_bytesWrittenWhileUnknown >= _maxFileBytes) {
          await rotate();
        }
      }
      return true;
    } catch (e) {
      _degraded = true;
      _lastFailureAt = DateTime.now();
      _currentBytes = -1;
      debugPrint('[LogFileSink] Write failed, degraded mode: $e');
      return false;
    }
  }

  bool appendEmergencySync(String line) {
    try {
      final file = File(_paths.currentLogFile);
      final bytes = utf8.encode('$line\n');
      final known = _ensureCurrentBytesSync();
      file.writeAsBytesSync(bytes, mode: FileMode.append, flush: true);
      // 全同步，没有 await 间隙，但仍用 `+=` 与 [appendBatch] 保持同一套记账口径。
      if (known >= 0) {
        _currentBytes += bytes.length;
        _bytesWrittenWhileUnknown = 0;
        _checkRotationSync();
      } else {
        _currentBytes = -1;
        _bytesWrittenWhileUnknown += bytes.length;
        if (_bytesWrittenWhileUnknown >= _maxFileBytes) {
          _rotateSync();
        }
      }
      return true;
    } catch (e) {
      _degraded = true;
      _lastFailureAt = DateTime.now();
      _currentBytes = -1;
      debugPrint('[LogFileSink] Emergency write failed: $e');
      return false;
    }
  }

  Future<int> _ensureCurrentBytes() async {
    if (_currentBytes >= 0) return _currentBytes;
    _currentBytes = await _statCurrentFileSize();
    return _currentBytes;
  }

  int _ensureCurrentBytesSync() {
    if (_currentBytes >= 0) return _currentBytes;
    try {
      final file = File(_paths.currentLogFile);
      _currentBytes = file.existsSync() ? file.lengthSync() : 0;
    } catch (_) {
      // 同 [_statCurrentFileSize]：读不到就保持未知，不能伪造成 0。
      _currentBytes = -1;
    }
    return _currentBytes;
  }

  Future<void> _checkRotation() async {
    try {
      if (_currentBytes >= _maxFileBytes) {
        await rotate();
      }
    } catch (e) {
      debugPrint('[LogFileSink] Rotation check failed: $e');
    }
  }

  void _checkRotationSync() {
    try {
      if (_currentBytes >= _maxFileBytes) {
        _rotateSync();
      }
    } catch (e) {
      debugPrint('[LogFileSink] Sync rotation check failed: $e');
    }
  }

  Future<void> rotate() async {
    try {
      if (_maxRotatedFiles <= 1) {
        final current = File(_paths.currentLogFile);
        if (await current.exists()) {
          await current.writeAsString('');
        }
        _currentBytes = 0;
        _bytesWrittenWhileUnknown = 0;
        return;
      }

      final oldest = File(_paths.rotatedFile(_maxRotatedFiles - 1));
      if (await oldest.exists()) {
        await oldest.delete();
      }

      for (int i = _maxRotatedFiles - 2; i >= 1; i--) {
        final from = File(_paths.rotatedFile(i));
        if (await from.exists()) {
          await from.rename(_paths.rotatedFile(i + 1));
        }
      }

      final current = File(_paths.currentLogFile);
      if (await current.exists()) {
        await current.rename(_paths.rotatedFile(1));
      }

      await File(_paths.currentLogFile).create();
      _currentBytes = 0;
      _bytesWrittenWhileUnknown = 0;
    } catch (e) {
      _currentBytes = -1;
      debugPrint('[LogFileSink] Rotation failed: $e');
    }
  }

  void _rotateSync() {
    try {
      if (_maxRotatedFiles <= 1) {
        final current = File(_paths.currentLogFile);
        if (current.existsSync()) {
          current.writeAsStringSync('');
        }
        _currentBytes = 0;
        _bytesWrittenWhileUnknown = 0;
        return;
      }

      final oldest = File(_paths.rotatedFile(_maxRotatedFiles - 1));
      if (oldest.existsSync()) {
        oldest.deleteSync();
      }

      for (int i = _maxRotatedFiles - 2; i >= 1; i--) {
        final from = File(_paths.rotatedFile(i));
        if (from.existsSync()) {
          from.renameSync(_paths.rotatedFile(i + 1));
        }
      }

      final current = File(_paths.currentLogFile);
      if (current.existsSync()) {
        current.renameSync(_paths.rotatedFile(1));
      }
      File(_paths.currentLogFile).createSync();
      _currentBytes = 0;
      _bytesWrittenWhileUnknown = 0;
    } catch (e) {
      _currentBytes = -1;
      debugPrint('[LogFileSink] Sync rotation failed: $e');
    }
  }

  /// 真实 stat 一次并顺带把内存计数对齐（诊断页读取 / 外部改动后的自愈入口）。
  /// 热路径的轮转判定不走这里，见 [_checkRotation]。
  Future<int> currentFileSize() async {
    final size = await _statCurrentFileSize();
    // ⚠️ 只有读到真值才回填内存计数。stat 失败时若把 0 缓存进去，由于热路径
    // 已经不再每次 stat，这个假的 0 会一直留着，导致要再写满一整个
    // maxFileBytes 才轮转——文件直接涨到上限的两倍。
    if (size >= 0) _currentBytes = size;
    return size < 0 ? 0 : size;
  }

  /// 返回 -1 表示**读不到**（区别于「文件不存在」的确定值 0）。
  Future<int> _statCurrentFileSize() async {
    try {
      final file = File(_paths.currentLogFile);
      if (!await file.exists()) return 0;
      return await file.length();
    } catch (_) {
      return -1;
    }
  }

  Future<List<File>> listLogFiles() async {
    final files = <File>[];
    final current = File(_paths.currentLogFile);
    if (await current.exists()) {
      files.add(current);
    }
    for (int i = 1; i < _maxRotatedFiles; i++) {
      final rotated = File(_paths.rotatedFile(i));
      if (await rotated.exists()) {
        files.add(rotated);
      }
    }
    return files;
  }

  void resetDegraded() {
    _degraded = false;
    _lastFailureAt = null;
    _currentBytes = -1;
    _bytesWrittenWhileUnknown = 0;
  }
}
