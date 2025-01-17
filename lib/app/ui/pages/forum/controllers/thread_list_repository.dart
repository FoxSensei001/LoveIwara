import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/forum_thread_section_dto.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';

class ThreadListRepository extends LoadingMoreBase<ForumThreadModel> {
  final ForumService _forumService = Get.find<ForumService>();
  final String categoryId;
  final Function(dynamic name, dynamic description)? updateCategoryName;

  ThreadListRepository({required this.categoryId, this.updateCategoryName, this.maxLength = 300});
  
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
      final result = await _forumService.fetchForumThreads(
        categoryId,
        page: _pageIndex,
        limit: 20,
      );

      if (!result.isSuccess) {
        throw Exception(result.message);
      }

      final section = result.data?['section'] as ForumThreadSectionDto;
      updateCategoryName?.call(section.name, section.description);

      if (_pageIndex == 0) {
        clear();
      }

      final threads = result.data?['results'] as List<ForumThreadModel>;
      
      for (final thread in threads) {
        add(thread);
      }

      _hasMore = threads.isNotEmpty;
      _pageIndex++;
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      LogUtils.e('加载帖子列表失败',
          error: exception, stack: stack, tag: 'ThreadListRepository');
    }
    return isSuccess;
  }
} 