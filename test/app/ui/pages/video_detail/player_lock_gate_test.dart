import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 播放器锁定态对**所有**输入通道生效的闸门。
///
/// 用户报的是：锁上之后空格照样暂停、鼠标侧键照样跳转。真因是「锁定」当时只被
/// 当成「挡手指」——只有 `_onTap` 检查了锁定态，遮罩层也只吃 `onTap`，三条快捷键
/// 派发入口一条都没查。
///
/// 修法不是在三处各加一次判断（那正是 Work Item 1 那个「键盘好了鼠标还坏着」
/// 的成因），而是把键盘与鼠标解析出动作之后的路径收成**唯一一个出口**
/// `_dispatchVideoShortcut`，闸门放在那里。下面钉的就是这个结构：任何人把某条
/// 入口重新接回旧的分派函数，就等于绕开了锁定闸门，这里会失败。
void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/app/ui/pages/video_detail/widgets/player/my_video_screen.dart',
    ).readAsStringSync();
  });

  /// 取出某个方法的正文并剥掉注释——扫源码的闸门只该看代码。
  String bodyOf(String signature) {
    final start = source.indexOf(signature);
    expect(start, greaterThan(-1), reason: '找不到 $signature');
    final end = source.indexOf('\n  }', start);
    expect(end, greaterThan(start), reason: '$signature 的正文没有正常结束');
    return source
        .substring(start, end)
        .split('\n')
        .map((line) {
          final idx = line.indexOf('//');
          return idx == -1 ? line : line.substring(0, idx);
        })
        .join('\n');
  }

  test('唯一出口里必须先查锁定态，再谈分派', () {
    final body = bodyOf('void _dispatchVideoShortcut(');
    expect(
      body.contains('isToolbarsLocked'),
      isTrue,
      reason: '锁定闸门没了：锁上之后快捷键会照常改播放状态',
    );
    expect(
      body.indexOf('isToolbarsLocked'),
      lessThan(body.indexOf('_dispatchKeybindingAction')),
      reason: '闸门必须在分派之前',
    );
    expect(
      body.contains('showLockButton'),
      isTrue,
      reason: '锁定态下要和点按一样把锁按钮亮出来，否则用户不知道为什么没反应',
    );
  });

  test('键盘入口只经由唯一出口分派', () {
    final body = bodyOf('KeyEventResult _handlePlayerKeyEvent(');
    expect(body.contains('_dispatchVideoShortcut('), isTrue);
    expect(
      body.contains('_dispatchKeybindingAction('),
      isFalse,
      reason: '直接调用分派＝绕开锁定闸门',
    );
    expect(
      body.contains('_dispatchOnInitialPlaybackCover('),
      isFalse,
      reason: '封面放行也必须走唯一出口，否则锁定态在封面上失效',
    );
  });

  test('鼠标入口只经由唯一出口分派', () {
    final body = bodyOf('void _handlePlayerPointerDown(');
    expect(body.contains('_dispatchVideoShortcut('), isTrue);
    expect(
      body.contains('_dispatchKeybindingAction('),
      isFalse,
      reason: '直接调用分派＝绕开锁定闸门',
    );
    expect(body.contains('_dispatchOnInitialPlaybackCover('), isFalse);
  });

  test('点按仍与快捷键同规则：锁定时只亮锁按钮，不切工具栏', () {
    final body = bodyOf('void _onTap()');
    expect(body.contains('isToolbarsLocked'), isTrue);
    expect(body.contains('showLockButton'), isTrue);
  });
}
