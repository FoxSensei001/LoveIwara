import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/saved_search_config.model.dart';
import 'package:i_iwara/app/services/saved_search_config_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 右侧抽屉：展示并管理当前栏目（视频/图库）已保存的快速筛选配置。
/// 支持点击应用、删除、重命名、拖动排序，以及保存当前筛选为新配置。
class SavedSearchConfigDrawer extends StatelessWidget {
  final String segment;

  /// 应用某个已保存配置。
  final void Function(SavedSearchConfig config) onApply;

  /// 将「当前激活的筛选条件」保存为一条新配置。
  final VoidCallback onAddCurrent;

  const SavedSearchConfigDrawer({
    super.key,
    required this.segment,
    required this.onApply,
    required this.onAddCurrent,
  });

  SavedSearchConfigService get _service =>
      Get.find<SavedSearchConfigService>();

  String _summaryOf(BuildContext context, SavedSearchConfig config) {
    final t = slang.Translations.of(context);
    final parts = <String>[];

    if (config.rating.isNotEmpty) {
      final rating = MediaRating.values.firstWhere(
        (r) => r.value == config.rating,
        orElse: () => MediaRating.ALL,
      );
      if (rating != MediaRating.ALL) parts.add(rating.label);
    }
    if (config.date.isNotEmpty) parts.add(config.date);
    if (config.tags.isNotEmpty) {
      parts.add(t.savedSearchConfig.tagsCount(count: config.tags.length));
    }

    if (parts.isEmpty) return t.savedSearchConfig.noConditions;
    return parts.join(' · ');
  }

  Future<void> _renameConfig(
    BuildContext context,
    SavedSearchConfig config,
  ) async {
    final t = slang.Translations.of(context);
    final controller = TextEditingController(text: config.name);
    final newName = await showAppDialog<String>(
      Builder(
        builder: (dialogContext) => AlertDialog(
          title: Text(t.savedSearchConfig.rename),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: t.savedSearchConfig.nameLabel,
              hintText: t.savedSearchConfig.nameHint,
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
      await _service.rename(segment, config.id, newName);
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
            // 头部：标题 + 保存当前筛选
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Icon(Icons.bookmarks_outlined, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.savedSearchConfig.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: t.savedSearchConfig.addCurrent,
                    onPressed: onAddCurrent,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                final list = _service.listFor(segment);
                if (list.isEmpty) {
                  return Center(
                    child: MyEmptyWidget(message: t.savedSearchConfig.empty),
                  );
                }
                return ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) =>
                      _service.reorder(segment, oldIndex, newIndex),
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      elevation: 4,
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final config = list[index];
                    final displayName = config.name.isNotEmpty
                        ? config.name
                        : t.savedSearchConfig.unnamed;
                    return Material(
                      key: ValueKey(config.id),
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () => onApply(config),
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
                                      displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _summaryOf(context, config),
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
                                tooltip: t.savedSearchConfig.rename,
                                onPressed: () => _renameConfig(context, config),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: colorScheme.error,
                                ),
                                tooltip: t.common.delete,
                                onPressed: () =>
                                    _service.remove(segment, config.id),
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
                t.savedSearchConfig.reorderHint,
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
