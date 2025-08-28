import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

enum MDToastType { success, error, info, warning }
enum MDToastStyle { filled, outlined, light }

class MDToastWidget extends StatelessWidget {
  final String message;
  final MDToastType type;
  final MDToastStyle style;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double? elevation;
  final VoidCallback? onTap;
  final bool dismissible;

  const MDToastWidget({
    super.key,
    required this.message,
    this.type = MDToastType.info,
    this.style = MDToastStyle.filled,
    this.leftIcon,
    this.rightIcon,
    this.textStyle,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
    this.onTap,
    this.dismissible = false,
  });

  Color get _backgroundColor {
    switch (type) {
      case MDToastType.success:
        return style == MDToastStyle.filled 
            ? Colors.green.shade800
            : style == MDToastStyle.light
                ? Colors.green.shade50
                : Colors.transparent;
      case MDToastType.error:
        return style == MDToastStyle.filled
            ? Colors.red.shade800
            : style == MDToastStyle.light
                ? Colors.red.shade50
                : Colors.transparent;
      case MDToastType.warning:
        return style == MDToastStyle.filled
            ? Colors.orange.shade800
            : style == MDToastStyle.light
                ? Colors.orange.shade50
                : Colors.transparent;
      case MDToastType.info:
      return style == MDToastStyle.filled
            ? Colors.grey.shade800
            : style == MDToastStyle.light
                ? Colors.grey.shade50
                : Colors.transparent;
    }
  }

  Color get _borderColor {
    switch (type) {
      case MDToastType.success:
        return Colors.green.shade800;
      case MDToastType.error:
        return Colors.red.shade800;
      case MDToastType.warning:
        return Colors.orange.shade800;
      case MDToastType.info:
      return Colors.grey.shade800;
    }
  }

  Color get _textColor {
    if (style == MDToastStyle.filled) {
      return Colors.white;
    } else {
      return _borderColor;
    }
  }

  IconData get _defaultIcon {
    switch (type) {
      case MDToastType.success:
        return Icons.check_circle_outline;
      case MDToastType.error:
        return Icons.error_outline;
      case MDToastType.warning:
        return Icons.warning_amber_rounded;
      case MDToastType.info:
      return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget toastContent = Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        border: style != MDToastStyle.filled
            ? Border.all(color: _borderColor, width: 1)
            : null,
        boxShadow: [
          if (elevation != null && elevation! > 0)
            BoxShadow(
              color: Colors.black.withAlpha(51),
              offset: Offset(0, elevation! / 2),
              blurRadius: elevation!,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leftIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: leftIcon,
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                _defaultIcon,
                color: _textColor,
                size: 20,
              ),
            ),
          Flexible(
            child: Text(
              message,
              style: textStyle?.copyWith(color: _textColor) ??
                  TextStyle(
                    color: _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (rightIcon != null)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: rightIcon,
            ),
          if (dismissible)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(Icons.close, color: _textColor, size: 18),
                onPressed: () {
                  // 使用 oktoast 的 dismissAllToast
                  dismissAllToast();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      toastContent = GestureDetector(
        onTap: onTap,
        child: toastContent,
      );
    }

    return toastContent;
  }
}
