import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// `showModalBottomSheet` 正文的收口壳。
///
/// 收口前：24 个文件各写一份 `Container(color: Colors.white,
/// borderRadius: BorderRadius.vertical(top: Radius.circular(16)))`
/// 当外壳——`Colors.white` 是硬编码，暗色主题下这些弹窗全是一块刺眼的白板；
/// 圆角、内边距、标题行、底部安全区（[computeSheetBottomInset]）也是各写各的。
///
/// 面板背景这一轮同 [GlassAlertDialog]：刻意留在传统档，不接液态 lens——
/// `showModalBottomSheet` 的默认出入场是位移而不是透明度过渡，Opacity 那条坑
/// 踩不上，但材质选择权还是交给以后：调用点不用关心这层是传统还是液态。
class GlassBottomSheet extends StatelessWidget {
  const GlassBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showCloseButton = true,
    this.showDragHandle = true,
    this.maxHeightFactor,
    this.scrollable = false,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 16),
  });

  /// 标题（可选）；不传就没有标题行，只留拖拽把手 + 正文。
  final String? title;

  final Widget child;

  /// 有标题时是否带右侧玻璃关闭圆钮（约定同 [GlassAlertDialog]）。
  final bool showCloseButton;

  /// 顶部拖拽把手（一条短横线，纯装饰，不接手势——`showModalBottomSheet`
  /// 本身已经支持整块下滑关闭，把手只是视觉提示）。
  final bool showDragHandle;

  /// 正文最高不超过屏幕高度的这个比例（超出部分交给 [scrollable] 内部滚动）。
  /// 不传则不限高，由调用方自己控制内容高度。
  final double? maxHeightFactor;

  /// 正文过长时是否允许内部滚动。
  final bool scrollable;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    Widget body = child;
    if (scrollable) {
      body = SingleChildScrollView(child: body);
    }

    Widget content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(title!, style: theme.textTheme.titleLarge),
                ),
                if (showCloseButton) ...[
                  const SizedBox(width: 8),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.close),
                    tooltip: t.common.close,
                    onPressed: () => AppService.tryPop(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (maxHeightFactor != null)
            Flexible(child: body)
          else
            body,
        ],
      ),
    );

    return SheetBottomSafeArea(
      child: ConstrainedBox(
        constraints: maxHeightFactor == null
            ? const BoxConstraints()
            : BoxConstraints(maxHeight: screenHeight * maxHeightFactor!),
        child: _GlassBottomSheetShell(
          showDragHandle: showDragHandle,
          child: content,
        ),
      ),
    );
  }
}

/// 外壳：圆角顶 + 玻璃材质，替掉各页手写的 `Colors.white` 容器。
///
/// 复用 [GlassSurface]（全 App 唯一的玻璃材质定义处）而不是自己再画一套
/// fill/stroke——顶部单独圆角是 [GlassSurface.borderRadius] 已支持的口子，
/// 液态档要跟进也只用改这一处。
class _GlassBottomSheetShell extends StatelessWidget {
  const _GlassBottomSheetShell({required this.child, required this.showDragHandle});

  final Widget child;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GlassSurface(
      height: null,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) ...[
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// 打开一块 [GlassBottomSheet]。`backgroundColor: transparent` +
/// `isScrollControlled: true` 是固定搭配（壳自己画背景、自己算高度），
/// 不用在调用点重复传。
Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    builder: builder,
  );
}
