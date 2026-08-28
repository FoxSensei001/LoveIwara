import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_scope.dart';

/// 「叶子作用域一律由注册表派发」的闸门。
///
/// 播放器当初的缺陷是把按键处理挂在自己那只 Focus 上——焦点不在子树里就一条都
/// 收不到（真机实测 20 秒 5 次按键，0 条）。视频域改用 [ShortcutTargetRegistry]
/// 之后，图库域仍留着老写法，于是同一个缺陷在图库原封不动地又活了一份。
///
/// 这条闸门要防的正是「修一处、漏一处」：任何解析叶子作用域按键的文件，都必须
/// 同时把自己注册进注册表。
void main() {
  List<File> libDartFiles() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      // 服务自身的定义与文档不算调用方。
      .where((f) => !f.path.contains('player_keybinding/'))
      .toList();

  final leafScopes = ShortcutScope.values
      .where((s) => s != ShortcutScope.global)
      .toList();

  test('每个叶子作用域都有且仅有注册表这一个入口', () {
    for (final scope in leafScopes) {
      final registrars = <String>[];
      final resolvers = <String>[];
      for (final file in libDartFiles()) {
        final src = file.readAsStringSync();
        if (!src.contains('ShortcutScope.${scope.name}')) continue;
        // 是否把自己注册进了注册表，并且注册的就是这个作用域。
        final regIdx = src.indexOf('ShortcutTargetRegistry.instance.register(');
        if (regIdx != -1) {
          final window = src.substring(
            regIdx,
            (regIdx + 400).clamp(0, src.length),
          );
          if (window.contains('ShortcutScope.${scope.name}')) {
            registrars.add(file.path);
          }
        }
        // 是否在解析这个作用域的键盘事件。
        var idx = src.indexOf('.resolve(');
        while (idx != -1) {
          final window = src.substring(
            idx,
            (idx + 200).clamp(0, src.length),
          );
          if (window.contains('ShortcutScope.${scope.name}')) {
            resolvers.add(file.path);
            break;
          }
          idx = src.indexOf('.resolve(', idx + 1);
        }
      }

      expect(
        registrars,
        hasLength(1),
        reason:
            '$scope 应当恰好有一个注册点，实际: $registrars\n'
            '没有＝它还挂在自己的 Focus 上，焦点一旦外移快捷键就静默失效。',
      );
      for (final resolver in resolvers) {
        expect(
          registrars,
          contains(resolver),
          reason:
              '$resolver 解析了 $scope 的按键，却没把自己注册进注册表——'
              '这正是图库当初漏掉的那种写法。',
        );
      }
    }
  });

  test('叶子作用域不得再用 Focus.onKeyEvent 自己收键（会与注册表双触发）', () {
    for (final file in libDartFiles()) {
      final src = file.readAsStringSync();
      if (!src.contains('ShortcutTargetRegistry.instance.register(')) continue;
      expect(
        src.contains('onKeyEvent:'),
        isFalse,
        reason:
            '${file.path} 已经注册进注册表，却还留着 Focus.onKeyEvent —— '
            '两处都收会双触发（同一次按下调两次音量）。',
      );
    }
  });
}
