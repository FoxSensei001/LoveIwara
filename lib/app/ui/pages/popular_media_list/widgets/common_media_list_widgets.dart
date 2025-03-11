import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/shimmer_card.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 构建加载指示器
Widget? buildIndicator(
  BuildContext context,
  IndicatorStatus status,
  VoidCallback onErrorRefresh, {
  IconData? emptyIcon,
}) {
  Widget? finalWidget;

  // 提取通用的 shimmer grid 构建逻辑
  Widget buildShimmerGrid({required int itemCount}) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: MediaQuery.of(context).size.width <= 600 ? 180 : 200,
        crossAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
        mainAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
        childAspectRatio: 1 / 1.2,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => buildShimmerItem(
        MediaQuery.of(context).size.width <= 600 ? 180 : 200,
      ),
    );
  }

  switch (status) {
    case IndicatorStatus.none:
      return null;
      
    case IndicatorStatus.loadingMoreBusying:
    case IndicatorStatus.fullScreenBusying:
      final isFullScreen = status == IndicatorStatus.fullScreenBusying;
      final shimmerContent = Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: buildShimmerGrid(
          itemCount: isFullScreen ? 8 : (MediaQuery.of(context).size.width <= 600 ? 2 : 6),
        ),
      );
      
      if (isFullScreen) {
        return SliverFillRemaining(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
            ),
            child: shimmerContent,
          ),
        );
      }
      
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
        ),
        child: shimmerContent,
      );

    case IndicatorStatus.error:
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.errorContainer,
          child: InkWell(
            onTap: onErrorRefresh,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    slang.Translations.of(context).conversation.errors.loadFailedClickToRetry,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    case IndicatorStatus.fullScreenError:
      finalWidget = Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.errorContainer,
        child: InkWell(
          onTap: onErrorRefresh,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  slang.Translations.of(context).conversation.errors.loadFailed,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slang.Translations.of(context).conversation.errors.clickToRetry,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: finalWidget,
          ),
        ),
      );
    case IndicatorStatus.noMoreLoad:
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            slang.Translations.of(context).common.noMoreDatas,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    case IndicatorStatus.empty:
      finalWidget = Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon ?? Icons.image_not_supported,
              size: 48,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              slang.Translations.of(context).common.noData,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: finalWidget),
      );
  }
}

/// 构建骨架屏项目
Widget buildShimmerItem(double width) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: ShimmerCard(width: width),
  );
}

/// 构建标签样式
class TagStyle {
  static BorderRadius getBorderRadius({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 1,
  );

  static const TextStyle textStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontSize: 10,
    decoration: TextDecoration.none,
  );

  static const double iconSize = 10;
  static const double iconSpacing = 2;
}

// 分页控制栏组件
class PaginationBar extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool isLoading;
  final Function(int) onPageChanged;
  final VoidCallback? onRefresh;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.isLoading,
    required this.onPageChanged,
    this.onRefresh,
  });

  @override
  State<PaginationBar> createState() => _PaginationBarState();
}

class _PaginationBarState extends State<PaginationBar> {
  final TextEditingController _pageController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _jumpToPage() {
    if (widget.isLoading) return;
    
    try {
      final targetPage = int.parse(_pageController.text);
      if (targetPage >= 1 && targetPage <= widget.totalPages) {
        widget.onPageChanged(targetPage - 1);
        FocusScope.of(context).unfocus();
      } else {
        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('请输入有效页码 (1-${widget.totalPages})'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 输入非数字时显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入有效页码'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    _pageController.clear();
  }

  // 显示页面跳转对话框
  void _showJumpPageDialog() {
    _pageController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('跳转到指定页面'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('请输入页码 (1-${widget.totalPages})'),
            const SizedBox(height: 16),
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '页码',
              ),
              onSubmitted: (_) {
                Navigator.of(context).pop();
                _jumpToPage();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _jumpToPage();
            },
            child: Text('跳转'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          return isNarrow
              ? _buildCompactPaginationBar(context)
              : _buildFullPaginationBar(context);
        },
      ),
    );
  }

  // 构建完整的分页控制栏（适用于宽屏）
  Widget _buildFullPaginationBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧总数信息
          Container(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              '共 ${widget.totalItems} 项',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          
          // 中间分页导航
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavButton(
                icon: Icons.first_page,
                enabled: widget.currentPage > 0 && !widget.isLoading,
                onPressed: () => widget.onPageChanged(0),
              ),
              const SizedBox(width: 4),
              _buildNavButton(
                icon: Icons.chevron_left,
                enabled: widget.currentPage > 0 && !widget.isLoading,
                onPressed: () => widget.onPageChanged(widget.currentPage - 1),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: widget.isLoading ? null : _showJumpPageDialog,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 68),
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.currentPage + 1} / ${widget.totalPages}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildNavButton(
                icon: Icons.chevron_right,
                enabled: widget.currentPage < widget.totalPages - 1 && !widget.isLoading,
                onPressed: () => widget.onPageChanged(widget.currentPage + 1),
              ),
              const SizedBox(width: 4),
              _buildNavButton(
                icon: Icons.last_page,
                enabled: widget.currentPage < widget.totalPages - 1 && !widget.isLoading,
                onPressed: () => widget.onPageChanged(widget.totalPages - 1),
              ),
            ],
          ),
          
          // 右侧跳转控件
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                ),
                child: TextField(
                  controller: _pageController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    border: InputBorder.none,
                    hintText: '页码',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                  onSubmitted: (_) => _jumpToPage(),
                ),
              ),
              InkWell(
                onTap: widget.isLoading ? null : _jumpToPage,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: widget.isLoading 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
                  ),
                  child: Center(
                    child: Text(
                      '跳转',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建紧凑版的分页控制栏（适用于窄屏）
  Widget _buildCompactPaginationBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧：当前页/总页数 - 点击可跳转
          GestureDetector(
            onTap: widget.isLoading ? null : _showJumpPageDialog,
            child: Container(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${widget.currentPage + 1} / ${widget.totalPages}  (共 ${widget.totalItems} 项)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          
          // 右侧：上一页和下一页按钮
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavButton(
                icon: Icons.chevron_left,
                enabled: widget.currentPage > 0 && !widget.isLoading,
                onPressed: () => widget.onPageChanged(widget.currentPage - 1),
              ),
              const SizedBox(width: 12),
              _buildNavButton(
                icon: Icons.chevron_right,
                enabled: widget.currentPage < widget.totalPages - 1 && !widget.isLoading,
                onPressed: () => widget.onPageChanged(widget.currentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 辅助方法：构建导航按钮
  Widget _buildNavButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: enabled ? () {
          // 添加触感反馈
          HapticFeedback.lightImpact();
          onPressed();
        } : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: enabled 
                  ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 18,
                color: enabled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 