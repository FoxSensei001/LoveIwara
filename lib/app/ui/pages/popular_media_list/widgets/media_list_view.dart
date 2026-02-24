import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/utils/logger_utils.dart' show LogUtils;
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import 'package:i_iwara/utils/common_utils.dart' show CommonUtils;
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'common_media_list_widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart'; // 用于 ScrollDirection
import 'package:i_iwara/app/ui/pages/subscriptions/controllers/media_list_controller.dart'; // 导入 MediaListController
import 'dart:developer';

// 添加性能监视类
class PerformanceMonitor {
  static int _frameCount = 0;
  static int _lastReportTime = 0;
  static bool _isEnabled = false;
  static const int _reportIntervalMillis = 2000;

  static void initialize(bool enabled) {
    _isEnabled = enabled;
    if (_isEnabled) {
      _startMonitoring();
    }
  }

  static void _startMonitoring() {
    _frameCount = 0;
    _lastReportTime = DateTime.now().millisecondsSinceEpoch;

    SchedulerBinding.instance.addPostFrameCallback(_monitorFrames);
  }

  static void _monitorFrames(Duration timeStamp) {
    if (!_isEnabled) return;

    _frameCount++;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedTime = now - _lastReportTime;

    if (elapsedTime >= _reportIntervalMillis) {
      final fps = (_frameCount * 1000 / elapsedTime).toStringAsFixed(1);
      log('MediaListView Performance: $fps FPS');

      _frameCount = 0;
      _lastReportTime = now;
    }

    SchedulerBinding.instance.addPostFrameCallback(_monitorFrames);
  }
}

// 添加节流控制类
class ScrollThrottler {
  int _lastScrollTime = 0;
  final int _throttleInterval;

  ScrollThrottler({int throttleIntervalMillis = 16})
    : _throttleInterval = throttleIntervalMillis;

  bool shouldProcessScroll() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastScrollTime > _throttleInterval) {
      _lastScrollTime = now;
      return true;
    }
    return false;
  }
}

// 扩展LoadingMoreBase，确保所有子类都有requestTotalCount属性和分页方法
abstract class ExtendedLoadingMoreBase<T> extends LoadingMoreBase<T> {
  int requestTotalCount = 0;
  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;
  String? lastErrorMessage;

  @override
  bool get hasMore => _hasMore || forceRefresh;

  // 定义通用的数据获取方法，子类必须实现
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  );

  // 构建查询参数，子类可以覆盖
  Map<String, dynamic> buildQueryParams(int page, int limit) {
    return <String, dynamic>{};
  }

  // 从API响应中提取数据列表，子类可以覆盖
  List<T> extractDataList(Map<String, dynamic> response) {
    // 默认实现，子类应该覆盖
    return [];
  }

  // 从API响应中提取总数量，子类可以覆盖
  int extractTotalCount(Map<String, dynamic> response) {
    // 默认实现，子类应该覆盖
    return 0;
  }

  // 统一实现的分页数据加载方法
  Future<List<T>> loadPageData(int pageKey, int pageSize) async {
    try {
      final params = buildQueryParams(pageKey, pageSize);
      final response = await fetchDataFromSource(params, pageKey, pageSize);

      requestTotalCount = extractTotalCount(response);
      return extractDataList(response);
    } catch (e) {
      // 存储错误消息
      lastErrorMessage = CommonUtils.parseExceptionMessage(e);
      // 子类可通过覆盖logError方法来自定义错误日志
      logError('加载分页数据失败', e);
      rethrow;
    }
  }

  // 统一实现的无限滚动数据加载方法
  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    try {
      List<T> dataList = await loadPageData(_pageIndex, 20);

      if (_pageIndex == 0) {
        clear();
      }

      for (final T item in dataList) {
        add(item);
      }

      _hasMore = dataList.isNotEmpty;
      _pageIndex++;
      isSuccess = true;
    } catch (e) {
      isSuccess = false;
      // 存储错误消息
      lastErrorMessage = CommonUtils.parseExceptionMessage(e);
      logError('加载数据列表失败', e);
    }
    return isSuccess;
  }

  // 统一的刷新方法
  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _pageIndex = 0;
    forceRefresh = !notifyStateChanged;
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  // 统一的错误日志方法，子类可覆盖
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    // 默认实现
    LogUtils.e('$message: $error', error: error, stack: stackTrace);
  }
}

