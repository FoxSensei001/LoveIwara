import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import '../controllers/media_list_controller.dart';

/// 订阅列表基类 - 提供通用功能以减少子类重复代码
abstract class BaseSubscriptionList<T, R extends ExtendedLoadingMoreBase<T>> extends StatefulWidget {
  final String userId;
  final bool isPaginated;

  const BaseSubscriptionList({
    super.key,
    required this.userId,
    this.isPaginated = false,
  });
}

/// 订阅列表基类状态 - 提供通用状态管理
abstract class BaseSubscriptionListState<T, R extends ExtendedLoadingMoreBase<T>, W extends BaseSubscriptionList<T, R>> 
    extends State<W> with AutomaticKeepAliveClientMixin {
  
  late R repository;
  final ScrollController _scrollController = ScrollController();
  late final MediaListController _mediaListController;
  
  @override
  void initState() {
    super.initState();
    repository = createRepository();
    _mediaListController = Get.find<MediaListController>();
    // 注册滚动回调
    _mediaListController.registerScrollToTopCallback(_scrollToTop);
  }
  
  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 用户ID变化时重新创建数据源
    if (oldWidget.userId != widget.userId) {
      repository = createRepository();
      if (mounted) {
        setState(() {});
      }
    }
    
    // 分页模式变化时刷新并滚动到顶部
    if (oldWidget.isPaginated != widget.isPaginated) {
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
    // 注销滚动回调
    _mediaListController.unregisterScrollToTopCallback(_scrollToTop);
    _scrollController.dispose();
    repository.dispose();
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
  
  /// 统一刷新方法
  Future<void> refresh() async {
    if (widget.isPaginated) {
      setState(() {});
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
      itemBuilder: buildListItem,
    );
    
    return RefreshIndicator(
      onRefresh: refresh,
      child: mediaListView,
    );
  }
} 