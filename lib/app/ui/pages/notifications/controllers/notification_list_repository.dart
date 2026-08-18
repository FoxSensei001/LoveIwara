import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/loading_more_refresh_guard.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class NotificationListRepository extends LoadingMoreBase<Map<String, dynamic>>
    with LoadingMoreRefreshGuard<Map<String, dynamic>> {
  final UserService _userService = Get.find<UserService>();

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
    try {
      return await runGuardedRefresh(() async {
        forceRefresh = !notifyStateChanged;
        try {
          return await super.refresh(notifyStateChanged);
        } finally {
          forceRefresh = false;
        }
      });
    } catch (e, stack) {
      LogUtils.e('刷新通知列表失败', error: e, stack: stack);
      showToastWidget(
        MDToastWidget(
          message: '${slang.t.errors.failedToRefresh}: $e',
          type: MDToastType.error,
        ),
      );
      return false;
    }
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    // 代际 + 页码快照必须在 await 之前取：await 期间可能发生 refresh()，
    // 那样回来的第 N 页会被当成第 0 页写进列表，页码也跟着错位。
    final int generation = currentGeneration;
    final int page = _pageIndex;
    try {
      if (!_userService.isAuthenticated) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.errors.pleaseLoginFirst,
            type: MDToastType.error,
          ),
        );
        return false;
      }

      // 已认证但资料可能尚未加载完成：此处空安全，避免 NPE，交由资料就绪后重试。
      final userId = _userService.currentUser.value?.id;
      if (userId == null || userId.isEmpty) {
        return false;
      }

      final result = await _userService.fetchUserNotifications(
        userId,
        page: page,
        limit: 20,
      );

      if (!result.isSuccess) {
        throw Exception(result.message);
      }

      // await 期间已被 refresh() 作废 → 丢弃本次结果。必须返回 true：
      // 返回 false 会被 loading_more_list 映射成一个假的错误页。
      if (isStaleGeneration(generation)) {
        return true;
      }

      if (page == 0) {
        clear();
      }

      final notifications = result.data?.results ?? [];

      for (final notification in notifications) {
        add(notification);
      }

      _hasMore = notifications.isNotEmpty;
      _pageIndex = page + 1;
      isSuccess = true;
    } catch (e, stack) {
      if (isStaleGeneration(generation)) {
        return true;
      }
      isSuccess = false;
      LogUtils.e('加载通知列表失败', error: e, stack: stack);
      showToastWidget(
        MDToastWidget(
          message: '${slang.t.errors.failedToFetchData}: $e',
          type: MDToastType.error,
        ),
      );
    }
    return isSuccess;
  }
}