class MediaListView<T> extends StatefulWidget {
  final LoadingMoreBase<T> sourceList;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final IconData? emptyIcon;
  final bool isPaginated;
  final ExtendedListDelegate? extendedListDelegate;
  final ScrollController? scrollController;
  final double paddingTop;
  final bool enablePerformanceLogging;
  final bool showBottomPadding;
  final bool enablePullToRefresh;

  /// 分页切换时的回调（用于多选模式下重置选择）
  final VoidCallback? onPageChanged;

  const MediaListView({
    super.key,
    required this.sourceList,
    required this.itemBuilder,
    this.emptyIcon,
    this.isPaginated = false,
    this.extendedListDelegate,
    this.scrollController,
    this.paddingTop = 0,
    this.enablePerformanceLogging = false,
    this.showBottomPadding = true,
    this.enablePullToRefresh = true,
    this.onPageChanged,
  });

  @override
  State<MediaListView<T>> createState() => _MediaListViewState<T>();
}

class _MediaListViewState<T> extends State<MediaListView<T>> {
  int currentPage = 0;
  int itemsPerPage = 20;
  bool isLoading = false;
  List<T> paginatedItems = [];
  final TextEditingController _pageController = TextEditingController();
  // 添加指示器状态
  IndicatorStatus _indicatorStatus = IndicatorStatus.fullScreenBusying;

  // 错误消息
  String? _errorMessage;

  // 添加一个标志来跟踪是否是首次加载
  bool _isFirstLoad = true;

  // 添加一个标志来跟踪模式是否已切换
  bool _modeSwitched = false;

  final ScrollThrottler _scrollThrottler = ScrollThrottler();

  // 添加 MediaListController 引用
  MediaListController? _mediaListController;
  // 添加 rebuildKey 监听器引用，用于清理
  VoidCallback? _rebuildKeyListener;

  int get totalItems {
    if (widget.sourceList is ExtendedLoadingMoreBase<T>) {
      return (widget.sourceList as ExtendedLoadingMoreBase<T>)
          .requestTotalCount;
    }
    return 0;
  }

  int get totalPages => totalItems > 0 ? (totalItems / itemsPerPage).ceil() : 1;

  @override
  void initState() {
    super.initState();

    // 尝试获取 MediaListController 实例（如果可用）
    try {
      _mediaListController = Get.find<MediaListController>();
      // 如果控制器和滚动控制器可用，注册滚动到顶部回调
      if (_mediaListController != null && widget.scrollController != null) {
        _mediaListController!.registerScrollToTopCallback(_scrollToTop);
      }

      // 监听 rebuildKey 的变化，当它变化时触发数据刷新
      if (_mediaListController != null) {
        _rebuildKeyListener = ever(_mediaListController!.rebuildKey, (int key) {
          if (mounted) {
            refresh();
          }
        }).call;
      }
    } catch (e) {
      // 未找到 MediaListController，继续执行
      _mediaListController = null;
    }

    // 初始化性能监控
    if (widget.enablePerformanceLogging) {
      PerformanceMonitor.initialize(true);
    }

    if (widget.isPaginated) {
      _loadPaginatedData(0);
    }
  }

