import 'package:flutter/material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

enum EmojiSize {
  small('text-i'),
  medium('mid-i'),
  large('large-i'),
  extraLarge('xl-i');

  const EmojiSize(this.altSuffix);

  final String altSuffix;

  /// 根据alt后缀获取枚举值
  static EmojiSize? fromAltSuffix(String altSuffix) {
    for (final size in EmojiSize.values) {
      if (size.altSuffix == altSuffix) {
        return size;
      }
    }
    return null;
  }

  /// 获取国际化显示名称
  String get displayName {
    switch (this) {
      case EmojiSize.small:
        return slang.t.emoji.small;
      case EmojiSize.medium:
        return slang.t.emoji.medium;
      case EmojiSize.large:
        return slang.t.emoji.large;
      case EmojiSize.extraLarge:
        return slang.t.emoji.extraLarge;
    }
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
      case EmojiSize.extraLarge:
        return 72.0;
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
      case EmojiSize.extraLarge:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 4);
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
      case EmojiSize.extraLarge:
        return 10.0;
    }
  }
}
