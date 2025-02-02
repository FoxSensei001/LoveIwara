import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:loading_more_list/loading_more_list.dart';

class RecentThreadListRepository extends LoadingMoreBase<ForumThreadModel> {
  final ForumService _forumService = Get.find<ForumService>();
  int _pageIndex = 0;
  bool _hasMore = true;

  @override
  bool get hasMore => _hasMore;

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    try {
      final result = await _forumService.fetchRecentThreads(
        page: _pageIndex,
        limit: 20,
      );

      if (!result.isSuccess) {
        return false;
      }

      if (_pageIndex == 0) {
        clear();
      }

      addAll(result.data?.results ?? []);
      _hasMore = (result.data?.results.length ?? 0) >= 20;
      _pageIndex++;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _pageIndex = 0;
    _hasMore = true;
    return super.refresh(notifyStateChanged);
  }
} 