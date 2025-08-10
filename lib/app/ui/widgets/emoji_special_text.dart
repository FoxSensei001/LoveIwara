import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 表情包特殊文本类
class EmojiText extends SpecialText {
  static const String flag = "![表情](";
  final int start;

  EmojiText(TextStyle textStyle, {this.start = 0}) : super(flag, ")", textStyle);

  @override
  InlineSpan finishText() {
    final String emojiText = toString();
    
    // 提取图片URL
    final urlMatch = RegExp(r'!\[表情\]\((.*?)\)').firstMatch(emojiText);
    if (urlMatch == null) {
      return TextSpan(text: emojiText, style: textStyle);
    }
    
    final imageUrl = urlMatch.group(1)!;
    
    return ImageSpan(
      CachedNetworkImageProvider(imageUrl),
      imageWidth: 24,
      imageHeight: 24,
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      start: start,
      actualText: emojiText,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
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
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}

/// 表情包特殊文本构建器
class EmojiSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    required int index,
  }) {
    if (flag.isEmpty) return null;

    // index是开始标志的结束索引，所以文本开始索引应该是index-(flag.length-1)
    if (isStart(flag, EmojiText.flag)) {
      return EmojiText(
        textStyle ?? const TextStyle(),
        start: index - (EmojiText.flag.length - 1),
      );
    }
    
    return null;
  }
}
