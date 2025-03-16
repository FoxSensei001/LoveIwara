import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';

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
  
  @override
  void initState() {
    super.initState();
    repository = createRepository();
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
    
    // 分页模式变化时刷新
    if (oldWidget.isPaginated != widget.isPaginated) {
      if (mounted) {
        Future.microtask(() => refresh());
      }
    }
  }
  
  @override
  void dispose() {
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
          } catch (e) {
            LogUtils.e('刷新数据失败', error: e);
          }
        }
      });
    } else {
      await repository.refresh(true);
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
      itemBuilder: buildListItem,
    );
    
    return RefreshIndicator(
      onRefresh: refresh,
      child: mediaListView,
    );
  }
} 