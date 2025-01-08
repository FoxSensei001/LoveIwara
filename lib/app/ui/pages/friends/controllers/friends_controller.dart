import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/friends/repositories/friend_list_repository.dart';
import 'package:i_iwara/app/ui/pages/friends/repositories/friend_request_repository.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:oktoast/oktoast.dart';
class FriendsController extends GetxController {
  final UserService _userService = Get.find();

  late FriendListRepository friendRepository;
  late FriendRequestRepository requestRepository;

  final ScrollController friendListScrollController = ScrollController();
  final ScrollController requestListScrollController = ScrollController();

  // 用于记录已删除的好友ID
  final RxSet<String> removedFriendIds = <String>{}.obs;

  // 使用Map来跟踪每个用户的加载状态
  final RxMap<String, bool> removingFriendIds = <String, bool>{}.obs;
  final RxMap<String, bool> restoringFriendIds = <String, bool>{}.obs;
  final RxMap<String, bool> acceptingRequestIds = <String, bool>{}.obs;
  final RxMap<String, bool> rejectingRequestIds = <String, bool>{}.obs;
  final RxMap<String, bool> cancelingRequestIds = <String, bool>{}.obs;

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
    if (removingFriendIds[userId] == true) return;
    
    try {
      removingFriendIds[userId] = true;
      // 立即更新UI
      removedFriendIds.add(userId);
      
      // 后台处理API请求
      final result = await _userService.removeFriend(userId);
      if (!result.isSuccess) {
        // 如果失败，恢复状态
        removedFriendIds.remove(userId);
        showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error));
      }
    } finally {
      removingFriendIds.remove(userId);
    }
  }

  // 恢复好友
  Future<void> restoreFriend(String userId) async {
    if (restoringFriendIds[userId] == true) return;
    
    try {
      restoringFriendIds[userId] = true;
      removedFriendIds.remove(userId);
      
      final result = await _userService.addFriend(userId);
      if (!result.isSuccess) {
        removedFriendIds.add(userId);
        showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error));
      }
    } finally {
      restoringFriendIds.remove(userId);
    }
  }

  // 接受好友请求
  Future<void> acceptFriendRequest(String requestId) async {
    if (acceptingRequestIds[requestId] == true) return;
    
    try {
      acceptingRequestIds[requestId] = true;
      final result = await _userService.acceptFriendRequest(requestId);
      if (result.isSuccess) {
        requestRepository.refresh();
        // 刷新好友列表
        friendRepository.refresh();
      } else {
        showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error));
      }
    } finally {
      acceptingRequestIds.remove(requestId);
    }
  }

  // 拒绝好友请求
  Future<void> rejectFriendRequest(String requestId) async {
    if (rejectingRequestIds[requestId] == true) return;
    
    try {
      rejectingRequestIds[requestId] = true;
      final result = await _userService.rejectFriendRequest(requestId);
      if (result.isSuccess) {
        requestRepository.refresh();
      } else {
        showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error));
      }
    } finally {
      rejectingRequestIds.remove(requestId);
    }
  }

  // 取消好友请求
  Future<void> cancelFriendRequest(String requestId) async {
    if (cancelingRequestIds[requestId] == true) return;
    
    try {
      cancelingRequestIds[requestId] = true;
      final result = await _userService.cancelFriendRequest(requestId);
      if (result.isSuccess) {
        requestRepository.refresh();
      } else {
        showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error));
      }
    } finally {
      cancelingRequestIds.remove(requestId);
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
