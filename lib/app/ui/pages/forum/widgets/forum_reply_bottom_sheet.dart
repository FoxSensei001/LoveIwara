import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/app/utils/comment_markup.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/common/widgets/input/input_components.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class ForumReplyBottomSheet extends StatefulWidget {
  const ForumReplyBottomSheet({
    super.key,
    required this.threadId,
    this.onSubmit,
    this.maxBodyInputLimit = 100000,
    this.initialContent,
    this.quote,
    this.signatureContext = SignatureContext.empty,
  });

  final String threadId;
  final VoidCallback? onSubmit;
  final int maxBodyInputLimit;
  final String? initialContent;

  /// 小尾巴的上下文：论坛给得出主题标题、版块名和楼主，回复某一楼时还多一个
  /// 「回给谁」。见 [SignatureContext]。
  final SignatureContext signatureContext;

  /// 这条回复冲着哪一楼去。引用卡片画在输入框上方，用户可当场撤销；
  /// 真正的 markdown 引用块在提交那一刻才由 `CommentMarkup.compose` 拼出来。
  final ReplyQuote? quote;

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

    final result = await _forumService.postReply(widget.threadId, text);

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
      showAppToast(result.message, type: AppToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheetInput(
      title: t.forum.reply,
      hintText: t.common.writeYourContentHere,
      maxLength: widget.maxBodyInputLimit,
      maxLines: 5,
      showEmojiPicker: true, // 启用表情包功能
      showTranslation: true,
      showMarkdownHelp: true,
      showPreview: true,
      showRulesAgreement: true,
      onSubmit: _handleSubmit,
      isLoading: _isLoading,
      initialContent: widget.initialContent,
      quote: widget.quote,
      signatureContext: widget.signatureContext,
      titleIcon: Icons.reply_outlined,
    );
  }
}

/*
使用示例：

// 显示论坛回复底部弹窗
showGlassBottomSheet(
  context: context,
  builder: (context) => ForumReplyBottomSheet(
    threadId: 'thread_id',
    quote: ReplyQuote(floor: 1, username: 'username', excerpt: '原文摘要…'),
    onSubmit: () {
      // 刷新帖子列表
      listSourceRepository.refresh();
    },
  ),
);
*/
