import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../i18n/strings.g.dart' as slang;

/// Spatial controls only exist in the Quest build. An ordinary Android APK on
/// a headset still uses the ordinary player and must not advertise these inputs.
const usesQuestGestureGuide = appFlavor == 'quest';

enum QuestGuideMedia { video, gallery }

enum QuestGestureVisual {
  select,
  togglePanel,
  playPause,
  seek,
  galleryStick,
  gallerySwipe,
  galleryZoom,
  galleryPan,
  slideshow,
  move,
  scale,
  distance,
  resize,
  navigation,
  hands,
}

@immutable
class QuestGuideLesson {
  const QuestGuideLesson({
    required this.visual,
    required this.title,
    required this.description,
    required this.hint,
    required this.input,
    required this.icon,
  });

  final QuestGestureVisual visual;
  final String title;
  final String description;
  final String hint;
  final String input;
  final IconData icon;

  /// The fullscreen onboarding and the settings entry both render this catalog.
  /// Keep its claims aligned with SpatialInputPoller / ImmersiveActivity and
  /// GalleryStageView, especially the difference between image and window zoom.
  static List<QuestGuideLesson> forMedia(
    slang.Translations t,
    QuestGuideMedia media,
  ) {
    final q = t.videoDetail.gestureGuide.quest;
    return [
      QuestGuideLesson(
        visual: QuestGestureVisual.select,
        title: q.selectTitle,
        description: q.selectBody,
        hint: q.selectHint,
        input: q.trigger,
        icon: Icons.near_me_outlined,
      ),
      QuestGuideLesson(
        visual: QuestGestureVisual.togglePanel,
        title: q.panelTitle,
        description: q.panelBody,
        hint: q.panelHint,
        input: q.trigger,
        icon: Icons.space_dashboard_outlined,
      ),
      if (media == QuestGuideMedia.video) ...[
        QuestGuideLesson(
          visual: QuestGestureVisual.playPause,
          title: q.playTitle,
          description: q.playBody,
          hint: q.playHint,
          input: 'A / X',
          icon: Icons.play_circle_outline,
        ),
        QuestGuideLesson(
          visual: QuestGestureVisual.seek,
          title: q.seekTitle,
          description: q.seekBody,
          hint: q.seekHint,
          input: q.stick,
          icon: Icons.fast_forward_outlined,
        ),
      ] else ...[
        QuestGuideLesson(
          visual: QuestGestureVisual.galleryStick,
          title: q.browseTitle,
          description: q.browseBody,
          hint: q.browseHint,
          input: q.stick,
          icon: Icons.photo_library_outlined,
        ),
        QuestGuideLesson(
          visual: QuestGestureVisual.gallerySwipe,
          title: q.swipeTitle,
          description: q.swipeBody,
          hint: q.swipeHint,
          input: q.trigger,
          icon: Icons.swipe_left_outlined,
        ),
        QuestGuideLesson(
          visual: QuestGestureVisual.galleryZoom,
          title: q.zoomTitle,
          description: q.zoomBody,
          hint: q.zoomHint,
          input: '${q.trigger} + ${q.stick}',
          icon: Icons.zoom_in,
        ),
        QuestGuideLesson(
          visual: QuestGestureVisual.galleryPan,
          title: q.panTitle,
          description: q.panBody,
          hint: q.panHint,
          input: q.trigger,
          icon: Icons.pan_tool_alt_outlined,
        ),
        QuestGuideLesson(
          visual: QuestGestureVisual.slideshow,
          title: q.slideshowTitle,
          description: q.slideshowBody,
          hint: q.slideshowHint,
          input: 'A / X',
          icon: Icons.slideshow_outlined,
        ),
      ],
      QuestGuideLesson(
        visual: QuestGestureVisual.move,
        title: q.moveTitle,
        description: q.moveBody,
        hint: q.moveHint,
        input: q.grip,
        icon: Icons.open_with,
      ),
      QuestGuideLesson(
        visual: QuestGestureVisual.scale,
        title: q.scaleTitle,
        description: q.scaleBody,
        hint: q.scaleHint,
        input: q.bothGrips,
        icon: Icons.width_wide_outlined,
      ),
      QuestGuideLesson(
        visual: QuestGestureVisual.distance,
        title: q.distanceTitle,
        description: q.distanceBody,
        hint: q.distanceHint,
        input: q.stick,
        icon: Icons.swap_vert,
      ),
      QuestGuideLesson(
        visual: QuestGestureVisual.resize,
        title: q.resizeTitle,
        description: q.resizeBody,
        hint: q.resizeHint,
        input: q.trigger,
        icon: Icons.open_in_full,
      ),
      QuestGuideLesson(
        visual: QuestGestureVisual.navigation,
        title: q.navigationTitle,
        description: q.navigationBody,
        hint: q.navigationHint,
        input: 'B / Y · Menu',
        icon: Icons.keyboard_return,
      ),
      QuestGuideLesson(
        visual: QuestGestureVisual.hands,
        title: q.handsTitle,
        description: q.handsBody,
        hint: q.handsHint,
        input: q.handTracking,
        icon: Icons.front_hand_outlined,
      ),
    ];
  }
}
