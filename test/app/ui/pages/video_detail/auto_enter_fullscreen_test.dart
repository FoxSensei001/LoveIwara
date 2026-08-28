import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';

/// 「自动进入全屏」——三档：关（默认）／播放时再进入／进入详情页便进入。
///
/// 这是一项**新增能力，默认关闭**，不是把现有行为改成全屏。用户说得很明确：
/// 「我们不打算默认打开，只是把这个能力加上」。所以下面第一条守的就是默认值本身。
///
/// 两档「开」的差别只在**听哪一声枪响**，排除条件（私密视频、PiP、全屏接力、
/// 只在 Initial Entry 进一次）两档完全共用——否则再加一档就要把这些判断抄第三遍。
void main() {
  group('默认关闭', () {
    test('配置默认值是 off（改这一行就等于改所有人的行为）', () {
      expect(
        ConfigKey.AUTO_ENTER_FULLSCREEN_MODE_KEY.defaultValue,
        'off',
        reason: '这是新增能力不是新默认行为；默认打开会让所有老用户的播放行为突然变样',
      );
      expect(
        autoFullscreenModeFromConfig(
          ConfigKey.AUTO_ENTER_FULLSCREEN_MODE_KEY.defaultValue,
        ),
        AutoFullscreenMode.off,
      );
    });

    test('认不出来的值一律退回关闭，绝不会意外把功能打开', () {
      for (final junk in [null, '', 'true', true, 1, '天知道']) {
        expect(
          autoFullscreenModeFromConfig(junk),
          AutoFullscreenMode.off,
          reason: '脏数据 $junk 不该把用户扔进全屏',
        );
      }
    });

    test('关着的时候，任何触发时机与任何输入组合都不进全屏', () {
      for (final trigger in AutoFullscreenTrigger.values) {
        for (final blocked in [false, true]) {
          for (final pip in [false, true]) {
            expect(
              MyVideoStateController.shouldAutoEnterFullscreen(
                mode: AutoFullscreenMode.off,
                trigger: trigger,
                alreadyEntered: false,
                isAnyFullscreenActive: false,
                isPiPMode: pip,
                hasFullscreenHandoff: false,
                isPlaybackBlocked: blocked,
                hasVideoInfo: true,
              ),
              isFalse,
            );
          }
        }
      }
    });

    test('关着的时候也不会把人从全屏里踢出来', () {
      expect(
        MyVideoStateController.shouldAutoExitFullscreenForBlockedPlayback(
          mode: AutoFullscreenMode.off,
          isAnyFullscreenActive: true,
          isPiPMode: false,
          isPlaybackBlocked: true,
        ),
        isFalse,
        reason: '错误处理是这项新能力自己的契约；关着时本功能不该改变任何既有行为',
      );
    });
  });

  bool enter({
    required AutoFullscreenMode mode,
    required AutoFullscreenTrigger trigger,
    bool alreadyEntered = false,
    bool isAnyFullscreenActive = false,
    bool isPiPMode = false,
    bool hasFullscreenHandoff = false,
    bool isPlaybackBlocked = false,
    bool hasVideoInfo = true,
  }) => MyVideoStateController.shouldAutoEnterFullscreen(
    mode: mode,
    trigger: trigger,
    alreadyEntered: alreadyEntered,
    isAnyFullscreenActive: isAnyFullscreenActive,
    isPiPMode: isPiPMode,
    hasFullscreenHandoff: hasFullscreenHandoff,
    isPlaybackBlocked: isPlaybackBlocked,
    hasVideoInfo: hasVideoInfo,
  );

  group('档位与时机是配对的', () {
    test('「播放时再进入」只认播放开始，不认页面就绪', () {
      expect(
        enter(
          mode: AutoFullscreenMode.onPlaybackStart,
          trigger: AutoFullscreenTrigger.playbackStarted,
        ),
        isTrue,
      );
      expect(
        enter(
          mode: AutoFullscreenMode.onPlaybackStart,
          trigger: AutoFullscreenTrigger.detailPageReady,
        ),
        isFalse,
        reason: '这一档的整个意义就是「等播放真的开始」',
      );
    });

    test('「进入详情页便进入」只认页面就绪，不认播放开始', () {
      expect(
        enter(
          mode: AutoFullscreenMode.onDetailPageEnter,
          trigger: AutoFullscreenTrigger.detailPageReady,
        ),
        isTrue,
      );
      expect(
        enter(
          mode: AutoFullscreenMode.onDetailPageEnter,
          trigger: AutoFullscreenTrigger.playbackStarted,
        ),
        isFalse,
        reason: '页面就绪时已经进过了；再认一次播放开始只会让判定重复触发',
      );
    });

    test('「进入详情页便进入」要等到知道这是个什么视频', () {
      expect(
        enter(
          mode: AutoFullscreenMode.onDetailPageEnter,
          trigger: AutoFullscreenTrigger.detailPageReady,
          hasVideoInfo: false,
        ),
        isFalse,
        reason: 'videoInfo 还没回来就进去，遇到私密视频得再退出来，白闪一下',
      );
    });
  });

  group('两档共用的排除条件', () {
    for (final (mode, trigger) in const [
      (AutoFullscreenMode.onPlaybackStart, AutoFullscreenTrigger.playbackStarted),
      (
        AutoFullscreenMode.onDetailPageEnter,
        AutoFullscreenTrigger.detailPageReady,
      ),
    ]) {
      group(mode.name, () {
        test('干净的首次进入 -> 进', () {
          expect(enter(mode: mode, trigger: trigger), isTrue);
        });

        test('只在 Initial Entry 进一次：从作者页退回来、暂停后再播都不再进', () {
          expect(
            enter(mode: mode, trigger: trigger, alreadyEntered: true),
            isFalse,
          );
        });

        test('已经在全屏里就不用再进（系统全屏、应用全屏都算）', () {
          expect(
            enter(mode: mode, trigger: trigger, isAnyFullscreenActive: true),
            isFalse,
          );
        });

        test('PiP 期间不自动进（边界 5）', () {
          expect(enter(mode: mode, trigger: trigger, isPiPMode: true), isFalse);
        });

        test('全屏接力在场时让位：那条路自己会强制全屏，两个执行者会打架', () {
          expect(
            enter(mode: mode, trigger: trigger, hasFullscreenHandoff: true),
            isFalse,
            reason: '从全屏播放列表抽屉点进来的新页面由 VideoFullscreenHandoff 负责全屏',
          );
        });

        test('私密/已删除、外站视频、源错误 -> 不进（全屏里只有一张错误页）', () {
          expect(
            enter(mode: mode, trigger: trigger, isPlaybackBlocked: true),
            isFalse,
          );
        });
      });
    }
  });

  group('播不了就退回详情页（两档都生效）', () {
    bool exit({
      required AutoFullscreenMode mode,
      bool isAnyFullscreenActive = true,
      bool isPiPMode = false,
      bool isPlaybackBlocked = true,
    }) => MyVideoStateController.shouldAutoExitFullscreenForBlockedPlayback(
      mode: mode,
      isAnyFullscreenActive: isAnyFullscreenActive,
      isPiPMode: isPiPMode,
      isPlaybackBlocked: isPlaybackBlocked,
    );

    for (final mode in const [
      AutoFullscreenMode.onPlaybackStart,
      AutoFullscreenMode.onDetailPageEnter,
    ]) {
      group(mode.name, () {
        test('在全屏里发现播不了 -> 退出来', () {
          expect(
            exit(mode: mode),
            isTrue,
            reason: '错误 UI 属于详情页，不该藏在一个什么都不播的全屏播放器后面',
          );
        });

        test('本来就不在全屏 -> 无事发生', () {
          expect(exit(mode: mode, isAnyFullscreenActive: false), isFalse);
        });

        test('PiP 期间不自动退（边界 5 的另一半）', () {
          expect(exit(mode: mode, isPiPMode: true), isFalse);
        });

        test('播得好好的就不要动人家的全屏', () {
          expect(exit(mode: mode, isPlaybackBlocked: false), isFalse);
        });
      });
    }
  });

  group('全屏类型：系统全屏 / 应用全屏', () {
    test('默认是系统全屏，与手动点全屏钮的行为一致', () {
      expect(
        ConfigKey.AUTO_ENTER_FULLSCREEN_KIND_KEY.defaultValue,
        'systemFullscreen',
      );
      expect(
        autoFullscreenKindFromConfig(
          ConfigKey.AUTO_ENTER_FULLSCREEN_KIND_KEY.defaultValue,
        ),
        AutoFullscreenKind.systemFullscreen,
      );
    });

    test('认不出来的值退回系统全屏', () {
      for (final junk in [null, '', true, 1, 'appFullScreen', '天知道']) {
        expect(
          autoFullscreenKindFromConfig(junk),
          AutoFullscreenKind.systemFullscreen,
          reason: '脏数据 $junk 不该把用户送进另一种全屏',
        );
      }
    });

    test('桌面端按用户选的来', () {
      for (final kind in AutoFullscreenKind.values) {
        expect(
          MyVideoStateController.resolveAutoFullscreenKind(
            configured: kind,
            isDesktop: true,
          ),
          kind,
        );
      }
    });

    test('移动端一律回落系统全屏——应用全屏是桌面独有的概念', () {
      expect(
        MyVideoStateController.resolveAutoFullscreenKind(
          configured: AutoFullscreenKind.appFullscreen,
          isDesktop: false,
        ),
        AutoFullscreenKind.systemFullscreen,
        reason: '不回落的话，手机上选了这一档就变成「设置开着但什么都不发生」',
      );
    });
  });

  group('机制闸门：两个触发时机各自挂对地方', () {
    late String source;

    setUpAll(() {
      source = File(
        'lib/app/ui/pages/video_detail/controllers/my_video_state_controller.dart',
      ).readAsStringSync();
    });

    /// 取 `player.stream.playing.listen(...)` 那段回调的正文。
    String playingListenerBody() {
      final start = source.indexOf('player.stream.playing.listen(');
      expect(start, greaterThan(-1), reason: '找不到播放状态订阅');
      final end = source.indexOf('\n    });', start);
      expect(end, greaterThan(start), reason: '播放状态订阅的正文没有正常结束');
      return source.substring(start, end);
    }

    test('playbackStarted 挂在播放状态流上，而不是某个按钮回调上', () {
      expect(
        playingListenerBody().contains(
          '_reconcileAutoFullscreen(AutoFullscreenTrigger.playbackStarted)',
        ),
        isTrue,
        reason:
            '「开始播放」有三条路：用户按播放、首次进入自动播放、延迟初始播放在媒体'
            '就绪后自己开播。挂在按钮回调上会漏掉自动播放那条——而那正是这项功能'
            '最主要的场景。',
      );
    });

    test('playbackStarted 只有这一个触发点', () {
      final calls =
          '_reconcileAutoFullscreen(AutoFullscreenTrigger.playbackStarted)'
              .allMatches(source)
              .length;
      expect(
        calls,
        1,
        reason: '出现 $calls 次：多一个触发点就多一条会漂移的路径',
      );
    });

    test('detailPageReady 挂在信息就位的监听上，且开局补一次', () {
      final start = source.indexOf('void _setupAutoFullscreenWatchers()');
      expect(start, greaterThan(-1));
      final body = source.substring(start, source.indexOf('\n  }', start));
      for (final rx in ['mainErrorWidget', 'videoSourceErrorMessage', 'videoInfo']) {
        expect(
          body.contains(rx),
          isTrue,
          reason: '$rx 没被监听：这一路的变化不会触发自动全屏判定',
        );
      }
      expect(
        body.contains('rxEver'),
        isTrue,
        reason: 'GetX 的 ever 走 stream，取消一次订阅后会永久失聪（见 rx_ever.dart）',
      );
      expect(
        body.contains(
          '_reconcileAutoFullscreen(AutoFullscreenTrigger.detailPageReady);',
        ),
        isTrue,
        reason:
            '信息可能在挂监听之前就已经就位（本地视频、initialVideoInfo 直接带进来），'
            '不补这一次，「进入详情页便进入全屏」这档会静默失效',
      );
    });

    test('进与退都只经过唯一决策入口的纯函数', () {
      final start = source.indexOf(
        'void _reconcileAutoFullscreen(AutoFullscreenTrigger trigger)',
      );
      expect(start, greaterThan(-1));
      final body = source.substring(start, source.indexOf('\n  }', start));
      expect(body.contains('shouldAutoEnterFullscreen('), isTrue);
      expect(
        body.contains('shouldAutoExitFullscreenForBlockedPlayback('),
        isTrue,
        reason: '判定散在回调里就没法单测，也没法保证进退两侧的判据对称',
      );
    });

    test('应用全屏的开关必须走控制器的收口方法，不许各处直接赋值', () {
      final offenders = <String>[];
      for (final file in Directory('lib').listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        // 控制器自己就是收口点，允许在里面赋值
        if (file.path.endsWith('my_video_state_controller.dart')) continue;
        final body = file
            .readAsStringSync()
            .split('\n')
            .map((line) {
              final idx = line.indexOf('//');
              return idx == -1 ? line : line.substring(0, idx);
            })
            .join('\n');
        if (RegExp(r'isDesktopAppFullScreen\.value\s*=').hasMatch(body)) {
          offenders.add(file.path);
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            '这些文件直接给 isDesktopAppFullScreen 赋值：$offenders\n'
            '这个标志和 hideSystemUI/showSystemUI 是成对的，手写两半迟早漏一半——'
            '漏掉过一次就是「窗口无法拖动、被锁死在视频分区」。'
            '请改用 enterDesktopAppFullscreen() / exitDesktopAppFullscreen()。',
      );
    });

    test('自动进应用全屏也只有唯一决策入口这一处', () {
      final calls = 'enterDesktopAppFullscreen();'.allMatches(source).length;
      expect(
        calls,
        1,
        reason: '控制器内出现 $calls 处自动进应用全屏调用：每多一处就绕开一次排除条件',
      );
    });

    test('enterFullscreen 的自动调用只有唯一决策入口这一处', () {
      final autoCalls = RegExp(
        r'unawaited\(enterFullscreen\(\)\)',
      ).allMatches(source).length;
      expect(
        autoCalls,
        1,
        reason:
            '出现 $autoCalls 处自动进全屏调用：每多一处就绕开一次上面那套排除条件'
            '（私密视频、PiP、全屏接力）',
      );
    });
  });
}
