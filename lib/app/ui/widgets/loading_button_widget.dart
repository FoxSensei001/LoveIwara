import 'package:flutter/material.dart';

class LoadingButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String text;
  final String loadingText;
  final Widget? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;

  const LoadingButton({
    super.key,
    required this.onPressed,
    this.text = '点击重试',
    this.loadingText = '加载中...',
    this.icon = const Icon(Icons.refresh),
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 12,
    ),
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handlePress,
      icon: _isLoading
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(widget.foregroundColor),
        ),
      )
          : widget.icon ?? const Icon(Icons.refresh),
      label: Text(_isLoading ? widget.loadingText : widget.text),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        foregroundColor: widget.foregroundColor,
        padding: widget.padding,
        disabledBackgroundColor: widget.backgroundColor.withValues(alpha: 0.7),
        disabledForegroundColor: widget.foregroundColor.withValues(alpha: 0.7),
      ),
    );
  }
}