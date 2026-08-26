import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// # 输入弹窗（composer）玻璃词汇表
///
/// 发评论 / 发帖 / 回复 / 编辑这一族弹窗共用同一套骨架：
///
/// ```
/// ┌ 标题行：[图标] 标题 ················ [玻璃关闭圆钮]
/// ├ 输入域：GlassInputSurface(TextField / EnhancedEmojiTextField)
/// ├ 工具行：GlassComposerToolbar（翻译 · 表情 · MD 帮助 · 预览）
/// └ 动作行：GlassComposerActions（同意规则 · 取消 · 提交）
/// ```
///
/// 与 header 上的词汇表（`glass_morph.dart`）遵守同一套时值/曲线，并共享
/// [GlassTokens] 的底色与描边——弹窗里的控件和 header 上的胶囊是同一种材质，
/// 只是尺度不同。
///
/// 使用方要么直接用 `BaseDialogInput` / `BaseBottomSheetInput` 这两个底座
/// （它们已接好本文件的原语），要么在自定义弹窗里按上面的顺序拼这几块——
/// 别再各写各的 `IconButton` + `ElevatedButton`。

/// 玻璃输入域外壳：半透明底 + 细描边 + 大圆角，包住一个无边框的输入控件。
///
/// 输入控件自身的 `InputDecoration` 用 [glassFieldDecoration] 生成
/// （去掉 Material 的下划线/外框，改由这层壳提供视觉边界）。
class GlassInputSurface extends StatelessWidget {
  const GlassInputSurface({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.padding = EdgeInsets.zero,
    this.error = false,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  /// 校验失败：描边转错误色。壳本身不显示错误文案，那仍由调用方在下方渲染。
  final bool error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(
          alpha: cs.brightness == Brightness.dark ? 0.45 : 0.55,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: error ? cs.error : GlassTokens.stroke(cs),
          width: error ? 1.0 : 0.6,
        ),
      ),
      child: child,
    );
  }
}

/// 配 [GlassInputSurface] 用的无边框 `InputDecoration`。
///
/// 边界由外层玻璃壳提供，这里只负责 hint / 图标 / 内边距；[errorText] 与
/// [counterText] 仍可正常透出。
InputDecoration glassFieldDecoration(
  BuildContext context, {
  String? hint,
  String? label,
  IconData? icon,
  String? errorText,
  String? counterText,
}) {
  final cs = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hint,
    labelText: label,
    hintStyle: TextStyle(color: cs.onSurfaceVariant),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    prefixIcon: icon == null ? null : Icon(icon, color: cs.onSurfaceVariant),
    errorText: errorText,
    counterText: counterText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

/// composer 的工具行：把翻译 / 表情 / Markdown 帮助 / 预览这些副操作聚进
/// 一只玻璃胶囊，右对齐。
///
/// 每一项都是可选的（传 null 即不出现），并且用 [GlassGroupSlot] 包装——
/// 「有内容才能翻译」这类条件可用性变化时，按钮是被平滑挤进/挤出胶囊的，
/// 而不是瞬间出现。
class GlassComposerToolbar extends StatelessWidget {
  const GlassComposerToolbar({
    super.key,
    this.onTranslate,
    this.translateEnabled = true,
    this.onEmoji,
    this.onMarkdownHelp,
    this.onPreview,
    this.alignment = MainAxisAlignment.end,
  });

  /// 传 null 表示本弹窗不提供翻译；传了但 [translateEnabled] 为 false
  /// 表示当前不可用（如正文为空）。
  final VoidCallback? onTranslate;
  final bool translateEnabled;
  final VoidCallback? onEmoji;
  final VoidCallback? onMarkdownHelp;
  final VoidCallback? onPreview;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final children = <Widget>[
      if (onTranslate != null)
        GlassIconButton(
          icon: const Icon(Icons.translate),
          tooltip: t.common.translate,
          onPressed: translateEnabled ? onTranslate : null,
        ),
      if (onEmoji != null)
        GlassIconButton(
          icon: const Icon(Icons.emoji_emotions_outlined),
          tooltip: t.emoji.selectEmoji,
          onPressed: onEmoji,
        ),
      if (onMarkdownHelp != null)
        GlassIconButton(
          icon: const Icon(Icons.help_outline),
          tooltip: t.markdown.markdownSyntax,
          onPressed: onMarkdownHelp,
        ),
      if (onPreview != null)
        GlassIconButton(
          icon: const Icon(Icons.preview),
          tooltip: t.common.preview,
          onPressed: onPreview,
        ),
    ];
    if (children.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: alignment,
      children: [GlassButtonGroup(children: children)],
    );
  }
}

/// composer 的动作行：左侧规则状态徽标（可选）· 右侧提交键。
///
/// 不放取消键——每张弹窗右上角已经有玻璃关闭圆钮，底部再来一个「取消」是
/// 同一件事的第二个入口，白白占掉视觉权重。
///
/// 提交键是整行唯一的实心主色控件，视线自然落到它上面；加载中时文字原位
/// 换成转圈（尺寸不跳）。
class GlassComposerActions extends StatelessWidget {
  const GlassComposerActions({
    super.key,
    required this.onSubmit,
    this.submitText,
    this.isLoading = false,
    this.rulesAgreed,
    this.onRulesTap,
    this.onBlockedTap,
  });

  /// 为 null 表示不可提交（内容为空 / 超长 / 冷却中 / 未同意规则）。
  final VoidCallback? onSubmit;
  final String? submitText;
  final bool isLoading;

  /// 非 null 时在左侧显示规则状态徽标；值代表当前是否已同意。
  final bool? rulesAgreed;
  final VoidCallback? onRulesTap;

