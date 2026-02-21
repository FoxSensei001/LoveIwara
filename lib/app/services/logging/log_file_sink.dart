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
    List<String> lines, {
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
      final content = '${lines.join('\n')}\n';

      await file.writeAsString(
        content,
        mode: FileMode.append,
        flush: forceFlush,
      );

      await _checkRotation();
      return true;
    } catch (e) {
      _degraded = true;
      _lastFailureAt = DateTime.now();
      debugPrint('[LogFileSink] Write failed, degraded mode: $e');
      return false;
    }
  }

  bool appendEmergencySync(String line) {
    try {
      final file = File(_paths.currentLogFile);
      file.writeAsStringSync('$line\n', mode: FileMode.append, flush: true);
      _checkRotationSync();
      return true;
    } catch (e) {
      _degraded = true;
      _lastFailureAt = DateTime.now();
      debugPrint('[LogFileSink] Emergency write failed: $e');
      return false;
    }
  }

  Future<void> _checkRotation() async {
    try {
      final size = await currentFileSize();
      if (size >= _maxFileBytes) {
        await rotate();
      }
    } catch (e) {
      debugPrint('[LogFileSink] Rotation check failed: $e');
    }
  }

  void _checkRotationSync() {
    try {
      final file = File(_paths.currentLogFile);
      if (!file.existsSync()) return;
      if (file.lengthSync() >= _maxFileBytes) {
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
    } catch (e) {
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
    } catch (e) {
      debugPrint('[LogFileSink] Sync rotation failed: $e');
    }
  }

  Future<int> currentFileSize() async {
    try {
      final file = File(_paths.currentLogFile);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (_) {}
    return 0;
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
  }
}
