import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/player_box_scope.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/seek_preview.dart';

/// Seek Preview（进度条上方那扇预览窗口）。
///
/// 改造前它被实现了两遍，`160 x 90` 这两个魔数各写一份：竖屏视频被塞进横着的
/// 黑框里，画面只剩中间窄窄一条；同一个 160 在竖屏手机的内嵌播放器上几乎占掉
/// 半个播放器，在横屏平板全屏时又小到看不清。
///
/// 下面守三件事：几何是纯函数（可以穷举）、渲染只有一份、出现与消失都有过渡。
///
/// 关于语言：这扇窗口上唯一的文字是 `CommonUtils.formatDuration` 生成的
/// `01:23` / `01:23:45`，**纯数字、不经过翻译**，所以四种语言的渲染结果完全相同，
/// 没有可扫的维度。真正会撑爆它的是系统字体放大，那一维在下面扫了。
void main() {
  setUp(() {
    Get.reset();
    // 只读配置，不碰数据库：把默认值灌进 settings 就够 SeekPreview 用了。
    final config = ConfigService();
    for (final key in ConfigKey.values) {
      config.settings[key] = Rx<dynamic>(key.defaultValue);
    }
    Get.put<ConfigService>(config);
  });

  tearDown(Get.reset);

  group('几何（纯函数）', () {
    Size sizeFor({
      required Size playerBox,
      required double aspectRatio,
      SeekPreviewSize preference = SeekPreviewSize.standard,
    }) => resolveSeekPreviewFrameSize(
      playerBox: playerBox,
      videoAspectRatio: aspectRatio,
      preference: preference,
    );

    test('竖屏视频得到竖着的窗口，而不是被塞进 16:9 的黑边里', () {
      final portrait = sizeFor(
        playerBox: const Size(1600, 1000),
        aspectRatio: 9 / 16,
      );
      expect(
        portrait.height,
        greaterThan(portrait.width),
        reason: '竖屏视频的预览窗口必须是竖的——这正是改造前最伤的那条',
      );
      expect(portrait.width / portrait.height, closeTo(9 / 16, 0.001));
    });

    test('横屏视频保持自己的宽高比', () {
      final landscape = sizeFor(
        playerBox: const Size(1600, 1000),
        aspectRatio: 16 / 9,
      );
      expect(landscape.width / landscape.height, closeTo(16 / 9, 0.001));
    });

    test('跟着播放器走：全屏平板上的窗口显著大于竖屏手机的内嵌播放器', () {
      final inlinePhone = sizeFor(
        playerBox: const Size(392, 220),
        aspectRatio: 16 / 9,
      );
      final fullscreenTablet = sizeFor(
        playerBox: const Size(1600, 1000),
        aspectRatio: 16 / 9,
      );
      expect(
        fullscreenTablet.width,
        greaterThan(inlinePhone.width * 1.5),
        reason: '同一个 160 在两种场景下都不合适，正是「不响应式」的症状',
      );
    });

    test('宽度随播放器单调不减，并夹在上下限之间', () {
      double previous = -1;
      for (double side = 120; side <= 4000; side += 40) {
        final size = sizeFor(
          playerBox: Size(side * 16 / 9, side),
          aspectRatio: 16 / 9,
        );
        expect(size.width, greaterThanOrEqualTo(previous));
        expect(size.width, lessThanOrEqualTo(kSeekPreviewMaxWidth));
        expect(size.width, greaterThanOrEqualTo(kSeekPreviewFloorWidth));
        previous = size.width;
      }
    });

    test('永远不宽过播放器的一半', () {
      for (final box in const [
        Size(320, 180),
        Size(392, 220),
        Size(800, 450),
        Size(1600, 1000),
        Size(3840, 2160),
      ]) {
        for (final ar in const [9 / 16, 1.0, 4 / 3, 16 / 9, 2.4]) {
          final size = sizeFor(playerBox: box, aspectRatio: ar);
          expect(
            size.width,
            lessThanOrEqualTo(box.width * kSeekPreviewMaxWidthFraction + 0.01),
            reason: '$box / $ar 的窗口盖住了半个播放器',
          );
        }
      }
    });

    test('竖屏视频的高度被播放器高度封顶（除非已经压到宽度下限）', () {
      for (final box in const [
        Size(392, 220),
        Size(800, 450),
        Size(1000, 1600),
        Size(1600, 1000),
      ]) {
        final size = sizeFor(playerBox: box, aspectRatio: 9 / 16);
        final bool atFloor = size.width <= kSeekPreviewFloorWidth + 0.01;
        if (!atFloor) {
          expect(
            size.height,
            lessThanOrEqualTo(
              box.height * kSeekPreviewMaxHeightFraction + 0.01,
            ),
            reason: '$box 上的竖屏预览高过了播放器的一半',
          );
        }
        expect(
          size.height,
          lessThanOrEqualTo(box.height),
          reason: '$box 上的预览比播放器本身还高',
        );
      }
    });

    test('档位只是自动尺寸上的倍数，小 < 标准 < 大', () {
      const box = Size(1600, 1000);
      final small = sizeFor(
        playerBox: box,
        aspectRatio: 16 / 9,
        preference: SeekPreviewSize.small,
      );
      final standard = sizeFor(
        playerBox: box,
        aspectRatio: 16 / 9,
        preference: SeekPreviewSize.standard,
      );
      final large = sizeFor(
        playerBox: box,
        aspectRatio: 16 / 9,
        preference: SeekPreviewSize.large,
      );
      expect(small.width, lessThan(standard.width));
      expect(standard.width, lessThan(large.width));
    });

    test('退化输入不会崩，也不会算出 NaN', () {
      const cases = <(Size, double)>[
        (Size.zero, 16 / 9),
        (Size(double.infinity, double.infinity), 16 / 9),
        (Size(-100, -100), 16 / 9),
        (Size(double.nan, double.nan), 16 / 9),
        (Size(800, 450), 0),
        (Size(800, 450), double.nan),
        (Size(800, 450), double.infinity),
        (Size(800, 450), -2),
      ];
      for (final (box, ar) in cases) {
        final size = sizeFor(playerBox: box, aspectRatio: ar);
        expect(size.width.isFinite, isTrue, reason: '$box / $ar');
        expect(size.height.isFinite, isTrue, reason: '$box / $ar');
        expect(size.width, greaterThan(0), reason: '$box / $ar');
        expect(size.height, greaterThan(0), reason: '$box / $ar');
      }
    });

    test('极端宽高比被钳住，不会算出细成一条线的窗口', () {
      final ultraWide = sizeFor(
        playerBox: const Size(1600, 1000),
        aspectRatio: 100,
      );
      expect(
        ultraWide.height,
        greaterThan(10),
        reason: '脏数据的宽高比不该把窗口压成一条线',
      );
    });
  });

  group('边界钳制（纯函数）', () {
    test('正中间时以锚点居中', () {
      expect(
        seekPreviewFractionalOffset(
          anchorX: 400,
          trackWidth: 800,
          previewWidth: 160,
        ),
        closeTo(-0.5, 0.001),
      );
    });

    test('拖到最左：左边缘停在边距上，不越出进度条', () {
      const width = 160.0;
      final dx = seekPreviewFractionalOffset(
        anchorX: 0,
        trackWidth: 800,
        previewWidth: width,
      );
      final left = 0 + dx * width;
      expect(left, closeTo(kSeekPreviewEdgeMargin, 0.001));
    });

    test('拖到最右：右边缘停在边距上', () {
      const width = 160.0;
      const track = 800.0;
      final dx = seekPreviewFractionalOffset(
        anchorX: track,
        trackWidth: track,
        previewWidth: width,
      );
      final right = track + dx * width + width;
      expect(right, closeTo(track - kSeekPreviewEdgeMargin, 0.001));
    });

    test('窗口比进度条还宽时（放不下）一律居中，两边对称溢出', () {
      const track = 120.0;
      const width = 300.0;
      for (final anchor in const [0.0, 60.0, 120.0]) {
        final dx = seekPreviewFractionalOffset(
          anchorX: anchor,
          trackWidth: track,
          previewWidth: width,
        );
        final left = anchor + dx * width;
        expect(left, closeTo((track - width) / 2, 0.001));
      }
    });

    test('全程扫一遍：窗口始终留在进度条内（放得下时）', () {
      const track = 600.0;
      const width = 160.0;
      for (double anchor = 0; anchor <= track; anchor += 5) {
        final dx = seekPreviewFractionalOffset(
          anchorX: anchor,
          trackWidth: track,
          previewWidth: width,
        );
        final left = anchor + dx * width;
        expect(left, greaterThanOrEqualTo(kSeekPreviewEdgeMargin - 0.001));
        expect(
          left + width,
          lessThanOrEqualTo(track - kSeekPreviewEdgeMargin + 0.001),
        );
      }
    });
  });

  group('渲染：播放器尺寸 × 视频比例 × 字体缩放，一处都不许溢出', () {
    Widget host({
      required Size playerBox,
      required double aspectRatio,
      double textScale = 1.0,
      double anchorX = 100,
      bool visible = true,
      bool showFrame = true,
      bool reduceMotion = false,
    }) {
      return MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              disableAnimations: reduceMotion,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: PlayerBoxScope(
                size: playerBox,
                child: Center(
                  child: SizedBox(
                    width: playerBox.width,
                    height: playerBox.height,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: anchorX,
                          bottom: 0,
                          child: SeekPreview(
                            time: const Duration(hours: 1, minutes: 23, seconds: 45),
                            videoAspectRatio: aspectRatio,
                            anchorX: anchorX,
                            trackWidth: playerBox.width,
                            visible: visible,
                            showFrame: showFrame,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    const playerBoxes = <Size>[
      Size(320, 180), // 极小内嵌
      Size(392, 220), // 竖屏手机内嵌
      Size(800, 450), // 桌面窗口
      Size(1000, 1600), // 竖屏全屏
      Size(1600, 1000), // 平板全屏
    ];
    const aspectRatios = <double>[9 / 16, 3 / 4, 1.0, 16 / 9, 2.35];
    const textScales = <double>[0.85, 1.0, 1.3, 2.0];

    for (final box in playerBoxes) {
      for (final ar in aspectRatios) {
        for (final scale in textScales) {
          testWidgets(
            '播放器 ${box.width.toInt()}x${box.height.toInt()} / 比例 '
            '${ar.toStringAsFixed(2)} / 字体 ${scale}x 不溢出',
            (tester) async {
              await tester.pumpWidget(
                host(playerBox: box, aspectRatio: ar, textScale: scale),
              );
              await tester.pumpAndSettle();

              expect(tester.takeException(), isNull);

              final size = tester.getSize(find.byType(SeekPreview));
              expect(
                size.width,
                lessThanOrEqualTo(box.width),
                reason: '窗口比播放器还宽',
              );
              expect(
                size.height,
                lessThanOrEqualTo(box.height),
                reason: '窗口比播放器还高',
              );
            },
          );
        }
      }
    }

    testWidgets('画面区域用的是视频自己的宽高比', (tester) async {
      await tester.pumpWidget(
        host(playerBox: const Size(1600, 1000), aspectRatio: 9 / 16),
      );
      final frame = tester.getSize(find.byKey(kSeekPreviewFrameKey));
      expect(frame.width / frame.height, closeTo(9 / 16, 0.01));
    });

    testWidgets('字体放大到装不下时，窗口跟着变宽而不是把时间截掉', (tester) async {
      const box = Size(800, 450);
      await tester.pumpWidget(
        host(playerBox: box, aspectRatio: 16 / 9, textScale: 1.0),
      );
      final normal = tester.getSize(find.byType(SeekPreview));

      await tester.pumpWidget(
        host(playerBox: box, aspectRatio: 16 / 9, textScale: 4.0),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final huge = tester.getSize(find.byType(SeekPreview));

      expect(
        huge.width,
        greaterThan(normal.width),
        reason: '时间戳撑不开窗口就只能溢出或被截断',
      );
    });

    testWidgets('预览播放器还没就绪时只显示时间，不留一块空黑框', (tester) async {
      await tester.pumpWidget(
        host(
          playerBox: const Size(800, 450),
          aspectRatio: 16 / 9,
          showFrame: false,
        ),
      );
      expect(find.byKey(kSeekPreviewFrameKey), findsNothing);
      expect(find.text('01:23:45'), findsOneWidget);
    });

    testWidgets('档位设置立刻生效', (tester) async {
      const box = Size(1600, 1000);
      final config = Get.find<ConfigService>();

      await tester.pumpWidget(host(playerBox: box, aspectRatio: 16 / 9));
      final standard = tester.getSize(find.byKey(kSeekPreviewFrameKey));

      config.settings[ConfigKey.SEEK_PREVIEW_SIZE_KEY]!.value =
          SeekPreviewSize.large.name;
      await tester.pump();
      final large = tester.getSize(find.byKey(kSeekPreviewFrameKey));

      expect(large.width, greaterThan(standard.width));
    });

    testWidgets('认不出来的档位回到标准档', (tester) async {
      const box = Size(1600, 1000);
      final config = Get.find<ConfigService>();

      await tester.pumpWidget(host(playerBox: box, aspectRatio: 16 / 9));
      final standard = tester.getSize(find.byKey(kSeekPreviewFrameKey));

      config.settings[ConfigKey.SEEK_PREVIEW_SIZE_KEY]!.value = '天知道';
      await tester.pump();
      expect(tester.getSize(find.byKey(kSeekPreviewFrameKey)), standard);
    });

    group('有出有入', () {
      testWidgets('不可见时是淡出，不是直接消失', (tester) async {
        await tester.pumpWidget(
          host(
            playerBox: const Size(800, 450),
            aspectRatio: 16 / 9,
            visible: false,
          ),
        );
        expect(
          find.byType(SeekPreview),
          findsOneWidget,
          reason: '直接摘掉组件就是硬切；必须留在树里淡出',
        );
        final opacity = tester.widget<AnimatedOpacity>(
          find.descendant(
            of: find.byType(SeekPreview),
            matching: find.byType(AnimatedOpacity),
          ),
        );
        expect(opacity.opacity, 0.0);
        expect(opacity.duration, SeekPreview.kFade);
      });

      testWidgets('系统关掉动画时把时长归零，而不是跳过过渡逻辑', (tester) async {
        await tester.pumpWidget(
          host(
            playerBox: const Size(800, 450),
            aspectRatio: 16 / 9,
            reduceMotion: true,
          ),
        );
        final opacity = tester.widget<AnimatedOpacity>(
          find.descendant(
            of: find.byType(SeekPreview),
            matching: find.byType(AnimatedOpacity),
          ),
        );
        expect(opacity.duration, Duration.zero);
        final scale = tester.widget<AnimatedScale>(
          find.descendant(
            of: find.byType(SeekPreview),
            matching: find.byType(AnimatedScale),
          ),
        );
        expect(scale.duration, Duration.zero);
      });
    });
  });
}
