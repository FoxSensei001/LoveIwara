import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:loading_more_list/loading_more_list.dart';

class FriendListRepository extends LoadingMoreBase<User> {
  final UserService _userService = Get.find();

  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;

  @override
  bool get hasMore => _hasMore || forceRefresh;

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
      // 空安全：资料未加载完成时不崩，交由资料就绪后重试。
      final userId = _userService.currentUser.value?.id;
      if (userId == null || userId.isEmpty) {
        return false;
      }
      final result = await _userService.fetchFriends(
        page: _pageIndex,
        userId: userId,
      );

      if (result.isSuccess && result.data != null) {
        if (_pageIndex == 0) {
          clear();
        }

        for (final friend in result.data!.results) {
          add(friend);
        }

        _hasMore = result.data!.results.isNotEmpty;
        _pageIndex++;
        isSuccess = true;
      }
    } catch (e) {
      isSuccess = false;
    }
    return isSuccess;
  }
}
