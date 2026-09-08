import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/quest_gesture_guide.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/quest_gesture_guide_content.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/quest_gesture_illustration.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/video_gesture_guide.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/video_gesture_guide_page.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// Direct component tests can run in the standard flavor too, whose production
/// bundle intentionally excludes the Quest-only controller illustrations.
class _QuestTestAssets extends CachingAssetBundle {
  static final images = <String, ByteData>{};

  @override
  Future<ByteData> load(String key) async {
    if (images.containsKey(key)) return images[key]!;
    return rootBundle.load(key);
  }
}

class _DemoClock extends ValueNotifier<double> {
  _DemoClock() : super(0);
  bool get observed => hasListeners;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previewDir = Platform.environment['QUEST_GUIDE_PREVIEW_DIR'];
  final previewFont = Platform.environment['QUEST_GUIDE_PREVIEW_FONT'];
  late _DemoClock clock;

  setUpAll(() async {
    for (final name in ['left', 'right', 'left_grip', 'right_grip']) {
      final path = 'assets/images/quest/quest_controller_$name.png';
      _QuestTestAssets.images[path] = ByteData.sublistView(
        await File(path).readAsBytes(),
      );
    }
    // Non-English translations are deferred libraries in the app.
    for (final locale in slang.AppLocale.values) {
      await slang.LocaleSettings.setLocale(locale);
    }
    if (previewDir != null && previewFont != null) {
      final bytes = ByteData.sublistView(await File(previewFont).readAsBytes());
      for (final family in ['GuidePreview', 'Roboto']) {
        await (FontLoader(family)..addFont(Future.value(bytes))).load();
      }
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    }
  });

  setUp(() {
    clock = _DemoClock();
    slang.LocaleSettings.setLocaleSync(slang.AppLocale.en);
  });

  tearDown(() {
    clock.dispose();
    slang.LocaleSettings.setLocaleSync(slang.AppLocale.en);
  });

  Future<void> pumpGuide(
    WidgetTester tester, {
    Size size = const Size(1200, 900),
    QuestGuideMedia media = QuestGuideMedia.video,
    slang.AppLocale locale = slang.AppLocale.en,
    bool reducedMotion = false,
    double textScale = 1,
    Brightness brightness = Brightness.light,
    VoidCallback? onClose,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    slang.LocaleSettings.setLocaleSync(locale);
    await tester.pumpWidget(
      slang.TranslationProvider(
        child: MaterialApp(
          locale: locale.flutterLocale,
          supportedLocales: slang.AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFBD6024),
              brightness: brightness,
            ),
            fontFamily: previewFont == null ? null : 'GuidePreview',
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: reducedMotion,
              textScaler: TextScaler.linear(textScale),
            ),
            child: DefaultAssetBundle(
              bundle: _QuestTestAssets(),
              child: child!,
            ),
          ),
          home: RepaintBoundary(
            key: const ValueKey('guide_preview'),
            child: QuestGestureGuide(
              key: UniqueKey(),
              clock: clock,
              initialMedia: media,
              onClose: onClose ?? () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (previewDir != null) {
      final context = tester.element(find.byType(QuestGestureGuide));
      await tester.runAsync(() async {
        for (final path in _QuestTestAssets.images.keys) {
          await precacheImage(AssetImage(path), context);
        }
      });
      await tester.pump();
    }
  }

  Future<void> choose(WidgetTester tester, QuestGestureVisual visual) async {
    final choice = find.byKey(ValueKey('quest_lesson_${visual.name}'));
    await tester.ensureVisible(choice);
    await tester.pumpAndSettle();
    await tester.tap(choice);
    await tester.pumpAndSettle();
  }

  AnimatedQuestGestureIllustration illustration(WidgetTester tester) =>
      tester.widget<AnimatedQuestGestureIllustration>(
        find.byType(AnimatedQuestGestureIllustration),
      );

  testWidgets('media tabs and the catalog select the matching demonstration', (
    tester,
  ) async {
    await pumpGuide(tester);
    expect(find.byKey(const ValueKey('quest_lesson_seek')), findsOneWidget);
    final q = slang.t.videoDetail.gestureGuide.quest;
    await tester.tap(
      find.descendant(
        of: find.byType(GlassSegmentedControl),
        matching: find.text(q.galleryTab),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('quest_lesson_seek')), findsNothing);
    expect(
      find.byKey(const ValueKey('quest_lesson_gallerySwipe')),
      findsOneWidget,
    );
    await choose(tester, QuestGestureVisual.galleryZoom);
    expect(illustration(tester).visual, QuestGestureVisual.galleryZoom);
    expect(illustration(tester).media, QuestGuideMedia.gallery);
    expect(find.text(q.zoomBody), findsOneWidget);
    expect(find.text(q.zoomHint), findsOneWidget);
  });

  testWidgets(
    'pause stops the demo clock and replay starts the selected lesson',
    (tester) async {
      await pumpGuide(tester);
      clock.value = 2;
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('quest_guide_pause')));
      await tester.pumpAndSettle();
      expect(illustration(tester).pausedAt, 2);
      expect(clock.observed, isFalse);
      clock.value = 50;
      await tester.pump();
      expect(illustration(tester).pausedAt, 2);
      await tester.tap(find.byKey(const ValueKey('quest_guide_replay')));
      await tester.pumpAndSettle();
      expect(illustration(tester).startedAt, 50);
      expect(illustration(tester).pausedAt, isNull);
      expect(clock.observed, isTrue);
    },
  );

