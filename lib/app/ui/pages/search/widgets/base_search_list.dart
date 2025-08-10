import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/search/repositories/search_repository.dart';
import 'package:get/get.dart';
import '../../search/search_result.dart' as search;

/// 搜索列表基类
abstract class BaseSearchList<T, R extends SearchRepository<T>> extends StatefulWidget {
  final String query;
  final bool isPaginated;

  const BaseSearchList({
    super.key,
    required this.query,
    this.isPaginated = false,
  });
}

/// 搜索列表基类状态
abstract class BaseSearchListState<T, R extends SearchRepository<T>, W extends BaseSearchList<T, R>> extends State<W> {
  late R repository;
  final ScrollController _scrollController = ScrollController();
  late final search.SearchController _searchController;

  @override
  void initState() {
    super.initState();
    repository = createRepository();
    _searchController = Get.find<search.SearchController>(tag: 'search_controller');
    // 注册滚动回调
    _searchController.registerScrollToTopCallback(_scrollToTop);
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 如果搜索查询变更，重新创建仓库
    if (oldWidget.query != widget.query) {
      repository = createRepository();
    }
    
    // 分页模式变化时刷新并滚动到顶部
    if (oldWidget.isPaginated != widget.isPaginated) {
      Future.microtask(() {
        _scrollToTop();
      });
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
    _searchController.unregisterScrollToTopCallback(_scrollToTop);
    _scrollController.dispose();
    repository.dispose();
    super.dispose();
  }

  /// 创建搜索仓库实例
  R createRepository();
  
  /// 获取空列表的图标
  IconData get emptyIcon;
  
  /// 构建单个列表项
  Widget buildListItem(BuildContext context, T item, int index);

  @override
  Widget build(BuildContext context) {
    
    return MediaListView<T>(
      sourceList: repository,
      emptyIcon: emptyIcon,
      isPaginated: widget.isPaginated,
      scrollController: _scrollController,
      showBottomPadding: true, // 搜索页面使用默认值 true
      itemBuilder: buildListItem,
    );
  }
} 