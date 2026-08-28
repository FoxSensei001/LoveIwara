import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';

/// 「加载转圈时按空格不但没暂停，转圈反而重头再来」的回归测试。
///
/// 真机复现路径：设置里关掉「首次进入自动播放」→ 打开视频 → 在封面上点播放 →
/// 停在「正在添加监听器…」的转圈上 → 再按一次空格。
///
/// 两个成因叠在一起：
/// 1. 六处「播放/暂停」开关各自手写 `if (videoPlaying) 暂停 else 播放`，
///    而加载阶段 videoPlaying 还是 false —— 于是这一下被理解成「再请求一次播放」；
/// 2. `resetVideoInfo` 返回后 videoPlayerReady 仍是 false（要等 height 流回调
///    才置位），此时 `_isStartingDeferredInitialPlayback` 已经释放，所以那次
///    「再请求播放」会对同一个地址第二次 player.open，转圈从头再来。
void main() {
  PlayPauseIntent resolve({
    bool playing = false,
    bool pending = false,
    bool waitingOnCover = false,
  }) => MyVideoStateController.resolvePlayPauseIntent(
    videoPlaying: playing,
    isPlaybackPending: pending,
    isWaitingForInitialPlaybackStart: waitingOnCover,
  );

  group('方向判定', () {
    test('停着且没有待启动的播放 -> 播放', () {
      expect(resolve(), PlayPauseIntent.play);
    });

    test('正在播 -> 暂停', () {
      expect(resolve(playing: true), PlayPauseIntent.pause);
    });

    test('还没开始播、但播放已经在路上 -> 也是「停」，不是再请求一次播放', () {
      expect(resolve(pending: true), PlayPauseIntent.pause);
    });

    test('封面上已点过播放、正在转圈 -> 取消（还要把封面退回可点播放）', () {
      expect(
        resolve(pending: true, waitingOnCover: true),
        PlayPauseIntent.cancelPendingInitialPlayback,
      );
    });

    test('正在播时即便还挂着封面标记，也只是普通暂停', () {
      expect(
        resolve(playing: true, waitingOnCover: false),
        PlayPauseIntent.pause,
      );
    });

    test('取消之后再按一次 -> 回到播放（pending 已被暂停意图清掉）', () {
      expect(resolve(waitingOnCover: true), PlayPauseIntent.play);
    });
  });

  group('闸门：不许再有人手写这个开关', () {
    test('lib 下没有第二处 `videoPlaying ? pausePlayback : playFromUserAction`', () {
      final offenders = <String>[];
      final files = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          // 控制器自己就是那个收口点。
          .where((f) => !f.path.endsWith('my_video_state_controller.dart'));
      for (final file in files) {
        final src = file.readAsStringSync();
        var idx = src.indexOf('pausePlayback()');
        while (idx != -1) {
          final window = src.substring(
            (idx - 260).clamp(0, src.length),
            (idx + 260).clamp(0, src.length),
          );
          if (window.contains('playFromUserAction()')) {
            offenders.add(file.path);
            break;
          }
          idx = src.indexOf('pausePlayback()', idx + 1);
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            '这些文件又在自己判断播放/暂停方向: $offenders\n'
            '请改调 MyVideoStateController.togglePlayback() —— 只看 videoPlaying '
            '会在加载阶段把「停」误判成「播」，那正是转圈停不下来的成因。',
      );
    });

    test('封面上的首次播放请求必须经过 togglePlayback，不能直接再请求一次', () {
      final src = File(
        'lib/app/ui/pages/video_detail/widgets/player/my_video_screen.dart',
      ).readAsStringSync();
      final start = src.indexOf('void _dispatchOnInitialPlaybackCover(');
      expect(start, greaterThan(-1));
      final body = src
          .substring(start, src.indexOf('\n  }', start))
          .split('\n')
          .map((l) {
            final i = l.indexOf('//');
            return i == -1 ? l : l.substring(0, i);
          })
          .join('\n');
      expect(body.contains('togglePlayback('), isTrue);
      expect(
        body.contains('requestInitialPlayback('),
        isFalse,
        reason: '直接请求首次播放＝加载中再按一次会重开同一个地址',
      );
    });
  });
}
