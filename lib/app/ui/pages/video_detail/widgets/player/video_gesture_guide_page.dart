import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../../../../i18n/strings.g.dart' as slang;
import 'video_gesture_illustration.dart';

/// 首次进入视频详情前展示的「手势与交互指引」全屏页。
///
/// - 内容按平台区分：桌面端展示键鼠/触控板操作，移动端展示触摸手势；
/// - 布局按可用宽度自适应：窄屏（手机）单列，宽屏（云 PC）两到三列，
///   兼顾云 PC 与窄屏手机两类用户；
/// - 每张卡片以带固定顶/底控制栏的迷你播放器循环演示对应手势动效
///   （见 [AnimatedGestureIllustration]）。
class VideoGestureGuidePage extends StatefulWidget {
  const VideoGestureGuidePage({super.key});

  @override
  State<VideoGestureGuidePage> createState() => _VideoGestureGuidePageState();
}

class _VideoGestureGuidePageState extends State<VideoGestureGuidePage>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // 所有插画共享的动画时钟（累计秒数）。
  late final Ticker _clockTicker;
  final ValueNotifier<double> _clock = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

    _clockTicker = createTicker((elapsed) {
      _clock.value = elapsed.inMicroseconds / 1e6;
    })..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 尊重系统「减弱动态效果」设置。
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _entrance.value = 1.0;
    } else if (!_entrance.isCompleted && !_entrance.isAnimating) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _clockTicker.dispose();
    _clock.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = slang.Translations.of(context);
    final g = t.videoDetail.gestureGuide;
    final bool isDesktop = GetPlatform.isDesktop;

    final List<_GestureItem> controls = isDesktop
        ? [
            _GestureItem(GestureVisual.tap, g.dTap),
            _GestureItem(GestureVisual.doubleTap, g.dDoubleTap),
            _GestureItem(GestureVisual.keys, g.dKeys),
          ]
        : [
            _GestureItem(GestureVisual.tap, g.mTap),
            _GestureItem(GestureVisual.doubleTap, g.mDoubleTap),
            _GestureItem(GestureVisual.hDrag, g.mHorizontalDrag),
            _GestureItem(GestureVisual.vDrag, g.mVerticalDrag),
            _GestureItem(GestureVisual.longPress, g.mLongPress),
          ];

    final List<_GestureItem> transform = isDesktop
        ? [
            _GestureItem(GestureVisual.pinch, g.dTrackpadPinch),
            _GestureItem(GestureVisual.rotate, g.dTrackpadRotate),
            _GestureItem(GestureVisual.ctrlWheel, g.dCtrlWheel),
            _GestureItem(GestureVisual.shiftWheel, g.dShiftWheel),
          ]
        : [
            _GestureItem(GestureVisual.pinch, g.mPinch),
            _GestureItem(GestureVisual.rotate, g.mRotate),
          ];

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 列数：窄屏 1 列（手机），中屏 2 列，宽屏 3 列（云 PC）。
                      final double w = constraints.maxWidth;
                      final int columns = w >= 1040
                          ? 3
                          : w >= 640
                          ? 2
                          : 1;
                      const double gap = 16;
                      const double hPad = 20;
                      const double contentMaxWidth = 1120;
                      final double usable =
                          (w < contentMaxWidth ? w : contentMaxWidth) -
                          hPad * 2;
                      final double cardWidth = columns == 1
                          ? usable
                          : (usable - gap * (columns - 1)) / columns;

                      return Scrollbar(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: contentMaxWidth,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _Header(
                                    title: g.title,
                                    intro: g.firstTimeIntro,
                                    onClose: _dismiss,
                                  ),
                                  const SizedBox(height: 24),
                                  _SectionLabel(text: g.basicTitle),
                                  const SizedBox(height: 12),
                                  _CardWrap(
                                    gap: gap,
                                    cardWidth: cardWidth,
                                    items: controls,
                                    clock: _clock,
                                  ),
                                  const SizedBox(height: 28),
                                  _SectionLabel(text: g.zoomTitle),
                                  const SizedBox(height: 12),
                                  _CardWrap(
                                    gap: gap,
                                    cardWidth: cardWidth,
                                    items: transform,
                                    clock: _clock,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _BottomBar(label: g.startWatching, onStart: _dismiss),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================ 组成部件 ============================

class _Header extends StatelessWidget {
  final String title;
  final String intro;
  final VoidCallback onClose;

  const _Header({
    required this.title,
    required this.intro,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            Color.alphaBlend(
              cs.primaryContainer.withValues(alpha: 0.35),
              cs.surfaceContainerHigh,
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.gesture, color: cs.onPrimary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: onClose,
                icon: Icon(Icons.close, color: cs.onPrimaryContainer),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            intro,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: 0.86),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _CardWrap extends StatelessWidget {
  final double gap;
  final double cardWidth;
  final List<_GestureItem> items;
  final ValueListenable<double> clock;

  const _CardWrap({
    required this.gap,
    required this.cardWidth,
    required this.items,
    required this.clock,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: items
          .map(
            (e) => SizedBox(
              width: cardWidth,
              child: _GestureCard(item: e, clock: clock),
            ),
          )
          .toList(),
    );
  }
}

class _GestureCard extends StatelessWidget {
  final _GestureItem item;
  final ValueListenable<double> clock;

  const _GestureCard({required this.item, required this.clock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: AnimatedGestureIllustration(
              visual: item.visual,
              clock: clock,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Text(
              item.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String label;
  final VoidCallback onStart;

  const _BottomBar({required this.label, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_circle_outline),
              label: Text(label),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GestureItem {
  final GestureVisual visual;
  final String text;
  const _GestureItem(this.visual, this.text);
}
