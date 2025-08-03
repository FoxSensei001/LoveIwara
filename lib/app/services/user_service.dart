import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/profile_user_dto.dart';
import 'package:i_iwara/app/models/dto/user_request_dto.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/user_notification_count.model.dart';
import 'package:i_iwara/i18n/strings.g.dart';

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';
import '../models/api_result.model.dart';
import '../models/user.model.dart';
import '../routes/app_routes.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class UserService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storage = StorageService();

  final String _tag = '[UserService]';

  Rxn<User> currentUser = Rxn<User>();
  RxInt notificationCount = RxInt(0);
  RxInt friendRequestsCount = RxInt(0);
  RxInt messagesCount = RxInt(0);
  Timer? _notificationTimer;
  
  // 认证状态监听
  StreamSubscription<bool>? _authStateSubscription;

  // 缓存相关
  User? _cachedUser;
  DateTime? _lastUserDataUpdate;
  static const Duration _cacheValidDuration = Duration(hours: 1);

  bool get isLogin => currentUser.value != null;
  RxBool isLogining = RxBool(false);

  // 新增：基于token的认证状态
  bool get isAuthenticated => _authService.isAuthenticated;

  String get userAvatar =>
      currentUser.value?.avatar?.avatarUrl ?? CommonConstants.defaultAvatarUrl;

  // 开始通知计数定时任务
  void startNotificationTimer() {
    if (_notificationTimer == null) {
      _notificationTimer = Timer.periodic(const Duration(minutes: 15), (timer) async {
        if (_authService.hasToken) {
          await refreshNotificationCount();
        }
      });
      // 立即执行一次
      if (_authService.hasToken) {
        refreshNotificationCount();
      }
    }
  }

  // 停止通知计数定时任务
  void stopNotificationTimer() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }

  void clearAllNotificationCounts() {
    stopNotificationTimer();
    notificationCount.value = 0;
    friendRequestsCount.value = 0;
    messagesCount.value = 0;
  }

  // 获取通知计数
  Future<void> refreshNotificationCount() async {
    try {
      final result = await fetchUserNotificationCount();
      if (result.data != null) {
        notificationCount.value = result.data?.notifications ?? 0;
        friendRequestsCount.value = result.data?.friendRequests ?? 0;
        messagesCount.value = result.data?.messages ?? 0;
      }
    } catch (e) {
      LogUtils.e('获取通知计数失败', tag: _tag, error: e);
    }
  }

  @override
  void onClose() {
    stopNotificationTimer();
    _authStateSubscription?.cancel();
    super.onClose();
  }

  UserService() {
    LogUtils.d('$_tag 初始化用户服务');
    
    // 监听认证状态变化
    _setupAuthStateListener();
    
    // 如果当前已经认证，初始化用户数据
    if (_authService.isAuthenticated) {
      _initializeUserData();
    }
  }
  
  // 设置认证状态监听器
  void _setupAuthStateListener() {
    _authStateSubscription = _authService.authStateStream.listen((isAuthenticated) {
      LogUtils.d('$_tag 认证状态变化: $isAuthenticated');
      
      if (isAuthenticated) {
        // 用户已认证，初始化用户数据
        _initializeUserData();
      } else {
        // 用户未认证，清理数据
        _clearUserData();
      }
    });
  }
  
  // 初始化用户数据
  void _initializeUserData() {
    if (_authService.hasToken) {
      try {
        LogUtils.d('$_tag 存在有效TOKEN，尝试加载用户数据');
        // 先尝试加载缓存的用户数据
        _loadCachedUserData();
        // 后台异步刷新用户数据
        _refreshUserDataInBackground();
      } catch (e) {
        LogUtils.e('$_tag 初始化用户失败', error: e);
        // 错误处理已经在 AuthService 中统一处理
      }
    } else {
      LogUtils.d('$_tag 未登录');
    }
  }
  
  // 清理用户数据
  void _clearUserData() {
    currentUser.value = null;
    _cachedUser = null;
    _lastUserDataUpdate = null;
    clearAllNotificationCounts();
    stopNotificationTimer();
    LogUtils.d('$_tag 用户数据已清理');
  }

  // 抓取用户资料
  Future<void> fetchUserProfile() async {
    try {
      isLogining.value = true;
      LogUtils.d('$_tag 开始抓取用户资料');
      final response = await _apiService.get<Map<String, dynamic>>('/user');
      LogUtils.d('$_tag 获取到用户资料响应');

      final user = User.fromJson(response.data!['user']);
      currentUser.value = user;

      // 保存到缓存
      await _saveCachedUserData(user);

      LogUtils.d('$_tag 用户资料解析完成: ${user.name}');
      // 获取到用户资料后启动通知计数定时器
      startNotificationTimer();
    } catch (e) {
      LogUtils.e('抓取用户资料失败', error: e);
      if (e is! UnauthorizedException) {
        throw AuthServiceException(t.errors.failedToOperate);
      }
      rethrow;
    } finally {
      isLogining.value = false;
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

  /// 移除朋友
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

  /// 获取当前的用户信息
  /// /user 
  Future<ApiResult<ProfileUserDto>> fetchProfileUser() async {
    try {
      final response = await _apiService.get(ApiConstants.user);
      return ApiResult.success(data: ProfileUserDto.fromJson(response.data));
    } catch (e) {
      LogUtils.e('获取当前用户信息失败', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  /// 更新用户信息
  /// /user/:userId
  /// @putbody {
  /// 
  ///   // 如果更新黑名单，则给出此参数
  ///   "tagBlacklist": [
  ///     "abigail_williams"
  ///   ]
  /// }
  Future<ApiResult<User>> updateUserProfile(List<String>? tagBlacklist) async {
    if (tagBlacklist != null) {
      try {
        final response = await _apiService.put(ApiConstants.userWithId(currentUser.value?.id ?? ''), data: {
          'tagBlacklist': tagBlacklist,
        });
        return ApiResult.success(data: User.fromJson(response.data));
      } catch (e) {
        LogUtils.e('更新用户信息失败', error: e);
        return ApiResult.fail(t.errors.failedToOperate);
      }
    }
    return ApiResult.fail(t.errors.invalidParameter);
  }


  /// 标记消息已读(单个)
  /// /notifications/:id/read
  Future<ApiResult<void>> markNotificationAsRead(String notificationId) async {
    try {
      await _apiService.post(ApiConstants.userNotificationWithId(notificationId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('标记消息已读失败', error: e);
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  /// 标记消息已读(全部)
  /// /notifications/all/read
  Future<ApiResult<void>> markAllNotificationAsRead() async {
    try {
      await _apiService.post(ApiConstants.userNotificationAllRead);
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('标记消息已读失败', error: e);
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  /// 获取消息 count
  /// /user/counts
  Future<ApiResult<UserNotificationCount>> fetchUserNotificationCount() async {
    try {
      final response = await _apiService.get(ApiConstants.userCounts);
      return ApiResult.success(data: UserNotificationCount.fromJson(response.data));
    } catch (e) {
      LogUtils.e('获取消息 count 失败', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  /// 获取通知信息
  /// /user/:id/notifications
  /// 结构体
  /// {
  ///   /// 必须存在的字段 notNull
  ///   id, // notNull
  ///   type, // notNull 操作，比如 newComment有新的评论，newReply有新的回复
  ///   createdAt, // notNull 创建时间
  ///   updatedAt, // notNull 更新时间
  ///   read, // notNull 是否已读
  ///   
  ///   /// 目前我就找到了这两种情况，所以后面在实现列表渲染时，还要记录报错 （未设计的情况，然后给个提示UI和复制按钮，可以复制该JSON）
  ///   /// 特殊情况1: type: newReply 并且有 comment、vide，此时表示有视频的回复
  ///   /// 特殊情况2: type: newComment 并且有 comment、profile (对应user.model.dart)，此时表示有人在作者详情页给自己发了评论
  /// }
  Future<ApiResult<PageData<Map<String, dynamic>>>> fetchUserNotifications(String userId, {int page = 0, int limit = 20}) async {
    try {
      final response = await _apiService.get(ApiConstants.userNotifications(userId), queryParameters: {
        'page': page,
        'limit': limit,
      });
      final List<Map<String, dynamic>> results = (response.data['results'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      final PageData<Map<String, dynamic>> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );
      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取通知信息失败', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  // 添加处理登出的方法（优化版）
  void handleLogout() {
    LogUtils.d('$_tag 接收到登出通知');
    _clearUserData();
    
    // 清理缓存文件
    _clearCachedUserData();

    LogUtils.d('$_tag 用户服务状态已清理');
  }

  // 加载缓存的用户数据
  Future<void> _loadCachedUserData() async {
    try {
      final cachedUserJson = await _storage.readSecureData('cached_user_data');
      final lastUpdateStr = await _storage.readSecureData('cached_user_data_timestamp');

      if (cachedUserJson != null && lastUpdateStr != null) {
        final lastUpdate = DateTime.tryParse(lastUpdateStr);
        if (lastUpdate != null) {
          _lastUserDataUpdate = lastUpdate;

          // 检查缓存是否还有效
          final now = DateTime.now();
          final cacheAge = now.difference(lastUpdate);

          if (cacheAge <= _cacheValidDuration) {
            final userMap = jsonDecode(cachedUserJson) as Map<String, dynamic>;
            _cachedUser = User.fromJson(userMap);
            currentUser.value = _cachedUser;

            LogUtils.d('$_tag 成功加载缓存的用户数据，缓存年龄: ${cacheAge.inMinutes}分钟');

            // 启动通知计数定时器
            startNotificationTimer();
            return;
          } else {
            LogUtils.d('$_tag 缓存的用户数据已过期，缓存年龄: ${cacheAge.inHours}小时');
          }
        }
      }

      LogUtils.d('$_tag 没有有效的缓存用户数据');
    } catch (e) {
      LogUtils.e('$_tag 加载缓存用户数据失败', error: e);
    }
  }

  // 保存用户数据到缓存
  Future<void> _saveCachedUserData(User user) async {
    try {
      _cachedUser = user;
      _lastUserDataUpdate = DateTime.now();

      final userJson = jsonEncode(user.toJson());
      await _storage.writeSecureData('cached_user_data', userJson);
      await _storage.writeSecureData('cached_user_data_timestamp', _lastUserDataUpdate!.toIso8601String());

      LogUtils.d('$_tag 用户数据已缓存');
    } catch (e) {
      LogUtils.e('$_tag 缓存用户数据失败', error: e);
    }
  }

  // 清理缓存的用户数据
  Future<void> _clearCachedUserData() async {
    try {
      await _storage.deleteSecureData('cached_user_data');
      await _storage.deleteSecureData('cached_user_data_timestamp');
      LogUtils.d('$_tag 缓存用户数据已清理');
    } catch (e) {
      LogUtils.e('$_tag 清理缓存用户数据失败', error: e);
    }
  }

  // 后台异步刷新用户数据
  void _refreshUserDataInBackground() {
    Future.microtask(() async {
      if (_authService.hasToken) {
        try {
          LogUtils.d('$_tag 开始后台刷新用户数据');
          await _fetchUserProfileSilently();
        } catch (e) {
          LogUtils.w('$_tag 后台刷新用户数据失败: $e');
          // 网络错误时不清理现有的用户数据和token
        }
      }
    });
  }

  // 静默获取用户资料（不影响UI状态）
  Future<void> _fetchUserProfileSilently() async {
    try {
      LogUtils.d('$_tag 开始静默抓取用户资料');
      final response = await _apiService.get<Map<String, dynamic>>('/user');
      LogUtils.d('$_tag 静默获取到用户资料响应');

      final user = User.fromJson(response.data!['user']);
      currentUser.value = user;

      // 保存到缓存
      await _saveCachedUserData(user);

      LogUtils.d('$_tag 用户资料静默更新完成: ${user.name}');

      // 获取到用户资料后启动通知计数定时器
      startNotificationTimer();
    } catch (e) {
      LogUtils.e('$_tag 静默抓取用户资料失败', error: e);
      // 这里不抛出异常，避免影响启动流程
      // 如果是认证错误，让API拦截器处理
      rethrow;
    }
  }
}
