import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/user_request_dto.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/loading_more_refresh_guard.dart';

class FriendRequestRepository extends LoadingMoreBase<UserRequestDTO>
    with LoadingMoreRefreshGuard<UserRequestDTO> {
  final UserService _userService = Get.find();

  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  void resetPagingState() {
    super.resetPagingState(); // 代际自增，作废在途回写
    _hasMore = true;
    _pageIndex = 0;
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    return runGuardedRefresh(() async {
      forceRefresh = !notifyStateChanged;
      try {
        return await super.refresh(notifyStateChanged);
      } finally {
        forceRefresh = false;
      }
    });
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    // 代际 + 页码快照必须在 await 之前取：await 期间可能发生 refresh()，
    // 那样回来的第 N 页会被当成第 0 页写进列表，页码也跟着错位。
    final int generation = currentGeneration;
    final int page = _pageIndex;
    try {
      // 空安全：资料未加载完成时不崩，交由资料就绪后重试。
      final userId = _userService.currentUser.value?.id;
      if (userId == null || userId.isEmpty) {
        return false;
      }
      final result = await _userService.fetchUserFriendsRequests(
        page: page,
        userId: userId,
      );

      // await 期间已被 refresh() 作废 → 丢弃本次结果。必须返回 true：
      // 返回 false 会被 loading_more_list 映射成一个假的错误页。
      if (isStaleGeneration(generation)) {
        return true;
      }

      if (result.isSuccess && result.data != null) {
        if (page == 0) {
          clear();
        }

        for (final request in result.data!.results) {
          add(request);
        }

        _hasMore = result.data!.results.isNotEmpty;
        _pageIndex = page + 1;
        isSuccess = true;
      }
    } catch (e, stack) {
      if (isStaleGeneration(generation)) {
        return true;
      }
      isSuccess = false;
      LogUtils.e('加载好友申请列表失败', error: e, stack: stack);
    }
    return isSuccess;
  }
}
