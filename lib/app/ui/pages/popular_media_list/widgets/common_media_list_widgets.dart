import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/shimmer_card.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'dart:ui';

/// 构建加载指示器
Widget? buildIndicator(
  BuildContext context,
  IndicatorStatus status,
  VoidCallback onErrorRefresh, {
  IconData? emptyIcon,
  double paddingTop = 0,
}) {
  Widget? finalWidget;

  // 提取通用的 shimmer grid 构建逻辑
  Widget buildShimmerGrid({required int itemCount}) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent:
            MediaQuery.of(context).size.width <= 600 ? 180 : 200,
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
      // 加载更多时的 Shimmer 效果
      final shimmerContent = Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: buildShimmerGrid(
          // 加载更多时显示较少数量的骨架项
          itemCount: (MediaQuery.of(context).size.width <= 600 ? 2 : 6),
        ),
      );
      // 加载更多指示器使用固定的垂直 Padding
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: 8.0, // 使用固定的垂直 padding
          horizontal: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
        ),
        child: shimmerContent,
      );

    case IndicatorStatus.fullScreenBusying:
      // 全屏加载时的 Shimmer 效果
      final fullScreenShimmerContent = Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: buildShimmerGrid(
          itemCount: 8, // 全屏加载时显示更多骨架项
        ),
      );
      // 全屏指示器需要应用传入的 paddingTop
      return SliverFillRemaining(
        child: Padding(
          padding: EdgeInsets.only(
            top: paddingTop, // 应用传入的 paddingTop
            left: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
            right: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
          ),
          child: fullScreenShimmerContent,
        ),
      );

    case IndicatorStatus.error:
      // 加载更多错误指示器
      return Padding(
        // 使用固定的垂直 Padding
        padding: EdgeInsets.symmetric(
          vertical: 8.0, // 使用固定的垂直 padding
          horizontal: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
        ),
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
                    slang.t
                        .conversation
                        .errors
                        .loadFailedClickToRetry,
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
      // 全屏错误指示器
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
                  slang.t.conversation.errors.loadFailed,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slang.t
                      .conversation
                      .errors
                      .clickToRetry,
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
            // 应用传入的 paddingTop
            padding: EdgeInsets.only(
              top: paddingTop, // 应用传入的 paddingTop
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: finalWidget,
          ),
        ),
      );
    case IndicatorStatus.noMoreLoad:
      // 无更多数据指示器
      return Padding(
        // 使用固定的垂直 Padding
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), // 调整 Padding
        child: Center(
          child: Text(
            slang.t.common.noMoreDatas,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    case IndicatorStatus.empty:
      // 空状态指示器
      finalWidget = Container(
        padding: EdgeInsets.only(
          // 应用传入的 paddingTop
          top: paddingTop + 16, // 应用传入的 paddingTop
          left: 16,
          right: 16,
          bottom: 16,
        ),
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
              slang.t.common.noData,
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
  final bool useBlurEffect;
  final double paddingBottom;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.isLoading,
    required this.onPageChanged,
    this.onRefresh,
    this.useBlurEffect = false,
    this.paddingBottom = 0,
  });

  @override
  State<PaginationBar> createState() => _PaginationBarState();
}

