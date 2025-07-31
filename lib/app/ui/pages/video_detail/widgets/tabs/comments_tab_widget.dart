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
import 'package:i_iwara/app/ui/widgets/grid_speed_dial.dart';
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
    return Scaffold(
      body: Column(
        children: [
          // 只保留评论列表，不显示顶部评论数量
          Expanded(
            child: Obx(() => CommentSection(
              controller: commentController,
              authorUserId: videoController.videoInfo.value?.user?.id,
            )),
          ),
        ],
      ),
      // 使用GridSpeedDial替代固定头部，并添加评论数量徽章
      floatingActionButton: Obx(() {
        final commentCount = commentController.totalComments.value;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Stack(
            clipBehavior: Clip.none, // Allows badge to overflow
            alignment: Alignment.center,
            children: [
              GridSpeedDial(
                // 主按钮图标
                icon: Icons.more_vert,
                activeIcon: Icons.close,
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 8,
                animationDuration: const Duration(milliseconds: 300),
                direction: SpeedDialDirection.up,
                spacing: 8,
                spaceBetweenChildren: 8,
                
                // 子按钮配置
                childrens: [
                  [
                    // 第一列：刷新评论
                    SpeedDialChild(
                      child: const Icon(Icons.refresh, color: Colors.white),
                      backgroundColor: Colors.blue,
                      onTap: () {
                        commentController.refreshComments();
                      },
                    ),
                  ],
                  [
                    // 第二列：写评论
                    SpeedDialChild(
                      child: const Icon(Icons.send, color: Colors.white),
                      backgroundColor: Colors.green,
                      onTap: () => _showCommentDialog(context),
                    ),
                  ],
                ],
              ),
              // 添加评论数量徽章
              if (commentCount > 0)
                Positioned(
                  top: -8, // Adjust as needed to position the badge above the icon
                  right: -8, // Adjust as needed to position the badge to the right of the icon
                  child: Badge(
                    label: Text('$commentCount'),
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Adjust padding for better appearance
                    alignment: Alignment.center,
                  ),
                ),
            ],
          ),
        );
      }),
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
