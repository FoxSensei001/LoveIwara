import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/common/widgets/input/input_components.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class ForumEditReplyDialog extends StatefulWidget {
  const ForumEditReplyDialog({
    super.key,
    required this.post,
    required this.initialContent,
    this.onSubmit,
    this.maxBodyInputLimit = 100000,
  });

  /// 要编辑的那一楼本体。
  ///
  /// ⛔ 这里原先收的是 [ThreadDetailRepository]，编辑时再从它里面
  /// `firstWhere(id)` 把楼层捞出来——而分页模式下帖子详情页渲染的是页面自己
  /// 维护的那份列表，repository 的 items 从头到尾是空的，于是 firstWhere 必抛，
  /// 「编辑回复」在分页模式下 100% 弹「获取数据失败」。
  ///
  /// 调用方手里本来就握着这条楼层，绕一圈去数据源里找它既多余又不成立。
  final ThreadCommentModel post;
  final String initialContent;
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

    // 接口要的是整条楼层的 JSON，只有 body 换成新内容。
    final Map<String, dynamic> jsonBody = widget.post.toJson();
    jsonBody['body'] = text;

    // 发送编辑请求
    final result = await _forumService.editPost(widget.post.id, jsonBody);

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
      showAppToast(result.message, type: AppToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialogInput(
      title: t.forum.editReply,
      hintText: t.common.writeYourContentHere,
      maxLength: widget.maxBodyInputLimit,
      maxLines: 5,
      showEmojiPicker: true, // 启用表情包功能
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
