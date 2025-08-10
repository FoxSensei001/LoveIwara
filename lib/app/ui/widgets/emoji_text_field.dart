import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EmojiTextField extends StatefulWidget {
  final TextEditingController controller;
  final int? maxLines;
  final int? maxLength;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final FocusNode? focusNode;

  const EmojiTextField({
    super.key,
    required this.controller,
    this.maxLines,
    this.maxLength,
    this.decoration,
    this.onChanged,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<EmojiTextField> createState() => _EmojiTextFieldState();
}

class _EmojiTextFieldState extends State<EmojiTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _focusNode = widget.focusNode ?? FocusNode();
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
    setState(() {});
    widget.onChanged?.call(_controller.text);
  }

  // 解析文本中的表情包Markdown语法
  List<Widget> _buildTextSpans(String text) {
    final spans = <Widget>[];
    final regex = RegExp(r'!\[表情\]\((.*?)\)');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // 添加匹配前的文本
      if (match.start > lastIndex) {
        final beforeText = text.substring(lastIndex, match.start);
        if (beforeText.isNotEmpty) {
          spans.add(Text(beforeText));
        }
      }

      // 添加表情包图片
      final imageUrl = match.group(1)!;
      spans.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 12,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    // 添加剩余的文本
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        spans.add(Text(remainingText));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // 隐藏的TextField用于处理输入
          Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              onChanged: widget.onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
          // 可见的显示层
          GestureDetector(
            onTap: () {
              if (!_focusNode.hasFocus) {
                _focusNode.requestFocus();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                minHeight: (widget.maxLines ?? 1) * 20.0 + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 显示文本和表情包
                  if (_controller.text.isNotEmpty)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: _buildTextSpans(_controller.text),
                    )
                  else
                    Text(
                      widget.decoration?.hintText ?? '',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 16,
                      ),
                    ),
                  
                  // 字符计数
                  if (widget.maxLength != null) ...[
                    const SizedBox(height: 8),
                    Align(
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
                  ],
                  
                  // 错误文本
                  if (widget.decoration?.errorText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.decoration!.errorText!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
