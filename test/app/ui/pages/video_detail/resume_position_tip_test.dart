import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/bottom_toolbar_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 「已从上次位置继续播放」提示条。
///
/// 这条提示一度整个失效：UI 还在，但**没有任何地方把 `showResumePositionTip`
/// 置为 true** —— 历史进度还原被重构成 `_deferredInitialPlaybackPosition` 时，
/// 点亮它的那一行丢了。下面既守行为判定，也守窄屏几何。
Widget host({
  required double width,
  required Duration position,
  required bool isFullScreen,
  VoidCallback? onRestart,
  VoidCallback? onDismiss,
  double textScale = 1.0,
}) {
  return slang.TranslationProvider(
    child: MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: ResumePositionTip(
                    position: position,
                    isFullScreen: isFullScreen,
                    onRestart: onRestart ?? () {},
                    onDismiss: onDismiss ?? () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('该不该打扰用户', () {
    test('还原到片头附近就别提示了（还原本来还会往回退 4 秒）', () {
      expect(
        MyVideoStateController.shouldOfferResumeTip(Duration.zero),
        isFalse,
      );
      expect(
        MyVideoStateController.shouldOfferResumeTip(
          const Duration(seconds: 2),
        ),
        isFalse,
      );
    });

    test('确实跳过了一段才提示', () {
      expect(
        MyVideoStateController.shouldOfferResumeTip(
          const Duration(seconds: 3),
        ),
        isTrue,
      );
      expect(
        MyVideoStateController.shouldOfferResumeTip(
          const Duration(minutes: 12, seconds: 34),
        ),
        isTrue,
      );
    });

    test('停留时间必须长过工具栏的 3 秒自动隐藏，否则按钮根本来不及点', () {
      expect(
        MyVideoStateController.kResumeTipDwell,
        greaterThan(const Duration(seconds: 3)),
      );
    });
  });

  group('等画面真的跑起来才点亮', () {
    // `player.open` 返回 ≠ 画面出来了：后面还有加监听器、缓冲、首帧，网络差时能
    // 拖好几秒。在打开那一刻就开始烧停留计时，用户看到提示时它已经快没了。
    bool reveal({
      Duration pending = const Duration(minutes: 12, seconds: 34),
      required Duration current,
      bool buffering = false,
      bool playing = true,
    }) => MyVideoStateController.shouldRevealResumeTipNow(
      pendingPosition: pending,
      currentPosition: current,
      videoBuffering: buffering,
      videoPlaying: playing,
    );

    test('还在缓冲时不点亮', () {
      expect(
        reveal(current: const Duration(minutes: 12, seconds: 34), buffering: true),
        isFalse,
      );
    });

    test('还没开播时不点亮（暂停在加载态上）', () {
      expect(
        reveal(current: const Duration(minutes: 12, seconds: 34), playing: false),
        isFalse,
      );
    });

    test('在播、不缓冲、进度落在历史位置上 -> 点亮', () {
      expect(
        reveal(current: const Duration(minutes: 12, seconds: 34)),
        isTrue,
      );
    });

    test('mpv 报的首个位置略早于目标也算数（容差）', () {
      expect(
        reveal(current: const Duration(minutes: 12, seconds: 33)),
        isTrue,
      );
    });

    test('进度还在片头 -> 说明还原压根没生效，宁可不提示也不能撒谎', () {
      expect(reveal(current: Duration.zero), isFalse);
      expect(reveal(current: const Duration(seconds: 5)), isFalse);
    });
  });

  group('窄屏不溢出', () {
    // 200：手机竖屏里再分屏的极端情况；360：普通手机竖屏；
    // 600/900：平板与全屏。竖屏视频的播放器宽度同样落在这一段里。
    for (final width in <double>[200, 260, 320, 360, 600, 900]) {
      for (final fullScreen in <bool>[false, true]) {
        testWidgets('宽度 $width / 全屏=$fullScreen 不溢出', (tester) async {
          await tester.pumpWidget(
            host(
              width: width,
              position: const Duration(hours: 1, minutes: 23, seconds: 45),
              isFullScreen: fullScreen,
            ),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('放大字体到 1.5 倍也不溢出', (tester) async {
      await tester.pumpWidget(
        host(
          width: 240,
          position: const Duration(minutes: 12, seconds: 34),
          isFullScreen: false,
          textScale: 1.5,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('常规宽度下收缩的是文字，动作按钮保持原样', (tester) async {
      Future<Size> actionSizeAt(double width) async {
        await tester.pumpWidget(
          host(
            width: width,
            position: const Duration(hours: 1, minutes: 23, seconds: 45),
            isFullScreen: false,
          ),
        );
        final t = slang.Translations.of(
          tester.element(find.byType(ResumePositionTip)),
        );
        return tester.getSize(
          find.ancestor(
            of: find.text(t.videoDetail.restartFromBeginning),
            matching: find.byType(Material),
          ).first,
        );
      }

      final wide = await actionSizeAt(900);
      final narrow = await actionSizeAt(360);
      expect(
        narrow,
        wide,
        reason: '文字被省略还能猜出意思，按钮被压没了这条提示就废了',
      );
    });

    testWidgets('极窄时按钮仍在，只是文字也开始省略', (tester) async {
      await tester.pumpWidget(
        host(
          width: 180,
          position: const Duration(hours: 1, minutes: 23, seconds: 45),
          isFullScreen: false,
        ),
      );
      expect(tester.takeException(), isNull);
      final t = slang.Translations.of(
        tester.element(find.byType(ResumePositionTip)),
      );
      expect(
        find.text(t.videoDetail.restartFromBeginning),
        findsOneWidget,
        reason: '再窄也不能把唯一的操作弄没了',
      );
    });
  });

  group('密度分档（纯函数）', () {
    // 装饰先走、操作最后走：图标与关闭钮是可以牺牲的，动作按钮不是。
    test('宽裕时全档显示', () {
      expect(
        resolveResumeTipDensity(
          maxWidth: 600,
          actionWidth: 80,
          iconWidth: 14,
          closeWidth: 32,
        ),
        ResumeTipDensity.full,
      );
    });

    test('放不下装饰时先丢图标与关闭钮', () {
      expect(
        resolveResumeTipDensity(
          maxWidth: 160,
          actionWidth: 80,
          iconWidth: 14,
          closeWidth: 32,
        ),
        ResumeTipDensity.compact,
      );
    });

    test('连文字最小宽度都保不住时才让按钮文字省略', () {
      expect(
        resolveResumeTipDensity(
          maxWidth: 90,
          actionWidth: 80,
          iconWidth: 14,
          closeWidth: 32,
        ),
        ResumeTipDensity.minimal,
      );
    });

    test('档位随宽度单调，不会来回跳', () {
      ResumeTipDensity at(double w) => resolveResumeTipDensity(
        maxWidth: w,
        actionWidth: 80,
        iconWidth: 14,
        closeWidth: 32,
      );
      final order = {
        ResumeTipDensity.minimal: 0,
        ResumeTipDensity.compact: 1,
        ResumeTipDensity.full: 2,
      };
      var previous = -1;
      for (double w = 60; w <= 400; w += 5) {
        final current = order[at(w)]!;
        expect(current, greaterThanOrEqualTo(previous));
        previous = current;
      }
    });
  });

  group('几何账本与真实高度一致', () {
    // bottomToolbarEstimatedHeight 被源错误浮层与全屏播放列表抽屉用来预留空间。
    // 算小了子组件会溢出画到播放条上，按钮把点击吃掉（issue #110 同类问题）；
    // 算大了则白白挤掉画面。这里直接拿渲染出来的真实高度对账。
    for (final fullScreen in <bool>[false, true]) {
      testWidgets('全屏=$fullScreen 时预估的续播提示高度不小于实际', (tester) async {
        await tester.pumpWidget(
          host(
            width: 600,
            position: const Duration(minutes: 12, seconds: 34),
            isFullScreen: fullScreen,
          ),
        );
        final actual = tester.getSize(find.byType(ResumePositionTip)).height;

        double estimate({required bool showResumeTip}) =>
            bottomToolbarEstimatedHeight(
              isFullScreen: fullScreen,
              isSmallScreen: false,
              showResumeTip: showResumeTip,
              showQuickActions: false,
              bottomInset: 0,
              textScaler: TextScaler.noScaling,
            );
        final booked = estimate(showResumeTip: true) -
            estimate(showResumeTip: false);

        expect(
          booked,
          greaterThanOrEqualTo(actual),
          reason: '预估($booked) 小于实际($actual)：预留不够，会溢出到播放条上',
        );
        expect(
          booked - actual,
          lessThanOrEqualTo(4.0),
          reason: '预估($booked) 比实际($actual) 大太多：白白挤掉画面',
        );
      });
    }
  });

  group('有出有入：出现与消失都要有过渡', () {
    Widget revealHost({required bool visible, bool reduceMotion = false}) {
      return slang.TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(disableAnimations: reduceMotion),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 600,
                    child: ResumeTipReveal(
                      visible: visible,
                      child: ResumePositionTip(
                        position: const Duration(minutes: 12, seconds: 34),
                        isFullScreen: false,
                        onRestart: () {},
                        onDismiss: () {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('入场：高度是长出来的，不是一帧蹦出来的', (tester) async {
      await tester.pumpWidget(revealHost(visible: false));
      final collapsed = tester.getSize(find.byType(ResumeTipReveal)).height;

      await tester.pumpWidget(revealHost(visible: true));
      await tester.pump(const Duration(milliseconds: 80));
      final mid = tester.getSize(find.byType(ResumeTipReveal)).height;

      await tester.pumpAndSettle();
      final full = tester.getSize(find.byType(ResumeTipReveal)).height;

      expect(full, greaterThan(collapsed));
      expect(
        mid,
        allOf(greaterThan(collapsed), lessThan(full)),
        reason: '中途高度必须落在两者之间——只淡入不长高的话，下面的进度条会跳一下',
      );
    });

    testWidgets('退场：内容还在，是整条缩回去而不是空壳渐隐', (tester) async {
      await tester.pumpWidget(revealHost(visible: true));
      await tester.pumpAndSettle();
      final full = tester.getSize(find.byType(ResumeTipReveal)).height;

      await tester.pumpWidget(revealHost(visible: false));
      await tester.pump(const Duration(milliseconds: 80));
      final mid = tester.getSize(find.byType(ResumeTipReveal)).height;

      expect(
        find.byType(ResumePositionTip),
        findsOneWidget,
        reason: '退场期间要保留最后一次的内容',
      );
      expect(mid, lessThan(full));

      await tester.pumpAndSettle();
      expect(find.byType(ResumePositionTip), findsNothing);
    });

    testWidgets('系统关掉动画时立即完成，而不是跳过过渡逻辑', (tester) async {
      await tester.pumpWidget(revealHost(visible: false, reduceMotion: true));
      await tester.pumpWidget(revealHost(visible: true, reduceMotion: true));
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(ResumePositionTip), findsOneWidget);
    });
  });

  group('闸门：提示不得跟着工具栏一起淡出', () {
    // 用户报的原话：「工具栏隐藏时它就不显示了」。提示有自己的 8 秒停留，点一下
    // 画面收起工具栏不该把它一起带走——那条「从头播放」还没点呢。
    late String source;

    setUpAll(() {
      source = File(
        'lib/app/ui/pages/video_detail/widgets/player/bottom_toolbar_widget.dart',
      ).readAsStringSync();
    });

    String bodyOf(String signature) {
      final start = source.indexOf(signature);
      expect(start, greaterThan(-1), reason: '找不到 $signature');
      final end = source.indexOf('\n  }', start);
      expect(end, greaterThan(start));
      return source.substring(start, end);
    }

    test('提示自己那一段不套 ToolbarFadeVisibility', () {
      expect(
        bodyOf('Widget _buildResumeTip()').contains('ToolbarFadeVisibility'),
        isFalse,
        reason: '套上就等于把提示的寿命交给了工具栏',
      );
    });

    test('会淡出的两段里都不许再出现提示', () {
      for (final sig in [
        'Widget _buildBottomToolbar(',
        'Widget _buildTopInteractionLayer(',
      ]) {
        expect(
          bodyOf(sig).contains('ResumePositionTip'),
          isFalse,
          reason: '$sig 是随工具栏淡出的，提示放进去就会跟着消失',
        );
      }
    });

    test('提示与工具栏共处同一个 Column，位置由布局算出而不是拿估算值猜偏移', () {
      final build = bodyOf('  Widget build(BuildContext context) {');
      expect(build.contains('_buildResumeTip()'), isTrue);
      expect(
        build.contains('_buildBottomToolbar('),
        isTrue,
        reason: '两者必须在同一棵 Column 里，否则只能拿估算高度定位，迟早叠到播放条上',
      );
    });
  });
}
