import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 本地来源在图库文件夹卡片墙上的分页池。
class LocalImageFolderListRepository
    extends ExtendedLoadingMoreBase<LocalImageFolder> {
  LocalImageFolderListRepository({
    required this.sourceId,
    required this.sortOrder,
    LocalMediaRepository? repository,
  }) : _repository = repository ?? LocalMediaRepository();

  final String sourceId;
  final LocalImageFolderSort sortOrder;
  final LocalMediaRepository _repository;

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final items = _repository.pageImageFolders(
      sourceId: sourceId,
      sort: sortOrder,
      offset: page * limit,
      limit: limit,
    );
    return <String, dynamic>{
      'items': items,
      'count': _repository.countImageFolders(sourceId: sourceId),
    };
  }

  @override
  List<LocalImageFolder> extractDataList(Map<String, dynamic> response) {
    return (response['items'] as List<LocalImageFolder>?) ??
        const <LocalImageFolder>[];
  }

  @override
  int extractTotalCount(Map<String, dynamic> response) =>
      (response['count'] as int?) ?? 0;

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e('加载本机图库列表失败: $message', error: error, stack: stackTrace);
  }
}
