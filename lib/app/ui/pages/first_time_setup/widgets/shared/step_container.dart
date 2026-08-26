import 'package:flutter/material.dart';

import 'layouts.dart';

/// 步骤底部的提示条。
///
/// 过去五个步骤各写各的：主题步用 `primaryContainer` + 调色板图标，
/// 基础步用 `primaryContainer` + 灯泡，播放器步用 `primaryContainer` +
/// 「更新」图标，网络步用 `secondaryContainer` + wifi，欢迎步干脆没有。
/// 同一句「这些设置以后都能改」在四个步骤里长着四张脸。
///
/// 现在只有两种语气，且由这里决定长相：
///
///   - [StepTipBanner.info]（默认）：说明性提示，主题色底。
///   - [StepTipBanner.warning]：需要用户留意的后果（如「重启后生效」），
///     次要容器色底 —— 这是**有意**的区分，不是漏改。
class StepTipBanner extends StatelessWidget {
  final String text;
  final bool warning;

  const StepTipBanner.info(this.text, {super.key}) : warning = false;

  const StepTipBanner.warning(this.text, {super.key}) : warning = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isNarrow = stepIsNarrow(context);

    final background = warning ? cs.secondaryContainer : cs.primaryContainer;
    final foreground = warning
        ? cs.onSecondaryContainer
        : cs.onPrimaryContainer;
    final icon = warning ? Icons.error_outline : Icons.lightbulb_outline;

    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : StepMetrics.cardPadding),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(StepMetrics.cardRadius),
      ),
      child: Row(
        // 文案换行后图标要贴着第一行，不能跟着整段一起居中。
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Icon(icon, color: foreground, size: 20),
          Expanded(
            child: Text(
              text,
              style:
                  (isNarrow
                          ? theme.textTheme.bodySmall
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(color: foreground, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
