import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/follows/repositories/followers_list_repository.dart';
import 'package:i_iwara/app/ui/pages/follows/repositories/following_list_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';

class FollowsController extends GetxController {
  final String userId;
  final bool initIsFollowing;

  FollowsController({
    required this.userId,
    required this.initIsFollowing,
  });

  late FollowingListRepository followingRepository;
  late FollowersListRepository followersRepository;

  final ScrollController followingListScrollController = ScrollController();
  final ScrollController followersListScrollController = ScrollController();

  /// 特别关注是本地列表（UserPreferenceService），没有分页仓库，但同样要
  /// 有自己的滚动控制器来驱动回到顶部浮钮。
  final ScrollController specialFollowsScrollController = ScrollController();

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

  /// 刷新指定 tab。特别关注（index 2）是本地数据，没有可刷新的远端来源。
  Future<void> refreshCurrentTab(int tabIndex) async {
    switch (tabIndex) {
      case 0:
        isLoadingFollowing.value = true;
        try {
          await followingRepository.refresh(true);
        } finally {
          isLoadingFollowing.value = false;
        }
      case 1:
        isLoadingFollowers.value = true;
        try {
          await followersRepository.refresh(true);
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
    specialFollowsScrollController.dispose();
    super.onClose();
  }
} 