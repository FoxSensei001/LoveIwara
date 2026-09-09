import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 本地来源在视频卡片墙上的分页池。
///
/// 本地库的查询是同步 sqlite 调用，但仍沿用 [ExtendedLoadingMoreBase] 的
/// 分页契约：这样 `MediaListView` 的瀑布流、分页、刷新和过期请求保护都与线上
/// 视频共用，来源切换也只需要替换池，而不是再造一套列表状态机。
class LocalMediaListRepository extends ExtendedLoadingMoreBase<LocalMediaItem> {
  LocalMediaListRepository({
    required this.sourceId,
    required this.sortOrder,
    this.categoryId,
    LocalMediaRepository? repository,
  }) : _repository = repository ?? LocalMediaRepository();

  final String sourceId;
  final LocalMediaSort sortOrder;
  final String? categoryId;
  final LocalMediaRepository _repository;

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final items = _repository.queryItems(
      sourceId: sourceId,
      categoryId: categoryId,
      sort: sortOrder,
      offset: page * limit,
      limit: limit,
    );
    return <String, dynamic>{
      'items': items,
      'count': _repository.countItems(
        sourceId: sourceId,
        categoryId: categoryId,
      ),
    };
  }

  @override
  List<LocalMediaItem> extractDataList(Map<String, dynamic> response) {
    return (response['items'] as List<LocalMediaItem>?) ??
        const <LocalMediaItem>[];
  }

  @override
  int extractTotalCount(Map<String, dynamic> response) =>
      (response['count'] as int?) ?? 0;

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e('加载本机视频列表失败: $message', error: error, stack: stackTrace);
  }
}
