import 'dart:async';

import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/shimmer_card.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:dio/dio.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 全局错误监听器，用于捕获最近的DioException
class GlobalErrorListener {
  static DioException? _lastDioException;
  static DateTime? _lastErrorTime;
  static const Duration _errorValidDuration = Duration(seconds: 5);

  /// 记录DioException
  static void recordDioException(DioException exception) {
    _lastDioException = exception;
    _lastErrorTime = DateTime.now();
  }

  /// 获取最近的DioException（如果在有效时间内）
  static DioException? getRecentDioException() {
    if (_lastDioException != null && _lastErrorTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastErrorTime!) <= _errorValidDuration) {
        return _lastDioException;
      }
    }
    return null;
  }

  /// 清除记录的异常
  static void clearException() {
    _lastDioException = null;
    _lastErrorTime = null;
  }
}

/// 骨架图布局配置类
class SkeletonLayoutConfig {
  final double maxCrossAxisExtent;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const SkeletonLayoutConfig({
    required this.maxCrossAxisExtent,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    this.childAspectRatio = 1.0,
  });

  /// 创建默认配置（使用 MediaLayoutUtils 的默认值）
  factory SkeletonLayoutConfig.defaultConfig(double availableWidth) {
    final safeWidth = availableWidth.isFinite && availableWidth > 0
        ? availableWidth
        : 600.0;
    final int crossAxisCount = MediaLayoutUtils.calculateCrossAxisCount(
      safeWidth,
    );
    final double maxCrossAxisExtent = safeWidth / crossAxisCount;

    return SkeletonLayoutConfig(
      maxCrossAxisExtent: maxCrossAxisExtent,
      crossAxisSpacing: MediaLayoutUtils.crossAxisSpacing,
      mainAxisSpacing: MediaLayoutUtils.mainAxisSpacing,
      childAspectRatio: 1.0,
    );
  }

  /// 从 SliverWaterfallFlowDelegateWithMaxCrossAxisExtent 提取配置
  factory SkeletonLayoutConfig.fromDelegate(
    SliverWaterfallFlowDelegateWithMaxCrossAxisExtent delegate,
  ) {
    return SkeletonLayoutConfig(
      maxCrossAxisExtent: delegate.maxCrossAxisExtent,
      crossAxisSpacing: delegate.crossAxisSpacing,
      mainAxisSpacing: delegate.mainAxisSpacing,
      childAspectRatio: 1.0, // 默认宽高比为1:1
    );
  }
}

/// 构建加载指示器
Widget? buildIndicator(
  BuildContext context,
  IndicatorStatus status,
  VoidCallback onErrorRefresh, {
  IconData? emptyIcon,
  double paddingTop = 0,
  String? errorMessage,
  SkeletonLayoutConfig? skeletonLayoutConfig,
}) {
  Widget? finalWidget;

  switch (status) {
    case IndicatorStatus.none:
      return null;

    case IndicatorStatus.loadingMoreBusying:
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );

    case IndicatorStatus.fullScreenBusying:
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          padding: EdgeInsets.only(top: paddingTop),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 旋转的优雅加载动画
              SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 2.seconds,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                  )
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 1.seconds,
                    curve: Curves.easeInOutSine,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.1, 1.1),
                    end: const Offset(0.9, 0.9),
                    duration: 1.seconds,
                    curve: Curves.easeInOutSine,
                  ),
              const SizedBox(height: 24),
              // 文字动画
              Text(
                    CommonConstants.applicationNickname,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: 1.seconds)
                  .then()
                  .fadeOut(duration: 1.seconds),
            ],
          ),
        ),
      );

    case IndicatorStatus.error:
      // 加载更多错误指示器
      return Padding(
        // 使用固定的垂直 Padding
        padding: const EdgeInsets.symmetric(
          vertical: 8.0, // 使用固定的垂直 padding
          horizontal: 5.0,
        ),
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.errorContainer,
          child: InkWell(
            onTap: onErrorRefresh,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.error_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          errorMessage ??
                              slang
                                  .t
                                  .conversation
                                  .errors
                                  .loadFailedClickToRetry,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      slang.t.conversation.errors.clickToRetry,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
                  errorMessage ?? slang.t.conversation.errors.loadFailed,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  slang.t.conversation.errors.clickToRetry,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
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
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 8.0,
        ), // 调整 Padding
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
  /// 分页控制条本体高度（不含底部安全区占位与上方渐隐区）。
  /// 右下角「回到顶部」、左下角批量操作这些悬浮控件在分页模式下
  /// 都要在安全区之上再抬这一段，否则会压在分页按钮上。
  static const double barHeight = 46.0;

  /// `useBlurEffect` 模式下，分页栏内容上方额外的透明渐入区高度。
  /// 调用方给列表预留底部空间时要把它一并算进去，否则最后一行会被压在渐变里。
  ///
  /// 只是一条软边，不是背景：2026-08-20 从 28 收到 14——过长的渐入区会在栏体
  /// 之上糊出一片，看起来像分页栏的阴影漏到了内容里（与
  /// [GlassTokens.headerFadeExtent] 同一次收紧）。
  static const double fadeAboveExtent = 14.0;

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool isLoading;
  final Function(int) onPageChanged;
  final VoidCallback? onRefresh;
  final bool useBlurEffect;
  final double paddingBottom;
  final bool showBottomPadding;
  final bool isTotalCountUnknown;
  final bool canGoNext;

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
    this.showBottomPadding = true,
    this.isTotalCountUnknown = false,
    this.canGoNext = true,
  });

  @override
  State<PaginationBar> createState() => _PaginationBarState();
}

