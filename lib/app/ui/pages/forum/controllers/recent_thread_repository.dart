import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/loading_more_refresh_guard.dart';

class RecentThreadListRepository extends LoadingMoreBase<ForumThreadModel>
    with LoadingMoreRefreshGuard<ForumThreadModel> {
  final ForumService _forumService = Get.find<ForumService>();
  int _pageIndex = 0;
  bool _hasMore = true;

  RecentThreadListRepository();

  @override
  bool get hasMore => _hasMore;

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    // 代际 + 页码快照必须在 await 之前取：await 期间可能发生 refresh()，
    // 那样回来的第 N 页会被当成第 0 页写进列表，页码也跟着错位。
    final int generation = currentGeneration;
    final int page = _pageIndex;
    try {
      final result = await _forumService.fetchRecentThreads(
        page: page,
        limit: 20,
      );

      // await 期间已被 refresh() 作废 → 丢弃本次结果。必须返回 true：
      // 返回 false 会被 loading_more_list 映射成一个假的错误页。
      if (isStaleGeneration(generation)) {
        return true;
      }

      if (!result.isSuccess) {
        return false;
      }

      if (page == 0) {
        clear();
      }

      addAll(result.data?.results ?? []);
      _hasMore = (result.data?.results.length ?? 0) >= 20;
      _pageIndex = page + 1;
      return true;
    } catch (e, stack) {
      if (isStaleGeneration(generation)) {
        return true;
      }
      LogUtils.e(
        '加载最近帖子失败',
        error: e,
        stack: stack,
        tag: 'RecentThreadListRepository',
      );
      return false;
    }
  }

  @override
  void resetPagingState() {
    super.resetPagingState(); // 代际自增，作废在途回写
    _pageIndex = 0;
    _hasMore = true;
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    return runGuardedRefresh(() => super.refresh(notifyStateChanged));
  }
}
