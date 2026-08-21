import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 「最近帖子」数据源，支持瀑布流和分页模式。
///
/// 基类 [ExtendedLoadingMoreBase] 已带代际防护（refresh 作废在途回写）与
/// 统一的 loadData / loadPageData 实现，这里只负责拼请求和拆响应。
class RecentThreadListRepository
    extends ExtendedLoadingMoreBase<ForumThreadModel> {
  final ForumService _forumService = Get.find<ForumService>();

  RecentThreadListRepository();

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final result = await _forumService.fetchRecentThreads(
      page: page,
      limit: limit,
    );

    if (!result.isSuccess) {
      lastErrorMessage = result.message;
      throw Exception(result.message);
    }

    final pageData = result.data!;
    return <String, dynamic>{
      'results': pageData.results,
      'count': pageData.count,
    };
  }

  @override
  List<ForumThreadModel> extractDataList(Map<String, dynamic> response) {
    return response['results'] as List<ForumThreadModel>;
  }

  @override
  int extractTotalCount(Map<String, dynamic> response) {
    final threads = response['results'] as List<ForumThreadModel>;
    return response['count'] as int? ?? threads.length;
  }

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e(
      message,
      error: error,
      stack: stackTrace,
      tag: 'RecentThreadListRepository',
    );
  }
}
