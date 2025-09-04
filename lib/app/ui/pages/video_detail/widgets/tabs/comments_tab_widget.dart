import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/ui/pages/comment/controllers/comment_controller.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_bottom_sheet.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_section_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/grid_speed_dial.dart';
import 'package:oktoast/oktoast.dart';

import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 静态实现的评论Tab组件
class CommentsTabWidget extends StatelessWidget {
  final CommentController commentController;
  final MyVideoStateController videoController;

  static const double _edgePadding = 16.0;
  static const double _bottomPadding = 32.0; // 增加底部间距

  const CommentsTabWidget({
    super.key,
    required this.commentController,
    required this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Obx(
                  () => CommentSection(
                    controller: commentController,
                    authorUserId: videoController.videoInfo.value?.user?.id,
                    topPadding: 0.0,
                  ),
                ),
              ),
              // 浮动按钮
              Positioned(
                right: _edgePadding,
                bottom: _bottomPadding,
                child: Obx(() {
                  final commentCount = commentController.totalComments.value;
                  final sortOrder = commentController.sortOrder.value;
                  return GridSpeedDial(
                    activeIcon: Icons.close,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    spacing: 4,
                    spaceBetweenChildren: 3,
                    direction: SpeedDialDirection.up,
                    childPadding: const EdgeInsets.all(4),
                    childrens: [
                      [
                        // 第一列
                        SpeedDialChild(
                          child: const Icon(Icons.refresh_rounded),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          onTap: () {
                            commentController.refreshComments();
                          },
                        ),
                        SpeedDialChild(
                          child: const Icon(Icons.edit_outlined),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          onTap: () =>
                              _showCommentDialog(context, commentController),
                        ),
                        SpeedDialChild(
                          child: Icon(
                            sortOrder
                                ? Icons
                                      .arrow_downward_rounded // 倒序图标
                                : Icons.arrow_upward_rounded, // 正序图标
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.tertiaryContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onTertiaryContainer,
                          onTap: () {
                            commentController.toggleSortOrder();
                          },
                        ),
                      ],
                    ],
                    child: commentCount > 0
                        ? Text(
                            commentCount > 99 ? '99+' : commentCount.toString(),
                            textAlign: TextAlign.center,
                          )
                        : const Icon(Icons.comment_outlined),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  static void _showCommentDialog(
    BuildContext context,
    CommentController commentController,
  ) {
    final t = slang.Translations.of(context);
    if (!Get.find<UserService>().isLogin) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.pleaseLoginFirst,
          type: MDToastType.error,
        ),
      );
      LoginService.showLogin();
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentInputBottomSheet(
        title: t.common.sendComment,
        submitText: t.common.send,
        onSubmit: (text) async {
          if (text.trim().isNotEmpty) {
            await commentController.postComment(text);
          } else {
            showToastWidget(
              MDToastWidget(
                message: t.errors.commentCanNotBeEmpty,
                type: MDToastType.error,
              ),
            );
          }
        },
      ),
    );
  }
}
