import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';

/// 向导里「点一下去改某个值」的设置行。
///
/// 开关行直接用 [GlassSwitchItem]、单选行用 [GlassChoiceItem]，
/// 剩下这一类（快进秒数、语言、Anime4K 预设、色觉辅助……）过去是三种长相：
///
///   - `NumberSettingTile`：图标底板 + 右侧胶囊数字，无箭头；
///   - 语言选择：图标底板 + 右侧一枚带图标的文字按钮，标签「修改」还是
///     硬编码中文；
///   - Anime4K / 色觉辅助：各自带投影的独立卡片，直接嵌在设置卡里，
///     于是卡中有卡、还多出一层阴影。
///
/// 现在统一成 [GlassSettingTile]：左图标、标题（+ 副标题）、右侧当前值 + 箭头，
/// 行高、留白、分隔线缩进都与同卡片里的开关行一致。
class StepActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  /// 右侧显示的当前值。
  final String value;

  /// 当前值是否为「已生效的非默认选择」：是则用主题色，读得出来「改过了」。
  final bool valueHighlighted;

  final VoidCallback onTap;

  const StepActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.subtitle,
    this.valueHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GlassSettingTile(
      icon: icon,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 值可能很长（语言名、预设名），让它先换行/省略，别把标题挤没。
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueHighlighted ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 20, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}
