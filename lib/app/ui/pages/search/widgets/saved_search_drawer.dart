import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/saved_search.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/saved_search_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 以「全局右侧抽屉」形式展示「已保存搜索」。
///
/// 通过 root navigator 推入一个从屏幕右侧滑入的全高面板，覆盖整个界面，
/// 不受调用方（如搜索弹窗）自身布局边界的限制。
/// 点击应用或保存当前搜索时，会先关闭该抽屉再回调。
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

  Future<void> _renameSearch(
    BuildContext context,
    SavedSearch search,
  ) async {
    final t = slang.Translations.of(context);
    final controller = TextEditingController(text: search.name);
    final newName = await showAppDialog<String>(
      Builder(
        builder: (dialogContext) => AlertDialog(
          title: Text(t.savedSearch.rename),
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
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t.common.cancel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: Text(t.common.save),
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

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // 头部：标题 + 保存当前搜索
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Icon(Icons.bookmarks_outlined, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.savedSearch.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save_outlined),
                    tooltip: t.savedSearch.addCurrent,
                    onPressed: onAddCurrent,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                final list = _service.list;
                if (list.isEmpty) {
                  return Center(
                    child: MyEmptyWidget(message: t.savedSearch.empty),
                  );
                }
                return ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) =>
                      _service.reorder(oldIndex, newIndex),
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      elevation: 4,
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final search = list[index];
                    return Material(
                      key: ValueKey(search.id),
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () => onApply(search),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.drag_handle),
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
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _summaryOf(context, search),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color:
                                                colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: t.savedSearch.rename,
                                onPressed: () => _renameSearch(context, search),
                              ),
                              IconButton(
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
                      ),
                    );
                  },
                );
              }),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                t.savedSearch.reorderHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
