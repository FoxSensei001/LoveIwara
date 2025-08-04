import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../models/comment.model.dart';
import '../controllers/comment_controller.dart';
import 'comment_item_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class CommentSection extends StatelessWidget {
  final CommentController controller;
  final String? authorUserId;

  const CommentSection({super.key, required this.controller, this.authorUserId});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.comments.isEmpty) {
        // 初始加载时显示Shimmer骨架屏
        return _buildShimmerList();
      } else if (controller.errorMessage.value.isNotEmpty &&
          controller.comments.isEmpty) {
        // 如果有错误且没有评论，显示错误信息和重试按钮
        return _buildErrorState(context);
      } else if (!controller.isLoading.value && controller.comments.isEmpty) {
        // 如果没有评论，显示空状态
        return _buildEmptyState(context);
      } else {
        // 显示评论列表
        return _buildCommentList();
      }
    });
  }

  // 构建Shimmer骨架屏列表
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmerItem(),
    );
  }

  // 构建单个Shimmer骨架屏项
  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Theme.of(Get.context!).colorScheme.surfaceVariant.withOpacity(0.3),
      highlightColor: Theme.of(Get.context!).colorScheme.surface,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像占位
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12.0),
            // 文本占位
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    height: 12.0,
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Container(
                    height: 12.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    height: 10.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建错误状态视图
  Widget _buildErrorState(BuildContext context) {
    final t = slang.Translations.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 48.0,
            ),
            const SizedBox(height: 16.0),
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            FilledButton.icon(
              onPressed: controller.refreshComments,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(t.common.retry),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建空状态视图
  Widget _buildEmptyState(BuildContext context) {
    final t = slang.Translations.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24.0),
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 64.0,
            ),
            const SizedBox(height: 16.0),
            Text(
              t.common.tmpNoComments,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 构建评论列表视图
  Widget _buildCommentList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!controller.isLoading.value &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100 &&
            controller.hasMore.value) {
          // 接近底部时加载更多评论
          controller.loadMoreComments();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.comments.length + 1,
        separatorBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        itemBuilder: (context, index) {
          if (index < controller.comments.length) {
            Comment comment = controller.comments[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: CommentItem(
                key: ValueKey(comment.id),
                comment: comment,
                authorUserId: authorUserId,
                controller: controller,
              ),
            );
          } else {
            // 最后一项显示加载指示器或结束提示
            return _buildLoadMoreIndicator(context);
          }
        },
      ),
    );
  }

  // 构建加载更多指示器
  Widget _buildLoadMoreIndicator(BuildContext context) {
    final t = slang.Translations.of(context);
    if (controller.hasMore.value) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: controller.isLoading.value
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      '加载中...',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16.0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8.0),
                Text(
                  t.common.noMoreDatas,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
