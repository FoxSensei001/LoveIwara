import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/player_notice.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/mpv_playback_error_classifier.dart';

/// 这些用例锁的是 issue #110 的四条硬约束：任何日志都不该阻塞播放、
/// 提示只有一个槽、风暴打不垮 UI、播放面不可见时提示不能白白烧掉停留时间。
void main() {
  late PlayerNoticeCenter center;
  late Duration position;
  late bool suppressed;

  /// 26 进制字母后缀，刻意不用数字：signatureOf 会把 -?\d+ 归一成 <n>，
  /// 用数字做后缀会让几百条日志塌成同一个签名，测不出「不同签名」。
  String token(int index) {
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    return '${letters[(index ~/ 26) % 26]}${letters[index % 26]}';
  }

  /// vd 前缀 + "could not open codec" -> degraded / videoDecodeProblem
  void reportDecode(String variant) => center.reportLog(
    prefix: 'vd',
    level: 'error',
    text: 'could not open codec $variant',
  );

  /// ad 前缀且不含 "error decoding audio" -> degraded / audioUnavailable
  void reportAudio(String variant) => center.reportLog(
    prefix: 'ad',
    level: 'error',
    text: 'audio device lost $variant',
  );

  /// issue #110 的原始噪声：mpv 主动关连接时 FFmpeg 的兜底返回码。
  void reportBenignTcp() => center.reportLog(
    prefix: 'ffmpeg',
    level: 'error',
    text: 'tcp: ffurl_write returned 0xffffd8ba',
  );

  setUpAll(() async {
    // 静默级分支会调用 LogUtils.d，需先初始化其 late logger。
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  setUp(() {
    position = const Duration(seconds: 12);
    suppressed = false;
    center = PlayerNoticeCenter(
      tag: 'PlayerNoticeTest',
      currentPosition: () => position,
      isSuppressed: () => suppressed,
    );
  });

  tearDown(() {
    center.dispose();
  });

  group('PlayerNotice 相等性', () {
    test('detail 不参与比较，重复提示对 Rx 是同一个值', () {
      const a = PlayerNotice(
        kind: PlayerNoticeKind.networkUnstable,
        level: PlayerNoticeLevel.info,
        detail: 'tcp: ffurl_write returned 0xffffd8ba',
      );
      const b = PlayerNotice(
        kind: PlayerNoticeKind.networkUnstable,
        level: PlayerNoticeLevel.info,
        detail: 'tcp: ffurl_read returned 0xffffd8bb',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(
        a,
        isNot(
          equals(
            const PlayerNotice(
              kind: PlayerNoticeKind.networkUnstable,
              level: PlayerNoticeLevel.warning,
            ),
          ),
        ),
      );
    });
  });

  group('静默级', () {
    test('无论刷多少条都不写 notice.value，也不进可见问题列表', () {
      for (var i = 0; i < 20; i++) {
        reportBenignTcp();
      }
      expect(center.notice.value, isNull);
      expect(center.notableIssues, isEmpty);
    });

    test('静默级仍然进台账，靠 occurrences 事后可查', () {
      reportBenignTcp();
      reportBenignTcp();
      reportDecode('aa');
      // notableIssues 排除静默级，所以只看得到解码那条。
      expect(center.notableIssues, hasLength(1));
      expect(center.notableIssues.single.kind, PlaybackErrorKind.videoDecodeProblem);
    });
  });

  group('升级为 repeatedProblems', () {
    test('60 秒内 3 个不同签名会升级', () async {
      reportDecode('aa'); // 首条直接发出
      reportDecode('ab'); // 窗口=2，被 2 秒下限挡住但仍计入窗口
      await Future.delayed(const Duration(milliseconds: 2100));
      reportDecode('ac'); // 窗口=3，越过阈值

      expect(center.notice.value?.kind, PlayerNoticeKind.repeatedProblems);
      expect(center.notice.value?.level, PlayerNoticeLevel.warning);
    });

    test('同一个签名重复 3 次不升级', () async {
      reportDecode('aa');
      reportDecode('aa');
      await Future.delayed(const Duration(milliseconds: 2100));
      reportDecode('aa');

      // 30 秒同签名冷却把后两条挡在窗口外，窗口里始终只有 1 个签名。
      expect(center.notice.value?.kind, PlayerNoticeKind.videoDecodeProblem);
      expect(center.notableIssues.single.occurrences, 3);
    });
  });

  group('台账', () {
    test('永不超过 50 条，重复只累加 occurrences', () {
      for (var i = 0; i < 60; i++) {
        reportDecode(token(i));
        expect(center.notableIssues.length, lessThanOrEqualTo(50));
      }
      expect(center.notableIssues, hasLength(50));

      // 最早的签名已被 LRU 淘汰
      expect(
        center.notableIssues.any((e) => e.signature.endsWith('codec ${token(0)}')),
        isFalse,
      );
      // 最新的排在最前
      expect(center.notableIssues.first.signature.endsWith('codec ${token(59)}'), isTrue);

      for (var i = 0; i < 4; i++) {
        reportDecode(token(59));
      }
      expect(center.notableIssues, hasLength(50));
      expect(center.notableIssues.first.occurrences, 5);
      expect(center.notableIssues.first.positionAtFirst, const Duration(seconds: 12));
    });
  });

  group('生命周期', () {
    test('onPlaybackAdvanced 清空窗口并收起提示', () async {
      reportDecode('aa');
      reportDecode('ab'); // 窗口=2
      await Future.delayed(const Duration(milliseconds: 2100));
      expect(center.notice.value, isNotNull);

      center.onPlaybackAdvanced();
      expect(center.notice.value, isNull);

      // 窗口被清空，这条只是窗口里的第 1 个签名，不该升级。
      reportDecode('ac');
      expect(center.notice.value?.kind, PlayerNoticeKind.videoDecodeProblem);
    });

    test('reset 清空台账、提示与发射下限', () {
      reportBenignTcp();
      reportDecode('aa');
      expect(center.notableIssues, isNotEmpty);
      expect(center.notice.value, isNotNull);

      center.reset();
      expect(center.notableIssues, isEmpty);
      expect(center.notice.value, isNull);

      // 下限也一并归零：新一轮播放的第一条提示不该被上一轮的时间戳压住。
      reportAudio('aa');
      expect(center.notice.value?.kind, PlayerNoticeKind.audioUnavailable);
    });
  });

  group('风暴防护', () {
    test('500 条不同签名下 2 秒发射下限依然成立', () {
      reportDecode('aa');
      expect(center.notice.value?.kind, PlayerNoticeKind.videoDecodeProblem);

      for (var i = 1; i < 500; i++) {
        reportAudio(token(i));
      }

      // 下限若失效，槽位会被 audioUnavailable 或 repeatedProblems 冲掉。
      expect(center.notice.value?.kind, PlayerNoticeKind.videoDecodeProblem);
      expect(center.notableIssues, hasLength(50));
    });

    test('isSuppressed 为真时不发提示，但台账照记', () {
      suppressed = true;
      reportDecode('aa');
      expect(center.notice.value, isNull);
      expect(center.notableIssues, hasLength(1));
    });
  });

  group('播放面可见性门控', () {
    test('不可见时提示被挂起而不是丢失，恢复可见后补发', () async {
      center.setSurfaceAvailable(false);
      reportDecode('aa');
      expect(center.notice.value, isNull);

      // 挂起期间不启动停留计时，等再久也不会被超时吞掉。
      await Future.delayed(const Duration(milliseconds: 120));
      expect(center.notice.value, isNull);

      center.setSurfaceAvailable(true);
      expect(center.notice.value?.kind, PlayerNoticeKind.videoDecodeProblem);
    });

    test('恢复可见时没有挂起项则不凭空造提示', () {
      center.setSurfaceAvailable(false);
      center.setSurfaceAvailable(true);
      expect(center.notice.value, isNull);
    });
  });
}
