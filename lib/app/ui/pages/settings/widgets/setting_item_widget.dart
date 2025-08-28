import 'package:flutter/material.dart';

class SettingItem extends StatefulWidget {
  final String label;
  final String initialValue;
  final String? Function(String) validator;
  final Function(String) onValid;
  final TextInputType keyboardType;
  final bool readOnly;
  final TextStyle? labelStyle;
  final TextStyle? inputStyle;
  final InputDecoration? inputDecoration;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final Widget? icon;
  final bool splitTwoLine;
  final Widget? labelSuffix;

  const SettingItem({
    super.key,
    required this.label,
    required this.initialValue,
    required this.validator,
    required this.onValid,
    this.readOnly = false,
    this.keyboardType = TextInputType.number,
    this.labelStyle,
    this.inputStyle,
    this.inputDecoration,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.icon,
    this.splitTwoLine = false,
    this.labelSuffix,
  });

  @override
  State<SettingItem> createState() => _SettingItemState();
}

class _SettingItemState extends State<SettingItem> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  void _handleChanged(String value) {
    final error = widget.validator(value);
    setState(() {
      _errorText = error;
    });
    if (error == null) {
      widget.onValid(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.splitTwoLine) ...[
            Row(
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.label,
                          style: widget.labelStyle ??
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (widget.labelSuffix != null) widget.labelSuffix!,
                      // 添加 labelSuffix
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTextField(),
          ] else ...[
            Row(
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.label,
                          style: widget.labelStyle ??
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (widget.labelSuffix != null) widget.labelSuffix!,
                      // 添加 labelSuffix
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: _buildTextField(),
                ),
              ],
            ),
          ],
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _errorText!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    // TextField 代码保持不变
    return TextField(
      readOnly: widget.readOnly,
      decoration: widget.inputDecoration ??
          InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _errorText == null
                    ? Colors.grey.shade300
                    : Colors.redAccent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _errorText == null
                    ? Theme.of(context).primaryColor
                    : Colors.redAccent,
                width: 2,
              ),
            ),
            filled: true,
            fillColor:
            widget.readOnly ? Colors.grey.shade100 : Colors.transparent,
          ),
      keyboardType: widget.keyboardType,
      controller: _controller,
      onChanged: _handleChanged,
      style: widget.inputStyle ?? Theme.of(context).textTheme.titleMedium,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
