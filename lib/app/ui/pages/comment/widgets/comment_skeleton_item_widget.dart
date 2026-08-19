import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// 评论骨架屏：镜像 CommentItem 的扁平线程布局
/// （头像列 + 名字行 / 元信息行 / 正文两行 / 幽灵动作行）。
class CommentSkeletonItem extends StatelessWidget {
  final bool isReply;

  const CommentSkeletonItem({super.key, this.isReply = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.6,
    );
    final highlightColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.35,
    );

    Widget box({
      required double height,
      double? width,
      double radius = 6,
      bool isCircle = false,
    }) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: baseColor,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(radius),
        ),
      );
    }

    Widget line({required double height, required double widthFactor}) {
      return FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: Alignment.centerLeft,
        child: box(height: height),
      );
    }

    Widget pill({required double height, required double width}) {
      return box(height: height, width: width, radius: 999);
    }

    final double avatarSize = isReply ? 30 : 36;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像列
            box(height: avatarSize, width: avatarSize, isCircle: true),
            const SizedBox(width: 10),
            // 内容列
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名字行：名字 + 楼号
                  Row(
                    children: [
                      box(height: 13, width: 110),
                      const Spacer(),
                      if (!isReply) box(height: 11, width: 26),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 元信息行
                  box(height: 11, width: 150),
                  const SizedBox(height: 10),
                  // 正文两行
                  line(height: 12, widthFactor: 0.95),
                  const SizedBox(height: 6),
                  line(height: 12, widthFactor: 0.6),
                  const SizedBox(height: 10),
                  // 动作行
                  Row(
                    children: [
                      if (!isReply) ...[
                        pill(height: 22, width: 56),
                        const SizedBox(width: 8),
                        pill(height: 22, width: 44),
                      ],
                      const Spacer(),
                      pill(height: 22, width: 52),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
