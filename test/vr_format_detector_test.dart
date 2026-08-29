import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/app/utils/vr_format_detector.dart';

/// XR 片源格式检测器的闸门。
///
/// 下面这些用例全部来自 1125 条真实 Iwara 视频里挑出来的真样本，**期望值不许
/// 改**——它们守着两条命根子：
///
///   1. 文本永远不能单独判决：宽高比 ≈16:9 时哪怕标题喊 VR 也否决成平面
///      （作者同时发了平面版和 VR 版，这个文件是平面版）。
///   2. 否定词 ≠ 正向词：`VRアリ` 是「另有 VR 版」= 平面；`VR Version` 是正向。
void main() {
  /// 一趟走完两阶段：文本怀疑 → 宽高比判决。
  VrFormatVerdict? run({
    String? title,
    String? body,
    List<String>? tags,
    int? width,
    int? height,
  }) {
    final suspicion = VrFormatDetector.suspectFromMetadata(
      title: title,
      body: body,
      tags: tags,
    );
    return VrFormatDetector.decideWithDimensions(
      suspicion,
      width: width,
      height: height,
    );
  }

  group('阶段B 宽高比否决文本', () {
    test('【VR180】但 1920x1080：宽高比把文本否决成平面', () {
      final verdict = run(
        title: '【VR180】Various Characters2【NIKKE】',
        tags: ['vr', 'vr180'],
        width: 1920,
        height: 1080,
      )!;
      expect(verdict.format, VrSourceFormat.flatMono);
      expect(verdict.isVr, isFalse);
    });

    test('普通 MMD + 1920x1080 + 无 VR 标签：平面', () {
      final verdict = run(
        title: '【MMD】恋愛サーキュレーション',
        tags: ['mmd'],
        width: 1920,
        height: 1080,
      )!;
      expect(verdict.format, VrSourceFormat.flatMono);
    });
  });

  group('否定词表', () {
    test('【VRアリ】+ 1920x1080：否定词 → 平面', () {
      final suspicion = VrFormatDetector.suspectFromMetadata(
        title: '【VRアリ】おかず詰め合わせ vol.2【MMD/R18】',
      );
      expect(suspicion.negated, isTrue);
      expect(suspicion.suspected, isFalse);

      final verdict = VrFormatDetector.decideWithDimensions(
        suspicion,
        width: 1920,
        height: 1080,
      )!;
      expect(verdict.format, VrSourceFormat.flatMono);
    });

    test('VR Version 不是否定词：正向信号', () {
      final suspicion = VrFormatDetector.suspectFromMetadata(
        title: 'Good Place (180° VR Version)',
      );
      expect(suspicion.negated, isFalse);
      expect(suspicion.suspected, isTrue);
    });
  });

  group('阶段B 宽高比坐实 VR', () {
    test('180° VR Version + 1920x960 → equirect180 + sideBySide', () {
      final verdict = run(
        title: 'Good Place (180° VR Version)',
        width: 1920,
        height: 960,
      )!;
      expect(verdict.format.projection, VrProjection.equirect180);
      expect(verdict.format.stereoLayout, VrStereoLayout.sideBySide);
    });

    test('【VR】无 180/360 信号 + 2160x1080 → 缺省 equirect180 + sideBySide', () {
      final verdict = run(
        title: '【VR】ぺこらさんイメージビデオ風「恋愛デコレート」',
        width: 2160,
        height: 1080,
      )!;
      expect(verdict.format.projection, VrProjection.equirect180);
      expect(verdict.format.stereoLayout, VrStereoLayout.sideBySide);
    });

    test('VR 360 + 3840x1920 → equirect360 + mono', () {
      final verdict = run(
        title: 'MMD Miku Porn - VR 360 3D Test - Gear VR Compatible',
        width: 3840,
        height: 1920,
      )!;
      expect(verdict.format.projection, VrProjection.equirect360);
      expect(verdict.format.stereoLayout, VrStereoLayout.mono);
    });
  });

  group('标签必须精确匹配 id，不得子串误报', () {
    for (final tag in ['vrchat', 'vroid', 'cm3d2']) {
      test('$tag 单独出现 + 1920x1080：不误报，判平面', () {
        final suspicion = VrFormatDetector.suspectFromMetadata(
          title: 'gameplay clip',
          tags: [tag],
        );
        expect(suspicion.suspected, isFalse,
            reason: '$tag 含 vr/3d 子串但与 VR 无关，白名单精确匹配不该命中');

        final verdict = VrFormatDetector.decideWithDimensions(
          suspicion,
          width: 1920,
          height: 1080,
        )!;
        expect(verdict.format, VrSourceFormat.flatMono);
      });
    }
  });

  group('无尺寸：停在怀疑不下结论', () {
    test('【VR180】xxx 无尺寸：阶段A suspect，阶段B 返回 null', () {
      final suspicion =
          VrFormatDetector.suspectFromMetadata(title: '【VR180】xxx');
      expect(suspicion.suspected, isTrue);

      final verdict = VrFormatDetector.decideWithDimensions(suspicion);
      expect(verdict, isNull);
    });
  });

  group('立体编排：文本显式写 SBS 时覆盖', () {
    test('Checkpoint Version SBS + 2:1 → 立体编排为 sideBySide', () {
      final suspicion = VrFormatDetector.suspectFromMetadata(
        title: 'Hololive Shiori Novella - Checkpoint Version SBS',
      );
      expect(suspicion.stereoHint, VrStereoLayout.sideBySide);

      final verdict = VrFormatDetector.decideWithDimensions(
        suspicion,
        width: 3840,
        height: 1920,
      )!;
      expect(verdict.format.stereoLayout, VrStereoLayout.sideBySide);
    });
  });

  group('全角拉丁标记必须折成半角后召回（日文输入法默认全角）', () {
    for (final title in <String>[
      '【ＶＲ】爆乳フィギュア', // 全角 ＶＲ
      'ＶＲ動画 高画質',
      '［ＶＲ１８０］新作', // 全角方括号 + 全角数字
    ]) {
      test('$title：全角标记折半角后 suspect', () {
        final suspicion = VrFormatDetector.suspectFromMetadata(title: title);
        expect(suspicion.suspected, isTrue,
            reason: '全角 ＶＲ 折成半角 vr 后应命中正向文本');
      });
    }

    test('全角 ＶＲ１８０ + 2:1 → equirect180', () {
      final verdict = run(
        title: '［ＶＲ１８０］新作',
        width: 3840,
        height: 1920,
      )!;
      expect(verdict.format.projection, VrProjection.equirect180);
    });
  });

  group('分辨率/格式后缀紧贴 VR 也要召回（VR8K/8KVR/VR3D…）', () {
    for (final title in <String>[
      'VR8K 超高画質フィギュア',
      'VR4K best scene',
      'VR60fps smooth',
      '8KVR 体験版',
      'VR3D リアル',
    ]) {
      test('$title：紧贴分辨率的裸 vr 词 suspect', () {
        final suspicion = VrFormatDetector.suspectFromMetadata(title: title);
        expect(suspicion.suspected, isTrue,
            reason: 'vr 紧挨分辨率数字不该被数字边界吞掉');
      });
    }

    test('VR8K + 3840x1920 → equirect180（无 360 信号缺省 180）', () {
      final verdict = run(
        title: 'VR8K 超高画質フィギュア',
        width: 3840,
        height: 1920,
      )!;
      expect(verdict.isVr, isTrue);
      expect(verdict.format.projection, VrProjection.equirect180);
    });

    test('vrchat / vroid 含 vr 子串但不是紧贴数字：文本不误报', () {
      for (final title in <String>['vrchat gameplay', 'vroid studio clip']) {
        final suspicion = VrFormatDetector.suspectFromMetadata(title: title);
        expect(suspicion.suspected, isFalse, reason: '$title 的 vr 后跟字母，非分辨率');
      }
    });
  });

  group('缺尺寸一律推迟（null ⟺ 无宽高，与是否被怀疑无关）', () {
    test('未被怀疑 + 无尺寸：也返回 null（不给非 null 平面终判）', () {
      final suspicion = VrFormatDetector.suspectFromMetadata(
        title: '【MMD】ただの普通の動画',
      );
      expect(suspicion.suspected, isFalse);
      // 关键：不能返回非 null 平面终判，否则遵循「非 null 即终判」的调用方
      // 会停止复检，起播期真实 2:1 到手也不再判决 → 无信号 2:1 被永久漏判。
      expect(VrFormatDetector.decideWithDimensions(suspicion), isNull);
    });

    test('无文本信号 + 起播拿到 2:1：纯宽高比把它认成 VR', () {
      final suspicion = VrFormatDetector.suspectFromMetadata(
        title: '【MMD】ただの普通の動画',
      );
      final verdict = VrFormatDetector.decideWithDimensions(
        suspicion,
        width: 2160,
        height: 1080,
      )!;
      expect(verdict.isVr, isTrue);
      expect(verdict.format.projection, VrProjection.equirect180);
    });
  });

  group('片源格式值对象：判等与序列化', () {
    test('toConfigString / fromConfigString 往返一致', () {
      const format = VrSourceFormat(
        projection: VrProjection.equirect360,
        stereoLayout: VrStereoLayout.topBottom,
      );
      expect(format.toConfigString(), 'equirect360:topBottom');
      expect(VrSourceFormat.fromConfigString(format.toConfigString()), format);
    });

    test('解析失败一律容错回退到 flat+mono', () {
      expect(VrSourceFormat.fromConfigString(''), VrSourceFormat.flatMono);
      expect(VrSourceFormat.fromConfigString('garbage'), VrSourceFormat.flatMono);
      expect(VrSourceFormat.fromConfigString(null), VrSourceFormat.flatMono);
      expect(VrSourceFormat.fromConfigString(42), VrSourceFormat.flatMono);
    });

    test('值相等即判等', () {
      const a = VrSourceFormat(
        projection: VrProjection.equirect180,
        stereoLayout: VrStereoLayout.sideBySide,
      );
      const b = VrSourceFormat(
        projection: VrProjection.equirect180,
        stereoLayout: VrStereoLayout.sideBySide,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('用户手动指定压过推断：来源与满置信', () {
      const verdict = VrFormatVerdict.userSpecified(
        VrSourceFormat(
          projection: VrProjection.equirect180,
          stereoLayout: VrStereoLayout.topBottom,
        ),
      );
      expect(verdict.source, VrVerdictSource.userSpecified);
      expect(verdict.confidence, 1.0);
    });
  });
  // ── 语义反转：标题里的 vr 在说「不是 VR」 ────────────────────────────────
  //
  // 实测 1125 条真实样本命中 25 条（2.2%），形如 `Non VR MMD …`。
  // 关键在于：62% 的视频在详情期拿不到宽高，阶段B 无从否决，所以一旦阶段A
  // 把这类片判成「疑似 VR」，用户就会在一条明确写着「非 VR」的普通视频上
  // 看到 VR 默认档。这几条是防回归的闸门，去掉 _stripSemanticNegations 即红。
  group('语义反转短语不得被当成正向信号', () {
    for (final title in <String>[
      'Non VR MMD  名探偵プリキュア！ キュアアルカナ シャドウ', // 实测真实标题
      'NonVR MMD メランコリック　リン', // 实测真实标题
      'Non-VR dance test',
      'No VR version here',
      '【MMD】Cinematic Dance VR未対応',
      'ダンス VRなし',
    ]) {
      test('不怀疑：$title', () {
        final s = VrFormatDetector.suspectFromMetadata(title: title);
        expect(
          s.suspected,
          isFalse,
          reason: '「$title」明确在说不是 VR，不该被判成疑似 VR',
        );
      });
    }

    test('抹掉反转短语后，同句里的真信号仍要认出来', () {
      // 抹掉而非一票否决：一条标题可以既写「Non VR 版」又写「VR180 另发」，
      // 一票否决会把后者一起误杀，伤到召回率这个硬指标。
      final s = VrFormatDetector.suspectFromMetadata(
        title: 'Non VR ver. / VR180 ver. also available',
      );
      expect(s.suspected, isTrue);
      expect(s.projectionHint, VrProjection.equirect180);
    });

    test('全角写法的反转短语同样不得漏网', () {
      final s = VrFormatDetector.suspectFromMetadata(title: 'ＭＭＤ　ＶＲ未対応');
      expect(s.suspected, isFalse);
    });
  });

}