  /// 不可提交时点提交键的兜底反馈（例如未同意规则→弹出规则全文）。
  ///
  /// 光把按钮置灰等于「点了没反应」，用户不知道卡在哪一步；给出这个回调后
  /// 按钮仍保持禁用外观、但可点，点下去直接把用户送到该处理的那一步。
  final VoidCallback? onBlockedTap;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final agreed = rulesAgreed;
    return Row(
      children: [
        if (agreed != null)
          Flexible(
            child: Align(
              alignment: Alignment.centerLeft,
              child: GlassRulesBadge(agreed: agreed, onTap: onRulesTap),
            ),
          ),
        const Spacer(),
        const SizedBox(width: 8),
        GlassSubmitButton(
          onPressed: onSubmit,
          onBlockedTap: onBlockedTap,
          isLoading: isLoading,
          label: submitText ?? t.common.send,
        ),
      ],
    );
  }
}

/// 规则同意状态徽标：软色胶囊（未同意=中性、已同意=绿），点按打开规则全文。
///
/// 与列表项上的软色 chip 同一套配方（12% 透明度底 + 圆角 999 + 小图标 +
/// 小号粗体字），比复选框更像「一个可点开查看的状态」，也不会让人误以为
/// 勾一下就会把内容发出去。
class GlassRulesBadge extends StatelessWidget {
  const GlassRulesBadge({super.key, required this.agreed, this.onTap});

  final bool agreed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    // 已同意=绿（状态达成），未同意=中性（待办，不是错误——别用红吓人）
    final Color color = agreed ? Colors.green : cs.onSurfaceVariant;
    return GlassPressable(
      onTap: onTap,
      builder: (context, pressed) => AnimatedContainer(
        duration: GlassTokens.pressDuration,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: pressed ? 0.20 : 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 勾 ↔ 书本图标交叉过渡，同意的那一刻能被看见
            GlassAnimatedIcon(
              icon: Icon(
                agreed ? Icons.verified_rounded : Icons.article_outlined,
                size: 15,
                color: color,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                t.common.agreeToRules,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 提交键：主色实心胶囊，高度与玻璃胶囊一致（[GlassTokens.pillHeight]），
/// 按下带同款缩放反馈；加载中时标签原位换成转圈。
///
/// 「禁用」分两种：
///   - [onPressed] 与 [onBlockedTap] 都为 null：纯禁用，不可点（如内容为空——
///     缺什么用户自己看得见）；
///   - [onPressed] 为 null 但给了 [onBlockedTap]：保持禁用外观但可点，点下去
///     跳到该处理的那一步（如未同意规则→弹规则全文）。置灰且点不动会让人
///     以为是坏了。
class GlassSubmitButton extends StatelessWidget {
  const GlassSubmitButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
    this.onBlockedTap,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;
  final VoidCallback? onBlockedTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool enabled = onPressed != null && !isLoading;
    final bool tappable = enabled || (!isLoading && onBlockedTap != null);
    final Color background = enabled
        ? cs.primary
        : Color.alphaBlend(cs.onSurface.withValues(alpha: 0.10), cs.surface);
    final Color foreground = enabled
        ? cs.onPrimary
        : cs.onSurface.withValues(alpha: 0.38);

    // 底色与前景色一起插值（见 GlassAnimatedColors）：只动底色的话，
    // 「不可提交 → 可提交」时底色在推移、文字却已经跳完色，读成「闪了一下」。
    return GlassAnimatedColors(
      colors: [background, foreground],
      builder: (context, animatedColors) => GlassPressable(
        onTap: enabled ? onPressed : (tappable ? onBlockedTap : null),
        enabled: tappable,
        builder: (context, pressed) => AnimatedContainer(
          duration: GlassTokens.pressDuration,
          curve: Curves.easeOut,
          height: GlassTokens.pillHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: pressed
                ? Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.10),
                    animatedColors[0],
                  )
                : animatedColors[0],
            borderRadius: BorderRadius.circular(GlassTokens.pillHeight / 2),
            // ⛔ 不加 boxShadow：可提交与否已经由底色/前景色分得很开，
            // 再吐一圈外投影会把这枚胶囊读成一张浮起来的卡片。
          ),
          child: Center(
            // 标签 ↔ 转圈原位交叉过渡，胶囊宽度平滑伸缩
            child: AnimatedSize(
              duration: GlassTokens.motionDuration,
              curve: GlassTokens.motionCurve,
              child: AnimatedSwitcher(
                duration: GlassTokens.motionDuration,
                switchInCurve: GlassTokens.motionCurve,
                switchOutCurve: GlassTokens.motionCurve.flipped,
                child: isLoading
                    ? SizedBox(
                        key: const ValueKey('submit-loading'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            animatedColors[1],
                          ),
                        ),
                      )
                    : Row(
                        key: const ValueKey('submit-label'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 18, color: animatedColors[1]),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            label,
                            style: TextStyle(
                              color: animatedColors[1],
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// composer 的标题行：[图标] 标题 ··· [玻璃关闭圆钮]。
///
/// 关闭键一律是 `GlassIconButton(standalone: true)`——弹窗关闭/动作键用玻璃
/// 圆钮是项目铁律，不要退回 `IconButton`。
class GlassComposerHeader extends StatelessWidget {
  const GlassComposerHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.icon,
    this.trailing,
  });

  final String title;
  final VoidCallback onClose;
  final IconData? icon;

  /// 关闭钮左侧的额外控件（如冷却计时徽标）。
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
        GlassIconButton(
          standalone: true,
          icon: const Icon(Icons.close),
          tooltip: t.common.close,
          onPressed: onClose,
        ),
      ],
    );
  }
}