  testWidgets(
    'reduced motion renders a useful still and has no clock listener',
    (tester) async {
      await pumpGuide(tester, reducedMotion: true);
      expect(find.byKey(const ValueKey('quest_guide_pause')), findsNothing);
      expect(clock.observed, isFalse);
      final before = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(AnimatedQuestGestureIllustration),
              matching: find.byType(CustomPaint),
            ),
          )
          .map((w) => w.painter)
          .toList();
      clock.value = 500;
      await tester.pump();
      final after = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(AnimatedQuestGestureIllustration),
              matching: find.byType(CustomPaint),
            ),
          )
          .map((w) => w.painter)
          .toList();
      expect(after, before);
    },
  );

  testWidgets(
    'the persistent continue action remains reachable on a narrow panel',
    (tester) async {
      var closed = false;
      await pumpGuide(
        tester,
        size: const Size(360, 720),
        onClose: () => closed = true,
      );
      final action = find.byKey(const ValueKey('quest_guide_done'));
      expect(tester.getRect(action).height, greaterThanOrEqualTo(60));
      expect(tester.getRect(action).bottom, lessThanOrEqualTo(720));
      await tester.tap(action);
      expect(closed, isTrue);
    },
  );

  testWidgets(
    'both media guides lay out in all locales, narrow panels and large text',
    (tester) async {
      for (final locale in slang.AppLocale.values) {
        for (final media in QuestGuideMedia.values) {
          for (final width in [360.0, 680.0, 1200.0]) {
            await pumpGuide(
              tester,
              locale: locale,
              media: media,
              size: Size(width, 900),
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '$locale $media $width',
            );
          }
        }
      }
      await pumpGuide(
        tester,
        locale: slang.AppLocale.en,
        media: QuestGuideMedia.gallery,
        size: const Size(360, 800),
        textScale: 1.8,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the existing route selects the guide for the installed flavor', (
    tester,
  ) async {
    await tester.pumpWidget(
      slang.TranslationProvider(
        child: MaterialApp(
          home: const VideoGestureGuidePage(
            initialQuestMedia: QuestGuideMedia.gallery,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    if (usesQuestGestureGuide) {
      expect(find.byType(QuestGestureGuide), findsOneWidget);
      expect(illustration(tester).media, QuestGuideMedia.gallery);
    } else {
      expect(find.byType(QuestGestureGuide), findsNothing);
      expect(
        find.text(slang.t.videoDetail.gestureGuide.zoomTitle),
        findsOneWidget,
      );
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  if (usesQuestGestureGuide) {
    testWidgets(
      'the settings dialog reopens the same Quest guide and closes normally',
      (tester) async {
        late BuildContext host;
        await tester.pumpWidget(
          slang.TranslationProvider(
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  host = context;
                  return const Scaffold(body: Text('settings'));
                },
              ),
            ),
          ),
        );
        final closed = VideoGestureGuideDialog.show(host);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(QuestGestureGuide), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('quest_guide_close')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await closed;
        expect(find.byType(QuestGestureGuide), findsNothing);
        expect(find.text('settings'), findsOneWidget);
      },
    );
  }

  test(
    'image zoom and gallery swipes never resize or translate the spatial stage',
    () {
      for (final visual in [
        QuestGestureVisual.galleryZoom,
        QuestGestureVisual.galleryPan,
        QuestGestureVisual.gallerySwipe,
      ]) {
        final before = QuestGestureFrame(visual, 0);
        final moving = QuestGestureFrame(visual, before.duration * .6);
        expect(moving.screen, before.screen);
      }
      final zoom = QuestGestureFrame(QuestGestureVisual.galleryZoom, 3.5);
      expect(zoom.imageScale, greaterThan(1));
      const zoomAnchor = Offset(12, -20);
      expect(zoomAnchor * zoom.imageScale + zoom.imageOffset, zoomAnchor);
      final scale = QuestGestureFrame(QuestGestureVisual.scale, 3.5);
      expect(scale.screenScale, greaterThan(1));
      expect(scale.imageScale, 1);
      const swipe = QuestGestureFrame(QuestGestureVisual.gallerySwipe, 0);
      expect(
        QuestGestureFrame(swipe.visual, swipe.duration * .6).galleryIndex,
        1,
      );
      expect(
        QuestGestureFrame(swipe.visual, swipe.duration * .8).galleryIndex,
        2,
      );
    },
  );

  test(
    'controller artwork stays inside the illustration throughout movement',
    () {
      const viewport = Rect.fromLTWH(0, 0, 720, 480);
      for (final visual in QuestGestureVisual.values) {
        for (final seconds in [0.0, 1.4, 3.5, 4.4]) {
          for (final left in [true, false]) {
            final rect = QuestGestureFrame(
              visual,
              seconds,
            ).controllerRect(left: left);
            expect(
              viewport.contains(rect.topLeft),
              isTrue,
              reason: '$visual $left $seconds',
            );
            expect(
              viewport.contains(rect.bottomRight),
              isTrue,
              reason: '$visual $left $seconds',
            );
          }
        }
      }
    },
  );

  test('controller assets are bundled only in the Quest flavor', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets().where(
      (path) => path.startsWith('assets/images/quest/'),
    );
    expect(assets.length, usesQuestGestureGuide ? 4 : 0);
  });

  // Optional visual QA artifacts, produced from the real Flutter widget tree.
  // CI runs the behavior checks above without depending on local fonts/files.
  if (previewDir != null) {
    testWidgets('render Quest guide previews', (tester) async {
      Future<void> capture(String name) async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('guide_preview')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1.5);
          try {
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory(previewDir).create(recursive: true);
            await File(
              '$previewDir/$name.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
          } finally {
            image.dispose();
          }
        });
      }

      for (final media in QuestGuideMedia.values) {
        await pumpGuide(
          tester,
          media: media,
          locale: slang.AppLocale.zhCn,
          size: const Size(1200, 960),
        );
        final visuals = media == QuestGuideMedia.video
            ? [
                QuestGestureVisual.playPause,
                QuestGestureVisual.move,
                QuestGestureVisual.scale,
                QuestGestureVisual.hands,
              ]
            : [QuestGestureVisual.gallerySwipe, QuestGestureVisual.galleryZoom];
        for (final visual in visuals) {
          await choose(tester, visual);
          clock.value += 3.2;
          await tester.pump();
          tester
              .widget<SingleChildScrollView>(
                find.byType(SingleChildScrollView).first,
              )
              .controller!
              .jumpTo(0);
          await tester.pump();
          await capture('${media.name}_${visual.name}');
        }
      }
      await pumpGuide(
        tester,
        media: QuestGuideMedia.gallery,
        locale: slang.AppLocale.ja,
        size: const Size(360, 900),
        brightness: Brightness.dark,
      );
      clock.value += 2.5;
      await tester.pump();
      await capture('gallery_narrow_dark');
    });
  }
}
