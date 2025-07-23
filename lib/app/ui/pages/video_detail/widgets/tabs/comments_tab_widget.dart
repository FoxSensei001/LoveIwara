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
    return Column(
      children: [
        // 评论头部：评论数量和发布评论按钮
        _buildCommentsHeader(context),
        
        // 评论列表
        Expanded(
          child: Obx(() => CommentSection(
            controller: commentController,
            authorUserId: videoController.videoInfo.value?.user?.id,
          )),
        ),
      ],
    );
  }

  Widget _buildCommentsHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：评论数量标题
          Row(
            children: [
              Icon(
                Icons.comment,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Obx(() => Text(
                '评论 (${commentController.totalComments.value})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              )),
              const Spacer(),
              // 刷新按钮
              IconButton(
                onPressed: () => commentController.refreshComments(),
                icon: const Icon(Icons.refresh),
                tooltip: '刷新评论',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 第二行：发布评论输入框样式按钮
          _buildCommentInputButton(context),
        ],
      ),
    );
  }

  Widget _buildCommentInputButton(BuildContext context) {
    final UserService userService = Get.find();
    
    return Obx(() {
      return InkWell(
        onTap: () => _showCommentDialog(context),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(25),
            color: Theme.of(context).cardColor,
          ),
          child: Row(
            children: [
              // 用户头像
              CircleAvatar(
                radius: 16,
                backgroundImage: userService.isLogin && userService.userAvatar.isNotEmpty
                    ? NetworkImage(userService.userAvatar)
                    : null,
                backgroundColor: Colors.grey[300],
                child: !userService.isLogin || userService.userAvatar.isEmpty
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              
              const SizedBox(width: 12),
              
              // 占位文字
              Expanded(
                child: Text(
                  userService.isLogin ? '写下你的评论...' : '登录后发表评论',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
              
              // 发送图标
              Icon(
                Icons.send,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showCommentDialog(BuildContext context) {
    final UserService userService = Get.find();
    
    if (!userService.isLogin) {
      showToastWidget(
        MDToastWidget(
          message: '请先登录',
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
      Get.toNamed(Routes.LOGIN);
      return;
    }

    Get.dialog(
      CommentInputDialog(
        title: '发表评论',
        submitText: '发送',
        onSubmit: (text) async {
          if (text.trim().isEmpty) {
            showToastWidget(
              MDToastWidget(
                message: '评论内容不能为空',
                type: MDToastType.error,
              ),
              position: ToastPosition.bottom,
            );
            return;
          }
          
          await commentController.postComment(text);
        },
      ),
      barrierDismissible: true,
    );
  }
} 