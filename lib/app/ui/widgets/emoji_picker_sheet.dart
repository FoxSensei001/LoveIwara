import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_widget.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';

class EmojiPickerSheet extends StatefulWidget {
  final Function(String imageUrl, EmojiSize size) onEmojiSelected;
  final EmojiSize initialSize;
  final Function(EmojiSize) onSizeChanged;

  const EmojiPickerSheet({
    super.key,
    required this.onEmojiSelected,
    this.initialSize = EmojiSize.medium,
    required this.onSizeChanged,
  });

  @override
  State<EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<EmojiPickerSheet> {
  late EmojiSize _selectedSize;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.initialSize;
  }

  void _handleEmojiSelected(String imageUrl) {
    widget.onEmojiSelected(imageUrl, _selectedSize);
  }

  void _handleSizeChanged(EmojiSize size) {
    setState(() {
      _selectedSize = size;
    });
    widget.onSizeChanged(size);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 400; // 窄屏判断

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_emotions),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '选择表情包',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                // 表情包规格选择器
                if (!isNarrowScreen) ...[
                  // 宽屏：水平布局
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: EmojiSize.values.map((size) {
                      return GestureDetector(
                        onTap: () => _handleSizeChanged(size),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _selectedSize == size
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            size.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: _selectedSize == size
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  // 窄屏：显示当前选中的规格
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedSize.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // 窄屏时的规格选择器（单独一行）
          if (isNarrowScreen) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: EmojiSize.values.map((size) {
                  return GestureDetector(
                    onTap: () => _handleSizeChanged(size),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedSize == size
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        size.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _selectedSize == size
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          
          // 表情包选择器
          Expanded(
            child: EmojiPickerWidget(
              onEmojiSelected: _handleEmojiSelected,
            ),
          ),
        ],
      ),
    );
  }
}

/*
使用示例：

// 显示表情选择器
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => EmojiPickerSheet(
    initialSize: EmojiSize.medium, // 初始选中的规格
    onEmojiSelected: (imageUrl, size) {
      // 处理表情包选择
      print('选择了表情包: $imageUrl, 规格: ${size.displayName}');
      Navigator.pop(context);
    },
    onSizeChanged: (size) {
      // 处理规格变化
      print('规格变更为: ${size.displayName}');
    },
  ),
);

// 在其他地方也可以使用，比如评论输入、论坛发帖等
*/
