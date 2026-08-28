import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_action.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_scope.dart';

void main() {
  group('初始播放封面放行名单', () {
    test('放行「播放/暂停」：这是唤起首次播放的唯一入口', () {
      expect(
        isShortcutAllowedOnInitialPlaybackCover(ShortcutAction.playPause),
        isTrue,
      );
    });

    test('放行「全屏切换」：只切换呈现方式，不依赖已打开的媒体', () {
      expect(
        isShortcutAllowedOnInitialPlaybackCover(
          ShortcutAction.toggleFullscreen,
        ),
        isTrue,
      );
    });

    test('拦下所有依赖播放器状态的动作（进度/音量/倍速）', () {
      const blocked = <ShortcutAction>[
        ShortcutAction.seekForward,
        ShortcutAction.seekBackward,
        ShortcutAction.volumeUp,
        ShortcutAction.volumeDown,
        ShortcutAction.toggleMute,
        ShortcutAction.speedUp,
        ShortcutAction.speedDown,
      ];
      for (final action in blocked) {
        expect(
          isShortcutAllowedOnInitialPlaybackCover(action),
          isFalse,
          reason: '$action 需要已打开的媒体，封面阶段不应放行',
        );
      }
    });

    test('名单精确等于「播放/暂停 + 全屏切换」', () {
      // 名单是键盘与鼠标两条入口共用的唯一真相；扩容必须是显式决定，
      // 并同步在 my_video_screen 的 _dispatchOnInitialPlaybackCover 里接线。
      expect(
        kShortcutActionsAllowedOnInitialPlaybackCover,
        equals(<ShortcutAction>{
          ShortcutAction.playPause,
          ShortcutAction.toggleFullscreen,
        }),
      );
    });

    test('名单只收视频域动作：全局/图库动作不会误入封面阶段', () {
      for (final action in kShortcutActionsAllowedOnInitialPlaybackCover) {
        expect(
          action.scope,
          ShortcutScope.video,
          reason: '$action 不是视频域动作，不该出现在播放器封面放行名单里',
        );
      }
    });
  });
}
