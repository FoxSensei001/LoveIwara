import 'config_service.dart';

/// Serializes first-entry guidance across video and gallery navigation. Every
/// caller waits for the visible guide, including callers arriving after its
/// persisted flag has already been set.
class GestureGuidePresenter {
  GestureGuidePresenter({required this.present});

  final Future<void> Function(String location) present;
  Future<void>? _pending;

  Future<void> showIfNeeded(
    ConfigService config, {
    required bool isQuest,
    bool isGallery = false,
  }) {
    if (isGallery && !isQuest) return Future<void>.value();
    return _pending ??= _show(
      config,
      isQuest: isQuest,
      isGallery: isGallery,
    ).whenComplete(() => _pending = null);
  }

  Future<void> _show(
    ConfigService config, {
    required bool isQuest,
    required bool isGallery,
  }) async {
    final key = isQuest
        ? ConfigKey.QUEST_GESTURE_GUIDE_SHOWN_V1
        : ConfigKey.VIDEO_GESTURE_GUIDE_SHOWN;
    if (config[key] == true) return;
    await config.setSetting(key, true, save: true);
    await present(
      isQuest && isGallery
          ? '/video_gesture_guide?media=gallery'
          : '/video_gesture_guide',
    );
  }
}
