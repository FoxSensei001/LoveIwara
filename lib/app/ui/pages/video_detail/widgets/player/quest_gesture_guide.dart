import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';

import '../../../../../../i18n/strings.g.dart' as slang;
import 'quest_gesture_guide_content.dart';
import 'video_gesture_illustration.dart';

/// The Quest variant lives in the existing 2D guide route. A single large,
/// selectable demonstration keeps controller labels legible at panel distance
/// and avoids rendering a dozen looping scenes at once on the headset.
class QuestGestureGuide extends StatefulWidget {
  const QuestGestureGuide({
    super.key,
    required this.clock,
    required this.onClose,
    this.initialMedia = QuestGuideMedia.video,
  });

  final ValueListenable<double> clock;
  final VoidCallback onClose;
  final QuestGuideMedia initialMedia;

  @override
  State<QuestGestureGuide> createState() => _QuestGestureGuideState();
}

class _QuestGestureGuideState extends State<QuestGestureGuide> {
  final _scroll = ScrollController();
  final _demonstration = GlobalKey();
  late QuestGuideMedia _media = widget.initialMedia;
  int _selected = 0;
  late double _startedAt = widget.clock.value;
  double? _pausedAt;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _select(int index, {bool reveal = false}) {
    setState(() {
      _selected = index;
      _startedAt = widget.clock.value;
      // Selecting a lesson preserves the user's pause preference.
      if (_pausedAt != null) _pausedAt = 0;
    });
    if (reveal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final target = _demonstration.currentContext;
        if (target == null) return;
        Scrollable.ensureVisible(
          target,
          alignment: .05,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  void _togglePause() {
    setState(() {
      if (_pausedAt == null) {
        _pausedAt = math.max(0, widget.clock.value - _startedAt);
      } else {
        _startedAt = widget.clock.value - _pausedAt!;
        _pausedAt = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final q = t.videoDetail.gestureGuide.quest;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final lessons = QuestGuideLesson.forMedia(t, _media);
    final lesson = lessons[_selected];
    final reduced = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _scroll,
                child: SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'META QUEST',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.5,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      q.title,
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -.6,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      q.intro,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            height: 1.5,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              GlassIconButton(
                                key: const ValueKey('quest_guide_close'),
                                icon: const Icon(Icons.close),
                                tooltip: t.common.close,
                                standalone: true,
                                size: 60,
                                onPressed: widget.onClose,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _QuestMediaPicker(
                            key: const ValueKey('quest_guide_media'),
                            media: _media,
                            onChanged: (index) {
                              setState(() {
                                _media = QuestGuideMedia.values[index];
                                _selected = 0;
                                _startedAt = widget.clock.value;
                                if (_pausedAt != null) _pausedAt = 0;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          LayoutBuilder(
                            key: _demonstration,
                            builder: (context, constraints) {
                              final illustration = Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Semantics(
                                    image: true,
                                    label: lesson.title,
                                    child: AnimatedQuestGestureIllustration(
                                      key: const ValueKey(
                                        'quest_guide_illustration',
                                      ),
                                      visual: lesson.visual,
                                      media: _media,
                                      clock: widget.clock,
                                      startedAt: _startedAt,
                                      pausedAt: _pausedAt,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            reduced ? q.still : q.looping,
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: cs.onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                        if (!reduced) ...[
                                          GlassIconButton(
                                            key: const ValueKey(
                                              'quest_guide_pause',
                                            ),
                                            size: 60,
                                            icon: Icon(
                                              _pausedAt == null
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                            ),
                                            tooltip: _pausedAt == null
                                                ? q.pauseDemo
                                                : q.resumeDemo,
                                            onPressed: _togglePause,
                                          ),
                                          const SizedBox(width: 8),
                                          GlassIconButton(
                                            key: const ValueKey(
                                              'quest_guide_replay',
                                            ),
                                            size: 60,
                                            icon: const Icon(
                                              Icons.replay_rounded,
                                            ),
                                            tooltip: q.replay,
                                            onPressed: () {
                                              setState(() {
                                                _startedAt = widget.clock.value;
                                                _pausedAt = null;
                                              });
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              );
                              final details = _LessonDetails(
                                lesson: lesson,
                                position: q.lessonCount(
                                  current: _selected + 1,
                                  total: lessons.length,
                                ),
                                onPrevious: _selected == 0
                                    ? null
                                    : () => _select(_selected - 1),
                                onNext: _selected == lessons.length - 1
                                    ? null
                                    : () => _select(_selected + 1),
                              );
                              if (constraints.maxWidth >= 900 &&
                                  MediaQuery.textScalerOf(context).scale(16) <
                                      24) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 6, child: illustration),
                                    const SizedBox(width: 32),
                                    Expanded(flex: 4, child: details),
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  illustration,
                                  const SizedBox(height: 24),
                                  details,
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            q.catalog,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final scaled =
                                  MediaQuery.textScalerOf(context).scale(16) >=
                                  24;
                              final columns =
                                  !scaled && constraints.maxWidth >= 900
                                  ? 3
                                  : !scaled && constraints.maxWidth >= 580
                                  ? 2
                                  : 1;
                              final width =
                                  (constraints.maxWidth - (columns - 1) * 12) /
                                  columns;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  for (
                                    var index = 0;
                                    index < lessons.length;
                                    index++
                                  )
                                    SizedBox(
                                      width: width,
                                      child: _LessonChoice(
                                        key: ValueKey(
                                          'quest_lesson_${lessons[index].visual.name}',
                                        ),
                                        lesson: lessons[index],
                                        index: index,
                                        selected: index == _selected,
                                        onTap: () =>
                                            _select(index, reveal: true),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            q.scopeNote,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                  top: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: .4),
                  ),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _QuestGuideAction(
                    key: const ValueKey('quest_guide_done'),
                    label: q.done,
                    icon: Icons.check_rounded,
                    onPressed: widget.onClose,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonDetails extends StatelessWidget {
  const _LessonDetails({
    required this.lesson,
    required this.position,
    required this.onPrevious,
    required this.onNext,
  });

  final QuestGuideLesson lesson;
  final String position;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final q = slang.Translations.of(context).videoDetail.gestureGuide.quest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          position,
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            lesson.input,
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          lesson.title,
          key: const ValueKey('quest_guide_lesson_title'),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          lesson.description,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                lesson.hint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GlassIconButton(
              key: const ValueKey('quest_guide_previous'),
              size: 60,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: q.previous,
              standalone: true,
              onPressed: onPrevious,
            ),
            IntrinsicWidth(
              child: _QuestGuideAction(
                key: const ValueKey('quest_guide_next'),
                label: q.next,
                icon: Icons.arrow_forward_rounded,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LessonChoice extends StatelessWidget {
  const _LessonChoice({
    super.key,
    required this.lesson,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final QuestGuideLesson lesson;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: selected
          ? cs.primaryContainer.withValues(alpha: .45)
          : cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        selected: selected,
        minTileHeight: 64,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Text(
          (index + 1).toString().padLeft(2, '0'),
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? cs.primary : cs.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        minLeadingWidth: 20,
        horizontalTitleGap: 12,
        title: Text(
          lesson.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: Icon(
          selected ? Icons.play_circle_outline : lesson.icon,
          size: 20,
          color: selected ? cs.primary : cs.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Two full-size choices stay readable when a narrow panel / large text cannot
/// fit even the selected label inside the usual dropdown pill.
class _QuestMediaPicker extends StatelessWidget {
  const _QuestMediaPicker({
    super.key,
    required this.media,
    required this.onChanged,
  });

  final QuestGuideMedia media;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final q = slang.Translations.of(context).videoDetail.gestureGuide.quest;
    final cs = Theme.of(context).colorScheme;
    final items = [
      GlassSegmentItem(
        label: q.videoTab,
        icon: const Icon(Icons.ondemand_video_outlined),
      ),
      GlassSegmentItem(
        label: q.galleryTab,
        icon: const Icon(Icons.photo_library_outlined),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final minimum = GlassSegmentedControl.minWidthFor(
          context,
          items,
          minVisibleItems: 2,
        );
        if (constraints.maxWidth >= minimum) {
          return GlassAdaptiveSegmentedControl(
            height: 60,
            minVisibleItems: 2,
            items: items,
            selectedIndex: media.index,
            onChanged: onChanged,
          );
        }
        return RadioGroup<int>(
          groupValue: media.index,
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                if (index > 0) const SizedBox(height: 8),
                Material(
                  color: index == media.index
                      ? cs.primaryContainer.withValues(alpha: .45)
                      : cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 60),
                    child: RadioListTile<int>(
                      value: index,
                      title: Text(items[index].label),
                      secondary: items[index].icon,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Uses the app's press behavior, with room for a 60dp target and wrapping
/// translations instead of the composer's fixed-height, single-line submit.
class _QuestGuideAction extends StatefulWidget {
  const _QuestGuideAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  State<_QuestGuideAction> createState() => _QuestGuideActionState();
}

class _QuestGuideActionState extends State<_QuestGuideAction> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: FocusableActionDetector(
        enabled: enabled,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GlassPressable(
          enabled: enabled,
          onTap: widget.onPressed,
          builder: (context, pressed) => Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: !enabled
                  ? cs.surfaceContainerHighest
                  : pressed
                  ? Color.alphaBlend(
                      Colors.black.withValues(alpha: .08),
                      cs.primary,
                    )
                  : cs.primary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _focused ? cs.onPrimary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 22,
                  color: enabled ? cs.onPrimary : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: enabled ? cs.onPrimary : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
