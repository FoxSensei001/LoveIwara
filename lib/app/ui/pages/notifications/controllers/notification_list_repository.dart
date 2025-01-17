import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class NotificationListRepository extends LoadingMoreBase<Map<String, dynamic>> {
  final UserService _userService = Get.find<UserService>();
  
  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;
  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    try {
      _hasMore = true;
      _pageIndex = 0;
      forceRefresh = !notifyStateChanged;
      final bool result = await super.refresh(notifyStateChanged);
      forceRefresh = false;
      return result;
    } catch (e, stack) {
      LogUtils.e('刷新通知列表失败', error: e, stack: stack);
      showToastWidget(MDToastWidget(
        message: '${slang.t.errors.failedToRefresh}: $e',
        type: MDToastType.error,
      ));
      return false;
    }
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    try {
      if (!_userService.isLogin) {
        showToastWidget(MDToastWidget(
          message: slang.t.errors.pleaseLoginFirst,
          type: MDToastType.error,
        ));
        return false;
      }

      final result = await _userService.fetchUserNotifications(
        _userService.currentUser.value!.id,
        page: _pageIndex,
        limit: 20,
      );

      if (!result.isSuccess) {
        throw Exception(result.message);
      }

      if (_pageIndex == 0) {
        clear();
      }

      final notifications = result.data?.results ?? [];
      
      for (final notification in notifications) {
        add(notification);
      }

      _hasMore = notifications.isNotEmpty;
      _pageIndex++;
      isSuccess = true;
    } catch (e, stack) {
      isSuccess = false;
      LogUtils.e('加载通知列表失败', error: e, stack: stack);
      showToastWidget(MDToastWidget(
        message: '${slang.t.errors.failedToFetchData}: $e',
        type: MDToastType.error,
      ));
    }
    return isSuccess;
  }
} 