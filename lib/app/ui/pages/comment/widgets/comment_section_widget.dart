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
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmerItem(),
    );
  }

  // 构建单个Shimmer骨架屏项
  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像占位
            Container(
              width: 40.0,
              height: 40.0,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12.0),
            // 文本占位
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12.0, color: Colors.white),
                  const SizedBox(height: 8.0),
                  Container(height: 12.0, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 8.0),
                  Container(height: 12.0, width: 200.0, color: Colors.white),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: controller.refreshComments,
              icon: const Icon(Icons.refresh),
              label: Text(t.common.retry),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          t.common.tmpNoComments,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
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
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.comments.length + 1,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index < controller.comments.length) {
            Comment comment = controller.comments[index];
            return CommentItem(
              comment: comment,
              authorUserId: authorUserId,
              controller: controller,
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: controller.isLoading.value
              ? const CircularProgressIndicator()
              : const SizedBox.shrink(),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            t.common.noMoreDatas,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
  }
}
