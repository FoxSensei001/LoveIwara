import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/tag_detail_dialog.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 本地收藏夹的标签筛选区（chip 多选，AND 语义）。
///
/// 候选标签来自 [FavoriteService.getFolderTagStats]——也就是**当前收藏夹里真实
/// 存在的标签**，而不是热门页那套从 Iwara 接口搜来的标签收藏历史：本地收藏是
/// 离线数据，只有夹内实际出现过的标签才保证选中后有结果，同时还能顺带给出
/// 每个标签的条目数当作选择依据。
class FolderTagFilter extends StatefulWidget {
  const FolderTagFilter({
    super.key,
    required this.folderId,
    required this.selectedTags,
    required this.onChanged,
  });

  final String folderId;

  /// 当前已选标签（受控，由调用方持有）。
  final List<Tag> selectedTags;

  final ValueChanged<List<Tag>> onChanged;

  @override
  State<FolderTagFilter> createState() => _FolderTagFilterState();
}

class _FolderTagFilterState extends State<FolderTagFilter> {
  /// 候选标签超过这个数量才显示搜索框，少量标签时一眼能扫完，不必加一层输入。
  static const int _searchFieldThreshold = 8;

  /// chip 区最大高度：标签多时自己内部滚动，避免把整个筛选弹窗顶高。
  static const double _chipsMaxHeight = 220;

  final TextEditingController _searchController = TextEditingController();

  /// null 表示仍在读库。
  List<FolderTagStat>? _stats;

  String _query = '';

  /// chip 是否展示原始 key（false 时展示当前语言译名）。
  bool _showOriginalTags = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final next = _searchController.text.trim();
      if (next == _query) return;
      setState(() => _query = next);
    });
    _loadTags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    final stats = await FavoriteService.to.getFolderTagStats(widget.folderId);
    if (!mounted) return;
    setState(() => _stats = stats);
  }

  bool _isSelected(String tagId) =>
      widget.selectedTags.any((tag) => tag.id == tagId);

  void _toggle(Tag tag, bool selected) {
    final next = List<Tag>.from(widget.selectedTags);
    if (selected) {
      if (!next.any((element) => element.id == tag.id)) next.add(tag);
    } else {
      next.removeWhere((element) => element.id == tag.id);
    }
    widget.onChanged(next);
  }

  /// 展示顺序：已选优先（否则滚动后看不见自己选了什么），其余按条目数降序。
  ///
  /// 已选但夹内已不存在的标签（条目被删掉了）也保留，否则用户没法取消它。
  List<FolderTagStat> get _orderedCandidates {
    final stats = _stats ?? const <FolderTagStat>[];
    final knownIds = stats.map((stat) => stat.tag.id).toSet();
    final orphans = widget.selectedTags
        .where((tag) => !knownIds.contains(tag.id))
        .map((tag) => FolderTagStat(tag: tag, count: 0));

    final all = [...orphans, ...stats];
    final selected = all.where((stat) => _isSelected(stat.tag.id));
    final unselected = all.where((stat) => !_isSelected(stat.tag.id));
    return [...selected, ...unselected];
  }

  /// 搜索同时匹配原始 key 与当前语言译名，两种习惯都能搜到。
  bool _matchesQuery(Tag tag) {
    if (_query.isEmpty) return true;
    final query = _query.toLowerCase();
    return tag.id.toLowerCase().contains(query) ||
        TagLocalizationService.displayName(
          tag.id,
        ).toLowerCase().contains(query);
  }

  /// 候选里是否存在「译名 ≠ 原始 key」——决定是否显示原文/译文切换。
  bool _hasMeaningfulTranslation(List<FolderTagStat> candidates) {
    for (final stat in candidates) {
      if (TagLocalizationService.displayName(stat.tag.id) != stat.tag.id) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final candidates = _orderedCandidates;
    final visible = candidates
        .where((stat) => _matchesQuery(stat.tag))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, candidates),
        if (widget.selectedTags.length >= 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              t.favorite.tagFilterMatchAll,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (candidates.length > _searchFieldThreshold)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSearchField(context),
          ),
        if (_stats == null)
          const SizedBox(
            height: 72,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (candidates.isEmpty)
          _buildPlaceholder(context, t.favorite.noTagsInFolder)
        else if (visible.isEmpty)
          _buildPlaceholder(context, t.favorite.noMatchingTags)
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: _chipsMaxHeight),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: visible
                    .map((stat) => _buildTagChip(context, stat))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, List<FolderTagStat> candidates) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final selectedCount = widget.selectedTags.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            t.common.tag,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (selectedCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                t.favorite.selectedTagCount(count: selectedCount),
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (_hasMeaningfulTranslation(candidates))
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(_showOriginalTags ? Icons.translate : Icons.tag),
              tooltip: _showOriginalTags
                  ? t.common.showTranslatedTag
                  : t.common.showOriginalTag,
              onPressed: () =>
                  setState(() => _showOriginalTags = !_showOriginalTags),
            ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.help_outline),
            tooltip: t.common.tagLocalizationGuideTitle,
            onPressed: () => showTagLocalizationGuideDialog(context),
          ),
          if (selectedCount > 0)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.backspace_outlined),
              tooltip: t.favorite.clearSelectedTags,
              onPressed: () => widget.onChanged(const []),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: GlassTokens.fill(colorScheme),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: GlassTokens.stroke(colorScheme),
          width: GlassTokens.strokeWidth,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          hintText: t.favorite.searchTags,
          hintStyle: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.clear, size: 18),
                  tooltip: t.common.clear,
                  onPressed: _searchController.clear,
                ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, FolderTagStat stat) {
    final tag = stat.tag;
    final selected = _isSelected(tag.id);
    final colorScheme = Theme.of(context).colorScheme;
    final isEcchi = tag.type == MediaRating.ECCHI.value;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _showOriginalTags
                ? tag.id
                : TagLocalizationService.displayName(tag.id),
          ),
          if (isEcchi || tag.sensitive) ...[
            const SizedBox(width: 4),
            Icon(
              isEcchi ? Icons.local_offer : Icons.warning,
              size: 12,
              color: Colors.red,
            ),
          ],
          // 条目数是选标签时最直接的依据；已选但夹内已不存在的标签没有计数
          if (stat.count > 0) ...[
            const SizedBox(width: 6),
            Text(
              '${stat.count}',
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      selected: selected,
      onSelected: (value) => _toggle(tag, value),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
