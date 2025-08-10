import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'emoji_special_text.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';

class EnhancedEmojiTextField extends StatefulWidget {
  final TextEditingController controller;
  final int? maxLines;
  final int? maxLength;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final FocusNode? focusNode;
  final Function(String imageUrl)? onEmojiInserted;

  const EnhancedEmojiTextField({
    super.key,
    required this.controller,
    this.maxLines,
    this.maxLength,
    this.decoration,
    this.onChanged,
    this.enabled = true,
    this.focusNode,
    this.onEmojiInserted,
  });

  @override
  State<EnhancedEmojiTextField> createState() => EnhancedEmojiTextFieldState();
}

class EnhancedEmojiTextFieldState extends State<EnhancedEmojiTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late EmojiSpecialTextSpanBuilder _specialTextSpanBuilder;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _focusNode = widget.focusNode ?? FocusNode();
    _specialTextSpanBuilder = EmojiSpecialTextSpanBuilder();
    
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  // 插入表情包
  void insertEmoji(String imageUrl, {EmojiSize? size}) {
    if (!widget.enabled) return;
    
    final currentText = _controller.text;
    final selection = _controller.selection;
    
    // 确保光标位置有效
    final start = selection.start >= 0 ? selection.start : currentText.length;
    final end = selection.end >= 0 ? selection.end : start;
    
    // 确保索引不超出字符串范围
    final safeStart = start.clamp(0, currentText.length);
    final safeEnd = end.clamp(safeStart, currentText.length);
    
    // 在光标位置插入图片Markdown语法
    final beforeCursor = currentText.substring(0, safeStart);
    final afterCursor = currentText.substring(safeEnd);
    
    // 根据规格生成不同的Markdown语法
    String emojiMarkdown;
    if (size != null && size != EmojiSize.medium) {
      // 如果不是默认中等大小，则添加规格后缀
      emojiMarkdown = '![emo:${size.altSuffix}]($imageUrl)';
    } else {
      // 默认中等大小，使用标准格式
      emojiMarkdown = '![emo]($imageUrl)';
    }
    
    final newText = beforeCursor + emojiMarkdown + afterCursor;
    final newCursorPosition = safeStart + emojiMarkdown.length;
    
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: newCursorPosition);
    
    widget.onEmojiInserted?.call(imageUrl);
    
    // 确保获取焦点
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _focusNode.hasFocus && widget.enabled
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).dividerColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
        color: widget.enabled 
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 主要的输入区域
          ExtendedTextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            enabled: widget.enabled,
            specialTextSpanBuilder: _specialTextSpanBuilder,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null, // 完全禁用字符计数
            decoration: InputDecoration(
              hintText: widget.decoration?.hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          
          // 字符计数
          if (widget.maxLength != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_controller.text.length}/${widget.maxLength}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _controller.text.length > widget.maxLength!
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
          
          // 错误文本
          if (widget.decoration?.errorText != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                widget.decoration!.errorText!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 创建一个简单的文本输入对话框
class SimpleTextInputDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final int? maxLength;
  final Function(String) onConfirm;

  const SimpleTextInputDialog({
    super.key,
    required this.title,
    required this.initialValue,
    this.maxLength,
    required this.onConfirm,
  });

  @override
  State<SimpleTextInputDialog> createState() => _SimpleTextInputDialogState();
}

class _SimpleTextInputDialogState extends State<SimpleTextInputDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLength: widget.maxLength,
        maxLines: 5,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_controller.text);
            Navigator.of(context).pop();
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}