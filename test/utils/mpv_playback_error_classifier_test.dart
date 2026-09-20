import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/utils/mpv_playback_error_classifier.dart';

/// 这些样本全部取自 mpv / FFmpeg 的实际格式串，
/// 目的是锁住 issue #110 的修复：
/// 1. 正常关连接的网络日志必须静默；
/// 2. `vd` 和 `ad` 的同一句文案必须分流（现网 bug 就是这里混了）；
/// 3. 不变量 I1——任何输入都不可能产生 silent/transient/degraded 之外的档位。
void main() {
  PlaybackErrorSignal? classify(String prefix, String level, String text) =>
      MpvPlaybackErrorClassifier.classifyLog(
        prefix: prefix,
        level: level,
        text: text,
      );

  /// 表驱动样例：期望为 null 表示这条日志根本不该被分类
  ({
    String prefix,
    String level,
    String text,
    PlaybackErrorTier? tier,
    PlaybackErrorKind? kind,
  })
  row(
    String prefix,
    String level,
    String text, [
    PlaybackErrorTier? tier,
    PlaybackErrorKind? kind,
  ]) => (prefix: prefix, level: level, text: text, tier: tier, kind: kind);

  final table = [
    // ── issue #110：mpv 主动关连接时 FFmpeg 打的返回码，播放从未中断 ──
    row(
      'ffmpeg/network',
      'error',
      'tcp: ffurl_write returned 0xffffd8ba',
      PlaybackErrorTier.silent,
      PlaybackErrorKind.networkReconnect,
    ),
    row(
      'ffmpeg/network',
      'error',
      'tcp: ffurl_read returned 0xdfb9b0bb',
      PlaybackErrorTier.silent,
      PlaybackErrorKind.networkReconnect,
    ),
    // 没有 ffmpeg 前缀、只靠正文以 "tcp:" 开头也要能认出来
    row(
      '',
      'error',
      'tcp: ffurl_write returned 0xffffd8ba',
      PlaybackErrorTier.silent,
      PlaybackErrorKind.networkReconnect,
    ),
    row(
      'ffmpeg/demuxer',
      'error',
      'https: Cannot read from the resource.',
      PlaybackErrorTier.transient,
      PlaybackErrorKind.networkUnreachable,
    ),

    // ── vd / ad 同文案分流：这就是 prefix-aware 存在的理由 ──
    row(
      'vd',
      'error',
      'Could not open codec.',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.videoDecodeProblem,
    ),
    row(
      'ad',
      'error',
      'Could not open codec.',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.audioUnavailable,
    ),
    row(
      'vd',
      'error',
      'Could not find decoder for codec "hevc".',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.videoDecodeProblem,
    ),
    row(
      'vd',
      'error',
      'Error while decoding frame!',
      PlaybackErrorTier.silent,
      PlaybackErrorKind.decodeGlitch,
    ),
    row(
      'vd/lavc',
      'error',
      'Falling back to software decoding.',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.hardwareDecodeFallback,
    ),
    row(
      'vd',
      'error',
      'Hardware decoding failed for codec h264.',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.hardwareDecodeFallback,
    ),
    row(
      'ad',
      'error',
      'Error decoding audio.',
      PlaybackErrorTier.silent,
      PlaybackErrorKind.decodeGlitch,
    ),
    row(
      'ad/lavc',
      'error',
      'Requested audio codec family unavailable.',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.audioUnavailable,
    ),

    // ── 其它 mpv 模块 ──
    row(
      'file',
      'error',
      'Read error.',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.unknown,
    ),
    // stream 是通用流层（本地文件也从它走），正文不带网络味道就不归因到网络
    row(
      'stream',
      'error',
      'Failed to recreate cache!',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.unknown,
    ),
    row(
      'stream',
      'error',
      'Failed to connect to cdn1.iwara.tv:443',
      PlaybackErrorTier.transient,
      PlaybackErrorKind.networkUnreachable,
    ),
    // ★ 真机取样（安卓平板，2026-09-20）：**每一次** player.open 都会吐这两条，
    // 在线和本地一模一样。`ffmpeg/video` 那条原先被无条件判成网络不可达，
    // 就是「点开本地视频也弹请检查网络」的真凶。
    row(
      'ffmpeg/video',
      'error',
      'h264_mediacodec: Both surface and native_window are NULL',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.unknown,
    ),
    row(
      'lavf',
      'error',
      'Failed to create file cache.',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.unknown,
    ),
    // 真机断网取样（同日）：DNS 挂了才是该说网络的那一条，它照常归因
    row(
      'ffmpeg',
      'error',
      'tcp: Failed to resolve hostname aiko.iwara.tv: No address associated with hostname',
      PlaybackErrorTier.transient,
      PlaybackErrorKind.networkUnreachable,
    ),
    // 同一次断网里 ffmpeg 还吐了这两条：它们在本地文件上也会出现（截断的 mp4、
    // 坏索引），语义是「文件读不下去」而不是「网络断了」，不归因。
    row(
      'ffmpeg',
      'error',
      'Seek failed (to 1591020, size 234090325)',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.unknown,
    ),
    row(
      'ffmpeg/demuxer',
      'error',
      'mov,mp4,m4a,3gp,3g2,mj2: stream 0, offset 0x1846ec: partial file',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.unknown,
    ),
    // ffmpeg 层的非网络报错不许换成「请检查网络」——放本地文件时最常撞上
    row(
      'ffmpeg/demuxer',
      'error',
      'Could not find codec parameters for stream 0',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.unknown,
    ),
    row(
      'ffmpeg/mov,mp4,m4a,3gp,3g2,mj2',
      'error',
      'moov atom not found',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.unknown,
    ),

    // ── cplayer ──
    row(
      'cplayer',
      'error',
      'Errors when loading file https://files.iwara.tv/a/1.mp4.',
      PlaybackErrorTier.silent,
      PlaybackErrorKind.duplicateSummary,
    ),
    row(
      'cplayer',
      'error',
      'Can not open external file https://files.iwara.tv/subs/1.vtt.',
      PlaybackErrorTier.silent,
      PlaybackErrorKind.auxFileSkipped,
    ),
    row(
      'cplayer',
      'error',
      'Audio device got removed, trying to reload audio chain',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.audioUnavailable,
    ),
    row(
      'cplayer',
      'error',
      'No sound is being played.',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.audioUnavailable,
    ),
    row(
      'cplayer',
      'error',
      'Failed to open https://files.iwara.tv/a/1.mp4.',
      PlaybackErrorTier.transient,
      PlaybackErrorKind.openFailed,
    ),

    // ── 未匹配的模块一律降级但不致命 ──
    row(
      'vo/gpu',
      'error',
      'Could not create window for hwdec interop',
      PlaybackErrorTier.degraded,
      PlaybackErrorKind.unknown,
    ),

    // ── 级别过滤：只有 error / fatal 才进入分类 ──
    row('cplayer', 'info', 'Could not open codec.'),
    row('vd', 'warn', 'Could not open codec.'),
    row('ffmpeg/network', 'v', 'tcp: ffurl_write returned 0xffffd8ba'),
    row('ad', 'debug', 'Could not open codec.'),
    row('cplayer', 'trace', 'Failed to open file.'),
  ];

  group('表驱动分类', () {
    for (final c in table) {
      final expectation = c.tier == null ? 'null（不分类）' : '${c.tier}/${c.kind}';
      test('[${c.prefix}][${c.level}] ${c.text} -> $expectation', () {
        final signal = classify(c.prefix, c.level, c.text);
        if (c.tier == null) {
          expect(signal, isNull);
          return;
        }
        expect(signal, isNotNull);
        expect(signal!.tier, c.tier);
        expect(signal.kind, c.kind);
        // 原始文案必须原样保留，供 ledger / 详情面板回溯
        expect(signal.raw, c.text);
      });
    }
  });

  group('issue #110 回归', () {
    test('ffurl_write / ffurl_read 的返回码只是关连接，绝不提示', () {
      for (final code in ['0xffffd8ba', '0xffffd8bb', '-10054']) {
        final signal = classify(
          'ffmpeg/network',
          'error',
          'tcp: ffurl_write returned $code',
        );
        expect(signal!.tier, PlaybackErrorTier.silent);
        expect(signal.kind, PlaybackErrorKind.networkReconnect);
      }
    });

    test('fatal 级别、大小写与空白同样处理', () {
      final signal = classify(
        ' FFMPEG/Network ',
        ' FATAL ',
        'TCP: ffurl_read RETURNED 0xdfb9b0bb',
      );
      expect(signal!.tier, PlaybackErrorTier.silent);
      expect(signal.kind, PlaybackErrorKind.networkReconnect);
    });
  });

  group('只有确实带网络味道的日志才说网络', () {
    test('ffmpeg / stream 前缀不再无条件归因到网络', () {
      for (final prefix in ['ffmpeg', 'ffmpeg/demuxer', 'stream']) {
        final signal = classify(prefix, 'error', 'Failed to recreate cache!')!;
        expect(
          signal.kind,
          isNot(PlaybackErrorKind.networkUnreachable),
          reason: '[$prefix] 放本地文件时这句会变成「请检查网络」',
        );
      }
    });

    test('协议前缀 / 连接措辞仍然认得出来', () {
      final byProtocol = classify(
        'ffmpeg/demuxer',
        'error',
        'https: Cannot read from the resource.',
      )!;
      final byPhrase = classify('stream', 'error', 'Connection timed out')!;
      final byModule = classify(
        'ffmpeg/network',
        'error',
        'Some unrecognized network failure',
      )!;
      for (final signal in [byProtocol, byPhrase, byModule]) {
        expect(signal.kind, PlaybackErrorKind.networkUnreachable);
        expect(signal.tier, PlaybackErrorTier.transient);
      }
    });
  });

  group('vd / ad 必须分流', () {
    test('同一句 "Could not open codec." 在两个前缀下结论不同', () {
      final video = classify('vd', 'error', 'Could not open codec.')!;
      final audio = classify('ad', 'error', 'Could not open codec.')!;
      // 现网 bug：media_kit 抹掉 prefix 后，音频解码失败也去劝用户换视频解码器
      expect(video.kind, isNot(audio.kind));
      expect(video.kind, PlaybackErrorKind.videoDecodeProblem);
      expect(audio.kind, PlaybackErrorKind.audioUnavailable);
    });
  });

  group('cplayer 外挂文件', () {
    test('"Can not open external file" 静默，不被裸 "can not open" 规则吃掉', () {
      final aux = classify(
        'cplayer',
        'error',
        'Can not open external file https://files.iwara.tv/subs/1.vtt.',
      )!;
      expect(aux.tier, PlaybackErrorTier.silent);
      expect(aux.kind, PlaybackErrorKind.auxFileSkipped);

      // 对照组：同样以 "Can not open" 开头，但不是外挂文件，结论必须不同
      final other = classify(
        'cplayer',
        'error',
        'Can not open audio device alsa/default.',
      )!;
      expect(other.kind, isNot(PlaybackErrorKind.auxFileSkipped));
    });
  });

  group('不变量 I1：不存在 fatal 档', () {
    test('枚举本身就只有三档', () {
      expect(PlaybackErrorTier.values.toSet(), {
        PlaybackErrorTier.silent,
        PlaybackErrorTier.transient,
        PlaybackErrorTier.degraded,
      });
      expect(PlaybackErrorTier.values.length, 3);
      expect(
        PlaybackErrorTier.values.map((e) => e.name),
        isNot(contains('fatal')),
      );
    });

    test('任意前缀 × 任意级别的真实语料都落在三档之内', () {
      const prefixes = [
        '',
        'ffmpeg',
        'ffmpeg/network',
        'ffmpeg/demuxer',
        'vd',
        'vd/lavc',
        'ad',
        'ad/lavc',
        'file',
        'stream',
        'cplayer',
        'vo/gpu',
        'libmpv_render',
        'demux',
        'auto_profiles',
      ];
      const levels = ['error', 'fatal', 'warn', 'info', 'v', 'debug', 'trace'];
      const corpus = [
        'tcp: ffurl_write returned 0xffffd8ba',
        'tcp: ffurl_read returned 0xdfb9b0bb',
        'https: Cannot read from the resource.',
        'Could not open codec.',
        'Could not find decoder for codec "av1".',
        'Error while decoding frame!',
        'Falling back to software decoding.',
        'Hardware decoding failed for codec h264.',
        'Error decoding audio.',
        'Requested audio codec family unavailable.',
        'Read error.',
        'Failed to recreate cache!',
        'Errors when loading file https://files.iwara.tv/a/1.mp4.',
        'Can not open external file https://files.iwara.tv/subs/1.vtt.',
        'Audio device got removed, trying to reload audio chain',
        'No sound is being played.',
        'Failed to open https://files.iwara.tv/a/1.mp4.',
        'Could not create window for hwdec interop',
        'after creating texture: OpenGL error OUT_OF_MEMORY.',
        'Failed to open https://files.iwara.tv:8443/a/1.mp4: -10054',
        '',
      ];

      const allowed = {
        PlaybackErrorTier.silent,
        PlaybackErrorTier.transient,
        PlaybackErrorTier.degraded,
      };

      for (final prefix in prefixes) {
        for (final level in levels) {
          for (final text in corpus) {
            final signal = classify(prefix, level, text);
            if (signal == null) {
              // 只有非 error/fatal 才允许返回 null
              expect(
                ['error', 'fatal'].contains(level),
                isFalse,
                reason: '[$prefix][$level] $text 不该被丢弃',
              );
              continue;
            }
            expect(
              allowed.contains(signal.tier),
              isTrue,
              reason: '[$prefix][$level] $text 产生了越界档位 ${signal.tier}',
            );
            expect(signal.signature, isNotEmpty);
          }
        }
      }
    });
  });

  group('signatureOf 归一化', () {
    String sig(String prefix, String text) =>
        MpvPlaybackErrorClassifier.signatureOf(prefix, text);

    test('十六进制与十进制错误码塌缩成同一个 key', () {
      // 0xffffd8ba 就是 -10054 的另一种写法，分成两个 key 会顶穿风暴抑制
      final a = sig('ffmpeg/network', 'tcp: ffurl_write returned 0xffffd8ba');
      final b = sig('ffmpeg/network', 'tcp: ffurl_write returned 0xffffd8bb');
      final c = sig('ffmpeg/network', 'tcp: ffurl_write returned -10054');
      expect(a, b);
      expect(a, c);
    });

    test('不同 URL 塌缩成同一个 key', () {
      final a = sig(
        'cplayer',
        'Failed to open https://files.iwara.tv/a/aaaa1111.mp4.',
      );
      final b = sig(
        'cplayer',
        'Failed to open https://cdn.iwara.tv/b/bbbb2222.mp4.',
      );
      expect(a, b);
    });

    test('前缀参与 key，且大小写/空白不敏感', () {
      expect(
        sig(' VD ', 'Could not open codec.'),
        sig('vd', 'COULD NOT OPEN CODEC.'),
      );
      // 同一句话在 vd / ad 下必须是两个 key，否则两种故障会互相压制
      expect(
        sig('vd', 'Could not open codec.'),
        isNot(sig('ad', 'Could not open codec.')),
      );
    });

    test('host:port 归一', () {
      expect(
        sig('stream', 'Failed to connect to cdn1.iwara.tv:8443'),
        sig('stream', 'Failed to connect to cdn2.iwara.tv:443'),
      );
    });

    test('classifyLog 产出的 signature 与 signatureOf 一致', () {
      final signal = classify(
        'ffmpeg/network',
        'error',
        'tcp: ffurl_write returned 0xffffd8ba',
      )!;
      expect(
        signal.signature,
        sig('ffmpeg/network', 'tcp: ffurl_write returned 0xffffd8ba'),
      );
    });
  });
}
