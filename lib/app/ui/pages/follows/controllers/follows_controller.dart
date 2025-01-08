import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/follows/repositories/followers_list_repository.dart';
import 'package:i_iwara/app/ui/pages/follows/repositories/following_list_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';

class FollowsController extends GetxController {
  final String userId;
  final bool initIsFollowing;
  final UserService _userService = Get.find();

  FollowsController({
    required this.userId,
    required this.initIsFollowing,
  });

  late FollowingListRepository followingRepository;
  late FollowersListRepository followersRepository;

  final ScrollController followingListScrollController = ScrollController();
  final ScrollController followersListScrollController = ScrollController();

  // 加载状态指示器
  final RxBool isLoadingFollowing = false.obs;
  final RxBool isLoadingFollowers = false.obs;

  // 使用Map来跟踪每个用户的关注/取关状态
  final RxMap<String, bool> followingUserIds = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    followingRepository = FollowingListRepository(userId);
    followersRepository = FollowersListRepository(userId);
  }

  // 刷新当前标签页
  Future<void> refreshCurrentTab(int tabIndex) async {
    if (tabIndex == 0) {
      isLoadingFollowing.value = true;
      try {
        await followingRepository.refresh();
      } finally {
        isLoadingFollowing.value = false;
      }
    } else {
      isLoadingFollowers.value = true;
      try {
        await followersRepository.refresh();
      } finally {
        isLoadingFollowers.value = false;
      }
    }
  }

  // 跳转到用户详情页
  void navigateToUserProfile(String username) {
    NaviService.navigateToAuthorProfilePage(username);
  }

  @override
  void onClose() {
    followingRepository.dispose();
    followersRepository.dispose();
    followingListScrollController.dispose();
    followersListScrollController.dispose();
    super.onClose();
  }
} 