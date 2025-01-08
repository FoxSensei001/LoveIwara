import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
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

  const ExpandableTagsWidget({
    super.key,
    required this.tags,
    this.initialVisibleCount = 5,
    this.horizontalPadding = 16.0,
    this.spacing = 8.0,
    this.runSpacing = 4.0,
  });

  @override
  _ExpandableTagsWidgetState createState() => _ExpandableTagsWidgetState();
}

class _ExpandableTagsWidgetState extends State<ExpandableTagsWidget>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // 添加预定义的现代化颜色列表
  static const List<Color> _tagColors = [
    Color(0xFF5D4037), // 深棕色
    Color(0xFF455A64), // 蓝灰色
    Color(0xFF2E7D32), // 深绿色
    Color(0xFF1565C0), // 深蓝色
    Color(0xFF6A1B9A), // 深紫色
    Color(0xFFC62828), // 深红色
    Color(0xFF4527A0), // 靛蓝色
    Color(0xFF00695C), // 深青色
    Color(0xFF558B2F), // 橄榄绿
    Color(0xFFEF6C00), // 深橙色
  ];

  // 根据标签ID获取颜色
  Color _getTagColor(String tagId) {
    if (tagId.isEmpty) return _tagColors[0];
    
    // 计算字符串的简单哈希值
    int hash = 0;
    for (var i = 0; i < tagId.length; i++) {
      hash = tagId.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    // 确保hash为正数并获取颜色索引
    hash = hash.abs();
    return _tagColors[hash % _tagColors.length];
  }

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
                ? Colors.red.withOpacity(0.08)
                : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tag.sensitive
                  ? Colors.red.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
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

