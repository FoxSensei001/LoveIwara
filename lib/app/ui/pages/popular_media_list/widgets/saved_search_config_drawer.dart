import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/saved_search_config.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/saved_search_config_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_saved_items_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/i18n/strings.g.dart' show t;

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

  SavedSearchConfigService get _service => Get.find<SavedSearchConfigService>();

  /// 弹出命名对话框，把「当前激活的筛选条件」保存为一条新配置。
  ///
  /// 热门视频/图库与订阅页的 header 共用这一个入口，保证各页保存出的
  /// 配置结构、默认命名规则完全一致。
  static Future<void> promptSaveCurrent({
    required String segment,
    required List<Tag> tags,
    required String date,
    required String rating,
  }) async {
    final name = await showGlassPromptNameDialog(
      title: t.savedSearchConfig.namePromptTitle,
      hint: t.savedSearchConfig.nameHint,
      initialText: _buildDefaultConfigName(
        tags: tags,
        date: date,
        rating: rating,
      ),
    );
    if (name == null) return;

    final config = SavedSearchConfig(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.isEmpty
          ? _buildDefaultConfigName(tags: tags, date: date, rating: rating)
          : name,
      tags: List<Tag>.from(tags),
      date: date,
      rating: rating,
    );
    await Get.find<SavedSearchConfigService>().add(segment, config);
    showGlassToast(
      t.savedSearchConfig.saveSuccess,
      type: GlassToastType.success,
      position: GlassToastPosition.bottom,
    );
  }

  /// 根据筛选条件生成一个默认名称（评级/日期/标签数）。
  static String _buildDefaultConfigName({
    required List<Tag> tags,
    required String date,
    required String rating,
  }) {
    final parts = <String>[];
    if (rating.isNotEmpty) {
      final r = MediaRating.values.firstWhere(
        (e) => e.value == rating,
        orElse: () => MediaRating.ALL,
      );
      if (r != MediaRating.ALL) parts.add(r.label);
    }
    if (date.isNotEmpty) parts.add(date);
    if (tags.isNotEmpty) {
      parts.add(t.savedSearchConfig.tagsCount(count: tags.length));
    }
    return parts.isEmpty ? t.savedSearchConfig.noConditions : parts.join(' · ');
  }

  /// 条目摘要：评级 · 日期 · 标签名（直接展示标签内容而不是只报数量）。
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
    parts.addAll(config.tags.map((tag) => '#${tag.id}'));

    if (parts.isEmpty) return t.savedSearchConfig.noConditions;
    return parts.join(' · ');
  }

  Future<void> _renameConfig(
    BuildContext context,
    SavedSearchConfig config,
  ) async {
    final t = slang.Translations.of(context);
    final newName = await showGlassPromptNameDialog(
      title: t.savedSearchConfig.rename,
      hint: t.savedSearchConfig.nameHint,
      initialText: config.name,
    );
    if (newName != null && newName.isNotEmpty) {
      await _service.rename(segment, config.id, newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return GlassSavedItemsDrawer<SavedSearchConfig>(
      title: t.savedSearchConfig.title,
      addTooltip: t.savedSearchConfig.addCurrent,
      renameTooltip: t.savedSearchConfig.rename,
      emptyMessage: t.savedSearchConfig.empty,
      reorderHint: t.savedSearchConfig.reorderHint,
      items: () => _service.listFor(segment),
      itemKey: (config) => ValueKey(config.id),
      itemTitle: (config) => config.name.isNotEmpty
          ? config.name
          : t.savedSearchConfig.unnamed,
      itemSubtitle: (ctx, config) => _summaryOf(ctx, config),
      onApply: onApply,
      onAddCurrent: onAddCurrent,
      onRename: (config) => _renameConfig(context, config),
      onDelete: (config) => _service.remove(segment, config.id),
      onReorder: (oldIndex, newIndex) =>
          _service.reorder(segment, oldIndex, newIndex),
    );
  }
}
