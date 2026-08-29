import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 「接着看」入口的收口闸门。
///
/// # ⛔ 为什么会有这个文件
///
/// 视频详情页里 `MyVideoScreen` 原本有 6 个构造点（PiP / 全屏叠加层 / 宽屏 /
/// 窄屏 / 纯播放器 / 播放器内容），视频池那两个参数只有全屏与 PiP 两处传了，
/// 于是「接着看」的贴边把手**只在全屏才出现**——而池是页面的属性，跟内嵌还是
/// 全屏毫无关系。这类"一处一处传"的缺陷只会再犯，所以下发口收成
/// `_buildPlayerScreen` 一个，并在这里钉死。
void main() {
  test('⛔ 视频详情页只能有一个 MyVideoScreen 构造点（否则视频池参数必漏）', () {
    final source = File(
      'lib/app/ui/pages/video_detail/video_detail_page_v2.dart',
    ).readAsStringSync();

    final count = 'MyVideoScreen('.allMatches(source).length;
    expect(
      count,
      1,
      reason:
          '视频详情页里出现了 $count 处 MyVideoScreen(...)。新增播放器请走 '
          '_buildPlayerScreen()——它是 hasPlaybackQueue / onOpenQueueDrawer 的\n'
          '唯一下发口，绕过去就会重演「接着看把手只在全屏出现」。',
    );

    expect(
      source,
      contains('Widget _buildPlayerScreen('),
      reason: '唯一构造点应当是 _buildPlayerScreen()。',
    );
    for (final param in [
      'hasPlaybackQueue: _hasPlaybackQueue',
      'onOpenQueueDrawer: _openQueueDrawer',
    ]) {
      expect(
        param.allMatches(source).length,
        1,
        reason: '$param 应当只在 _buildPlayerScreen() 里出现一次。',
      );
    }
  });
}