  // 添加滚动到顶部方法
  void _scrollToTop() {
    if (widget.scrollController != null &&
        widget.scrollController!.hasClients) {
      widget.scrollController!.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void didUpdateWidget(MediaListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 处理滚动控制器变化
    if (oldWidget.scrollController != widget.scrollController &&
        _mediaListController != null) {
      // 注销旧的回调
      if (oldWidget.scrollController != null) {
        _mediaListController!.unregisterScrollToTopCallback(_scrollToTop);
      }
      // 注册新的回调
      if (widget.scrollController != null) {
        _mediaListController!.registerScrollToTopCallback(_scrollToTop);
      }
    }

    // 检测模式切换
    if (oldWidget.isPaginated != widget.isPaginated) {
      _modeSwitched = true;

      // 如果有滚动控制器，滚动到顶部
      if (widget.scrollController != null) {
        widget.scrollController!.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      // 从瀑布流切换到分页模式
      if (widget.isPaginated && !oldWidget.isPaginated) {
        currentPage = 0;
        _loadPaginatedData(currentPage);
      }
      // 从分页切换到瀑布流模式
      else if (!widget.isPaginated && oldWidget.isPaginated) {
        // 确保瀑布流模式下数据能正确加载
        Future.microtask(() {
          if (widget.sourceList.isEmpty) {
            widget.sourceList.refresh(true);
          }
        });
      }
    }
    // 检测数据源变化
    else if (oldWidget.sourceList != widget.sourceList) {
      if (widget.isPaginated) {
        currentPage = 0;
        _loadPaginatedData(currentPage);
      } else {
        // 确保瀑布流模式下数据能正确加载
        Future.microtask(() {
          if (widget.sourceList.isEmpty) {
            widget.sourceList.refresh(true);
          }
        });
      }
    }
  }

  Future<void> _loadPaginatedData(int page) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      // 根据是否是首次加载或模式切换来设置适当的指示器状态
      if (_isFirstLoad || _modeSwitched || page == 0) {
        _indicatorStatus = IndicatorStatus.fullScreenBusying;
      } else {
        _indicatorStatus = IndicatorStatus.loadingMoreBusying;
      }
    });

    // 记录页面是否变化
    final bool pageChanged = page != currentPage && !_isFirstLoad;

    try {
      if (widget.sourceList is ExtendedLoadingMoreBase<T>) {
        final repo = widget.sourceList as ExtendedLoadingMoreBase<T>;
        final items = await repo.loadPageData(page, itemsPerPage);

        // 确保组件仍然挂载
        if (!mounted) return;

        // 添加过渡动画效果
        if (items.isNotEmpty &&
            paginatedItems.isNotEmpty &&
            page != currentPage) {
          // 先设置状态为过渡中
          setState(() {
            isLoading = true;
            _indicatorStatus = IndicatorStatus.none;
          });

          // 短暂延迟后更新数据，制造平滑过渡效果
          await Future.delayed(const Duration(milliseconds: 150));
        }

        setState(() {
          paginatedItems = items;
          currentPage = page;
          isLoading = false;
          _isFirstLoad = false;
          _modeSwitched = false;

          // 根据结果设置适当的状态
          if (items.isEmpty && page == 0) {
            _indicatorStatus = IndicatorStatus.empty;
          } else if (items.isEmpty) {
            _indicatorStatus = IndicatorStatus.noMoreLoad;
          } else {
            _indicatorStatus = IndicatorStatus.none;
          }
        });

        // 页面变化且数据加载成功后，滚动到顶部
        if (pageChanged && widget.scrollController != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.scrollController!.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }

        // 页面变化时触发回调（用于多选模式重置选择）
        if (pageChanged) {
          widget.onPageChanged?.call();
        }
      } else {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          _isFirstLoad = false;
          _modeSwitched = false;
          _indicatorStatus = IndicatorStatus.fullScreenError;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        _isFirstLoad = false;
        _modeSwitched = false;
        _errorMessage = CommonUtils.parseExceptionMessage(e);
        _indicatorStatus = page == 0
            ? IndicatorStatus.fullScreenError
            : IndicatorStatus.error;
      });
    }
  }

  Future<void> refresh() async {
    if (widget.isPaginated) {
      await _loadPaginatedData(0);
    } else {
      await widget.sourceList.refresh(true);
    }
  }

  // 添加错误刷新方法
  Future<void> errorRefresh() async {
    if (widget.isPaginated) {
      await _loadPaginatedData(currentPage);
    } else {
      await widget.sourceList.errorRefresh();
    }
  }

  @override
  void dispose() {
    // 如果已注册，注销滚动到顶部回调
    if (_mediaListController != null && widget.scrollController != null) {
      _mediaListController!.unregisterScrollToTopCallback(_scrollToTop);
    }
    // 清理 rebuildKey 监听器
    _rebuildKeyListener?.call();
    _pageController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // 使用节流器降低滚动事件处理频率
    if (!_scrollThrottler.shouldProcessScroll()) {
      return false;
    }

    // 检查是否是有效的滚动通知
    if (notification.depth != 0) {
      return false;
    }

    // 向 MediaListController 报告滚动事件，用于头部动画
    if (notification is ScrollUpdateNotification &&
        _mediaListController != null) {
      ScrollDirection direction = ScrollDirection.idle;
      if (notification.scrollDelta! > 0.1) {
        // 阈值，避免噪音
        direction = ScrollDirection.reverse; // 向上滚动，内容向上移动
      } else if (notification.scrollDelta! < -0.1) {
        // 阈值
        direction = ScrollDirection.forward; // 向下滚动，内容向下移动
      }
      // 仅在确定方向或到达顶部/底部时通知
      if (direction != ScrollDirection.idle ||
          notification.metrics.pixels == 0 ||
          notification.metrics.pixels == notification.metrics.maxScrollExtent) {
        _mediaListController!.notifyListScroll(
          notification.metrics.pixels,
          direction,
        );
      }
    }

    // 达到加载更多的像素点
    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      if (notification.metrics.pixels + 200 >=
              notification.metrics.maxScrollExtent &&
          notification.metrics.maxScrollExtent > 0) {
        // 确保有可滚动内容
        if (widget.isPaginated) {
          // 分页模式下不自动加载下一页
        } else {
          // 瀑布流模式下加载更多
          if (widget.sourceList.hasMore && !widget.sourceList.isLoading) {
            widget.sourceList.loadMore();
          }
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPaginated) {
      return _buildPaginatedView(context);
    } else {
      return _buildInfiniteScrollView(context);
    }
  }

  Widget _buildInfiniteScrollView(BuildContext context) {
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;

    // 使用工具类计算列数和最大交叉轴范围
    final int crossAxisCount = MediaLayoutUtils.calculateCrossAxisCount(
      screenWidth,
    );
    final double maxCrossAxisExtent = screenWidth / crossAxisCount;

    // 提取骨架图布局配置
    final skeletonLayoutConfig =
        widget.extendedListDelegate
            is SliverWaterfallFlowDelegateWithMaxCrossAxisExtent
        ? SkeletonLayoutConfig.fromDelegate(
            widget.extendedListDelegate
                as SliverWaterfallFlowDelegateWithMaxCrossAxisExtent,
          )
        : SkeletonLayoutConfig.defaultConfig(context);

    final scrollView = LoadingMoreCustomScrollView(
      controller: widget.scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: <Widget>[
        LoadingMoreSliverList(
          SliverListConfig<T>(
            extendedListDelegate:
                widget.extendedListDelegate ??
                SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                  crossAxisSpacing: MediaLayoutUtils.crossAxisSpacing,
                  mainAxisSpacing: MediaLayoutUtils.mainAxisSpacing,
                ),
            itemBuilder: widget.itemBuilder,
            sourceList: widget.sourceList,
            padding: EdgeInsets.only(
              top: widget.paddingTop,
              left: 5.0,
              right: 5.0,
              bottom: widget.showBottomPadding
                  ? computeBottomSafeInset(MediaQuery.of(context))
                  : 0,
            ),
            lastChildLayoutType: LastChildLayoutType.foot,
            indicatorBuilder: (context, status) {
              // 获取错误消息
              String? errorMessage = _errorMessage;
              if (widget.sourceList is ExtendedLoadingMoreBase<T>) {
                final extendedList =
                    widget.sourceList as ExtendedLoadingMoreBase<T>;
                errorMessage = extendedList.lastErrorMessage ?? _errorMessage;
              }

              // 如果有错误消息且列表为空，强制显示全屏错误状态
              IndicatorStatus actualStatus = status;
              if (errorMessage != null &&
                  errorMessage.isNotEmpty &&
                  status == IndicatorStatus.empty &&
                  widget.sourceList.isEmpty) {
                actualStatus = IndicatorStatus.fullScreenError;
              }

              // 判断是否为全屏状态
              final bool isFullScreenIndicator =
                  actualStatus == IndicatorStatus.fullScreenBusying ||
                  actualStatus == IndicatorStatus.fullScreenError ||
                  actualStatus == IndicatorStatus.empty;

              return buildIndicator(
                context,
                actualStatus,
                () => widget.sourceList.errorRefresh(),
                emptyIcon: widget.emptyIcon,
                paddingTop: isFullScreenIndicator ? widget.paddingTop : 0,
                errorMessage: errorMessage,
                skeletonLayoutConfig: skeletonLayoutConfig,
              );
            },
          ),
        ),
      ],
    );

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: widget.enablePullToRefresh
          ? RefreshIndicator(
              displacement: widget.paddingTop,
              onRefresh: () => widget.sourceList.refresh(true),
              child: scrollView,
            )
          : scrollView,
    );
  }

  Widget _buildPaginatedView(BuildContext context) {
    // 获取系统底部安全区域高度
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));
    // 计算分页栏所需的底部边距（PaginationBar内部已处理paddingBottom，这里只需要基础高度）
    final paginationBarHeight = 46;

    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;

    // 使用工具类计算列数和最大交叉轴范围
    final int crossAxisCount = MediaLayoutUtils.calculateCrossAxisCount(
      screenWidth,
    );
    final double maxCrossAxisExtent = screenWidth / crossAxisCount;

    // 提取骨架图布局配置
    final skeletonLayoutConfig =
        widget.extendedListDelegate
            is SliverWaterfallFlowDelegateWithMaxCrossAxisExtent
        ? SkeletonLayoutConfig.fromDelegate(
            widget.extendedListDelegate
                as SliverWaterfallFlowDelegateWithMaxCrossAxisExtent,
          )
        : SkeletonLayoutConfig.defaultConfig(context);

    return Stack(
      children: [
        // 主内容区域
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: widget.enablePullToRefresh
              ? RefreshIndicator(
                  // 设置下拉指示器的垂直偏移量
                  displacement: widget.paddingTop,
                  onRefresh: refresh,
                  child: _buildPaginatedContent(
                    context,
                    paginationBarHeight,
                    bottomInset,
                    maxCrossAxisExtent,
                    skeletonLayoutConfig,
                  ),
                )
              : _buildPaginatedContent(
                  context,
                  paginationBarHeight,
                  bottomInset,
                  maxCrossAxisExtent,
                  skeletonLayoutConfig,
                ),
        ),

        // 分页控制栏 - 底部固定位置
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: PaginationBar(
            currentPage: currentPage,
            totalPages: totalPages,
            totalItems: totalItems,
            isLoading: isLoading,
            onPageChanged: _loadPaginatedData,
            useBlurEffect: true,
            paddingBottom: bottomInset,
            showBottomPadding: widget.showBottomPadding,
          ),
        ),
      ],
    );
  }

  Widget _buildPaginatedContent(
    BuildContext context,
    int paginationBarHeight,
    double bottomInset,
    double maxCrossAxisExtent,
    SkeletonLayoutConfig skeletonLayoutConfig,
  ) {
    // 判断当前状态并显示相应的指示器
    if (_indicatorStatus == IndicatorStatus.fullScreenBusying ||
        _indicatorStatus == IndicatorStatus.fullScreenError ||
        (_indicatorStatus == IndicatorStatus.empty && paginatedItems.isEmpty)) {
      // 全屏状态直接显示指示器
      final indicator = buildIndicator(
        context,
        _indicatorStatus,
        errorRefresh,
        emptyIcon: widget.emptyIcon,
        // 全屏指示器需要应用 paddingTop
        paddingTop: widget.paddingTop,
        errorMessage: _errorMessage,
        skeletonLayoutConfig: skeletonLayoutConfig,
      );

      // 如果是SliverFillRemaining，需要套一层CustomScrollView
      if (indicator is SliverFillRemaining) {
        return LoadingMoreCustomScrollView(
          controller: widget.scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [indicator],
        );
      }

      // 其他情况套一个SingleChildScrollView确保可滚动
      return SingleChildScrollView(
        controller: widget.scrollController,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200, // 减去大致的头部和底部高度
          child: Center(child: indicator ?? const SizedBox.shrink()),
        ),
      );
    }

    // 数据已加载，显示内容
    final reservedBottom =
        paginationBarHeight.toDouble() +
        (widget.showBottomPadding ? bottomInset : 0) +
        4; // 为分页控制栏留出空间

    return LoadingMoreCustomScrollView(
      controller: widget.scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.only(
            top: widget.paddingTop,
            left: 5.0,
            right: 5.0,
            bottom: reservedBottom,
          ),
          sliver: SliverWaterfallFlow(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  widget.itemBuilder(context, paginatedItems[index], index),
              childCount: paginatedItems.length,
            ),
            gridDelegate:
                widget.extendedListDelegate
                    is SliverWaterfallFlowDelegateWithMaxCrossAxisExtent
                ? widget.extendedListDelegate
                      as SliverWaterfallFlowDelegateWithMaxCrossAxisExtent
                : SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: maxCrossAxisExtent,
                    crossAxisSpacing: MediaLayoutUtils.crossAxisSpacing,
                    mainAxisSpacing: MediaLayoutUtils.mainAxisSpacing,
                  ),
          ),
        ),
        // 加载更多指示器
        if (_indicatorStatus == IndicatorStatus.loadingMoreBusying ||
            _indicatorStatus == IndicatorStatus.error ||
            _indicatorStatus == IndicatorStatus.noMoreLoad)
          SliverToBoxAdapter(
            child: buildIndicator(
              context,
              _indicatorStatus,
              errorRefresh,
              emptyIcon: widget.emptyIcon,
              // 加载更多/错误/无更多 指示器不需要顶部padding
              paddingTop: 0,
              errorMessage: _errorMessage,
              skeletonLayoutConfig: skeletonLayoutConfig,
            ),
          ),
      ],
    );
  }
}
