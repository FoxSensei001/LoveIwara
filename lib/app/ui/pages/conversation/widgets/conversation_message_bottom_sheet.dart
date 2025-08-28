import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/common/widgets/input/input_components.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';

class ConversationMessageBottomSheet extends StatefulWidget {
  const ConversationMessageBottomSheet({
    super.key,
    required this.conversationId,
    this.onSubmit,
  });

  final String conversationId;
  final VoidCallback? onSubmit;

  @override
  State<ConversationMessageBottomSheet> createState() => _ConversationMessageBottomSheetState();
}

class _ConversationMessageBottomSheetState extends State<ConversationMessageBottomSheet> {
  final ConversationService _conversationService = Get.find<ConversationService>();
  bool _isLoading = false;

  void _handleSubmit(String text) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await _conversationService.sendMessage(
      widget.conversationId,
      text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (result.isSuccess) {
      widget.onSubmit?.call();
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      showToastWidget(
        MDToastWidget(
          message: result.message,
          type: MDToastType.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheetInput(
      title: t.conversation.sendMessage,
      hintText: t.common.writeYourContentHere,
      maxLength: 1000,
      maxLines: 5,
      showEmojiPicker: true,
      showTranslation: true,
      showMarkdownHelp: true,
      showPreview: true,
      showRulesAgreement: false,
      onSubmit: _handleSubmit,
      isLoading: _isLoading,
      titleIcon: Icons.send_outlined,
    );
  }
}
