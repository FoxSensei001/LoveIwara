import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../i18n/strings.g.dart' as slang;

/// 视频播放器手势 / 交互指引弹窗，按当前平台展示对应的操作说明。
class VideoGestureGuideDialog extends StatelessWidget {
  const VideoGestureGuideDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const VideoGestureGuideDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final g = t.videoDetail.gestureGuide;
    final theme = Theme.of(context);
    final isDesktop = GetPlatform.isDesktop;

    final List<_GuideEntry> basic = isDesktop
        ? [
            _GuideEntry(Icons.ads_click, g.dTap),
            _GuideEntry(Icons.touch_app, g.dDoubleTap),
            _GuideEntry(Icons.keyboard, g.dKeys),
          ]
        : [
            _GuideEntry(Icons.ads_click, g.mTap),
            _GuideEntry(Icons.touch_app, g.mDoubleTap),
            _GuideEntry(Icons.swap_horiz, g.mHorizontalDrag),
            _GuideEntry(Icons.swap_vert, g.mVerticalDrag),
            _GuideEntry(Icons.timer_outlined, g.mLongPress),
          ];

    final List<_GuideEntry> zoom = isDesktop
        ? [
            _GuideEntry(Icons.pinch, g.dTrackpadPinch),
            _GuideEntry(Icons.rotate_right, g.dTrackpadRotate),
            _GuideEntry(Icons.zoom_in, g.dCtrlWheel),
            _GuideEntry(Icons.rotate_90_degrees_ccw, g.dShiftWheel),
            _GuideEntry(Icons.open_with, g.dDrag),
          ]
        : [
            _GuideEntry(Icons.pinch, g.mPinch),
            _GuideEntry(Icons.rotate_right, g.mRotate),
            _GuideEntry(Icons.open_with, g.mPan),
          ];

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.gesture, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(g.title)),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(theme, g.basicTitle),
              ...basic.map((e) => _row(theme, e)),
              const SizedBox(height: 14),
              _sectionTitle(theme, g.zoomTitle),
              ...zoom.map((e) => _row(theme, e)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(g.restoreTip, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.close),
        ),
      ],
    );
  }

  Widget _sectionTitle(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 2),
    child: Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    ),
  );

  Widget _row(ThemeData theme, _GuideEntry e) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(e.icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(child: Text(e.text, style: theme.textTheme.bodyMedium)),
      ],
    ),
  );
}

class _GuideEntry {
  final IconData icon;
  final String text;
  const _GuideEntry(this.icon, this.text);
}
