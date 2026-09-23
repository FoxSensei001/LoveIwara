import 'package:flutter/material.dart';

/// AI 族界面（AI 搜索、AI 设置、供应商详情、接入向导、模型选择、翻译设置、
/// 小尾巴 AI 一言）共用的几块小积木。
///
/// ⭐ 为什么要有这个文件：收口前「信息卡」「小胶囊」「标签 + 输入框」「一行
/// 提示」这四样东西在七个文件里各写了三四份（同一个 `surfaceContainerHighest
/// @0.45 + 圆角 12` 抄了四遍，同一个 `圆角 6 + secondaryContainer@0.7 + 10px`
/// 抄了四遍），改一处就和另外三处长得不一样。这里只放**视觉**，不放业务。

/// 语气：决定胶囊 / 提示行的颜色。
enum AiTone { neutral, accent, success, warning, error }

extension on AiTone {
  Color foreground(ColorScheme cs) => switch (this) {
    AiTone.neutral => cs.onSurfaceVariant,
    AiTone.accent => cs.primary,
    AiTone.success => Colors.green.shade600,
    AiTone.warning => cs.tertiary,
    AiTone.error => cs.error,
  };

  Color background(ColorScheme cs) => switch (this) {
    AiTone.neutral => cs.surfaceContainerHighest.withValues(alpha: 0.7),
    AiTone.accent => cs.primaryContainer.withValues(alpha: 0.55),
    AiTone.success => Colors.green.withValues(alpha: 0.14),
    AiTone.warning => cs.tertiaryContainer.withValues(alpha: 0.55),
    AiTone.error => cs.errorContainer.withValues(alpha: 0.55),
  };
}

/// 一只小胶囊：供应商种类、模型能力、「缺密钥」「已停用」这类状态、「已改」标。
///
/// ⭐ 状态一律用**带字的**胶囊，不用小圆点：10px 的圆点撑不起「这条配置用不了」
/// 这么重要的事，而且色弱用户分不清红绿点。
class AiTag extends StatelessWidget {
  const AiTag(this.label, {super.key, this.tone = AiTone.neutral, this.icon});

  final String label;
  final AiTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = tone.foreground(cs);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tone.background(cs),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// 一块信息卡：浅底 + 细边 + 圆角 12。AI 搜索的方案卡、试跑结果块都是它。
class AiInfoCard extends StatelessWidget {
  const AiInfoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 12),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}

/// 一行提示：图标 + 字，颜色随语气。报错、警告、成功反馈共用这一种长相。
class AiNoticeLine extends StatelessWidget {
  const AiNoticeLine(
    this.message, {
    super.key,
    this.tone = AiTone.error,
    this.icon,
    this.maxLines,
  });

  final String message;
  final AiTone tone;
  final IconData? icon;
  final int? maxLines;

  IconData get _defaultIcon => switch (tone) {
    AiTone.error => Icons.error_outline,
    AiTone.warning => Icons.info_outline,
    AiTone.success => Icons.check_circle_outline,
    AiTone.neutral || AiTone.accent => Icons.info_outline,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = tone.foreground(cs);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1.5),
          child: Icon(icon ?? _defaultIcon, size: 14, color: fg),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            maxLines: maxLines,
            overflow: maxLines == null ? null : TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, height: 1.4, color: fg),
          ),
        ),
      ],
    );
  }
}

/// 「标签 + 控件」一组：小标题一行，下面是输入框（或别的控件），可选一行脚注。
///
/// [trailing] 摆在标签行右端（「恢复默认」之类的小钮）。
class AiLabeledField extends StatelessWidget {
  const AiLabeledField({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
    this.footer,
  });

  final String label;
  final Widget child;
  final Widget? trailing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        child,
        if (footer != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: cs.onSurfaceVariant,
              ),
              child: footer!,
            ),
          ),
      ],
    );
  }
}

/// 模型列表里的一行：名字 + 等宽 id + 能力胶囊，左边勾选框。
///
/// 接入向导的「选模型」一步与模型选择弹窗是同一个概念，共用这一行。
class AiModelCheckRow extends StatelessWidget {
  const AiModelCheckRow({
    super.key,
    required this.title,
    required this.checked,
    required this.onChanged,
    this.modelId,
    this.tags = const [],
  });

  final String title;

  /// 与 [title] 相同时不重复显示。
  final String? modelId;
  final List<Widget> tags;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final id = modelId;
    final showId = id != null && id.isNotEmpty && id != title;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: (v) => onChanged(v ?? false),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (showId)
                    Text(
                      id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  if (tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(spacing: 4, runSpacing: 4, children: tags),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
