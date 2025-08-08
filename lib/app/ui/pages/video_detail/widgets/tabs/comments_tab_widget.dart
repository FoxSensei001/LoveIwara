import 'dart:ui';
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
      body: Stack(
        children: [
          // 评论列表 - 添加顶部 padding
          Positioned.fill(
            child: Obx(() => CommentSection(
              controller: commentController,
              authorUserId: videoController.videoInfo.value?.user?.id,
              topPadding: 42.0, // 为浮动栏预留空间
            )),
          ),
          // 浮动的顶部操作栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    // 添加轻微的阴影
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Obx(() {
                      final commentCount = commentController.totalComments.value;
                      return Row(
                        children: [
                          // 评论图标
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(
                              Icons.comment_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 评论数量
                          Text(
                            '$commentCount',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.share.comments,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          // 占位符，将右侧按钮推到最右边
                          const Spacer(),
                          // 刷新按钮
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              onPressed: () {
                                commentController.refreshComments();
                              },
                              tooltip: t.common.refresh,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // 写评论按钮
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.edit_outlined, 
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () => _showCommentDialog(context),
                              tooltip: t.common.sendComment,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
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
