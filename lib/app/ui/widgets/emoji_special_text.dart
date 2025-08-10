import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';

/// 表情包特殊文本类
class EmojiText extends SpecialText {
  static const String flag = "![emo";
  final int start;

  EmojiText(TextStyle textStyle, {this.start = 0}) : super(flag, ")", textStyle);

  @override
  InlineSpan finishText() {
    final String emojiText = toString();
    
    // 提取图片URL和规格信息
    // 匹配格式：![emo]() 或 ![emo:规格]()
    final urlMatch = RegExp(r'!\[emo(?::([^\]]+))?\]\((.*?)\)').firstMatch(emojiText);
    if (urlMatch == null) {
      return TextSpan(text: emojiText, style: textStyle);
    }
    
    final imageUrl = urlMatch.group(2)!;
    final sizeSuffix = urlMatch.group(1); // 可能为null
    
    // 确定表情包规格
    EmojiSize emojiSize;
    if (sizeSuffix != null) {
      emojiSize = EmojiSize.fromAltSuffix(sizeSuffix) ?? EmojiSize.medium;
    } else {
      emojiSize = EmojiSize.medium; // 默认中等大小
    }
    
    return ImageSpan(
      CachedNetworkImageProvider(imageUrl),
      imageWidth: emojiSize.displaySize,
      imageHeight: emojiSize.displaySize,
      margin: emojiSize.margin,
      start: start,
      actualText: emojiText,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: emojiSize.displaySize,
          height: emojiSize.displaySize,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(emojiSize.borderRadius),
          ),
          child: Center(
            child: SizedBox(
              width: emojiSize.displaySize * 0.4,
              height: emojiSize.displaySize * 0.4,
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

    // 检查是否以表情包标志开始
    if (isStart(flag, EmojiText.flag)) {
      return EmojiText(
        textStyle ?? const TextStyle(),
        start: index - (EmojiText.flag.length - 1),
      );
    }
    
    return null;
  }
}