class _PaginationBarState extends State<PaginationBar>
    with TickerProviderStateMixin {
  final TextEditingController _pageController = TextEditingController();
  // 光弧沿页码卡片描边匀速循环游走
  late AnimationController _rotationController;
  // 光环整体的淡入淡出，用 AnimationController 驱动而非手动改 opacity，
  // 这样中途被打断（比如翻页又刚好加载完）时能从当前值平滑转向，不会跳变。
  late AnimationController _visibilityController;
  late final Animation<double> _ringOpacity;
  Timer? _showDelayTimer;
  // 光环是否已经挂载到树上（不等于是否可见——淡出过程中仍然挂载）
  bool _ringMounted = false;

  // 加载在这个时间内就结束的话，光环压根不出现，避免快请求下卡片一闪而过
  static const Duration _showDelay = Duration(milliseconds: 150);
  static const Duration _fadeDuration = Duration(milliseconds: 260);

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _visibilityController = AnimationController(
      vsync: this,
      duration: _fadeDuration,
    );
    _ringOpacity = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    if (widget.isLoading) {
      // 首帧就在加载中（例如带着 isLoading=true 进场），没有「上一帧」可淡入，
      // 直接以可见状态挂载即可。
      _ringMounted = true;
      _rotationController.repeat();
      _visibilityController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PaginationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _scheduleShow();
      } else {
        _scheduleHide();
      }
    }
  }

  void _scheduleShow() {
    _showDelayTimer?.cancel();
    _showDelayTimer = Timer(_showDelay, () {
      if (!mounted || !widget.isLoading) return;
      setState(() => _ringMounted = true);
      _rotationController.repeat();
      _visibilityController.forward();
    });
  }

  void _scheduleHide() {
    _showDelayTimer?.cancel();
    _showDelayTimer = null;
    if (!_ringMounted) return; // 还没来得及显示就结束了，直接作罢
    // 光环继续转动的同时淡出，转完再落幕，而不是瞬间消失
    _visibilityController.reverse().whenCompleteOrCancel(() {
      if (!mounted || widget.isLoading) return;
      setState(() => _ringMounted = false);
      _rotationController.stop();
    });
  }

  @override
  void dispose() {
    _showDelayTimer?.cancel();
    _pageController.dispose();
    _rotationController.dispose();
    _visibilityController.dispose();
    super.dispose();
  }

  void _jumpToPage() {
    if (widget.isLoading) return;

    try {
      final targetPage = int.parse(_pageController.text);
      final bool hasValidLowerBound = targetPage >= 1;
      final bool hasValidUpperBound =
          widget.isTotalCountUnknown || targetPage <= widget.totalPages;
      if (hasValidLowerBound && hasValidUpperBound) {
        widget.onPageChanged(targetPage - 1);
        FocusScope.of(context).unfocus();
      } else {
        // 显示错误提示
        if (!hasValidLowerBound) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(slang.t.common.pagination.invalidInput),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                slang.t.common.pagination.invalidPageNumber(
                  max: widget.totalPages,
                ),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
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
            if (!widget.isTotalCountUnknown)
              Text(
                slang.t.common.pagination.pleaseEnterPageNumber(
                  max: widget.totalPages,
                ),
              ),
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
    // 加载态不再跨栏铺一条横向进度条，而是把光环落在页码卡片自己身上
    // （见 _buildPageNumberPill），这里只负责常规的分页栏内容。
    final barContent = Container(
      decoration: BoxDecoration(
        color: widget.useBlurEffect
            ? Colors.transparent
            : Theme.of(context).colorScheme.surface,
        boxShadow: widget.useBlurEffect
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 主要内容区域
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              if (widget.isTotalCountUnknown) {
                return isNarrow
                    ? _buildUnknownTotalCompactPaginationBar(context)
                    : _buildUnknownTotalFullPaginationBar(context);
              }
              return isNarrow
                  ? _buildCompactPaginationBar(context)
                  : _buildFullPaginationBar(context);
            },
          ),
          // 底部安全区域占位
          if (widget.showBottomPadding && widget.paddingBottom > 0)
            SizedBox(height: widget.paddingBottom),
        ],
      ),
    );

    // 「悬浮」模式：不用 BackdropFilter，改为从上方透明→底部半透明的渐变蒙层，
    // 控件本身是自带底色的玻璃胶囊，列表内容能从分页栏背后透出来。
    if (widget.useBlurEffect) {
      const double fadeAbove = PaginationBar.fadeAboveExtent;
      return Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) => EdgeFadeScrim.bottom(
                height: constraints.maxHeight,
                solidExtent: widget.showBottomPadding
                    ? widget.paddingBottom
                    : 0,
                peakAlpha: 0.6,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: fadeAbove),
            child: barContent,
          ),
        ],
      );
    } else {
      // 直接返回常规内容
      return barContent;
    }
  }

  Widget _buildUnknownTotalFullPaginationBar(BuildContext context) {
    final pageNumberText =
        '${slang.t.common.pagination.pageNumber}: ${widget.currentPage + 1}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧：页码信息（总量未知时不显示总数）
          Container(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              pageNumberText,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          // 中间：上一页/下一页导航
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavButton(
                icon: Icons.chevron_left,
                enabled: widget.currentPage > 0 && !widget.isLoading,
                onPressed: () => widget.onPageChanged(widget.currentPage - 1),
              ),
              const SizedBox(width: 8),
              _buildPageNumberPill(
                context,
                text: '${widget.currentPage + 1}',
                height: 36,
                minWidth: 68,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              _wrapWithTooltipIfNeeded(
                widget.canGoNext,
                child: _buildNavButton(
                  icon: Icons.chevron_right,
                  enabled: widget.canGoNext && !widget.isLoading,
                  onPressed: () => widget.onPageChanged(widget.currentPage + 1),
                ),
              ),
            ],
          ),

          // 右侧占位，保持布局平衡
          const SizedBox(width: 140),
        ],
      ),
    );
  }

  Widget _buildUnknownTotalCompactPaginationBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧：页码信息（不可点击跳转）
          _buildPageNumberPill(
            context,
            text:
                '${slang.t.common.pagination.pageNumber}: ${widget.currentPage + 1}',
            height: 32,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
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
              _wrapWithTooltipIfNeeded(
                widget.canGoNext,
                child: _buildNavButton(
                  icon: Icons.chevron_right,
                  enabled: widget.canGoNext && !widget.isLoading,
                  onPressed: () => widget.onPageChanged(widget.currentPage + 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _wrapWithTooltipIfNeeded(bool enabled, {required Widget child}) {
    if (enabled) return child;
    return Tooltip(message: slang.t.common.noMoreDatas, child: child);
  }

  /// 页码卡片：加载时在卡片自身的胶囊描边上跑一段液态玻璃光弧，
  /// 取代原先跨越整条分页栏的横向进度条——加载态只发生在页码卡片上。
  Widget _buildPageNumberPill(
    BuildContext context, {
    required String text,
    required double height,
    required TextStyle style,
    double minWidth = 0,
  }) {
    final pill = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: GlassSurface(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: widget.isLoading ? null : _showJumpPageDialog,
        child: Center(child: Text(text, style: style)),
      ),
    );

    if (!_ringMounted) return pill;

    final cs = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        pill,
        Positioned.fill(
          child: IgnorePointer(
            child: FadeTransition(
              opacity: _ringOpacity,
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, _) => CustomPaint(
                  painter: _PillLoadingRingPainter(
                    phase: _rotationController.value,
                    primaryColor: cs.primary,
                    secondaryColor: cs.secondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建完整的分页控制栏（适用于宽屏）
  Widget _buildFullPaginationBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              _buildPageNumberPill(
                context,
                text: '${widget.currentPage + 1} / ${widget.totalPages}',
                height: 36,
                minWidth: 68,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              _buildNavButton(
                icon: Icons.chevron_right,
                enabled:
                    widget.currentPage < widget.totalPages - 1 &&
                    !widget.isLoading,
                onPressed: () => widget.onPageChanged(widget.currentPage + 1),
              ),
              const SizedBox(width: 4),
              _buildNavButton(
                icon: Icons.last_page,
                enabled:
                    widget.currentPage < widget.totalPages - 1 &&
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
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(18),
                  ),
                ),
                child: TextField(
                  controller: _pageController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                    hintText: slang.t.common.pagination.pageNumber,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  onSubmitted: (_) => _jumpToPage(),
                ),
              ),
              InkWell(
                onTap: widget.isLoading ? null : _jumpToPage,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(18),
                ),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: widget.isLoading
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.5)
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(18),
                    ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧：当前页/总页数 - 点击可跳转
          _buildPageNumberPill(
            context,
            text:
                '${widget.currentPage + 1} / ${widget.totalPages}  (${slang.t.common.pagination.totalItems(num: widget.totalItems)})',
            height: 32,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
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
                enabled:
                    widget.currentPage < widget.totalPages - 1 &&
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
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: GlassIconButton(
        standalone: true,
        size: 36,
        iconSize: 18,
        icon: Icon(icon),
        color: enabled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
        onPressed: enabled
            ? () {
                // 添加触感反馈
                HapticFeedback.lightImpact();
                onPressed();
              }
            : null,
      ),
    );
  }
}

/// 页码卡片加载光环：一段带头部亮点的渐变光弧，沿卡片胶囊描边匀速
/// 循环游走，替代原先跨越整条分页栏的横向进度条。
class _PillLoadingRingPainter extends CustomPainter {
  _PillLoadingRingPainter({
    required this.phase,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final double phase;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    final metrics = (Path()..addRRect(rrect)).computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final total = metric.length;
    if (total <= 0) return;

    final cometLength = total * 0.32;
    final start = phase * total;

    Path extractWrapped(double from, double length) {
      final end = from + length;
      if (end <= total) return metric.extractPath(from, end);
      return Path()
        ..addPath(metric.extractPath(from, total), Offset.zero)
        ..addPath(metric.extractPath(0, end - total), Offset.zero);
    }

    final comet = extractWrapped(start, cometLength);
    final bounds = comet.getBounds();
    if (bounds.isEmpty) return;

    // 光晕层：宽、模糊、低透明度
    canvas.drawPath(
      comet,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
        ..shader = LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.0),
            primaryColor.withValues(alpha: 0.55),
            secondaryColor.withValues(alpha: 0.55),
          ],
        ).createShader(bounds),
    );

    // 核心层：细、锐利、高透明度
    canvas.drawPath(
      comet,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.0),
            primaryColor,
            secondaryColor,
          ],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(covariant _PillLoadingRingPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
