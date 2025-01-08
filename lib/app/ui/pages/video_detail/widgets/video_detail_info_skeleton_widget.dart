import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MediaDetailInfoSkeletonWidget extends StatelessWidget {
  const MediaDetailInfoSkeletonWidget({super.key});

  // 提取常量
  static const double _horizontalPadding = 16.0;
  static const double _verticalSpacing = 16.0;
  static const double _smallSpacing = 8.0;
  static const BorderRadius _borderRadius = BorderRadius.all(Radius.circular(8.0));

  // 提取共用的Shimmer组件
  Widget _buildShimmerContainer({
    required double height,
    double? width,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? _borderRadius,
        ),
      ),
    );
  }

  @override
  Widget build(context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 播放器
              _buildShimmerContainer(
                height: width * 9 / 16,
                width: width,
                borderRadius: BorderRadius.zero,
              ),

              const SizedBox(height: _verticalSpacing),

              // 标题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: _buildShimmerContainer(height: 24, width: double.infinity),
              ),

              const SizedBox(height: _smallSpacing),

              // 用户信息
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: _smallSpacing),
                    _buildShimmerContainer(height: 16, width: 100),
                    const Spacer(),
                    _buildShimmerContainer(height: 32, width: 80),
                  ],
                ),
              ),

              const SizedBox(height: _smallSpacing),

              // 视频信息
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: Row(
                  children: [
                    _buildShimmerContainer(height: 16, width: 80),
                    const SizedBox(width: 16),
                    _buildShimmerContainer(height: 16, width: 60),
                    const SizedBox(width: 16),
                    _buildShimmerContainer(height: 16, width: 100),
                  ],
                ),
              ),

              const SizedBox(height: _verticalSpacing),

              // 描述
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerContainer(height: 16, width: double.infinity),
                    const SizedBox(height: _smallSpacing),
                    _buildShimmerContainer(height: 16, width: width * 0.8),
                    const SizedBox(height: _smallSpacing),
                    _buildShimmerContainer(height: 16, width: width * 0.6),
                  ],
                ),
              ),

              const SizedBox(height: _verticalSpacing),

              // 标签
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: Wrap(
                  spacing: _smallSpacing,
                  runSpacing: 4.0,
                  children: List.generate(5, (index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Chip(
                        label: Container(
                          width: 50 + (index * 10),
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: _borderRadius,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: _verticalSpacing),

              // 底部操作栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: Row(
                  children: [
                    _buildShimmerContainer(height: 36, width: 80),
                    const SizedBox(width: _verticalSpacing),
                    _buildShimmerContainer(height: 36, width: 80),
                    const Spacer(),
                    _buildShimmerContainer(height: 36, width: 100),
                  ],
                ),
              ),

              const SizedBox(height: _verticalSpacing),
            ],
          ),
        );
      },
    );
  }
}
