import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
          borderRadius: isCircle
              ? null
              : BorderRadius.circular(radius.toDouble()),
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

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: EdgeInsets.only(
          left: isReply ? 0.0 : 8.0,
          right: 8.0,
          top: 6.0,
          bottom: 6.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                box(height: 32, width: 32, isCircle: true),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          box(height: 14, width: 120),
                          const SizedBox(width: 8),
                          if (!isReply) pill(height: 14, width: 44),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          pill(height: 14, width: 44),
                          const SizedBox(width: 6),
                          pill(height: 14, width: 54),
                          const SizedBox(width: 6),
                          pill(height: 14, width: 40),
                        ],
                      ),
                      const SizedBox(height: 6),
                      box(height: 12, width: 92),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  line(height: 12, widthFactor: 0.92),
                  const SizedBox(height: 6),
                  line(height: 12, widthFactor: 0.7),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      pill(height: 24, width: 116),
                      const Spacer(),
                      if (!isReply) ...[
                        box(height: 20, width: 20, isCircle: true),
                        const SizedBox(width: 8),
                      ],
                      box(height: 16, width: 16, isCircle: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  line(height: 12, widthFactor: isReply ? 0.5 : 0.58),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