class _PaginationBarState extends State<PaginationBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pageController = TextEditingController();
  late AnimationController _loadingAnimController;
  late Animation<double> _progressAnimation;

  // 控制进度条可见性
  bool _showProgressBar = false;
  // 控制进度条是否已满
  bool _isProgressComplete = false;
  // 控制进度条淡出效果
  double _fadeOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _loadingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 创建一个非线性的进度动画
    _progressAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.6)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10.0,
      ),
    ]).animate(_loadingAnimController);

    // 设置初始状态
    _showProgressBar = widget.isLoading;
    if (_showProgressBar) {
      _loadingAnimController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PaginationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当加载状态改变时，控制动画
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        // 开始加载时，显示进度条并开始动画
        setState(() {
          _showProgressBar = true;
          _isProgressComplete = false;
          _fadeOpacity = 1.0;
        });
        _loadingAnimController.repeat(reverse: true);
      } else {
        // 加载结束时，先将进度推进到100%
        _completeProgressAndFadeOut();
      }
    }
  }

  // 完成进度并淡出
  void _completeProgressAndFadeOut() {
    // 停止重复动画
    _loadingAnimController.stop();

    // 设置为完成状态
    setState(() {
      _isProgressComplete = true;
    });

    // 延迟一小段时间后开始淡出动画
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      // 使用AnimatedOpacity需要在setState中更新状态
      setState(() {
        _fadeOpacity = 0.0;
      });

      // 淡出完成后隐藏进度条
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() {
          _showProgressBar = false;
        });
        _loadingAnimController.reset();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _loadingAnimController.dispose();
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
            content: Text(slang.t.common.pagination.invalidPageNumber(max: widget.totalPages)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 输入非数字时显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(slang.t.common.pagination.invalidInput),
          duration: const Duration(seconds: 2),
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
        title: Text(slang.t.common.pagination.jumpToPage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(slang.t.common.pagination.pleaseEnterPageNumber(max: widget.totalPages)),
            const SizedBox(height: 16),
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: slang.t.common.pagination.pageNumber,
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
            child: Text(slang.t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _jumpToPage();
            },
            child: Text(slang.t.common.pagination.jump),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final barContent = Stack(
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: widget.useBlurEffect ? Colors.transparent : Theme.of(context).colorScheme.surface,
            boxShadow: widget.useBlurEffect ? [] : [
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
        ),
        // 动画进度指示器
        if (_showProgressBar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _fadeOpacity,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: _isProgressComplete
                  ? _buildCompleteProgressIndicator(context)
                  : AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return _buildProgressIndicator(
                            context, _progressAnimation.value);
                      },
                    ),
            ),
          ),
      ],
    );

    // 根据是否使用毛玻璃效果返回不同的Widget
    if (widget.useBlurEffect) {
      // 使用ClipRect和BackdropFilter实现毛玻璃效果
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
            child: barContent,
          ),
        ),
      );
    } else {
      // 直接返回常规内容
      return barContent;
    }
  }

  // 构建已完成的进度指示器 (100%)
  Widget _buildCompleteProgressIndicator(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return SizedBox(
      height: 3,
      child: Stack(
        children: [
          // 背景光晕效果
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.7),
                  secondaryColor.withOpacity(0.7),
                  primaryColor.withOpacity(0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          // 前景进度条
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  secondaryColor,
                  primaryColor,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建优雅的进度指示器
  Widget _buildProgressIndicator(BuildContext context, double value) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final progressWidth = MediaQuery.of(context).size.width * value;

    return SizedBox(
      height: 3,
      child: Stack(
        children: [
          // 背景光晕效果
          Container(
            width: progressWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.7),
                  secondaryColor.withOpacity(0.7),
                  primaryColor.withOpacity(0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          // 前景进度条
          Container(
            width: progressWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  secondaryColor,
                  primaryColor,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // 进度条前端光点效果 - 只在进度条有实际宽度时才显示
          if (progressWidth > 6) // 确保进度条有足够宽度才显示光点
            Positioned(
              left: progressWidth - 6, // 从右侧改为左侧定位，基于实际进度宽度
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white,
                      secondaryColor,
                    ],
                    radius: 0.7,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建完整的分页控制栏（适用于宽屏）
  Widget _buildFullPaginationBar(BuildContext context) {
    double paddingBottom = MediaQuery.paddingOf(context).bottom + widget.paddingBottom;
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom, right: 12, left: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧总数信息
          Container(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              slang.t.common.pagination.totalItems(num: widget.totalItems),
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
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.3),
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
                enabled: widget.currentPage < widget.totalPages - 1 &&
                    !widget.isLoading,
                onPressed: () => widget.onPageChanged(widget.currentPage + 1),
              ),
              const SizedBox(width: 4),
              _buildNavButton(
                icon: Icons.last_page,
                enabled: widget.currentPage < widget.totalPages - 1 &&
                    !widget.isLoading,
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
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.3),
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(18)),
                ),
                child: TextField(
                  controller: _pageController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    border: InputBorder.none,
                    hintText: slang.t.common.pagination.pageNumber,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.7),
                    ),
                  ),
                  onSubmitted: (_) => _jumpToPage(),
                ),
              ),
              InkWell(
                onTap: widget.isLoading ? null : _jumpToPage,
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(18)),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: widget.isLoading
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(18)),
                  ),
                  child: Center(
                    child: Text(
                      slang.t.common.pagination.jump,
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
    double paddingBottom = MediaQuery.paddingOf(context).bottom + widget.paddingBottom;
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom, right: 12, left: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧：当前页/总页数 - 点击可跳转
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: widget.isLoading ? null : _showJumpPageDialog,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${widget.currentPage + 1} / ${widget.totalPages}  (${slang.t.common.pagination.totalItems(num: widget.totalItems)})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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
                enabled: widget.currentPage < widget.totalPages - 1 &&
                    !widget.isLoading,
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
        onTap: enabled
            ? () {
                // 添加触感反馈
                HapticFeedback.lightImpact();
                onPressed();
              }
            : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: enabled
                  ? Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.3)
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.1),
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
