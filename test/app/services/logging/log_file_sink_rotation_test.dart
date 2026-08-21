import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/log_file_sink.dart';
import 'package:i_iwara/app/services/logging/log_paths.dart';

Future<(LogFileSink, LogPaths)> _makeSink({
  required int maxFileBytes,
  int maxRotatedFiles = 3,
}) async {
  final tempDir = await Directory.systemTemp.createTemp('loveiwara_rotate_');
  addTearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });
  final paths = LogPaths.forTesting(
    logDir: '${tempDir.path}/logs',
    exportDir: '${tempDir.path}/export',
  );
  final sink = LogFileSink(paths)
    ..applyPolicy(
      maxFileBytes: maxFileBytes,
      maxRotatedFiles: maxRotatedFiles,
    );
  return (sink, paths);
}

void main() {
  group('LogFileSink 轮转（文件大小改内存维护后）', () {
    test('连续追加时当前文件始终不超过上限', () async {
      const maxBytes = 2000;
      final (sink, paths) = await _makeSink(maxFileBytes: maxBytes);

      final line = 'x' * 190; // +换行 ≈ 191 字节
      for (var i = 0; i < 60; i++) {
        expect(await sink.appendBatch([line]), isTrue);
        expect(
          await File(paths.currentLogFile).length(),
          lessThanOrEqualTo(maxBytes),
          reason: '第 $i 次追加后当前文件超限，说明内存计数与磁盘失配',
        );
      }
    });

    test('诊断页反复读取文件大小不会破坏后续轮转', () async {
      // H3 的用户可见症状就是「日志文件远超设置的上限」：currentFileSize()
      // 是诊断页刷新/导出走的路径，早先它会把 stat 结果无条件回填内存计数，
      // 一旦回填了错误的值，热路径（已不再 stat）就再也纠正不回来。
      const maxBytes = 2000;
      final (sink, paths) = await _makeSink(maxFileBytes: maxBytes);

      final line = 'x' * 190;
      for (var i = 0; i < 60; i++) {
        expect(await sink.appendBatch([line]), isTrue);
        // 每次追加后都模拟一次诊断页刷新。
        await sink.currentFileSize();
        expect(
          await File(paths.currentLogFile).length(),
          lessThanOrEqualTo(maxBytes),
          reason: '第 $i 次：读过文件大小之后轮转就失效了',
        );
      }
    });

    test('currentFileSize() 与磁盘真实大小一致', () async {
      final (sink, paths) = await _makeSink(maxFileBytes: 1024 * 1024);

      await sink.appendBatch(['第一行中文日志', '第二行中文日志']);
      final reported = await sink.currentFileSize();
      final actual = await File(paths.currentLogFile).length();

      // 中文按 UTF-8 是 3 字节/字，用 String.length 记账会严重低估——
      // 这条用例锁住「按字节记账」这个前提。
      expect(reported, actual);
      expect(reported, greaterThan(2 * '第一行中文日志'.length));
    });

    test('同步应急写入与异步批量写入交替时轮转仍然收敛', () async {
      const maxBytes = 2000;
      final (sink, paths) = await _makeSink(maxFileBytes: maxBytes);

      final line = 'y' * 190;
      for (var i = 0; i < 40; i++) {
        if (i.isEven) {
          expect(await sink.appendBatch([line]), isTrue);
        } else {
          expect(sink.appendEmergencySync(line), isTrue);
        }
        expect(
          await File(paths.currentLogFile).length(),
          lessThanOrEqualTo(maxBytes),
          reason: '第 $i 次：两条写入路径的记账口径不一致',
        );
      }
    });

    test('轮转文件数受 maxRotatedFiles 约束，不会无限堆积', () async {
      final (sink, paths) = await _makeSink(
        maxFileBytes: 500,
        maxRotatedFiles: 3,
      );

      final line = 'z' * 190;
      for (var i = 0; i < 40; i++) {
        await sink.appendBatch([line]);
      }

      expect(await File(paths.rotatedFile(1)).exists(), isTrue);
      expect(await File(paths.rotatedFile(2)).exists(), isTrue);
      // maxRotatedFiles = 3 → 只保留 .1 和 .2，第 3 个必须被删掉
      expect(await File(paths.rotatedFile(3)).exists(), isFalse);
    });
  });
}
