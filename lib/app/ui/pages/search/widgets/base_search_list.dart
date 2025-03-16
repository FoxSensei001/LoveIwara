import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/search/repositories/search_repository.dart';

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

  @override
  void initState() {
    super.initState();
    repository = createRepository();
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 如果搜索查询变更，重新创建仓库
    if (oldWidget.query != widget.query) {
      repository = createRepository();
    }
  }

  @override
  void dispose() {
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
      itemBuilder: buildListItem,
    );
  }
} 