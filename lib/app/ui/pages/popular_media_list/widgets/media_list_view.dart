import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/utils/logger_utils.dart' show LogUtils;
import 'package:loading_more_list/loading_more_list.dart';
import 'common_media_list_widgets.dart';

// 扩展LoadingMoreBase，确保所有子类都有requestTotalCount属性和分页方法
abstract class ExtendedLoadingMoreBase<T> extends LoadingMoreBase<T> {
  int requestTotalCount = 0;
  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;
  
  @override
  bool get hasMore => _hasMore || forceRefresh;
  
  // 定义通用的数据获取方法，子类必须实现
  Future<Map<String, dynamic>> fetchDataFromSource(Map<String, dynamic> params, int page, int limit);
  
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
      // 子类可通过覆盖logError方法来自定义错误日志
      logError('加载分页数据失败', e);
      return [];
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

  const MediaListView({
    super.key,
    required this.sourceList,
    required this.itemBuilder,
    this.emptyIcon,
    this.isPaginated = false,
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
  
  int get totalItems {
    if (widget.sourceList is ExtendedLoadingMoreBase<T>) {
      return (widget.sourceList as ExtendedLoadingMoreBase<T>).requestTotalCount;
    }
    return 0;
  }
  
  int get totalPages => totalItems > 0 ? (totalItems / itemsPerPage).ceil() : 1;

  @override
  void initState() {
    super.initState();
    if (widget.isPaginated) {
      _loadPaginatedData(0);
    }
  }

  @override
  void didUpdateWidget(MediaListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaginated != widget.isPaginated || oldWidget.sourceList != widget.sourceList) {
      if (widget.isPaginated && !oldWidget.isPaginated) {
        currentPage = 0;
        _loadPaginatedData(currentPage);
      }
    }
  }

  Future<void> _loadPaginatedData(int page) async {
    if (isLoading) return;
    
    setState(() {
      isLoading = true;
      _indicatorStatus = page == 0 
          ? IndicatorStatus.fullScreenBusying 
          : IndicatorStatus.loadingMoreBusying;
    });
    
    try {
      if (widget.sourceList is ExtendedLoadingMoreBase<T>) {
        final repo = widget.sourceList as ExtendedLoadingMoreBase<T>;
        final items = await repo.loadPageData(page, itemsPerPage);
        
        setState(() {
          paginatedItems = items;
          currentPage = page;
          isLoading = false;
          
          // 根据结果设置适当的状态
          if (items.isEmpty && page == 0) {
            _indicatorStatus = IndicatorStatus.empty;
          } else if (items.isEmpty) {
            _indicatorStatus = IndicatorStatus.noMoreLoad;
          } else {
            _indicatorStatus = IndicatorStatus.none;
          }
        });
      } else {
        setState(() {
          isLoading = false;
          _indicatorStatus = IndicatorStatus.fullScreenError;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        _indicatorStatus = page == 0 
            ? IndicatorStatus.fullScreenError 
            : IndicatorStatus.error;
      });
    }
  }

  void _nextPage() {
    if (currentPage < totalPages - 1) {
      _loadPaginatedData(currentPage + 1);
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _loadPaginatedData(currentPage - 1);
    }
  }

  void _jumpToPage() {
    try {
      final targetPage = int.parse(_pageController.text);
      if (targetPage >= 1 && targetPage <= totalPages) {
        _loadPaginatedData(targetPage - 1);
        FocusScope.of(context).unfocus();
      } else {
        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('请输入有效页码 (1-$totalPages)'),
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
    _pageController.dispose();
    super.dispose();
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
    return LoadingMoreCustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: <Widget>[
        LoadingMoreSliverList(
          SliverListConfig<T>(
            extendedListDelegate:
                SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: MediaQuery.of(context).size.width <= 600 ? MediaQuery.of(context).size.width / 2 : 200,
              crossAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
              mainAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
            ),
            itemBuilder: widget.itemBuilder,
            sourceList: widget.sourceList,
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
              right: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
              bottom: Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0,
            ),
            lastChildLayoutType: LastChildLayoutType.foot,
            indicatorBuilder: (context, status) => buildIndicator(
              context,
              status,
              () => widget.sourceList.errorRefresh(),
              emptyIcon: widget.emptyIcon,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginatedView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: () {
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
                );
                
                // 如果是SliverFillRemaining，需要套一层CustomScrollView
                if (indicator is SliverFillRemaining) {
                  return LoadingMoreCustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    slivers: [indicator],
                  );
                }
                
                // 其他情况套一个SingleChildScrollView确保可滚动
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200, // 减去大致的头部和底部高度
                    child: Center(child: indicator ?? const SizedBox.shrink()),
                  ),
                );
              }
              
              // 数据已加载，显示内容
              return LoadingMoreCustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
                      right: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
                      bottom: 60, // 为分页控制栏留出空间
                    ),
                    sliver: SliverWaterfallFlow(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => widget.itemBuilder(context, paginatedItems[index], index),
                        childCount: paginatedItems.length,
                      ),
                      gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: MediaQuery.of(context).size.width <= 600 ? MediaQuery.of(context).size.width / 2 : 200,
                        crossAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
                        mainAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
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
                      ),
                    ),
                ],
              );
            }(),
          ),
        ),
        // 分页控制栏
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          // 使用LayoutBuilder来获取可用宽度，根据宽度渲染不同的布局
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 判断是否为窄屏设备 - 600px是平板和手机的常用断点
              final isNarrow = constraints.maxWidth < 600;
              
              // 在窄屏设备上使用紧凑布局
              if (isNarrow) {
                return _buildCompactPaginationBar(context);
              } else {
                // 在宽屏上使用完整布局
                return _buildFullPaginationBar(context);
              }
            },
          ),
        ),
      ],
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
            constraints: BoxConstraints(maxWidth: 100),
            child: Text(
              '共 $totalItems 项',
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
                enabled: currentPage > 0 && !isLoading,
                onPressed: () => _loadPaginatedData(0),
              ),
              const SizedBox(width: 4),
              _buildNavButton(
                icon: Icons.chevron_left,
                enabled: currentPage > 0 && !isLoading,
                onPressed: _previousPage,
              ),
              const SizedBox(width: 8),
              Container(
                constraints: BoxConstraints(minWidth: 68),
                height: 36,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    '${currentPage + 1} / $totalPages',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildNavButton(
                icon: Icons.chevron_right,
                enabled: currentPage < totalPages - 1 && !isLoading,
                onPressed: _nextPage,
              ),
              const SizedBox(width: 4),
              _buildNavButton(
                icon: Icons.last_page,
                enabled: currentPage < totalPages - 1 && !isLoading,
                onPressed: () => _loadPaginatedData(totalPages - 1),
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
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(18)),
                ),
                child: TextField(
                  controller: _pageController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
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
                onTap: isLoading ? null : _jumpToPage,
                borderRadius: BorderRadius.horizontal(right: Radius.circular(18)),
                child: Container(
                  height: 36,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isLoading 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(18)),
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
            onTap: isLoading ? null : _showJumpPageDialog,
            child: Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${currentPage + 1} / $totalPages  (共 $totalItems 项)',
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
                enabled: currentPage > 0 && !isLoading,
                onPressed: _previousPage,
              ),
              const SizedBox(width: 12),
              _buildNavButton(
                icon: Icons.chevron_right,
                enabled: currentPage < totalPages - 1 && !isLoading,
                onPressed: _nextPage,
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
        onTap: enabled ? onPressed : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: enabled 
                  ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
                  : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
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
            Text('请输入页码 (1-$totalPages)'),
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
} 