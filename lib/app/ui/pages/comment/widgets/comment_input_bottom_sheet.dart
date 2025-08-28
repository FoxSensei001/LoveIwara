import 'package:flutter/material.dart';
import 'package:i_iwara/common/widgets/input/input_components.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class CommentInputBottomSheet extends StatefulWidget {
  final String? initialText;
  final Function(String) onSubmit;
  final String title;
  final String submitText;
  final int maxLength;

  const CommentInputBottomSheet({
    super.key,
    this.initialText,
    required this.onSubmit,
    required this.title,
    required this.submitText,
    this.maxLength = 1000,
  });

  @override
  State<CommentInputBottomSheet> createState() => _CommentInputBottomSheetState();
}

class _CommentInputBottomSheetState extends State<CommentInputBottomSheet> {
  bool _isLoading = false;



  void _handleSubmit(String text) async {
    setState(() {
      _isLoading = true;
    });
    await widget.onSubmit(text);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.t;
    
    return BaseBottomSheetInput(
      title: widget.title,
      hintText: t.common.writeYourCommentHere,
      maxLength: widget.maxLength,
      maxLines: 5,
      showEmojiPicker: true,  // 启用表情包功能
      showTranslation: true,
      showMarkdownHelp: true,
      showPreview: true,
      showRulesAgreement: true,
      onSubmit: _handleSubmit,
      isLoading: _isLoading,
      initialContent: widget.initialText,
      titleIcon: Icons.edit_outlined,
      submitText: widget.submitText,
    );
  }
}