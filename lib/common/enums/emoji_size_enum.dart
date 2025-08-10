import 'package:flutter/material.dart';

enum EmojiSize {
  small('text-i', '小'),
  medium('mid-i', '中'),
  large('large-i', '大');

  const EmojiSize(this.altSuffix, this.displayName);
  
  final String altSuffix;
  final String displayName;
  
  /// 根据alt后缀获取枚举值
  static EmojiSize? fromAltSuffix(String altSuffix) {
    for (final size in EmojiSize.values) {
      if (size.altSuffix == altSuffix) {
        return size;
      }
    }
    return null;
  }
  
  /// 获取对应的显示尺寸
  double get displaySize {
    switch (this) {
      case EmojiSize.small:
        return 24.0;
      case EmojiSize.medium:
        return 40.0;
      case EmojiSize.large:
        return 56.0;
    }
  }
  
  /// 获取对应的边距
  EdgeInsets get margin {
    switch (this) {
      case EmojiSize.small:
        return const EdgeInsets.symmetric(horizontal: 1, vertical: 1);
      case EmojiSize.medium:
        return const EdgeInsets.symmetric(horizontal: 2, vertical: 2);
      case EmojiSize.large:
        return const EdgeInsets.symmetric(horizontal: 4, vertical: 3);
    }
  }
  
  /// 获取对应的圆角
  double get borderRadius {
    switch (this) {
      case EmojiSize.small:
        return 4.0;
      case EmojiSize.medium:
        return 6.0;
      case EmojiSize.large:
        return 8.0;
    }
  }
}
