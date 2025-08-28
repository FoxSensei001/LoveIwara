import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_detail_repository.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/common/widgets/input/input_components.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';

class ForumEditReplyDialog extends StatefulWidget {
  const ForumEditReplyDialog({
    super.key,
    required this.postId,
    required this.initialContent,
    required this.repository,
    this.onSubmit,
    this.maxBodyInputLimit = 100000,
  });

  final String postId;
  final String initialContent;
  final ThreadDetailRepository repository;
  final VoidCallback? onSubmit;
  final int maxBodyInputLimit;

  @override
  State<ForumEditReplyDialog> createState() => _ForumEditReplyDialogState();
}

class _ForumEditReplyDialogState extends State<ForumEditReplyDialog> {
  final ForumService _forumService = Get.find<ForumService>();
  bool _isLoading = false;

  void _handleSubmit(String text) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // 从 repository 中获取原始回复数据
    ThreadCommentModel? originalPost;
    try {
      originalPost = widget.repository.firstWhere(
        (post) => post.id == widget.postId,
      );
    } catch (e) {
      // 找不到对应的回复
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      showToastWidget(
        MDToastWidget(
          message: t.errors.failedToFetchData,
          type: MDToastType.error,
        ),
      );
      return;
    }

    // 转换为 JSON 并更新 body
    final Map<String, dynamic> jsonBody = originalPost.toJson();
    jsonBody['body'] = text;

    // 发送编辑请求
    final result = await _forumService.editPost(
      widget.postId,
      jsonBody,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (result.isSuccess) {
      widget.onSubmit?.call();
      if (mounted) {
        AppService.tryPop();
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
    return BaseDialogInput(
      title: t.forum.editReply,
      hintText: t.common.writeYourContentHere,
      maxLength: widget.maxBodyInputLimit,
      maxLines: 5,
      showEmojiPicker: true,  // 启用表情包功能
      showTranslation: false,
      showMarkdownHelp: true,
      showPreview: true,
      showRulesAgreement: true,
      onSubmit: _handleSubmit,
      onCancel: () => AppService.tryPop(),
      isLoading: _isLoading,
      initialContent: widget.initialContent,
    );
  }
} 