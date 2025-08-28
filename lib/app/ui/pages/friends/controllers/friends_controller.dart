import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/friends/repositories/friend_list_repository.dart';
import 'package:i_iwara/app/ui/pages/friends/repositories/friend_request_repository.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';

class FriendsController extends GetxController {
  final UserService _userService = Get.find();

  late FriendListRepository friendRepository;
  late FriendRequestRepository requestRepository;

  final ScrollController friendListScrollController = ScrollController();
  final ScrollController requestListScrollController = ScrollController();

  // 添加加载状态指示器
  final RxBool isLoadingFriends = false.obs;
  final RxBool isLoadingRequests = false.obs;

  @override
  void onInit() {
    super.onInit();
    friendRepository = FriendListRepository();
    requestRepository = FriendRequestRepository();
  }

  // 刷新当前标签页
  Future<void> refreshCurrentTab(int tabIndex) async {
    if (tabIndex == 0) {
      isLoadingFriends.value = true;
      try {
        await friendRepository.refresh();
      } finally {
        isLoadingFriends.value = false;
      }
    } else {
      isLoadingRequests.value = true;
      try {
        await requestRepository.refresh();
      } finally {
        isLoadingRequests.value = false;
      }
    }
  }

  // 删除好友
  Future<void> removeFriend(String userId) async {
    final result = await _userService.removeFriend(userId);
    if (result.isSuccess) {
      friendRepository.refresh();
    } else {
      showToastWidget(
        MDToastWidget(message: result.message, type: MDToastType.error),
        position: ToastPosition.bottom
      );
    }
  }

  // 接受好友请求
  Future<void> acceptFriendRequest(String requestId) async {
    final result = await _userService.acceptFriendRequest(requestId);
    if (result.isSuccess) {
      requestRepository.refresh();
      // 刷新好友列表
      friendRepository.refresh();
    } else {
      showToastWidget(
        MDToastWidget(message: result.message, type: MDToastType.error),
        position: ToastPosition.bottom
      );
    }
  }

  // 拒绝好友请求
  Future<void> rejectFriendRequest(String requestId) async {
    final result = await _userService.rejectFriendRequest(requestId);
    if (result.isSuccess) {
      requestRepository.refresh();
    } else {
      showToastWidget(
        MDToastWidget(message: result.message, type: MDToastType.error),
        position: ToastPosition.bottom
      );
    }
  }

  /// 取消好友请求
  /// requestId 是目标用户的id
  Future<void> cancelFriendRequest(String requestId) async {
    final result = await _userService.cancelFriendRequest(requestId);
    if (result.isSuccess) {
      requestRepository.refresh();
    } else {
      showToastWidget(
        MDToastWidget(message: result.message, type: MDToastType.error),
        position: ToastPosition.bottom
      );
    }
  }

  @override
  void onClose() {
    friendRepository.dispose();
    requestRepository.dispose();
    friendListScrollController.dispose();
    requestListScrollController.dispose();
    super.onClose();
  }
}
