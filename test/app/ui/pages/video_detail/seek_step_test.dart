import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';

Duration _step(
  Duration current, {
  required bool forward,
  Duration total = const Duration(seconds: 100),
  int stepSeconds = 10,
}) => MyVideoStateController.resolveSeekStepTarget(
  current: current,
  total: total,
  stepSeconds: stepSeconds,
  forward: forward,
);

void main() {
  group('快进 / 快退一步的目标位置', () {
    test('正常前进一步', () {
      expect(_step(const Duration(seconds: 30), forward: true),
          const Duration(seconds: 40));
    });

    test('正常后退一步', () {
      expect(_step(const Duration(seconds: 30), forward: false),
          const Duration(seconds: 20));
    });

    test('前进越界钉到片尾', () {
      expect(_step(const Duration(seconds: 95), forward: true),
          const Duration(seconds: 100));
    });

    test('后退越界钉到零', () {
      expect(_step(const Duration(seconds: 5), forward: false), Duration.zero);
    });

    test('恰好落在零点也算越界（保持历史的严格大于语义）', () {
      expect(_step(const Duration(seconds: 10), forward: false), Duration.zero);
    });

    test('时长未知（0）时前进不会跑到负数或随机位置', () {
      expect(
        _step(const Duration(seconds: 30), forward: true, total: Duration.zero),
        Duration.zero,
      );
    });
  });

  group('连按累加', () {
    test('连按三次快进 = 三步，不是一步', () {
      // 复刻真实调用链：每一次都拿「上一次跳转后的位置」当基准。
      // handleSeek 是同步推进 currentPosition 的，所以这正是运行时的行为。
      var pos = const Duration(seconds: 0);
      for (var i = 0; i < 3; i++) {
        pos = _step(pos, forward: true);
      }
      expect(
        pos,
        const Duration(seconds: 30),
        reason: '连按不累加曾是真实缺陷：动画闸门把第 2、3 次的跳转一起吞了',
      );
    });

    test('连按到片尾后不再前进', () {
      var pos = const Duration(seconds: 0);
      for (var i = 0; i < 50; i++) {
        pos = _step(pos, forward: true);
      }
      expect(pos, const Duration(seconds: 100));
    });
  });

  group('闸门：动画节流不得挡住跳转', () {
    late String source;

    setUpAll(() {
      source = File(
        'lib/app/ui/pages/video_detail/widgets/player/my_video_screen.dart',
      ).readAsStringSync();
    });

    /// 取出某个方法的正文，**并剥掉注释**。
    ///
    /// 扫源码的闸门必须只看代码：第一版没剥注释，结果被正文里一句解释性的
    /// 注释误判成「跳转显式要求了开播」，闸门自己先假阳了。
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

    test('波纹动画函数里不许出现 handleSeek', () {
      // 这就是原缺陷的形状：「动画还在放就 return」的闸门写在跳转之前，
      // 于是约 1 秒的动画窗口把跳转一起吞掉。跳转必须待在闸门之外。
      final ripple = bodyOf('void _playSeekRipple(');
      expect(
        ripple.contains('handleSeek'),
        isFalse,
        reason: '跳转被挪回了动画节流函数里——连按会再次被吞',
      );
      expect(
        ripple.contains('RippleActive'),
        isTrue,
        reason: '动画节流闸门应当留在这里',
      );
    });

    test('跳转函数里不许出现动画节流闸门', () {
      final seek = bodyOf('void _seekByConfiguredStep(');
      expect(
        seek.contains('handleSeek'),
        isTrue,
        reason: '跳转函数应当真的发起跳转',
      );
      expect(
        seek.contains('RippleActive'),
        isFalse,
        reason: '动画状态不该参与跳转与否的判断',
      );
    });

    test('跳转不得默认唤起播放（暂停态微调进度不该开播）', () {
      final seek = bodyOf('void _seekByConfiguredStep(');
      expect(
        seek.contains('startPlayback'),
        isFalse,
        reason: '快进/快退走默认的「保持暂停态」，不该显式要求开播',
      );
    });
  });
}
