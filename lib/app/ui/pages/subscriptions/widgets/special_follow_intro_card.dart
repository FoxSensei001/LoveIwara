import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 「特别关注」首次引导卡片（挂在订阅页 header 的用户选择器下方）。
///
/// 老版本是一摞写死 `Colors.white` 的 `Container`，直接铺在教程遮罩的黑底上：
/// 深浅色主题都是同一副白字、一个绿色假「已关注」按钮（真按钮早就是 M3 的
/// `ElevatedButton.icon`），信息也散成四块并列的方框，读不出先后。
///
/// 现在整只是一张跟着主题走的卡片：渐变头部 + 编号步骤轨 + 一条管理提示 +
/// 明确的「知道了」。步骤轨代替了原来的假按钮示意图——用户要的是「先点哪、
/// 再点哪」的顺序，不是一张对不上号的截图。
class SpecialFollowIntroCard extends StatelessWidget {
  /// 点「知道了」时收掉整个教程遮罩。
  final VoidCallback onDismiss;

  const SpecialFollowIntroCard({super.key, required this.onDismiss});

  /// 卡片最大宽度；窄屏按屏宽收，两侧各留 16。
  static const double _maxWidth = 380;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = slang.Translations.of(context);
    final size = MediaQuery.sizeOf(context);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: math.min(_maxWidth, size.width - 32),
        // 教程内容挂在目标下方（订阅页 header 一带），太高会顶出屏幕底部——
        // 留出上方那截再封顶，超出的部分交给内部滚动
        constraints: BoxConstraints(maxHeight: size.height * 0.72),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 头部也进滚动区：小屏 + 大字号时它自己就能吃掉整张卡片的高度，
            // 钉住只会让整只 Column 竖着溢出。只有「知道了」常驻可见。
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _IntroHeader(
                      title: t.tutorial.specialFollowFeature,
                      description: t.tutorial.specialFollowDescription,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(text: t.tutorial.stepsTitle),
                          const SizedBox(height: 12),
                          _StepRail(
                            steps: [
                              t.tutorial.stepFollowAuthor,
                              t.tutorial.stepPickSpecial,
                              t.tutorial.stepSwitchHere,
                            ],
                          ),
                          const SizedBox(height: 18),
                          _TipRow(text: t.tutorial.specialFollowManagementTip),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: onDismiss,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(t.tutorial.gotIt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 渐变头部：星标徽章 + 标题 + 一句话说明。
class _IntroHeader extends StatelessWidget {
  final String title;
  final String description;

  const _IntroHeader({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.stars, color: cs.onPrimary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: 0.88),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// 小节标题：左侧一根主色竖条 + 文字（与手势指引页同一套写法）。
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
          // 跟着字号走，否则放大字号后这根竖条只剩半截
          height: MediaQuery.textScalerOf(context).scale(16),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        // 放大字号后这行会比卡片还宽，得让它自己换行
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// 编号步骤轨：圆形序号 + 连接线，读得出先后。
class _StepRail extends StatelessWidget {
  final List<String> steps;

  const _StepRail({required this.steps});

  /// 序号圆直径；连接线与它同轴。
  static const double _badgeSize = 26;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          _StepRow(
            index: i,
            text: steps[i],
            isLast: i == steps.length - 1,
            badgeSize: _badgeSize,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final String text;
  final bool isLast;
  final double badgeSize;

  const _StepRow({
    required this.index,
    required this.text,
    required this.isLast,
    required this.badgeSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // IntrinsicHeight：连接线要长到本行文字的底部，而行高由文字自己撑出来。
    // 只有三行短文本，代价可以忽略。
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: badgeSize,
            child: Column(
              children: [
                Container(
                  width: badgeSize,
                  height: badgeSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.outlineVariant,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              // 最后一行不留底部空档，否则卡片底下会多出一截空白
              padding: EdgeInsets.only(top: 3, bottom: isLast ? 0 : 14),
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部那条「去哪管理」的提示。
class _TipRow extends StatelessWidget {
  final String text;

  const _TipRow({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      // 中性底色而不是 tertiaryContainer：种子色一换那块底就可能变成脏黄绿，
      // 而且 onSurfaceVariant 压在上面的对比度也没保证
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
