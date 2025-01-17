import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/top_padding_height_widget.dart';
import 'package:shimmer/shimmer.dart';

class AuthorProfileSkeleton extends StatelessWidget {
  const AuthorProfileSkeleton({super.key});

  // 定义骨架屏颜色
  static const _baseColor = Color(0xFFE0E0E0);
  static const _highlightColor = Color(0xFFF5F5F5);
  static const _cardRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width >= 800;
    return isWideScreen ? _buildWideLayout(context) : _buildNormalLayout(context);
  }

  Widget _buildWideLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 400,
            child: CustomScrollView(
              slivers: _buildHeaderSliver(context),
            ),
          ),
          Container(
            width: 1,
            color: Colors.grey[200],
          ),
          Expanded(
            child: _buildContentSkeleton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalLayout(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ..._buildHeaderSliver(context),
          // 内容骨架
          _buildContentSkeletonSliver(),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderSliver(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 400;
    final bannerHeight = (screenWidth * 43 / 150).clamp(0.0, 300.0);
    final avatarSize = isNarrowScreen ? 60.0 : 80.0;

    return [
      SliverAppBar(
        expandedHeight: bannerHeight,
        pinned: true,
        flexibleSpace: Shimmer.fromColors(
          baseColor: _baseColor,
          highlightColor: _highlightColor,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: _baseColor,
                highlightColor: _highlightColor,
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[100]!, width: 2),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用户名
                    Shimmer.fromColors(
                      baseColor: _baseColor,
                      highlightColor: _highlightColor,
                      child: Container(
                        width: 150,
                        height: isNarrowScreen ? 20 : 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(_cardRadius),
                        ),
                      ),
                    ),
                    SizedBox(height: isNarrowScreen ? 4 : 8),
                    // 用户名和统计数据
                    Wrap(
                      spacing: isNarrowScreen ? 4 : 8,
                      runSpacing: isNarrowScreen ? 2 : 4,
                      children: List.generate(
                        4,
                        (index) => Shimmer.fromColors(
                          baseColor: _baseColor,
                          highlightColor: _highlightColor,
                          child: Container(
                            width: 80,
                            height: isNarrowScreen ? 16 : 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(_cardRadius / 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isNarrowScreen ? 4 : 8),
                    // 按钮组
                    Wrap(
                      spacing: isNarrowScreen ? 8 : 16,
                      runSpacing: isNarrowScreen ? 4 : 8,
                      children: List.generate(
                        2,
                        (index) => Shimmer.fromColors(
                          baseColor: _baseColor,
                          highlightColor: _highlightColor,
                          child: Container(
                            width: 100,
                            height: isNarrowScreen ? 32 : 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(_cardRadius),
                              border: Border.all(color: Colors.grey[100]!, width: 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // 个人简介
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: _baseColor,
                highlightColor: _highlightColor,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_cardRadius),
                  ),
                ),
              ),
              SizedBox(height: isNarrowScreen ? 4 : 8),
              // 评论按钮
              Shimmer.fromColors(
                baseColor: _baseColor,
                highlightColor: _highlightColor,
                child: Container(
                  height: isNarrowScreen ? 32 : 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_cardRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ];
  }

  Widget _buildContentSkeleton() {
    return Column(
      children: [
        TopPaddingHeightWidget(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Shimmer.fromColors(
                  baseColor: _baseColor,
                  highlightColor: _highlightColor,
                  child: Container(
                    height: 40,
                    margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(_cardRadius),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 16 / 10,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => Shimmer.fromColors(
              baseColor: _baseColor,
              highlightColor: _highlightColor,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_cardRadius),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSkeletonSliver() {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 16 / 10,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: _baseColor,
            highlightColor: _highlightColor,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_cardRadius),
              ),
            ),
          ),
          childCount: 6,
        ),
      ),
    );
  }
}
