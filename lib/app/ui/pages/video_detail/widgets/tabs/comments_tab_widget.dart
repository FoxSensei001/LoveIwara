import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/ui/pages/comment/controllers/comment_controller.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_dialog.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_section_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart' show AvatarWidget;
import 'package:i_iwara/common/constants.dart' show CommonConstants;
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart'; // 导入共享常量和组件
import 'package:i_iwara/app/ui/widgets/grid_speed_dial.dart'; // 导入GridSpeedDial

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
      // 使用GridSpeedDial替代固定头部
      floatingActionButton: GridSpeedDial(
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
    );
  }

  void _showCommentDialog(BuildContext context) {
    if (!Get.find<UserService>().isLogin) {
      showToastWidget(const MDToastWidget(message: '请先登录', type: MDToastType.error));
      Get.toNamed(Routes.LOGIN);
      return;
    }
    Get.dialog(
      CommentInputDialog(
        title: '发表评论',
        submitText: '发送', // 添加 submitText 参数
        onSubmit: (text) async {
          if (text.trim().isNotEmpty) {
            await commentController.postComment(text);
          } else {
            showToastWidget(const MDToastWidget(message: '评论内容不能为空', type: MDToastType.error));
          }
        },
      ),
    );
  }
}
