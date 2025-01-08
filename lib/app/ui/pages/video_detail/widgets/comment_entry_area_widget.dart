import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../common/constants.dart';
import '../../../../services/user_service.dart';
import '../../comment/controllers/comment_controller.dart';
import '../../../../../../i18n/strings.g.dart' as slang;
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
      if (commentController.isLoading.value &&
          !commentController.doneFirstTime.value) {
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
                  // 第一行：评论数量
                  Text(
                    t.videoDetail.commentCount(num: commentController.totalComments.value),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 第二行：根据是否有评论显示不同内容
                  Row(
                    children: [
                      AvatarWidget(
                        avatarUrl: commentController.comments.isNotEmpty
                            ? commentController.comments.first.user?.avatar?.avatarUrl
                            : userService.userAvatar,
                        defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                        headers: const {'referer': CommonConstants.iwaraBaseUrl},
                        radius: 20,
                        isPremium: commentController.comments.isNotEmpty
                            ? commentController.comments.first.user?.premium ?? false
                            : userService.currentUser.value?.premium ?? false,
                        isAdmin: commentController.comments.isNotEmpty
                            ? commentController.comments.first.user?.isAdmin ?? false
                            : userService.currentUser.value?.isAdmin ?? false,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          commentController.comments.isNotEmpty
                              ? _filterMarkdownImages(
                                  commentController.comments.first.body)
                              : t.videoDetail.writeYourCommentHere,
                          style: TextStyle(
                            fontSize: 14,
                            color: commentController.comments.isNotEmpty
                                ? Colors.black
                                : Colors.grey,
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
