import 'package:flutter/material.dart';

import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/expandable_section_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/tags_display_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// Iwara 标签区块：可展开卡片 + 头部「原文/译文」切换按钮 + 标签流式布局。
///
/// 切换按钮放在卡片头部展开/收起按钮旁边（纯图标），作用于卡片内全部标签。
class IwaraTagsSection extends StatefulWidget {
  final List<Tag> tags;
  final void Function(Tag)? onTagTap;

  const IwaraTagsSection({super.key, required this.tags, this.onTagTap});

  @override
  State<IwaraTagsSection> createState() => _IwaraTagsSectionState();
}

class _IwaraTagsSectionState extends State<IwaraTagsSection> {
  /// 是否展示原始 key（false 时展示当前语言译名）。
  bool _showOriginal = false;

  /// 是否存在「译名与原始 key 不同」的标签——只有此时切换按钮才有意义。
  bool get _hasMeaningfulTranslation {
    for (final tag in widget.tags) {
      if (TagLocalizationService.displayName(tag.id) != tag.id) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return ExpandableSectionWidget(
      title: t.common.iwaraTags,
      icon: Icons.label,
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
      child: TagsDisplayWidget(
        tags: widget.tags,
        onTagTap: widget.onTagTap,
        showOriginal: _showOriginal,
      ),
    );
  }
}
