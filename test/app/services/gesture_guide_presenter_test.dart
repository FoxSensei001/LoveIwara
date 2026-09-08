import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/gesture_guide_presenter.dart';

class _MemoryConfig extends ConfigService {
  final values = <ConfigKey, dynamic>{};
  final saved = <ConfigKey>[];

  @override
  dynamic operator [](ConfigKey key) => values[key] ?? key.defaultValue;

  @override
  Future<void> setSetting(
    ConfigKey key,
    dynamic value, {
    bool save = true,
  }) async {
    values[key] = value;
    if (save) saved.add(key);
  }
}

void main() {
  test(
    'an existing touch-guide flag does not suppress Quest onboarding',
    () async {
      final config = _MemoryConfig()
        ..values[ConfigKey.VIDEO_GESTURE_GUIDE_SHOWN] = true;
      final routes = <String>[];
      final presenter = GestureGuidePresenter(
        present: (route) async => routes.add(route),
      );

      await presenter.showIfNeeded(config, isQuest: true, isGallery: true);

      expect(routes, ['/video_gesture_guide?media=gallery']);
      expect(config.saved, [ConfigKey.QUEST_GESTURE_GUIDE_SHOWN_V1]);
      expect(config[ConfigKey.VIDEO_GESTURE_GUIDE_SHOWN], isTrue);

      // Reconstructing the presenter simulates a new app session using saved data.
      final reopened = GestureGuidePresenter(
        present: (route) async => routes.add(route),
      );
      await reopened.showIfNeeded(config, isQuest: true);
      expect(routes, hasLength(1));
    },
  );

  test(
    'video and gallery await the same visible guide after its flag is saved',
    () async {
      final config = _MemoryConfig();
      final closed = Completer<void>();
      final routes = <String>[];
      final presenter = GestureGuidePresenter(
        present: (route) {
          routes.add(route);
          return closed.future;
        },
      );
      var videoReady = false;
      var galleryReady = false;
      final video = presenter
          .showIfNeeded(config, isQuest: true)
          .then((_) => videoReady = true);
      await Future<void>.delayed(Duration.zero);
      expect(config[ConfigKey.QUEST_GESTURE_GUIDE_SHOWN_V1], isTrue);
      final gallery = presenter
          .showIfNeeded(config, isQuest: true, isGallery: true)
          .then((_) => galleryReady = true);
      await Future<void>.delayed(Duration.zero);

      expect(routes, ['/video_gesture_guide']);
      expect(videoReady, isFalse);
      expect(galleryReady, isFalse);
      closed.complete();
      await Future.wait([video, gallery]);
      expect(videoReady && galleryReady, isTrue);
      expect(config.saved, hasLength(1));
    },
  );

  test(
    'ordinary gallery entry does not consume ordinary video onboarding',
    () async {
      final config = _MemoryConfig();
      final routes = <String>[];
      final presenter = GestureGuidePresenter(
        present: (route) async => routes.add(route),
      );
      await presenter.showIfNeeded(config, isQuest: false, isGallery: true);
      expect(routes, isEmpty);
      expect(config.saved, isEmpty);
      await presenter.showIfNeeded(config, isQuest: false);
      expect(routes, ['/video_gesture_guide']);
      expect(config.saved, [ConfigKey.VIDEO_GESTURE_GUIDE_SHOWN]);
      expect(config[ConfigKey.QUEST_GESTURE_GUIDE_SHOWN_V1], isFalse);
    },
  );

  test('a failed presentation releases the in-flight guard', () async {
    final config = _MemoryConfig();
    var fail = true;
    final presenter = GestureGuidePresenter(
      present: (_) async {
        if (fail) throw StateError('navigator unavailable');
      },
    );
    await expectLater(
      presenter.showIfNeeded(config, isQuest: true),
      throwsStateError,
    );
    // AppService catches this failure so navigation continues. A later valid
    // attempt must not inherit the failed future (for example after a reset).
    config.values[ConfigKey.QUEST_GESTURE_GUIDE_SHOWN_V1] = false;
    fail = false;
    await presenter.showIfNeeded(config, isQuest: true);
    expect(config.saved, hasLength(2));
  });
}
