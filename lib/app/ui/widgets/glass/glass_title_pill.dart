import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dialog_motion.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
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
    this.icon,
    this.placeholderWidth = 140,
    this.flat = false,
    this.onTap,
  });

  /// 标题文本；null 表示仍在加载（显示 shimmer 占位条）。
  final String? title;

  /// 标题前的引导图标。
  ///
  /// 给「这只胶囊写的是一个实体、点它有详情可看」的场合用（标签页 / oreno3d
  /// 单实体浏览）：图标说的是**点了会怎样**，所以它和 [onTap] 是一对。
  ///
  /// ⛔ 别再往 [title] 里拼前缀字符（这两处原来是 `'# $name'`）：拼进去的字
  /// 会一路跟着进完整标题弹窗、进 tooltip、进读屏，还没法跟着主题走颜色。
  ///
  /// 加载中（[title] 为 null）时**不画**：那会儿画一枚光秃秃的图标和当年画一
  /// 个光秃秃的「#」一样不诚实，占位就老老实实只是占位。
  final IconData? icon;

  /// 可选副标题（如分类描述）；胶囊里不展示，只出现在完整标题弹窗里。
  final String? subtitle;

  /// shimmer 占位条宽度。
  final double placeholderWidth;

  /// 不自带玻璃壳：外层已经有一只常驻的壳（[GlassCapsuleMorph]）时用，
  /// 否则会套出壳中壳。与 `GlassSegmentedControl.flat` 同一口径。
  final bool flat;

  /// 点按 / 长按改开别的东西。
  ///
  /// 默认（null）是本组件的契约动作——弹完整标题弹窗。只有当这只胶囊写的
  /// **不是一段可能被截断的正文标题**、而是一个有自己详情页的实体时才该覆盖：
  /// 标签页那只写的是标签名，用户点它想看的是「原文 / 译文 / 复制 / 纠错」
  /// （`showTagDetailDialog`），弹一遍同样的几个字没有意义。
  final VoidCallback? onTap;

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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  // 跟着标题字号走，不写死：字体缩放调大时图标不能留在原地。
                  Icon(
                    icon,
                    size: (textTheme.titleMedium?.fontSize ?? 16) + 2,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    resolvedTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );

    // 标题还没到（shimmer 占位）时不接手势：此刻点开只会是一张空弹窗。
    // 自定义 [onTap] 不受这条约束——它开的是与标题文本无关的东西。
    final VoidCallback? handleTap =
        onTap ??
        (resolvedTitle == null
            ? null
            : () => showGlassFullTitleDialog(
                context,
                resolvedTitle,
                subtitle: subtitle,
              ));

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
          onTap: handleTap,
          onLongPress: handleTap,
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
        onTap: handleTap,
        onLongPress: handleTap,
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
                          showAppToast(
                            t.common.copiedToClipboard,
                            type: AppToastType.success,
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
