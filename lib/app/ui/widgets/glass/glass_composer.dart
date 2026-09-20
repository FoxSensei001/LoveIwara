import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// # 输入弹窗（composer）玻璃词汇表
///
/// 发评论 / 发帖 / 回复 / 编辑这一族弹窗共用同一套骨架：
///
/// ```
/// ┌ 标题行：[图标] 标题 ················ [设置齿轮] [玻璃关闭圆钮]
/// ├ 引用条：GlassQuoteCard（单行，带常驻勾选框）—— 仅回复场景
/// ├ 输入域：GlassInputSurface(TextField / EnhancedEmojiTextField)
/// └ 底 栏：GlassComposerBar（动作 · 字数 · 提交，**一行**）
/// ```
///
/// 底栏早先是上下两行（工具行 + 动作行），各自只装一两件东西、左右都是大片
/// 空白。合成一行之后省下的高度全部还给写作区——那才是这类界面唯一值得优化
/// 的量（Discourse 2025 composer 改版的唯一 KPI 就是它）。
/// [GlassComposerActions] 保留给「只有一枚确认键」的简单弹窗（如改标题）。
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
    this.compact = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;
  final VoidCallback? onBlockedTap;

  /// 紧凑态：只画一枚圆形箭头，不排 [label]（label 退为无障碍标签与 tooltip）。
  ///
  /// 回复 / 评论这类底栏用它。那一行要同时装动作组、状态、字数和这枚键，
  /// 一个带文字的胶囊在 360dp 宽上会把前面的东西挤到换行——「发送」这件事
  /// 靠一枚主色箭头已经说得足够清楚。发帖一类还是给文字（那张弹窗更正式，
  /// 也装得下）。
  final bool compact;

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
          width: compact ? GlassTokens.pillHeight : null,
          padding: compact
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 20),
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
                    : compact
                    ? Tooltip(
                        key: const ValueKey('submit-compact'),
                        message: label,
                        child: Icon(
                          icon ?? Icons.send_rounded,
                          size: 19,
                          color: animatedColors[1],
                          semanticLabel: label,
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

/// composer 顶上的**回复引用卡片**：这条回复是冲着哪一楼去的。
///
/// ```
/// ┌────────────────────────────────┐
/// │ ┃ ↩ 回复 #12 @alice        ✕  │
/// │ ┃ 「原文摘要…」                │
/// └────────────────────────────────┘
/// ```
///
/// ## 为什么引用不再躺在输入框里
///
/// 旧版把 `'Reply #N: @x\n---\n'` 直接塞进 [TextEditingController]，于是引用
/// 变成了一段「长得像正文、可以随便改」的字。光标落点又没定义（`controller.text`
/// 的 setter 把 selection 置成 -1，用户点哪儿光标就在哪儿），用户十有八九会点在
/// 那条 `---` 上接着打字，把语法改坏。
///
/// 引用是**结构**不是正文，所以它在这里，不在输入框里；真正发出去的那串字由
/// `CommentMarkup.compose` 在提交那一刻拼，用户碰不到语法，也就打不坏。
///
/// [quote] 传 null 表示没有引用——卡片会带高度过渡收起来，而不是硬切消失。
class GlassQuoteCard extends StatelessWidget {
  const GlassQuoteCard({
    super.key,
    required this.floor,
    required this.username,
    this.excerpt,
    this.enabled = true,
    this.onToggle,
    this.visible = true,
  });

  /// 被回复的楼层号。
  final int floor;

  /// 被回复者用户名，不含 `@`。
  final String username;

  /// 被回复内容的一行摘要；空则只显示楼层与用户名。
  final String? excerpt;

  /// 这条回复到底带不带引用。
  ///
  /// ⛔ 不带的时候卡片**照样在场**，只是勾选框空着、文字转灰——它同时是
  /// 「你在回 #12」这个事实的陈述。用 ✕ 把整张卡删掉的话，用户一旦点错就
  /// 再也看不到自己回的是哪一楼，而那条信息本身是没法撤销的。
  final bool enabled;

  /// 切换带不带。**整行都是它的触摸目标**，不只是那枚方框。
  ///
  /// ⛔ 这是**持久化**的偏好（写回配置），不是只影响这一条：「我不喜欢回复
  /// 带引用」是个长期主张，不该每次都重新勾一遍。
  final VoidCallback? onToggle;

  /// 收起时同样有过渡（项目约定：出现与消失都必须有动画）。
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: GlassTokens.capsuleMorphDuration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !visible
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Semantics(
                checked: enabled,
                label: t.forum.replyToFloor(
                  floor: floor.toString(),
                  username: username,
                ),
                child: GlassPressable(
                  // 整行都是勾选框的触摸目标。那枚 16px 的方框本身远小于
                  // 44/48 的最小触摸目标，单独去点它既难瞄又容易点空；而这
                  // 一整行除了「带不带引用」之外没有第二件事可做，不存在误触
                  // 别的动作的可能。
                  onTap: onToggle,
                  builder: (context, pressed) => _buildSurface(
                    context,
                    t,
                    cs,
                    pressed: pressed,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSurface(
    BuildContext context,
    slang.Translations t,
    ColorScheme cs, {
    required bool pressed,
  }) {
    final Color fg = enabled ? cs.primary : cs.onSurfaceVariant;
    return AnimatedContainer(
      duration: GlassTokens.pressDuration,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        // 按下时整行一起变深：反馈落在被点的那块面上，而不是只在方框里
        color: pressed
            ? cs.onSurface.withValues(alpha: 0.07)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: GlassInputSurface(
        borderRadius: 14,
        padding: const EdgeInsets.fromLTRB(9, 7, 12, 7),
        child: Row(
          children: [
            if (onToggle != null)
              // 纯视觉的勾选框：手势由整行那层接（两层都注册会打架，
              // 而且借来的按钮手势更深、会把外层那只吃掉）。
              GlassAnimatedIcon(
                icon: Icon(
                  enabled
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 17,
                  color: fg,
                ),
              )
            else
              // 左侧竖条：markdown 引用块在渲染侧也是这个形状，
              // 「写的时候」和「发出去之后」长得一样。
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.reply_rounded, size: 13, color: fg),
            const SizedBox(width: 5),
            Text(
              t.forum.replyToFloor(
                floor: floor.toString(),
                username: username,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            // 摘要跟在同一行、灰字、吃掉剩余宽度。占两行不值——它只是帮你
            // 确认「回的是哪条」，不是复刻原文。
            if (excerpt != null && excerpt!.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: Text(
                    excerpt!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled
                          ? cs.onSurfaceVariant
                          : cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// composer 的**单行底栏**：常驻动作 · 状态 · 字数 · 发送，全在一行。
///
/// 取代早先分成两行的「工具行 + 动作行」。
/// 那两行各自只装一两件东西、左右都是大片空白，而「写作空间」才是这类界面
/// 唯一值得优化的量——Discourse 2025 composer 改版的核心 KPI 就是把移动端
/// 写作区从 103px 提到 212px，别的都是顺带。
///
/// ## 为什么只有三枚常驻动作
///
/// 窄屏上能完整显示的 action 上限业界共识是 3（PatternFly 明文、M3 的 app bar
/// 给 trailing icon 定 ≤2、360dp 宽物理上只排得下 6–7 个 48dp 触摸目标）。
/// 超出的一律进 [_openMore] 那张玻璃菜单——**不做横向滚动**：dev.to 的
/// markdown 工具栏用过横滚，用户以为按钮消失了，最后改回动态 overflow。
///
/// ## 底栏上只有动作，没有状态
///
/// 小尾巴这类「这条会不会带」的**状态**一律收进 [_openMore] 那张菜单，不在
/// 底栏露面。两个理由：
///
/// 1. 动作与状态的标签规则本来就相反——动作说「点了会怎样」，状态说「现在
///    是什么」——并排必然有歧义（NN/g 拿 Mute 按钮讲的就是这件事）。与其
///    靠间距把它们隔开，不如干脆不并排。
/// 2. 它是**一次设定长期生效**的偏好（写回配置），不是每条都要决策的东西。
///    让它常驻在最显眼的一行，等于每次发评论都逼用户重看一遍一个早就定好的
///    选项，而那一格本来可以留给写作。
///
/// ## 只有发送键染色
///
/// "when every element is tinted, nothing stands out." 其余一律单色。
class GlassComposerBar extends StatelessWidget {
  const GlassComposerBar({
    super.key,
    required this.onSubmit,
    this.onBlockedTap,
    this.submitText,
    this.isLoading = false,
    this.onEmoji,
    this.onPreview,
    this.previewHasContent = false,
    this.onTranslate,
    this.translateEnabled = true,
    this.onMarkdownHelp,
    this.rulesAgreed,
    this.onRulesTap,
    this.showSignatureToggle = false,
    this.signatureEnabled = false,
    this.onSignatureToggle,
    this.showQuoteToggle = false,
    this.quoteEnabled = false,
    this.onQuoteToggle,
    this.length,
    this.limit,
  });

  final VoidCallback? onSubmit;
  final VoidCallback? onBlockedTap;

  /// 给了就是带文字的胶囊键（发帖一类），不给就是一枚圆形箭头（回复一类）。
  final String? submitText;
  final bool isLoading;

  /// 常驻的两枚动作。为 null 即不提供。
  final VoidCallback? onEmoji;
  final VoidCallback? onPreview;

  /// 眼睛上要不要挂那枚小红点：有东西可看时才挂。
  ///
  /// 空着的时候点预览只会得到一张空白，红点在那儿反而是骗人；写下第一个字
  /// 之后它才长出来（[GlassAnimatedDot] 自带弹跳显隐，不是硬切）。
  final bool previewHasContent;

  /// 以下几项进「更多」菜单。
  final VoidCallback? onTranslate;
  final bool translateEnabled;
  final VoidCallback? onMarkdownHelp;

  /// 非 null 表示本弹窗要过规则闸门。**未同意时**规则徽标会占住左端（它拦着
  /// 发送，必须看得见）；**同意之后整枚消失**，改进「更多」菜单里仍可重读
  /// ——同意是一次性的，之后每次发评论都再看一遍一个已完成的状态是纯噪音。
  final bool? rulesAgreed;
  final VoidCallback? onRulesTap;

  /// 本弹窗参不参与小尾巴。为真就在「更多」菜单里放一条带勾选的小尾巴。
  /// ⛔ 底栏上不放——见本类文档。
  final bool showSignatureToggle;
  final bool signatureEnabled;
  final VoidCallback? onSignatureToggle;

  /// 本条回复有没有可带的引用。为真就在「更多」菜单里放一条带勾选的引用开关。
  ///
  /// 它和引用条上那枚勾选框是**同一个持久化配置**的两个入口：引用条在场时
  /// 那里更顺手，但引用条只在回复场景出现，而菜单是恒定的——「我的回复要不
  /// 要带引用」这个偏好不该只有在正好回复某一楼时才找得到。
  final bool showQuoteToggle;
  final bool quoteEnabled;
  final VoidCallback? onQuoteToggle;

  /// 字数：正文已写的长度 / 可用额度（额度已扣掉引用头与小尾巴的开销）。
  /// 两者都给才显示，且**只在接近上限时**才淡入——平时它是噪音。
  final int? length;
  final int? limit;

  /// 到多少比例才把字数亮出来。X 也是这么做的：短草稿不显示数字。
  static const double _countRevealRatio = 0.8;

  Future<void> _openMore(BuildContext context) async {
    final t = slang.Translations.of(context);
    final entries = <GlassMenuEntry>[
      if (onTranslate != null)
        GlassMenuOption<String>(
          value: 'translate',
          label: t.common.translate,
          icon: Icons.translate,
          enabled: translateEnabled,
          showCheck: false,
        ),
      if (onMarkdownHelp != null)
        GlassMenuOption<String>(
          value: 'md',
          label: t.markdown.markdownSyntax,
          icon: Icons.help_outline,
          showCheck: false,
        ),
      // 引用与小尾巴**只在这里**出现（底栏上没有）。两者都是长期偏好、不是
      // 每条都要决策的东西，见本类文档「底栏上只有动作，没有状态」。
      // 勾没勾都在场：菜单要回答「现在是什么」，缺了未勾那一态就答不全。
      if (showQuoteToggle)
        GlassMenuOption<String>(
          value: 'quote',
          label: t.forum.attachQuote,
          icon: Icons.format_quote_rounded,
          selected: quoteEnabled,
        ),
      if (showSignatureToggle)
        GlassMenuOption<String>(
          value: 'sig',
          label: t.settings.signature,
          icon: Icons.edit_note,
          selected: signatureEnabled,
        ),
      // 已同意规则时才放这里；未同意时它在外面占着位置，不该重复出现。
      // 勾是**状态陈述**（你已经同意过了），点它是重读全文——不会取消同意，
      // 所以配一句副标题把这件事说破，免得被读成「再点一下就反悔」。
      if (rulesAgreed == true && onRulesTap != null)
        GlassMenuOption<String>(
          value: 'rules',
          label: t.common.agreeToRules,
          description: t.common.tapToReread,
          icon: Icons.verified_rounded,
          selected: true,
        ),
    ];
    if (entries.isEmpty) return;

    final picked = await showGlassMenu<String>(
      anchorContext: context,
      entries: entries,
    );
    switch (picked) {
      case 'quote':
        onQuoteToggle?.call();
      case 'translate':
        onTranslate?.call();
      case 'md':
        onMarkdownHelp?.call();
      case 'sig':
        onSignatureToggle?.call();
      case 'rules':
        onRulesTap?.call();
    }
  }

  bool get _hasMore =>
      onTranslate != null ||
      onMarkdownHelp != null ||
      showQuoteToggle ||
      showSignatureToggle ||
      (rulesAgreed == true && onRulesTap != null);

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bool pendingRules = rulesAgreed == false;

    final actions = <Widget>[
      if (onEmoji != null)
        GlassIconButton(
          icon: const Icon(Icons.emoji_emotions_outlined),
          tooltip: t.emoji.selectEmoji,
          onPressed: onEmoji,
        ),
      if (onPreview != null)
        GlassIconButton(
          icon: const Icon(Icons.visibility_outlined),
          tooltip: t.common.preview,
          showBadge: previewHasContent,
          onPressed: onPreview,
        ),
      if (_hasMore)
        Builder(
          // anchorContext 必须是触发件自身：菜单的落点和材质档都从它身上量。
          builder: (btnContext) => GlassIconButton(
            icon: const Icon(Icons.more_horiz),
            tooltip: t.common.more,
            opensOverlay: true,
            onPressed: () => _openMore(btnContext),
          ),
        ),
    ];

    return Row(
      children: [
        // 未同意规则：徽标占左端（它拦着发送，必须看得见）
        if (pendingRules)
          Flexible(
            child: Align(
              alignment: Alignment.centerLeft,
              child: GlassRulesBadge(agreed: false, onTap: onRulesTap),
            ),
          )
        else if (actions.isNotEmpty)
          GlassButtonGroup(
            touchFlexSignature: 'composer|${actions.length}',
            children: actions,
          ),

        const Spacer(),

        _CounterLabel(
          length: length,
          limit: limit,
          revealRatio: _countRevealRatio,
        ),

        const SizedBox(width: 8),
        GlassSubmitButton(
          onPressed: onSubmit,
          onBlockedTap: onBlockedTap,
          isLoading: isLoading,
          label: submitText ?? t.common.send,
          compact: submitText == null,
        ),
      ],
    );
  }
}

/// 字数标签：平时不在场，写到 [revealRatio] 才淡入，超限转错误色。
///
/// 「有出有入」：它不是硬切出现的，出入场都走透明度 + 宽度过渡，否则底栏
/// 会在用户打到某个字数时突然跳一下。
class _CounterLabel extends StatelessWidget {
  const _CounterLabel({
    required this.length,
    required this.limit,
    required this.revealRatio,
  });

  final int? length;
  final int? limit;
  final double revealRatio;

  @override
  Widget build(BuildContext context) {
    final int? len = length;
    final int? max = limit;
    if (len == null || max == null || max <= 0) {
      return const SizedBox.shrink();
    }
    final bool over = len > max;
    final bool show = over || len >= max * revealRatio;
    final cs = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: GlassTokens.motionDuration,
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        duration: GlassTokens.motionDuration,
        opacity: show ? 1 : 0,
        child: show
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '$len/$max',
                  style: TextStyle(
                    fontSize: 11,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: over ? cs.error : cs.onSurfaceVariant,
                    fontWeight: over ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
