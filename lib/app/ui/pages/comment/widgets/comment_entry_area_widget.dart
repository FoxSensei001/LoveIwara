import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/comment_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class CommentEntryAreaButtonWidget extends StatelessWidget {
  final CommentController commentController;
  final VoidCallback? onClickButton;

  const CommentEntryAreaButtonWidget({
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
        return _buildShimmerLine(context);
      }

      final colorScheme = Theme.of(context).colorScheme;
      final borderRadius = BorderRadius.circular(15);

      return Semantics(
        button: true,
        label: t.common.commentList,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              borderRadius: borderRadius,
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              borderRadius: borderRadius,
              onTap: onClickButton,
              splashColor: colorScheme.primary.withValues(alpha: 0.08),
              highlightColor: colorScheme.primary.withValues(alpha: 0.05),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题行：评论数量 + 待审核 + 展开暗示
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            t.common.totalComments(
                              count: commentController.totalComments.value,
                            ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${t.common.pendingCommentCount}: ${commentController.pendingCount.value}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 10),
                        Text(
                          t.common.expand,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // CTA 行：输入框样式（更像“按钮/入口”，而不是一条评论内容）
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.common.writeYourCommentHere,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // 一个 Shimmer 骨架屏
  Widget _buildShimmerLine(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(15);
    final baseColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.6,
    );
    final highlightColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.35,
    );

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: borderRadius,
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: InkWell(
          onTap: onClickButton,
          borderRadius: borderRadius,
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行 Shimmer
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Container(height: 16, color: baseColor)),
                      const SizedBox(width: 10),
                      Container(width: 42, height: 12, color: baseColor),
                      const SizedBox(width: 2),
                      Container(width: 18, height: 18, color: baseColor),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // CTA 行 Shimmer（输入框占位）
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
