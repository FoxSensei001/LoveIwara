import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 设置页的「玻璃设置项」组件族。
///
/// 设置页从 Material 控件（SwitchListTile / RadioListTile / ExpansionTile）
/// 迁到液态玻璃时的统一积木。视觉口径与 `glass_surface.dart` 一致：
/// [GlassTokens.fill] 半透明底 + [GlassTokens.stroke] 细描边，**没有 blur**；
/// 选中 / 开关 / 展开这类语义态一律走 [GlassAnimatedColors] /
/// [GlassAnimatedDot]，底色与前景色同一段过渡（只动底色会读成「闪了一下」，
/// 见 glass_morph.dart 顶部词汇表）。
///
/// 目前只服务设置模块；其它页面要复用时再考虑挪进 `widgets/glass/`。

/// 分组卡片容器：一组设置项外面那层圆角玻璃壳。
///
/// 替代原先各页手写的 `Card(elevation: 0, shape: RoundedRectangleBorder(...))`。
/// [children] 之间自动插入左缩进的发丝分隔线（与左侧导航列表同一视觉语言）；
/// 想自己控制分隔（比如首行）传 [divided] = false 的子项组合即可。
class GlassSettingSection extends StatelessWidget {
  /// 分组标题（可选）；传入时渲染在卡片顶部，用主题色小字。
  final String? title;

  /// 分组内的设置项（[GlassSettingTile] / [GlassSwitchItem] / …）。
  final List<Widget> children;

  /// 子项之间是否自动插发丝分隔线。
  final bool divided;

