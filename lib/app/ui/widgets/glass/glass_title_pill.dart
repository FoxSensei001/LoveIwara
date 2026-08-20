import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:shimmer/shimmer.dart';

/// 玻璃 header 中间的标题胶囊。
///
/// 设计约定：header 里的标题在长标题时会被省略号截断，用户会本能地去
/// 点按 / 长按它想看全文——所以标题胶囊必须可点按 / 长按，以放大淡入的
/// 动画弹出完整标题弹窗 [showGlassFullTitleDialog]，弹窗内自带翻译按钮。
///
/// [title] 为 null 时显示 shimmer 占位，就绪后经 [GlassShapeSwitcher]
/// 交叉过渡为文字、胶囊宽度平滑伸缩。
class GlassTitlePill extends StatelessWidget {
  const GlassTitlePill({
    super.key,
    this.title,
    this.subtitle,
    this.placeholderWidth = 140,
    this.flat = false,
  });

  /// 标题文本；null 表示仍在加载（显示 shimmer 占位条）。
  final String? title;

  /// 可选副标题（如分类描述）；胶囊里不展示，只出现在完整标题弹窗里。
  final String? subtitle;

  /// shimmer 占位条宽度。
  final double placeholderWidth;

  /// 不自带玻璃壳：外层已经有一只常驻的壳（[GlassCapsuleMorph]）时用，
  /// 否则会套出壳中壳。与 `GlassSegmentedControl.flat` 同一口径。
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final String? resolvedTitle = title;

    final Widget inner = resolvedTitle == null
        ? KeyedSubtree(
            key: const ValueKey('glass-title-shimmer'),
            child: Shimmer.fromColors(
              baseColor: colorScheme.surfaceContainerHighest,
              highlightColor: colorScheme.surface,
              child: Container(
                width: placeholderWidth,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          )
        : KeyedSubtree(
            key: const ValueKey('glass-title-text'),
            child: Text(
              resolvedTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          );

    void openFullTitle() {
      if (resolvedTitle == null) return;
      showGlassFullTitleDialog(context, resolvedTitle, subtitle: subtitle);
    }

    // 用 Row(min) + Flexible 而不是 Center：既能收缩包住短标题，
    // 又能在长标题时吃满可用宽度并按省略号截断
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: GlassShapeSwitcher(
            layoutAlignment: Alignment.centerLeft,
            sizeAlignment: Alignment.centerLeft,
            child: inner,
          ),
        ),
      ],
    );

    if (flat) {
      // 壳由外层提供，这里只出内容；点按/长按仍要能开全文弹窗
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GlassPressable(
          onTap: resolvedTitle == null ? null : openFullTitle,
          onLongPress: resolvedTitle == null ? null : openFullTitle,
          scale: 1,
          builder: (context, _) => content,
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: GlassSurface(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // 悬停快速预览全文；点按 / 长按进完整标题弹窗
        tooltip: resolvedTitle,
        onTap: resolvedTitle == null ? null : openFullTitle,
        onLongPress: resolvedTitle == null ? null : openFullTitle,
        child: content,
      ),
    );
  }
}

/// 完整标题弹窗：放大淡入动画出现，展示可选取的全文 + 翻译 / 关闭玻璃圆钮。
Future<void> showGlassFullTitleDialog(
  BuildContext context,
  String title, {
  String? subtitle,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: slang.Translations.of(context).common.close,
    barrierColor: Colors.black54,
    transitionDuration: GlassTokens.motionDuration,
    pageBuilder: (dialogContext, _, _) =>
        _GlassFullTitleDialog(title: title, subtitle: subtitle),
    transitionBuilder: (dialogContext, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: GlassTokens.motionCurve,
        reverseCurve: GlassTokens.motionCurve.flipped,
      );
      // 从标题胶囊所在的上方轻微放大淡入，呼应「从胶囊里长出来」
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          alignment: Alignment.topCenter,
          child: child,
        ),
      );
    },
  );
}

class _GlassFullTitleDialog extends StatelessWidget {
  const _GlassFullTitleDialog({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    // 有副标题时连同副标题一起送翻译
    final translateText = subtitle == null ? title : '$title\n\n$subtitle';
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部动作行：翻译 + 关闭（玻璃圆钮）
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.subject,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const Spacer(),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.copy_outlined),
                    tooltip: t.common.copy,
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: translateText),
                      );
                      showGlassToast(
                        t.common.copiedToClipboard,
                        type: GlassToastType.success,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.translate),
                    tooltip: t.common.translate,
                    onPressed: () =>
                        showTranslationDialog(context, text: translateText),
                  ),
                  const SizedBox(width: 8),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.close),
                    tooltip: t.common.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        SelectableText(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
