import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 源码卫生闸门。
///
/// # ⛔ 为什么会有这个文件
///
/// 2026-08-29：`playback_queue_drawer.dart` 里混进了 **3 个 NUL 字节**（`\x00`），
/// 是用 heredoc 生成文件时带进去的。后果非常隐蔽：
///
/// - `dart analyze` **完全不报错**——NUL 落在字符串字面量里是合法字符；
/// - 但它冒充了一个空格，于是 `'$id $title'.split(' ')` 永远切不出 2 段，
///   播放列表选择器**从来没工作过**，表现是"点了没反应"；
/// - `grep` 会把含 NUL 的文件判成 binary **直接跳过**，检索时静默漏掉整个文件。
///
/// 分析器和测试都抓不到、连 grep 都会骗你——只能靠一道字节级的闸门。
/// 明知故犯、且有据可查的豁免。
///
/// 目前为空：`content_block_service.dart` 曾经拿字面 NUL 当**复合 key 的分隔符**
/// （`'$caseSensitive\x00$pattern'`）——技巧本身正当，正是为了避开
/// "用空格拼 key 再 split"那类歧义——但字面字节同样会让 grep 跳过整个文件。
/// 2026-08-29 已改写成 `\x00` 转义（字符完全相同、运行时零变化），豁免随之取消。
const Set<String> _nulByteExemptFiles = <String>{};

void main() {
  test('⛔ 源码里不许出现 NUL 字节（分析器不报、grep 会把文件当二进制跳过）', () {
    final offenders = <String>[];
    for (final dir in ['lib', 'test', 'tool']) {
      final directory = Directory(dir);
      if (!directory.existsSync()) continue;
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File) continue;
        if (!entity.path.endsWith('.dart') &&
            !entity.path.endsWith('.yaml')) {
          continue;
        }
        final relative = entity.path.replaceAll(r'\', '/');
        if (_nulByteExemptFiles.contains(relative)) continue;
        final bytes = entity.readAsBytesSync();
        final count = bytes.where((b) => b == 0).length;
        if (count > 0) offenders.add('${entity.path}：$count 个');
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          '这些文件里有 NUL 字节。它在字符串字面量里是"合法"的，所以 analyze 不会报，\n'
          '但它会冒充空格/分隔符让运行时逻辑静默失效，还会让 grep 把整个文件当\n'
          '二进制跳过。多半是用 heredoc / 脚本生成文件时带进来的：\n'
          '${offenders.join('\n')}',
    );
  });
}