  const GlassSettingSection({super.key, this.title, required this.children, this.divided = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: GlassTokens.fill(theme.colorScheme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GlassTokens.stroke(theme.colorScheme),
          width: GlassTokens.strokeWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                title!,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (divided && i != children.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// 通用设置行：图标 + 标题（+ 副标题）+ 尾部任意控件。
///
/// 替代 `Card` + `ListTile` 组合。选中态（左栏导航、单选列表）底色 / 图标色 /
/// 文字色同一段过渡；点击走 InkWell 涟漪（玻璃壳自身不按压形变，行级控件
/// 按压反馈交给涟漪即可）。
class GlassSettingTile extends StatelessWidget {
  final IconData? icon;

  /// 自定义前缀（优先于 [icon]，例如头像）。
  final Widget? leading;

  final Widget title;
  final Widget? subtitle;

  /// 尾部控件（chevron、开关、徽标……）。
  final Widget? trailing;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 选中态：底色浅高亮，图标与标题染色。
  final bool selected;

  const GlassSettingTile({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return GlassAnimatedColors(
      colors: [
        // 底色
        selected
            ? cs.secondaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        // 图标色
        selected ? cs.primary : cs.onSurfaceVariant,
        // 标题色
        selected ? cs.primary : cs.onSurface,
      ],
      builder: (context, c) => Material(
        color: c[0],
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ] else if (icon != null) ...[
                  Icon(icon, size: 20, color: c[1]),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: (theme.textTheme.bodyMedium ?? const TextStyle())
                            .copyWith(
                              fontWeight: selected ? FontWeight.w500 : null,
                              color: c[2],
                            ),
                        child: title,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        DefaultTextStyle(
                          style: (theme.textTheme.bodySmall ?? const TextStyle())
                              .copyWith(color: cs.onSurfaceVariant),
                          child: subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 玻璃拨钮（轨道 + 圆点）。
///
/// [GlassSwitchItem] / [GlassSettingTile] 的尾部开关件，也可单独使用。
/// 轨道底色与圆点色作为一组语义色交给 [GlassAnimatedColors] 同步过渡；
/// 圆点位移走 [GlassTokens.motionDuration] 与色值同拍。轨道尺寸对齐 Material
/// Switch（52 x 32），保证替换后行高不跳。
class GlassToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const GlassToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 闭包里拿不到空提升，先落成局部非空变量。
    final ValueChanged<bool>? cb = onChanged;
    return GlassAnimatedColors(
      colors: [
        value ? cs.primary : cs.surfaceContainerHighest,
        value ? cs.onPrimary : cs.outline,
      ],
      builder: (context, c) {
        const trackWidth = 52.0;
        const trackHeight = 32.0;
        return GestureDetector(
          // 拨钮自身也要能点（不只靠整行 onTap）
          onTap: cb == null ? null : () => cb(!value),          child: Container(
            width: trackWidth,
            height: trackHeight,
            decoration: BoxDecoration(
              color: c[0],
              borderRadius: BorderRadius.circular(trackHeight / 2),
              border: Border.all(
                color: GlassTokens.stroke(cs),
                width: GlassTokens.strokeWidth,
              ),
            ),
            child: AnimatedAlign(
              duration: GlassTokens.motionDuration,
              curve: GlassTokens.motionCurve,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: trackHeight - 8,
                  height: trackHeight - 8,
                  decoration: BoxDecoration(color: c[1], shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 开关设置行：替代 `SwitchListTile`。
///
/// 整行可点切换；禁用态整行降透明度（Material 惯例）而不是换一套灰色。
class GlassSwitchItem extends StatelessWidget {
  final IconData? icon;
  final Widget title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const GlassSwitchItem({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return GlassSettingTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: GlassToggle(value: value, onChanged: onChanged),
      onTap: enabled ? () => onChanged!(!value) : null,
    );
  }
}

/// 单选设置行：替代 `RadioListTile`。
///
/// 行尾是「描边圆圈 + 选中实心点」，点的显隐走 [GlassAnimatedDot]，
/// 圈与点的颜色随选中态经 [GlassAnimatedColors] 过渡。
/// 与 [GlassSegmentedControl] 的分工：选项少（≤3）且都是短词时页面用分段胶囊；
/// 选项多 / 带副标题 / 在弹窗里时用这里。
class GlassChoiceItem<T> extends StatelessWidget {
  final T value;

  /// 当前选中值（由父级持有），等于 [value] 即选中。
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final Widget title;
  final Widget? subtitle;

  const GlassChoiceItem({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selected = value == groupValue;
    // 闭包里拿不到空提升，先落成局部非空变量。
    final ValueChanged<T>? cb = onChanged;
    return GlassSettingTile(
      title: title,
      subtitle: subtitle,
      selected: selected,
      onTap: cb == null ? null : () => cb(value),
      trailing: GlassAnimatedColors(
        colors: [
          selected ? cs.primary : cs.outlineVariant,
        ],
        builder: (context, c) => Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c[0], width: 2),
          ),
          child: Center(
            child: GlassAnimatedDot(
              visible: selected,
              size: 10,
              color: cs.primary,
              borderColor: Colors.transparent,
              borderWidth: 0,
            ),
          ),
        ),
      ),
    );
  }
}

/// 可展开卡片：替代 `ExpansionTile`。
///
/// 头部一行（图标 / 标题 / 副标题）+ 展开箭头，箭头旋转与内容高度过渡
/// 都不许硬切：箭头走 `AnimatedRotation`，内容用 `AnimatedCrossFade`
/// （淡出收起再淡入展开），时长统一 [GlassTokens.motionDuration]。
/// 整张卡片自带玻璃壳，多张并排时直接铺在列表里即可。
class GlassExpansionCard extends StatefulWidget {
  final IconData? icon;
  final Widget title;
  final Widget? subtitle;

  /// 展开区域的内容。
  final List<Widget> children;

  /// 点击头部是否展开（列表只读展示时置 false）。
  final bool expandable;

  final bool initiallyExpanded;

  const GlassExpansionCard({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.children,
    this.expandable = true,
    this.initiallyExpanded = false,
  });

  @override
  State<GlassExpansionCard> createState() => _GlassExpansionCardState();
}

class _GlassExpansionCardState extends State<GlassExpansionCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: GlassTokens.fill(cs),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GlassTokens.stroke(cs),
          width: GlassTokens.strokeWidth,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassSettingTile(
            icon: widget.icon,
            title: widget.title,
            subtitle: widget.subtitle,
            onTap: widget.expandable
                ? () => setState(() => _expanded = !_expanded)
                : null,
            trailing: widget.expandable
                ? AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: GlassTokens.motionDuration,
                    curve: GlassTokens.motionCurve,
                    child: Icon(
                      Icons.expand_more,
                      size: 22,
                      color: cs.onSurfaceVariant,
                    ),
                  )
                : null,
          ),
          AnimatedCrossFade(
            duration: GlassTokens.motionDuration,
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
                ...widget.children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
