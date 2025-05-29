import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/easy_throttle.dart';
import 'package:loading_more_list/loading_more_list.dart';

/// 订阅列表基类 - 提供通用功能以减少子类重复代码
abstract class BaseSubscriptionList<T, R extends ExtendedLoadingMoreBase<T>> extends StatefulWidget {
  final String userId;
  final bool isPaginated;
  final double paddingTop;

  const BaseSubscriptionList({
    super.key,
    required this.userId,
    this.isPaginated = false,
    this.paddingTop = 0,
  });

  @override
  State<BaseSubscriptionList<T, R>> createState();
}

/// 订阅列表基类状态 - 提供通用状态管理
abstract class BaseSubscriptionListState<T, R extends ExtendedLoadingMoreBase<T>, W extends BaseSubscriptionList<T, R>>
    extends State<W> with AutomaticKeepAliveClientMixin {

  late R repository;
  final ScrollController _scrollController = ScrollController();

  // 缓存机制
  final Map<String, Widget> _itemCache = {};

  @override
  void initState() {
    super.initState();
    repository = createRepository();

    // 添加滚动监听
    _scrollController.addListener(_throttledScrollListener);
  }

  // 滚动监听器 - 使用节流降低处理频率
  void _throttledScrollListener() {
    // 使用EasyThrottle进行节流控制
    EasyThrottle.throttle(
      'scroll_${widget.userId}', 
      const Duration(milliseconds: 16), 
      () {
        // 处理滚动事件，例如无限加载或分页预加载等
        final position = _scrollController.position;
        final maxScroll = position.maxScrollExtent;
        final currentScroll = position.pixels;

        // 当滚动到页面末尾前200像素时预加载下一页
        if (maxScroll - currentScroll <= 200 && !widget.isPaginated) {
          repository.loadMore();
        }
      }
    );
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 用户ID变化时重新创建数据源
    if (oldWidget.userId != widget.userId) {
      repository = createRepository();
      // 清除缓存
      _itemCache.clear();
      if (mounted) {
        setState(() {});
      }
    }

    // 分页模式变化时刷新并滚动到顶部
    if (oldWidget.isPaginated != widget.isPaginated) {
      // 清除缓存
      _itemCache.clear();
      if (mounted) {
        Future.microtask(() {
          refresh();
          // 滚动到顶部
          _scrollToTop();
        });
      }
    }
  }

  // 滚动到顶部方法
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_throttledScrollListener);
    _scrollController.dispose();
    repository.dispose();
    // 清除缓存
    _itemCache.clear();
    // 取消该滚动器相关的节流任务
    EasyThrottle.cancel('scroll_${widget.userId}');
    super.dispose();
  }

  /// 创建数据源存储库 - 子类必须实现
  R createRepository();

  /// 获取空状态图标 - 子类可以重写提供特定图标
  IconData get emptyIcon => Icons.hourglass_empty;

  /// 构建列表项 - 子类必须实现
  Widget buildListItem(BuildContext context, T item, int index);

  /// 获取扩展列表代理 - 子类可以重写以自定义布局
  SliverWaterfallFlowDelegate? get extendedListDelegate => null;

  /// 从缓存中获取或构建列表项
  Widget getCachedListItem(BuildContext context, T item, int index) {
    final String cacheKey = '${item.hashCode}_$index';

    return _itemCache.putIfAbsent(cacheKey, () {
      return buildListItem(context, item, index);
    });
  }

  /// 统一刷新方法
  Future<void> refresh() async {
    if (widget.isPaginated) {
      if (mounted) { // 添加 mounted 检查
        setState(() {});
      }
      Future.microtask(() {
        if (mounted) {
          try {
            (repository as ExtendedLoadingMoreBase).loadPageData(0, 20);
            // 滚动到顶部
            _scrollToTop();
          } catch (e) {
            LogUtils.e('刷新数据失败', error: e);
          }
        }
      });
    } else {
      // 清除缓存
      _itemCache.clear();
      await repository.refresh(true);
      // 滚动到顶部
      _scrollToTop();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final mediaListView = MediaListView<T>(
      sourceList: repository,
      emptyIcon: emptyIcon,
      isPaginated: widget.isPaginated,
      extendedListDelegate: extendedListDelegate,
      scrollController: _scrollController,
      paddingTop: widget.paddingTop,
      // 使用缓存机制构建列表项
      itemBuilder: getCachedListItem,
    );

    return mediaListView;
  }
} 