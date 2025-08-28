import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:super_clipboard/super_clipboard.dart';

import '../../../../../models/tag.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ExpandableTagsWidget extends StatefulWidget {
  final List<Tag> tags;
  final int initialVisibleCount;
  final double horizontalPadding;
  final double spacing;
  final double runSpacing;
  final Function(Tag)? onTagTap; // 新增标签点击回调

  const ExpandableTagsWidget({
    super.key,
    required this.tags,
    this.initialVisibleCount = 5,
    this.horizontalPadding = 16.0,
    this.spacing = 8.0,
    this.runSpacing = 4.0,
    this.onTagTap, // 新增参数
  });

  @override
  ExpandableTagsWidgetState createState() => ExpandableTagsWidgetState();
}

class ExpandableTagsWidgetState extends State<ExpandableTagsWidget>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _expanded = widget.tags.length <= widget.initialVisibleCount;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (_expanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleTagTap(Tag tag) {
    // 如果有标签点击回调，优先调用回调
    if (widget.onTagTap != null) {
      widget.onTagTap!(tag);
      return;
    }
    
    // 否则保持原来的复制行为
    final data = DataWriterItem();
    data.add(Formats.plainText(tag.id));
    SystemClipboard.instance?.write([data]);
    showToastWidget(MDToastWidget(message: slang.t.videoDetail.tagCopiedToClipboard(tagId: tag.id), type: MDToastType.success),position: ToastPosition.bottom, duration: const Duration(seconds: 1));
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
    if (widget.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
          child: Wrap(
            spacing: widget.spacing,
            runSpacing: widget.runSpacing,
            children: [
              ...widget.tags
                  .take(widget.initialVisibleCount)
                  .map(_buildTagChip),
              if (widget.tags.length > widget.initialVisibleCount)
                SizeTransition(
                  sizeFactor: _animation,
                  axisAlignment: -1.0,
                  child: Wrap(
                    spacing: widget.spacing,
                    runSpacing: widget.runSpacing,
                    children: widget.tags
                        .skip(widget.initialVisibleCount)
                        .map(_buildTagChip)
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
        if (widget.tags.length > widget.initialVisibleCount)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _toggleExpanded,
                  icon: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

