import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/oreno3d_localization_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/expandable_section_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart';
import 'package:i_iwara/app/ui/widgets/tag_detail_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// Oreno3d 实体区块：可展开卡片 + 头部「原文/译文」切换按钮 + 实体流式布局。
///
/// 与 [IwaraTagsSection] 同款设计：
/// - 头部切换（纯图标）作用于卡片内全部实体，在「当前语言译名」与「日文原名」间切换；
/// - 仅当存在「译名与原名不同」的实体时切换按钮才出现。
class Oreno3dTagsSection extends StatefulWidget {
  final dynamic oreno3dDetail;
  final Function(String, String, String) onSearchTap;

  const Oreno3dTagsSection({
    super.key,
    required this.oreno3dDetail,
    required this.onSearchTap,
  });

  @override
  State<Oreno3dTagsSection> createState() => _Oreno3dTagsSectionState();
}

class _Oreno3dTagsSectionState extends State<Oreno3dTagsSection> {
  /// 是否展示原文（false 时展示当前语言译名）。
  bool _showOriginal = false;

  /// 是否存在「译名与原名不同」的实体——只有此时切换按钮才有意义。
  bool get _hasMeaningfulTranslation {
    final detail = widget.oreno3dDetail;
    if (detail == null) return false;

    bool differs(String type, dynamic item) {
      if (item == null) return false;
      final localized = Oreno3dLocalizationService.displayName(
        type: type,
        id: item.id,
        name: item.name,
      );
      final original = Oreno3dLocalizationService.originalDisplay(
        type: type,
        id: item.id,
        fallback: item.name,
      );
      return localized != original;
    }

    if (differs('origin', detail.origin)) return true;
    for (final item in detail.tags) {
      if (differs('tag', item)) return true;
    }
    for (final item in detail.characters) {
      if (differs('character', item)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return ExpandableSectionWidget(
      title: t.oreno3d.name,
      icon: Icons.view_in_ar,
      headerAction: _hasMeaningfulTranslation
          ? IconButton(
              icon: Icon(
                _showOriginal ? Icons.translate : Icons.tag,
                size: 18,
              ),
              tooltip: _showOriginal
                  ? t.common.showTranslatedTag
                  : t.common.showOriginalTag,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => setState(() => _showOriginal = !_showOriginal),
            )
          : null,
      child: Oreno3dTagsWidget(
        oreno3dDetail: widget.oreno3dDetail,
        onSearchTap: widget.onSearchTap,
        showOriginal: _showOriginal,
      ),
    );
  }
}

class Oreno3dTagsWidget extends StatelessWidget {
  final dynamic oreno3dDetail;
  final Function(String, String, String) onSearchTap;

  /// 是否展示原文（false 时展示当前语言译名）。
  final bool showOriginal;

  const Oreno3dTagsWidget({
    super.key,
    required this.oreno3dDetail,
    required this.onSearchTap,
    this.showOriginal = false,
  });

  Widget _buildSearchableTag(
    BuildContext context, {
    required String id,
    required String label,
    required String localizedName,
    required String type,
    required Color color,
  }) {
    // 长按 / 右键：弹出实体详情（译文 + 原文 + 复制 + 翻译纠错反馈），
    // 与搜索页右上角「?」同款弹窗。跳转/搜索始终使用译名，便于在搜索页展示。
    void showDetail() => showOreno3dTagDetailDialog(
      context,
      type: type,
      id: id,
      localizedName: localizedName,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSearchTap(id, type, localizedName),
        onLongPress: showDetail,
        onSecondaryTap: showDetail,
        borderRadius: BorderRadius.circular(12),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.tagPaddingHorizontal,
              vertical: UIConstants.tagPaddingVertical,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<dynamic> items,
    required Color color,
    required String type,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: UIConstants.smallSpacing),
        Wrap(
          spacing: UIConstants.iconTextSpacing,
          runSpacing: UIConstants.smallSpacing,
          children: items.map((item) {
            // 展示当前语言译名（按 类别 + id 映射，缺失回退原名）；
            // showOriginal 为 true 时展示日文原名。跳转/搜索仍用原始 id + 译名。
            final String entityId = item.id ?? item.name;
            final localizedName = Oreno3dLocalizationService.displayName(
              type: type,
              id: item.id,
              name: item.name,
            );
            final originalName = Oreno3dLocalizationService.originalDisplay(
              type: type,
              id: item.id,
              fallback: item.name,
            );
            return _buildSearchableTag(
              context,
              id: entityId,
              label: showOriginal ? originalName : localizedName,
              localizedName: localizedName,
              type: type,
              color: color,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    if (oreno3dDetail == null) return const SizedBox.shrink();

    final hasOrigin = oreno3dDetail.origin != null;
    final hasTags = oreno3dDetail.tags.isNotEmpty;
    final hasCharacters = oreno3dDetail.characters.isNotEmpty;

    // 如果三者都为空，不显示
    if (!hasOrigin && !hasTags && !hasCharacters) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 原作信息
          if (hasOrigin) ...[
            _buildSection(
              context,
              title: t.oreno3d.origin,
              items: [oreno3dDetail.origin],
              color: Colors.green,
              type: 'origin',
            ),
          ],

          // Oreno3D标签
          if (hasTags) ...[
            if (hasOrigin)
              const SizedBox(height: UIConstants.interElementSpacing),
            _buildSection(
              context,
              title: t.oreno3d.tags,
              items: oreno3dDetail.tags,
              color: Colors.purple,
              type: 'tag',
            ),
          ],

          // 角色信息
          if (hasCharacters) ...[
            if (hasTags || hasOrigin)
              const SizedBox(height: UIConstants.interElementSpacing),
            _buildSection(
              context,
              title: t.oreno3d.characters,
              items: oreno3dDetail.characters,
              color: Colors.blue,
              type: 'character',
            ),
          ],
        ],
      ),
    );
  }
}
