import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../../common/constants.dart';
import '../../../../models/api_result.model.dart';
import '../../../../models/user.model.dart';
import '../../../../services/api_service.dart';
import '../../../../services/user_service.dart';
import '../../comment/controllers/comment_controller.dart';

class AuthorProfileController extends GetxController {
  final String username;
  final ApiService _apiService = Get.find();
  final UserService _userService = Get.find();
  late CommentController commentController;

  final RxBool isProfileLoading = RxBool(true);
  final Rxn<Widget> errorWidget = Rxn<Widget>();
  final Rxn<String> authorDescription = Rxn<String>();
  final Rxn<String> headerBackgroundUrl = Rxn<String>();
  final Rxn<User> author = Rxn<User>();
  final RxInt followingCounts = 0.obs;
  final RxInt followerCounts = 0.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final Rxn<int> videoCounts = Rxn<int>();

  // 添加关系状态
  final RxBool isFriendLoading = false.obs;
  final RxBool isFollowLoading = false.obs;
  final RxBool isFriendRequestPending = false.obs;
  final RxBool isCommentSheetVisible = false.obs;
  Worker? worker;

  AuthorProfileController({required this.username});

  @override
  void onInit() {
    super.onInit();

    initFetch();

    worker = ever(_userService.currentUser, (user) {
      if (user != null) {
        fetchRelationshipStatus();
      }
    });
  }

  @override
  void onClose() {
    Get.delete<CommentController>(tag: author.value!.id);
    worker?.dispose();
    super.onClose();
  }

  Future<void> initFetch() async {
    await fetchAuthorDescription();
    fetchFollowingCounts();
    fetchFollowerCounts();
    fetchRelationshipStatus(); // 获取关系状态
  }

  /// 抓取作者详情
  Future<void> fetchAuthorDescription() async {
    try {
      final authorData =
          await _apiService.get(ApiConstants.userProfile(username));
      author.value = User.fromJson(authorData.data['user']);
      commentController = Get.put(
        CommentController(
          id: author.value!.id,
          type: CommentType.profile,
        ),
        tag: author.value!.id,
      );
      authorDescription.value = authorData.data['body'];
      var header = authorData.data['header'];
      headerBackgroundUrl.value =
          CommonConstants.userProfileHeaderUrl(header?['id']);
      LogUtils.d('获取的用户信息: $authorData', 'AuthorProfileController');
    } catch (e) {
      LogUtils.e('抓取作者详情失败', tag: 'AuthorProfileController', error: e);
      errorWidget.value = Center(child: Text(t.errors.errorWhileFetching));
    } finally {
      isProfileLoading.value = false;
    }
  }

  /// 抓取作者粉丝数
  Future<void> fetchFollowerCounts() async {
    if (author.value == null) {
      return;
    }
    String userId = author.value!.id;
    try {
      final followerData = await _apiService
          .get('${ApiConstants.userFollowers(userId)}?limit=1');
      followerCounts.value = followerData.data['count'];
      LogUtils.d(
          '粉丝数: ${followerData.data['count']}', 'AuthorProfileController');
    } catch (e) {
      LogUtils.e('抓取作者粉丝数失败', tag: 'AuthorProfileController', error: e);
    }
  }

  /// 抓取作者关注数
  Future<void> fetchFollowingCounts() async {
    if (author.value == null) {
      return;
    }
    String userId = author.value!.id;
    try {
      final followingData = await _apiService
          .get('${ApiConstants.userFollowing(userId)}?limit=1');
      followingCounts.value = followingData.data['count'];
      LogUtils.d(
          '关注数: ${followingData.data['count']}', 'AuthorProfileController');
    } catch (e) {
      LogUtils.e('抓取作者关注数失败', tag: 'AuthorProfileController', error: e);
    }
  }

  /// 获取当前用户与作者的关系状态
  Future<void> fetchRelationshipStatus() async {
    if (author.value == null || !_userService.isLogin) {
      return;
    }

    String userId = author.value!.id;
    try {
      final response =
          await _apiService.get(ApiConstants.userRelationshipStatus(userId));
      isFriendRequestPending.value = response.data['status'] == 'pending';
    } catch (e) {
      LogUtils.e('获取关系状态失败', tag: 'AuthorProfileController', error: e);
    }
  }

  /// 关注作者
  Future<void> followAuthor() async {
    if (author.value == null) return;
    String userId = author.value!.id;
    try {
      isFollowLoading.value = true;
      ApiResult res = await _userService.followUser(userId);
      if (!res.isSuccess) {
        showToastWidget(MDToastWidget(message: res.message, type: MDToastType.error));
        return;
      }
      final authorData =
          await _apiService.get(ApiConstants.userProfile(username));
      author.value = User.fromJson(authorData.data['user']);
      followingCounts.value += 1;
    } finally {
      isFollowLoading.value = false;
    }
  }

  /// 取消关注作者
  Future<void> unfollowAuthor() async {
    if (author.value == null) return;
    String userId = author.value!.id;
    try {
      isFollowLoading.value = true;
      ApiResult res = await _userService.unfollowUser(userId);
      if (!res.isSuccess) {
        showToastWidget(MDToastWidget(message: res.message, type: MDToastType.error));
        return;
      }
      // 刷新页面
      final authorData =
          await _apiService.get(ApiConstants.userProfile(username));
      author.value = User.fromJson(authorData.data['user']);
      followingCounts.value -= 1;
    } finally {
      isFollowLoading.value = false;
    }
  }

  /// 发送朋友申请
  Future<void> sendFriendRequest() async {
    if (author.value == null) return;
    String userId = author.value!.id;
    try {
      isFriendLoading.value = true;
      ApiResult res = await _userService.addFriend(userId);
      if (!res.isSuccess) {
        showToastWidget(MDToastWidget(message: res.message, type: MDToastType.error));
        return;
      }
      isFriendRequestPending.value = true;
    } finally {
      isFriendLoading.value = false;
    }
  }

  /// 取消朋友申请
  Future<void> cancelFriendRequest() async {
    if (author.value == null) return;
    String userId = author.value!.id;
    try {
      isFriendLoading.value = true;
      ApiResult res = await _userService.removeFriend(userId);
      if (!res.isSuccess) {
        showToastWidget(MDToastWidget(message: res.message, type: MDToastType.error));
        return;
      }
      isFriendRequestPending.value = false;
      // 更新朋友状态
      if (author.value?.friend == true) {
        author.value = author.value?.copyWith(friend: false);
      }
    } finally {
      isFriendLoading.value = false;
    }
  }
}
