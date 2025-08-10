import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/common/widgets/input/input_components.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';

class ForumReplyBottomSheet extends StatefulWidget {
  const ForumReplyBottomSheet({
    super.key,
    required this.threadId,
    this.onSubmit,
    this.maxBodyInputLimit = 100000,
    this.initialContent,
  });

  final String threadId;
  final VoidCallback? onSubmit;
  final int maxBodyInputLimit;
  final String? initialContent;

  @override
  State<ForumReplyBottomSheet> createState() => _ForumReplyBottomSheetState();
}

class _ForumReplyBottomSheetState extends State<ForumReplyBottomSheet> {
  final ForumService _forumService = Get.find<ForumService>();
  bool _isLoading = false;

  void _handleSubmit(String text) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await _forumService.postReply(
      widget.threadId,
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
        Navigator.of(context).pop();
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
      title: t.forum.reply,
      hintText: t.common.writeYourContentHere,
      maxLength: widget.maxBodyInputLimit,
      maxLines: 5,
      showEmojiPicker: true,  // 启用表情包功能
      showTranslation: true,
      showMarkdownHelp: true,
      showPreview: true,
      showRulesAgreement: true,
      onSubmit: _handleSubmit,
      isLoading: _isLoading,
      initialContent: widget.initialContent,
      titleIcon: Icons.reply_outlined,
    );
  }
}

/*
使用示例：

// 显示论坛回复底部弹窗
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => ForumReplyBottomSheet(
    threadId: 'thread_id',
    initialContent: 'Reply #1: @username\n---\n',
    onSubmit: () {
      // 刷新帖子列表
      listSourceRepository.refresh();
    },
  ),
);
*/
