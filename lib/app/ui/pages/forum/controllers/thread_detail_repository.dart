import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';

class ThreadDetailRepository
    extends ExtendedLoadingMoreBase<ThreadCommentModel> {
  final ForumService _forumService = Get.find<ForumService>();
  final String categoryId;
  final String threadId;
  final Function(ForumThreadModel thread)? updateThread;
  bool firstLoad = true;
  final HistoryRepository _historyRepository = HistoryRepository();

  // 缓存帖子主体信息
  ForumThreadModel? _cachedThread;

  ThreadDetailRepository({
    required this.categoryId,
    required this.threadId,
    this.updateThread,
  });

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final result = await _forumService.fetchForumThread(
      categoryId,
      threadId,
      page: page,
      limit: limit,
    );

    if (!result.isSuccess) {
      lastErrorMessage = result.message;
      throw Exception(result.message);
    }

    final thread = result.data?['thread'] as ForumThreadModel;
    _cachedThread = thread;
    updateThread?.call(thread);

    if (firstLoad) {
      firstLoad = false;
      _historyRepository.addRecordWithCheck(HistoryRecord.fromThread(thread));
    }

    final posts = result.data?['posts'] as List<ThreadCommentModel>;

    return {'posts': posts, 'count': thread.numPosts};
  }

  @override
  List<ThreadCommentModel> extractDataList(Map<String, dynamic> response) {
    return response['posts'] as List<ThreadCommentModel>? ?? [];
  }

  @override
  int extractTotalCount(Map<String, dynamic> response) {
    return response['count'] as int? ?? 0;
  }

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e(
      message,
      error: error,
      stack: stackTrace,
      tag: 'ThreadDetailRepository',
    );
  }

  /// 获取缓存的帖子主体信息
  ForumThreadModel? get cachedThread => _cachedThread;
}
