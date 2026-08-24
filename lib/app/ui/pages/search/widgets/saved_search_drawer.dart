import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/saved_search.model.dart';
import 'package:i_iwara/app/services/saved_search_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_saved_items_drawer.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 以「全局右侧抽屉」形式展示「已保存搜索」。
///
/// 通过 root navigator 推入一个从屏幕右侧滑入的全高面板，覆盖整个界面。
Future<void> showSavedSearchDrawer({
  required void Function(SavedSearch search) onApply,
  required VoidCallback onAddCurrent,
}) {
  return showGlassRightDrawer(
    builder: (ctx) => SavedSearchDrawer(
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

  Future<void> _renameSearch(BuildContext context, SavedSearch search) async {
    final t = slang.Translations.of(context);
    final newName = await showGlassPromptNameDialog(
      title: t.savedSearch.rename,
      hint: t.savedSearch.nameHint,
      initialText: search.name,
    );
    if (newName != null && newName.isNotEmpty) {
      await _service.rename(search.id, newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return GlassSavedItemsDrawer<SavedSearch>(
      title: t.savedSearch.title,
      addTooltip: t.savedSearch.addCurrent,
      renameTooltip: t.savedSearch.rename,
      emptyMessage: t.savedSearch.empty,
      reorderHint: t.savedSearch.reorderHint,
      items: () => _service.list,
      itemKey: (search) => ValueKey(search.id),
      itemTitle: (search) => _displayName(context, search),
      itemSubtitle: (ctx, search) => _summaryOf(ctx, search),
      onApply: onApply,
      onAddCurrent: onAddCurrent,
      onRename: (search) => _renameSearch(context, search),
      onDelete: (search) => _service.remove(search.id),
      onReorder: (oldIndex, newIndex) =>
          _service.reorder(oldIndex, newIndex),
    );
  }
}
