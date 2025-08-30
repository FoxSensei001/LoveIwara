import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:super_clipboard/super_clipboard.dart';

import '../../../../../models/tag.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;


class TagsDisplayWidget extends StatelessWidget {
  final List<Tag> tags;
  final Function(Tag)? onTagTap;
  final int initialVisibleCount;
  final double spacing;
  final double runSpacing;

  const TagsDisplayWidget({
    super.key,
    required this.tags,
    this.onTagTap,
    this.initialVisibleCount = 5,
    this.spacing = 8.0,
    this.runSpacing = 4.0,
  });

  void _handleTagTap(Tag tag) {
    // 如果有标签点击回调，优先调用回调
    if (onTagTap != null) {
      onTagTap!(tag);
      return;
    }
    
    // 否则保持原来的复制行为
    final data = DataWriterItem();
    data.add(Formats.plainText(tag.id));
    SystemClipboard.instance?.write([data]);
    showToastWidget(
      MDToastWidget(
        message: slang.t.videoDetail.tagCopiedToClipboard(tagId: tag.id), 
        type: MDToastType.success
      ),
      position: ToastPosition.bottom, 
      duration: const Duration(seconds: 1)
    );
  }

  Widget _buildTagChip(Tag tag) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _handleTagTap(tag),
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
            tag.id,
            style: const TextStyle(
              fontSize: 13,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: tags.map(_buildTagChip).toList(),
    );
  }
}
