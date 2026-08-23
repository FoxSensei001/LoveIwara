import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/models/block_rule.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 命中屏蔽规则时，覆盖在「真实卡片」之上的磨砂遮罩。
///
/// 设计为 `Positioned.fill` 使用：它铺满下层真实卡片，因此屏蔽卡片与普通
/// 视频/图库卡片**完全等高**，瀑布流不会高低不齐。下层卡片被高斯模糊 + 遮罩
/// 隐藏，遮罩上居中展示锁徽章、屏蔽原因与「显示 / 为什么」操作。
class BlockedMediaOverlay extends StatelessWidget {
  final BlockMatch match;
  final VoidCallback onReveal;

  const BlockedMediaOverlay({
    super.key,
    required this.match,
    required this.onReveal,
  });

  String _reasonText() {
    final t = slang.t.settings.blockSettings;
    switch (match.rule.type) {
      case BlockRuleType.userId:
        return t.reasonUser;
      case BlockRuleType.regex:
        return t.reasonRegex(value: match.rule.value);
      case BlockRuleType.keyword:
        return t.reasonKeyword(value: match.rule.value);
    }
  }

  IconData _typeIcon() {
    switch (match.rule.type) {
      case BlockRuleType.keyword:
        return Icons.text_fields;
      case BlockRuleType.regex:
        return Icons.code;
      case BlockRuleType.userId:
        return Icons.person_off_outlined;
    }
  }

  void _showWhy(BuildContext context) {
    final t = slang.t.settings.blockSettings;
    showAppDialog(
      GlassAlertDialog(
        title: t.why,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_reasonText()),
            if (match.rule.label != null && match.rule.label!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                match.rule.label!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        actions: [
          GlassDialogAction(
            label: t.manageRules,
            emphasized: false,
            onPressed: () {
              AppService.tryPop();
              NaviService.navigateToBlockSettingsPage();
            },
          ),
          GlassDialogAction(
            label: slang.t.common.confirm,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = slang.t.settings.blockSettings;
    final radius = BorderRadius.circular(14);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.74),
            borderRadius: radius,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 锁徽章
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.9,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: scheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t.blocked,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                // 屏蔽原因
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _typeIcon(),
                        size: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _reasonText(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // 操作
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: onReveal,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: Text(t.reveal, maxLines: 1),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: () => _showWhy(context),
                      icon: const Icon(Icons.help_outline),
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      tooltip: t.why,
                      style: IconButton.styleFrom(
                        backgroundColor: scheme.surfaceContainerHighest
                            .withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// [BlockedMediaOverlay] 的显隐过渡：命中屏蔽规则时淡入放大，揭示后
/// （或规则被解除后）淡出收缩，而不是随宿主卡片的 `if` 分支被瞬间换掉。
///
/// 必须**常驻挂载**（由调用方 `Positioned.fill` 包一层、不加条件判断）才能
/// 让内部的 [AnimationController] 在 `visible` 反复切换间保持存活；`match`
/// 变 `null`（规则解除）或 `visible` 变 `false`（揭示）时都缓存最后一次非空
/// 的 match 继续渲染，动画播完再无内容可看。
class BlockedMediaOverlayFade extends StatefulWidget {
  final BlockMatch? match;
  final bool visible;
  final VoidCallback onReveal;

  const BlockedMediaOverlayFade({
    super.key,
    required this.match,
    required this.visible,
    required this.onReveal,
  });

  @override
  State<BlockedMediaOverlayFade> createState() =>
      _BlockedMediaOverlayFadeState();
}

class _BlockedMediaOverlayFadeState extends State<BlockedMediaOverlayFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: GlassTokens.motionDuration,
    value: widget.visible ? 1.0 : 0.0,
  );

  BlockMatch? _cachedMatch;

  @override
  void initState() {
    super.initState();
    _cachedMatch = widget.match;
  }

  @override
  void didUpdateWidget(covariant BlockedMediaOverlayFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.match != null) _cachedMatch = widget.match;
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = _cachedMatch;
    if (match == null) return const SizedBox.shrink();

    final curved = CurvedAnimation(
      parent: _controller,
      curve: GlassTokens.motionCurve,
      reverseCurve: GlassTokens.motionCurve.flipped,
    );
    return IgnorePointer(
      ignoring: !widget.visible,
      child: FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: BlockedMediaOverlay(match: match, onReveal: widget.onReveal),
        ),
      ),
    );
  }
}

/// 揭示原卡后叠加在缩略图右上角的「重新屏蔽」小标签。
class ReblockChip extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;

  const ReblockChip({super.key, required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      right: 6,
      child: GlassCapsuleReveal(
        visible: visible,
        child: Material(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility_off,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    slang.t.settings.blockSettings.reblock,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
