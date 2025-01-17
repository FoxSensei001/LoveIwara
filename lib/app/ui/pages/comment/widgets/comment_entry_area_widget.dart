import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../common/constants.dart';
import '../../../../services/user_service.dart';
import '../controllers/comment_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class CommentEntryAreaButtonWidget extends StatelessWidget {
  final UserService userService = Get.find();
  final CommentController commentController;
  final VoidCallback? onClickButton;

  CommentEntryAreaButtonWidget({
    super.key,
    required this.commentController,
    this.onClickButton,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      if (commentController.isLoading.value && !commentController.doneFirstTime.value) {
        return _buildShimmerLine();
      } else {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onClickButton,
            splashColor: Colors.blue.withAlpha(30),
            child: Container(
              width: double.infinity, // 确保 InkWell 覆盖整个宽度
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 第一行：评论数量和待审核评论数量
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.common.totalComments(count: commentController.totalComments.value),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (commentController.pendingCount.value > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${t.common.pendingCommentCount}: ${commentController.pendingCount.value}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 第二行：根据是否有评论显示不同内容
                  Row(
                    children: [
                      Obx(() {
                        String avatarUrl;
                        bool isPremium;
                        bool isAdmin;
                        if (commentController.comments.isNotEmpty) {
                          avatarUrl = commentController.comments.first.user?.avatar?.avatarUrl ?? CommonConstants.defaultAvatarUrl;
                          isPremium = commentController.comments.first.user?.premium ?? false;
                          isAdmin = commentController.comments.first.user?.isAdmin ?? false;
                        } else {
                          avatarUrl = userService.userAvatar;
                          isPremium = userService.currentUser.value?.premium ?? false;
                          isAdmin = userService.currentUser.value?.isAdmin ?? false;
                        }
                        return AvatarWidget(
                          avatarUrl: avatarUrl,
                          defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                          headers: const {'referer': CommonConstants.iwaraBaseUrl},
                          radius: 20,
                          isPremium: isPremium,
                          isAdmin: isAdmin,
                        );
                      }),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          commentController.comments.isNotEmpty
                              ? _filterMarkdownImages(commentController.comments.first.body)
                              : t.common.writeYourCommentHere,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  // 一个 Shimmer 骨架屏
  Widget _buildShimmerLine() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onClickButton,
        borderRadius: BorderRadius.circular(15),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity, // 确保 Shimmer 覆盖整个宽度
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一行 Shimmer
                Container(
                  width: 150,
                  height: 16,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                // 第二行 Shimmer
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 14,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 过滤 Markdown 中的图片语法，保留纯文本
  String _filterMarkdownImages(String text) {
    // 简单的正则表达式去除 Markdown 图片语法 ![alt](url)
    final RegExp imageRegex = RegExp(r'!\[.*?\]\(.*?\)');
    return text.replaceAll(imageRegex, '').trim();
  }
}
