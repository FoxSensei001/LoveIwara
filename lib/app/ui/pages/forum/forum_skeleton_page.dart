import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ForumSkeletonPage extends StatelessWidget {
  final double paddingTop;

  const ForumSkeletonPage({
    super.key,
    this.paddingTop = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 260;

    // 骨架内容
    Widget skeletonContent = ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => _buildSkeletonCategory(context, isWideScreen, isNarrowScreen),
    );

    // 根据屏幕宽度决定布局
    if (isNarrowScreen) {
      // 窄屏 Tab 布局
      skeletonContent = Column(
        children: [
          _buildSkeletonTabBar(context),
          Expanded(child: skeletonContent),
        ],
      );
    } else {
      // 宽屏 NavigationRail 布局
      skeletonContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeletonNavigationRail(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: skeletonContent,
            ),
          ),
        ],
      );
    }

    // 使用 Shimmer 包裹整个骨架
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.only(top: paddingTop),
        child: skeletonContent,
      ),
    );
  }

  // --- 构建骨架元素的辅助方法 ---

  Widget _buildSkeletonTabBar(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonNavigationRail(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: List.generate(5, (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 40,
                height: 8,
                color: Colors.white,
              ),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildSkeletonCategory(BuildContext context, bool isWideScreen, bool isNarrowScreen) {
    return Card(
      elevation: 0,
      margin: isNarrowScreen
          ? EdgeInsets.zero
          : const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题栏骨架
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 100,
                  height: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          // 子分类列表骨架
          if (isWideScreen) _buildWideSkeletonTable(context),
          ...List.generate(3, (index) => _buildSkeletonSubCategory(context, isWideScreen, isNarrowScreen)),
        ],
      ),
    );
  }

  Widget _buildWideSkeletonTable(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(3),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
          ),
          children: List.generate(4, (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              height: 14,
              width: index == 0 ? 60 : (index == 3 ? 80 : 40),
              color: Colors.white,
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildSkeletonSubCategory(BuildContext context, bool isWideScreen, bool isNarrowScreen) {
    if (isWideScreen) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(3),
          },
          children: [
            TableRow(
              children: [
                // 标题列
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(width: 16, height: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 150, height: 16, color: Colors.white),
                            const SizedBox(height: 4),
                            Container(width: 200, height: 12, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 统计列
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(width: 30, height: 14, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(width: 30, height: 14, color: Colors.white),
                ),
                // 最后回复列
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 100, height: 14, color: Colors.white),
                            const SizedBox(height: 4),
                            Container(width: 150, height: 12, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // 窄屏骨架
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 20, height: 20, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 16, color: Colors.white, margin: const EdgeInsets.only(right: 50)),
                    const SizedBox(height: 4),
                    Container(width: double.infinity, height: 12, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 150, height: 14, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 100, height: 12, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
