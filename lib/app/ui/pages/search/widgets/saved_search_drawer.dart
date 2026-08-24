import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/saved_search.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/saved_search_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 头部行占位（不含状态栏）：上边距 16 + 玻璃圆钮 44 + 下留白 4。
const double _kHeaderExtent = 16 + 44 + 4;

/// 底部排序提示行占位（不含底部安全区）：上边距 8 + 玻璃胶囊 32 + 下边距 16。
const double _kFooterExtent = 8 + 32 + 16;

/// 以「全局右侧抽屉」形式展示「已保存搜索」。
///
/// 通过 root navigator 推入一个从屏幕右侧滑入的全高面板，覆盖整个界面。
Future<void> showSavedSearchDrawer({
  required void Function(SavedSearch search) onApply,
  required VoidCallback onAddCurrent,
}) {
  final context = rootNavigatorKey.currentContext;
  if (context == null) return Future.value();

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: SavedSearchDrawer(
          onApply: (search) {
            Navigator.of(ctx).pop();
            onApply(search);
          },
          onAddCurrent: () {
            Navigator.of(ctx).pop();
            onAddCurrent();
          },
        ),
      );
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

/// 右侧抽屉：展示并管理「已保存搜索」。
/// 支持点击应用、删除、重命名、拖动排序，以及保存当前搜索为新条目。
///
/// 液态玻璃风格：条目为玻璃卡片，头部动作键 / 关闭钮一律走 [GlassIconButton]。
class SavedSearchDrawer extends StatelessWidget {
  /// 应用某个已保存搜索。
  final void Function(SavedSearch search) onApply;

  /// 将「当前激活的搜索条件」保存为一条新条目。
  final VoidCallback onAddCurrent;

  const SavedSearchDrawer({
    super.key,
    required this.onApply,
    required this.onAddCurrent,
  });

  SavedSearchService get _service => Get.find<SavedSearchService>();

  /// 各搜索分类的展示名。
  static String segmentLabel(SearchSegment segment) {
    switch (segment) {
      case SearchSegment.video:
        return slang.t.common.video;
      case SearchSegment.image:
        return slang.t.common.gallery;
      case SearchSegment.post:
        return slang.t.common.post;
      case SearchSegment.user:
        return slang.t.common.user;
      case SearchSegment.forum:
        return slang.t.forum.forum;
      case SearchSegment.forum_posts:
        return slang.t.forum.posts;
      case SearchSegment.oreno3d:
        return 'Oreno3D';
      case SearchSegment.playlist:
        return slang.t.common.playlist;
    }
  }

  String _summaryOf(BuildContext context, SavedSearch search) {
    final t = slang.Translations.of(context);
    final parts = <String>[segmentLabel(search.segment)];

    if (search.filters.isNotEmpty) {
      parts.add(t.savedSearch.filtersCount(count: search.filters.length));
    }

    return parts.join(' · ');
  }

  /// 标题：优先用户命名，其次关键词/标签名，最后兜底文案。
  String _displayName(BuildContext context, SavedSearch search) {
    final t = slang.Translations.of(context);
    if (search.name.isNotEmpty) return search.name;
    if (search.singleTagName.isNotEmpty) return '#${search.singleTagName}';
    if (search.keyword.isNotEmpty) return search.keyword;
    return t.savedSearch.noKeyword;
  }

  Future<void> _renameSearch(BuildContext context, SavedSearch search) async {
    final t = slang.Translations.of(context);
    final controller = TextEditingController(text: search.name);
    final newName = await showAppDialog<String>(
      Builder(
        builder: (dialogContext) => GlassAlertDialog(
          title: t.savedSearch.rename,
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: t.savedSearch.nameLabel,
              hintText: t.savedSearch.nameHint,
            ),
            onSubmitted: (v) => Navigator.of(dialogContext).pop(v.trim()),
          ),
          actions: [
            GlassDialogAction(
              label: t.common.cancel,
              emphasized: false,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            GlassDialogAction(
              label: t.common.save,
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
            ),
          ],
        ),
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      await _service.rename(search.id, newName);
    }
  }

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
          // 主体列表
          Positioned.fill(
            child: Obx(() {
              final list = _service.list;
              if (list.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: headerExtent),
                  child: Center(
                    child: MyEmptyWidget(message: t.savedSearch.empty),
                  ),
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
                onReorderItem: (oldIndex, newIndex) =>
                    _service.reorder(oldIndex, newIndex),
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
                  final search = list[index];
                  return Padding(
                    key: ValueKey(search.id),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassSurface(
                      onTap: () => onApply(search),
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
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
                                  _displayName(context, search),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _summaryOf(context, search),
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
                            tooltip: t.savedSearch.rename,
                            onPressed: () => _renameSearch(context, search),
                          ),
                          GlassIconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: colorScheme.error,
                            ),
                            tooltip: t.common.delete,
                            onPressed: () => _service.remove(search.id),
                          ),
                        ],
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

          // 顶部玻璃控件行：标题 + 保存当前搜索 + 关闭
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LiquidGlassScope(
              backend: kChromeGlassBackend,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.savedSearch.title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.bookmark_add_outlined),
                      tooltip: t.savedSearch.addCurrent,
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

          // 底部拖动排序提示胶囊
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LiquidGlassScope(
              backend: kChromeGlassBackend,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, safeBottom + 16),
                child: Center(
                  child: GlassSurface(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    borderRadius: BorderRadius.circular(999),
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
                          t.savedSearch.reorderHint,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12,
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
