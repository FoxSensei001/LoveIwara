import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MediaTileListSkeletonWidget extends StatelessWidget {
  const MediaTileListSkeletonWidget({super.key});

  static const double _itemHeight = 120.0;
  static const double _thumbnailWidth = 120.0;
  static const double _thumbnailHeight = 90.0;
  static const double _horizontalPadding = 16.0;
  static const double _verticalPadding = 8.0;
  static const double _spacing = 16.0;
  static const BorderRadius _borderRadius = BorderRadius.all(Radius.circular(8.0));

  Widget _buildShimmerContainer({
    required double height,
    double? width,
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? _borderRadius,
      ),
    );
  }

  Widget _buildTileContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: _verticalPadding,
        horizontal: _horizontalPadding,
      ),
      child: Row(
        children: [
          _buildShimmerContainer(
            height: _thumbnailHeight,
            width: _thumbnailWidth,
          ),
          const SizedBox(width: _spacing),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerContainer(height: 16),
                const SizedBox(height: 4),
                _buildShimmerContainer(height: 14),
                const SizedBox(height: 4),
                _buildShimmerContainer(height: 12, width: 100),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildShimmerContainer(height: 12, width: 60),
                    const SizedBox(width: _spacing),
                    _buildShimmerContainer(height: 12, width: 40),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemExtent: _itemHeight,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: _buildTileContent(),
        );
      },
    );
  }
}
