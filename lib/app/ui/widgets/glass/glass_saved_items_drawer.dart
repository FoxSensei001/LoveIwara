import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 头部行占位（不含状态栏）：上边距 16 + 玻璃圆钮 44 + 下留白 4。
const double _kHeaderExtent = 16 + 44 + 4;

/// 底部排序提示行占位（不含底部安全区）：上边距 8 + 玻璃胶囊 32 + 下边距 16。
const double _kFooterExtent = 8 + 32 + 16;

/// 玻璃风格的命名输入弹窗：标题 + 关闭圆钮 + 玻璃输入框 + 主色确认钮。
/// 返回 null 表示取消，否则为 trim 后的输入。
Future<String?> showGlassPromptNameDialog({
  required String title,
  required String hint,
  String initialText = '',
}) {
  final controller = TextEditingController(text: initialText);
  return showAppDialog<String>(
    Builder(
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        void submit() =>
            Navigator.of(dialogContext).pop(controller.text.trim());
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行：标题 + 玻璃关闭圆钮
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(dialogContext).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 玻璃输入框 + 主色确认钮
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: GlassTokens.fill(colorScheme),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: GlassTokens.stroke(colorScheme),
                            width: 0.6,
                          ),
                        ),
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: hint,
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.label_outline,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (_) => submit(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: submit,
                      tooltip: slang.t.common.save,
                      icon: const Icon(Icons.check),
                      constraints: const BoxConstraints.tightFor(
                        width: 48,
                        height: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// 以全局右侧抽屉形式展示任意面板。
Future<void> showGlassRightDrawer({
  BuildContext? context,
  required WidgetBuilder builder,
}) {
  final targetContext = context ?? rootNavigatorKey.currentContext;
  if (targetContext == null) return Future.value();

  return showGeneralDialog(
    context: targetContext,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(
      targetContext,
    ).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return Align(alignment: Alignment.centerRight, child: builder(ctx));
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ).drive(Tween(begin: const Offset(1, 0), end: Offset.zero)),
        child: child,
      );
    },
  );
}

/// 通用右侧抽屉：展示并管理已保存的配置/搜索项。
/// 支持点击应用、删除、重命名、拖动排序，以及保存当前项为新配置。
///
/// 液态玻璃风格：条目为玻璃卡片，头部动作键 / 关闭钮与命名弹窗的确认键一律走玻璃风格组件。
class GlassSavedItemsDrawer<T> extends StatelessWidget {
  final String title;
  final String? addTooltip;
  final String? renameTooltip;
  final String emptyMessage;
  final String reorderHint;
  final List<T> Function() items;
  final Key Function(T item) itemKey;
  final String Function(T item) itemTitle;
  final String Function(BuildContext context, T item) itemSubtitle;
  final void Function(T item) onApply;
  final VoidCallback onAddCurrent;
  final void Function(T item) onRename;
  final void Function(T item) onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;

  const GlassSavedItemsDrawer({
    super.key,
    required this.title,
    this.addTooltip,
    this.renameTooltip,
    required this.emptyMessage,
    required this.reorderHint,
    required this.items,
    required this.itemKey,
    required this.itemTitle,
    required this.itemSubtitle,
    required this.onApply,
    required this.onAddCurrent,
    required this.onRename,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    final double headerExtent = statusBarHeight + _kHeaderExtent;
    final double footerExtent = _kFooterExtent + safeBottom;

    return Drawer(
      width: 320,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 主体：列表铺满整个抽屉，用 paddingTop 让出 header 高度
          Positioned.fill(
            child: Obx(() {
              final list = items();
              if (list.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: headerExtent),
                  child: Center(child: MyEmptyWidget(message: emptyMessage)),
                );
              }
              return ReorderableListView.builder(
                padding: EdgeInsets.fromLTRB(
                  16,
                  headerExtent,
                  16,
                  footerExtent + 8,
                ),
                itemCount: list.length,
                buildDefaultDragHandles: false,
                onReorderItem: onReorder,
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) => Transform.scale(
                      scale: 1.0 + 0.04 * animation.value,
                      child: child,
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  final item = list[index];
                  return Padding(
                    key: itemKey(item),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassSurface(
                      height: 72,
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onTap: () => onApply(item),
                      child: Center(
                        child: Row(
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  Icons.drag_handle,
                                  size: 20,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemTitle(item),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    itemSubtitle(context, item),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GlassIconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              tooltip: renameTooltip ?? t.common.edit,
                              onPressed: () => onRename(item),
                            ),
                            GlassIconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: colorScheme.error,
                              ),
                              tooltip: t.common.delete,
                              onPressed: () => onDelete(item),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // 顶部渐变蒙层
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: EdgeFadeScrim.top(
              height: headerExtent + GlassTokens.headerFadeExtent,
              solidExtent: statusBarHeight,
            ),
          ),

          // 顶部玻璃控件行：标题 + 保存当前 + 关闭
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassChromeLayer(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.bookmark_add_outlined),
                      tooltip: addTooltip,
                      onPressed: onAddCurrent,
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
            ),
          ),

          // 底部渐变蒙层
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: EdgeFadeScrim.bottom(
              height: footerExtent + GlassTokens.bottomFadeExtent,
              solidExtent: safeBottom,
            ),
          ),

          // 底部排序提示胶囊
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            // group: false —— 只有一块玻璃（排序提示胶囊），分组省不出东西。
            child: GlassChromeLayer(
              group: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + safeBottom),
                child: Center(
                  child: GlassSurface(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.drag_indicator,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          reorderHint,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
