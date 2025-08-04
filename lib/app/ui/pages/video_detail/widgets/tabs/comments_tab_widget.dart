import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/ui/pages/comment/controllers/comment_controller.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_dialog.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_section_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:oktoast/oktoast.dart';

import 'package:i_iwara/i18n/strings.g.dart' as slang;

class CommentsTabWidget extends StatelessWidget {
  final CommentController commentController;
  final MyVideoStateController videoController;

  const CommentsTabWidget({
    super.key,
    required this.commentController,
    required this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      body: Column(
        children: [
          // 顶部操作栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Obx(() {
              final commentCount = commentController.totalComments.value;
              return Row(
                children: [
                  // 评论图标
                  Icon(
                    Icons.comment,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  // 评论数量
                  Text(
                    '$commentCount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  // 占位符，将右侧按钮推到最右边
                  const Spacer(),
                  // 刷新按钮
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      commentController.refreshComments();
                    },
                    tooltip: t.common.refresh,
                  ),
                  // 写评论按钮
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () => _showCommentDialog(context),
                    tooltip: t.common.sendComment,
                  ),
                ],
              );
            }),
          ),
          // 评论列表
          Expanded(
            child: Obx(() => CommentSection(
              controller: commentController,
              authorUserId: videoController.videoInfo.value?.user?.id,
            )),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    if (!Get.find<UserService>().isLogin) {
      showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error));
      Get.toNamed(Routes.LOGIN);
      return;
    }
    Get.dialog(
      CommentInputDialog(
        title: t.common.sendComment,
        submitText: t.common.send, // 添加 submitText 参数
        onSubmit: (text) async {
          if (text.trim().isNotEmpty) {
            await commentController.postComment(text);
          } else {
            showToastWidget(MDToastWidget(message: t.errors.commentCanNotBeEmpty, type: MDToastType.error));
          }
        },
      ),
    );
  }
}
