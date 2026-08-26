import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dialog_motion.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
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

/// 完整标题弹窗：轻微放大出现，展示可选取的全文 + 复制 / 翻译 / 关闭玻璃圆钮。
///
/// 走 [showAppDialog]（[GlassDialogRoute]）而不是自建 `showGeneralDialog`：
/// 自建那版的 `transitionBuilder` 里裹着 `FadeTransition`，`RenderOpacity` 在
/// α∈(0,1) 期间会 `saveLayer` 把子树隔离出去，里头玻璃圆钮的 backdrop 采样
/// 什么都吃不到——就是 `showGlassMenu` 踩过的「文字先到、玻璃后补」那个坑。
/// [GlassDialogTransition] 已经不含任何透明度层（只剩纯 `Transform` 的
/// 缩放/位移），换过来才敢给里头的按钮接液态档。
///
/// 钉死 [GlassDialogMotion.scale]：这弹窗在窄屏也是一张居中卡片（不是整页
/// 承载），走 `auto` 会在窄屏被判成整页位移，与「从标题胶囊里长出来」对不上。
Future<void> showGlassFullTitleDialog(
  BuildContext context,
  String title, {
  String? subtitle,
}) {
  return showAppDialog<void>(
    _GlassFullTitleDialog(title: title, subtitle: subtitle),
    dialogContext: context,
    motion: GlassDialogMotion.scale,
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
                  // 液态档由 [GlassDialogRoute] 在路由层供。
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
