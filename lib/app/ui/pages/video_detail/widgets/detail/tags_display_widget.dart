import 'package:flutter/material.dart';

import '../../../../../models/tag.model.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/ui/widgets/tag_detail_dialog.dart';

/// 标签流式布局（展示用）。
///
/// 「原文/译文」切换由外层（如 [IwaraTagsSection]）通过 [showOriginal] 控制；
/// 本组件仅负责渲染、点击跳转，以及长按 / 右键弹出标签详情。
class TagsDisplayWidget extends StatelessWidget {
  final List<Tag> tags;
  final Function(Tag)? onTagTap;

  /// 是否展示原始 key（false 时展示当前语言译名）。
  final bool showOriginal;

  final double spacing;
  final double runSpacing;

  const TagsDisplayWidget({
    super.key,
    required this.tags,
    this.onTagTap,
    this.showOriginal = false,
    this.spacing = 8.0,
    this.runSpacing = 4.0,
  });

  void _handleTagTap(Tag tag) {
    // 如果有标签点击回调，优先调用回调
    if (onTagTap != null) {
      onTagTap!(tag);
      return;
    }
    // 否则保持原来的复制行为（复制原始 key）
    copyTagText(tag.id);
  }

  Widget _buildTagChip(BuildContext context, Tag tag) {
    final localized = TagLocalizationService.displayName(tag.id);
    final hasTranslation = localized != tag.id;
    final label = showOriginal ? tag.id : localized;
    // 悬浮提示展示「另一面」：当前显示译名则提示原始 key，反之亦然。
    final tooltip = hasTranslation
        ? (showOriginal ? localized : tag.id)
        : null;

    final chip = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _handleTagTap(tag),
        // 长按 / 右键：弹出标签详情（译文 + 原始 key + 复制 + 反馈）。
        onLongPress: () => showTagDetailDialog(context, tag),
        onSecondaryTap: () => showTagDetailDialog(context, tag),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: tag.sensitive
                ? Colors.red.withAlpha(20)
                : Colors.grey.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tag.sensitive
                  ? Colors.red.withAlpha(51)
                  : Colors.grey.withAlpha(51),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              height: 1.2,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: chip);
    }
    return chip;
  }

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: tags.map((tag) => _buildTagChip(context, tag)).toList(),
    );
  }
}
