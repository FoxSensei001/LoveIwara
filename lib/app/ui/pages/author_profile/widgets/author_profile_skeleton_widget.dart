import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AuthorProfileSkeleton extends StatelessWidget {
  const AuthorProfileSkeleton({super.key});

  // 定义骨架屏颜色
  static const _baseColor = Color(0xFFE0E0E0);
  static const _highlightColor = Color(0xFFF5F5F5);
  static const _cardRadius = 12.0;
  static const _avatarSize = 100.0;

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width >= 600;
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
    final bannerHeight = (screenWidth * 0.3).clamp(200.0, 300.0);

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
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(_cardRadius),
                bottomRight: Radius.circular(_cardRadius),
              ),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: _baseColor,
                highlightColor: _highlightColor,
                child: Container(
                  width: _avatarSize,
                  height: _avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[100]!, width: 2),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: _baseColor,
                      highlightColor: _highlightColor,
                      child: Container(
                        width: 180,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(_cardRadius),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: List.generate(
                        3,
                        (index) => Shimmer.fromColors(
                          baseColor: _baseColor,
                          highlightColor: _highlightColor,
                          child: Container(
                            width: 90,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(_cardRadius / 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(
                        3,
                        (index) => Shimmer.fromColors(
                          baseColor: _baseColor,
                          highlightColor: _highlightColor,
                          child: Container(
                            width: 100,
                            height: 40,
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
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: _baseColor,
                highlightColor: _highlightColor,
                child: Container(
                  width: 120,
                  height: 24,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_cardRadius / 2),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: _baseColor,
                highlightColor: _highlightColor,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_cardRadius),
                    border: Border.all(color: Colors.grey[100]!, width: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Shimmer.fromColors(
            baseColor: _baseColor,
            highlightColor: _highlightColor,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_cardRadius * 2),
                border: Border.all(color: Colors.grey[100]!, width: 1),
              ),
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
    ];
  }

  Widget _buildContentSkeleton() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Shimmer.fromColors(
                  baseColor: _baseColor,
                  highlightColor: _highlightColor,
                  child: Container(
                    height: 40,
                    margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(_cardRadius),
                      border: Border.all(color: Colors.grey[100]!, width: 1),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
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
                  border: Border.all(color: Colors.grey[100]!, width: 1),
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
      padding: const EdgeInsets.all(20.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
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
                border: Border.all(color: Colors.grey[100]!, width: 1),
              ),
            ),
          ),
          childCount: 6,
        ),
      ),
    );
  }
}
