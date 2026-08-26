import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// GetX 的 Rx worker（`ever` / `everAll` / `once` / `debounce` / `interval`）
/// 零容忍闸门。
///
/// # 为什么整族都禁
///
/// 它们都走同一条路：`listener.listen(...)`，也就是 Rx 的 stream。而 GetX 5 rc 的
/// `GetListenable.subject` 把「把新值推进 stream」的内部监听者挂在 broadcast
/// 控制器的 `onCancel` 上（见 `lib/utils/rx_ever.dart` 的文档）——最后一个订阅者
/// 一取消，它就被摘掉，而控制器本身不会重建，于是**此后所有订阅者永久失聪**。
///
/// 这个 bug 的可怕之处在于它完全静默：
///   · 不报错、不抛异常、analyze 与单测都不会有任何反应；
///   · 同一个 Rx 上的 `Obx`（走 `addListener`）一切正常，只有 worker 那条链是死的；
///   · 只在「第二次打开这个页面」之后才出现，第一次开发自测永远碰不到。
///
/// 已经付出过的代价：下载完成后任务离开「下载中」区却不出现在历史区（2026-08-26
/// 真机日志里 `DownloadState emit` 有、配对的 `recv` 一条都没有）；作者页、
/// 媒体列表也都挂在常驻服务/控制器的 Rx 上，同样的地雷。
///
/// # 该用什么替代
///
/// `rxEver(rx, (value) { ... })`（`lib/utils/rx_ever.dart`）：挂 `addListener`，
/// 回调仍在微任务里执行，返回的仍是 GetX 的 `Worker`，调用点写法不变。
/// 需要节流 / 防抖的，在回调里自己用 `Timer`，不要回头去用 `debounce`。
void main() {
  test('lib/ 里没有 GetX Rx worker 调用（零容忍）', () {
    final offenders = <String>[];
    for (final file in _dartFiles()) {
      final rel = _rel(file);
      if (rel.startsWith('lib/i18n/')) continue;
      if (rel == 'lib/utils/rx_ever.dart') continue; // 文档里会提到这些名字
      final source = file.readAsStringSync().replaceAll(_comment, '');
      for (final match in _rxWorker.allMatches(source)) {
        final line =
            '\n'.allMatches(source.substring(0, match.start)).length + 1;
        offenders.add('$rel:$line ${match.group(2)}(');
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'GetX 的 Rx worker 在「订阅 -> 取消 -> 再订阅」之后永久失聪（详见本文件'
          '开头与 lib/utils/rx_ever.dart），请改用 rxEver：\n'
          '${offenders.join('\n')}',
    );
  });
}

/// 前面不能是标识符字符或点号，避免命中 `Duration.ever`、`xxxOnce(` 之类。
final RegExp _rxWorker = RegExp(
  r'(^|[^A-Za-z0-9_.$])(ever|everAll|once|debounce|interval)\s*\(',
  multiLine: true,
);

final RegExp _comment = RegExp(r'//.*');

Iterable<File> _dartFiles() sync* {
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) yield entity;
  }
}

String _rel(File file) => file.path.replaceAll(r'\', '/');
