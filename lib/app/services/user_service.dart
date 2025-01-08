import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/user_request_dto.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/i18n/strings.g.dart';

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';
import '../models/api_result.model.dart';
import '../models/user.model.dart';
import '../routes/app_routes.dart';
import 'api_service.dart';
import 'auth_service.dart';

class UserService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = Get.find<ApiService>();

  final String _tag = '[UserService]';

  Rxn<User> currentUser = Rxn<User>();

  bool get isLogin => currentUser.value != null;

  String get userAvatar =>
      currentUser.value?.avatar?.avatarUrl ?? CommonConstants.defaultAvatarUrl;

  Future<UserService> init() async {
    LogUtils.d('$_tag 初始化用户服务');
    if (_authService.hasToken) {
      try {
        LogUtils.d('$_tag 存在有效TOKEN，尝试获取用户资料');
        await fetchUserProfile();
      } catch (e) {
        LogUtils.e('$_tag 初始化用户失败', error: e);
        // 错误处理已经在 AuthService 中统一处理
      }
    } else {
      LogUtils.d('$_tag 未登录');
    }
    return this;
  }

  // 抓取用户资料
  Future<void> fetchUserProfile() async {
    try {
      LogUtils.d('$_tag 抓取用户资料');
      final response = await _apiService.get<Map<String, dynamic>>('/user');
      currentUser.value = User.fromJson(response.data!['user']);
      LogUtils.d('$_tag 用户资料: ${currentUser.value}');
    } catch (e) {
      LogUtils.e('抓取用户资料失败', error: e);
      if (e is! UnauthorizedException) {
        throw AuthServiceException(t.errors.failedToOperate);
      }
      rethrow;
    }
  }

  // 登录
  Future<void> logout() async {
    try {
      await _authService.logout();
      currentUser.value = null;
    } catch (e) {
      LogUtils.e('用户登出失败', error: e);
      throw AuthServiceException(t.errors.failedToOperate);
    }
  }

  /// 关注
  Future<ApiResult> followUser(String userId) async {
    // 检查用户ID是否为空
    if (userId.isEmpty) {
      return ApiResult.fail(t.errors.invalidParameter);
    }

    // 登录
    if (!_authService.hasToken) {
      Get.toNamed(Routes.LOGIN);
      return ApiResult.fail(t.errors.pleaseLoginFirst);
    }

    try {
      await _apiService.post(ApiConstants.userFollowOrUnfollow(userId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('关注失败', error: e);
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  /// 取消关注
  Future<ApiResult> unfollowUser(String userId) async {
    // 检查用户ID是否为空
    if (userId.isEmpty) {
      return ApiResult.fail(t.errors.invalidParameter);
    }

    // 登录
    if (!_authService.hasToken) {
      Get.toNamed(Routes.LOGIN);
      return ApiResult.fail(t.errors.pleaseLoginFirst);
    }

    try {
      await _apiService.delete(ApiConstants.userFollowOrUnfollow(userId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('取消关注失败', error: e);
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  /// 添加朋友
  Future<ApiResult> removeFriend(String userId) async {
    // 检查用户ID是否为空
    if (userId.isEmpty) {
      return ApiResult.fail(t.errors.invalidParameter);
    }

    // 登录
    if (!_authService.hasToken) {
      Get.toNamed(Routes.LOGIN);
      return ApiResult.fail(t.errors.pleaseLoginFirst);
    }

    try {
      await _apiService.delete(ApiConstants.userAddOrRemoveFriend(userId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('移除朋友失败', error: e);
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  /// 发送朋友申请
  Future<ApiResult> addFriend(String userId) async {
    // 检查用户ID是否为空
    if (userId.isEmpty) {
      return ApiResult.fail(t.errors.invalidParameter);
    }

    // 登录
    if (!_authService.hasToken) {
      Get.toNamed(Routes.LOGIN);
      return ApiResult.fail(t.errors.pleaseLoginFirst);
    }

    try {
      await _apiService.post(ApiConstants.userAddOrRemoveFriend(userId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('发送朋友申请失败', error: e);
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  /// 接受朋友请求
  Future<ApiResult> acceptFriendRequest(String requestId) async {
    return addFriend(requestId);
  }

  /// 拒绝朋友请求
  Future<ApiResult> rejectFriendRequest(String requestId) async {
    return removeFriend(requestId);
  }

  /// 取消朋友请求
  Future<ApiResult> cancelFriendRequest(String requestId) async {
    return removeFriend(requestId);
  }

  /// 朋友列表
  Future<ApiResult<PageData<User>>> fetchFriends(
      {int page = 0, int limit = 20, required String userId}) async {
    try {
      final response = await _apiService
          .get(ApiConstants.userFriends(userId), queryParameters: {
        'page': page,
        'limit': limit,
      });

      final List<User> results = (response.data['results'] as List)
          .map((userJson) => User.fromJson(userJson))
          .map((user) => user.copyWith(friend: true))
          .toList();

      final PageData<User> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );
      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取朋友列表失败', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  /// 代办请求列表
  Future<ApiResult<PageData<UserRequestDTO>>> fetchUserFriendsRequests(
      {int page = 0, int limit = 20, required String userId}) async {
    try {
      final response = await _apiService
          .get(ApiConstants.userFriendsRequests(userId), queryParameters: {
        'page': page,
        'limit': limit,
      });

      final List<UserRequestDTO> results = (response.data['results'] as List)
          .map((userJson) => UserRequestDTO.fromJson(userJson))
          .toList();

      final PageData<UserRequestDTO> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );
      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取朋友请求列表失败', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  /// 获取关注的用户
  Future<ApiResult<PageData<User>>> fetchFollowingUsers(
      {int page = 0, int limit = 20, required String userId}) async {
    try {
      final response = await _apiService.get(ApiConstants.userFollowing(userId), queryParameters: {
        'page': page,
        'limit': limit,
        });

      final List<User> results = (response.data['results'] as List)
          .map((item) => User.fromJson(item['user']))
          .toList();

      final PageData<User> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );
      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取关注用户列表失败', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  /// 获取粉丝
  Future<ApiResult<PageData<User>>> fetchFollowers(
      {int page = 0, int limit = 20, required String userId}) async {
    try {
      final response = await _apiService.get(ApiConstants.userFollowers(userId), queryParameters: {
        'page': page,
        'limit': limit,
      });

      final List<User> results = (response.data['results'] as List)
          .map((item) => User.fromJson(item['follower']))
          .toList();

      final PageData<User> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );
      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取粉丝列表失败', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  // 添加处理登出的方法
  void handleLogout() {
    currentUser.value = null;
  }
}
