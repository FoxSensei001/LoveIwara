import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';

class ThreadDetailRepository extends LoadingMoreBase<ThreadCommentModel> {
  final ForumService _forumService = Get.find<ForumService>();
  final String categoryId;
  final String threadId;
  final Function(ForumThreadModel thread)? updateThread;

  ThreadDetailRepository({
    required this.categoryId,
    required this.threadId,
    this.updateThread,
    this.maxLength = 300,
  });

  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;
  @override
  bool get hasMore => (_hasMore && length < maxLength) || forceRefresh;
  final int maxLength;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _pageIndex = 0;
    forceRefresh = !notifyStateChanged;
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    try {
      final result = await _forumService.fetchForumThread(
        categoryId,
        threadId,
        page: _pageIndex,
        limit: 20,
      );

      if (!result.isSuccess) {
        throw Exception(result.message);
      }

      final thread = result.data?['thread'] as ForumThreadModel;
      updateThread?.call(thread);

      if (_pageIndex == 0) {
        clear();
      }

      final posts = result.data?['posts'] as List<ThreadCommentModel>;
      
      for (final post in posts) {
        add(post);
      }

      _hasMore = posts.isNotEmpty;
      _pageIndex++;
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      LogUtils.e('加载帖子评论列表失败',
          error: exception, stack: stack, tag: 'ThreadDetailRepository');
    }
    return isSuccess;
  }
} 