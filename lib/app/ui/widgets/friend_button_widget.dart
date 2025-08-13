import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';

import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/common/constants.dart';

class FriendButtonWidget extends StatefulWidget {
  final User user;
  final Function(User user)? onUserUpdated;

  const FriendButtonWidget({
    super.key,
    required this.user,
    this.onUserUpdated,
  });

  @override
  State<FriendButtonWidget> createState() => _FriendButtonWidgetState();
}

class _FriendButtonWidgetState extends State<FriendButtonWidget> {
  bool _isLoading = true;
  late User _currentUser;
  final UserService _userService = Get.find();
  final ApiService _apiService = Get.find();
  String? _friendStatus;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _fetchFriendStatus();
  }

  Future<void> _fetchFriendStatus() async {
    if (!_userService.isLogin) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _apiService.get(
        ApiConstants.userRelationshipStatus(_currentUser.id),
      );
      if (mounted) {
        setState(() {
          _friendStatus = response.data['status'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _friendStatus = _currentUser.friend ? 'friends' : 'none';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    // 如果是自己，不显示按钮
    if (_userService.currentUser.value?.id == _currentUser.id) {
      return const SizedBox.shrink();
    }

    // 加载状态显示
    if (_isLoading) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text(t.common.loading),
      );
    }

    // 处于待办状态
    if (_friendStatus == 'pending') {
      return ElevatedButton.icon(
        onPressed: () => _handleFriendAction(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
        ),
        icon: const Icon(Icons.person_remove, size: 18),
        label: Text(t.common.cancelFriendRequest),
      );
    }

    // 已是朋友
    if (_friendStatus == 'friends') {
      return ElevatedButton.icon(
        onPressed: () => _handleFriendAction(context),
        icon: const Icon(Icons.person_remove, size: 18),
        label: Text(t.common.removeFriend),
      );
    }

    // 默认状态 - 添加朋友
    return ElevatedButton.icon(
      onPressed: () => _handleFriendAction(context),
      icon: const Icon(Icons.person_add, size: 18),
      label: Text(t.common.addFriend),
    );
  }

  Future<void> _handleFriendAction(BuildContext context) async {
    final t = slang.Translations.of(context);
    
    if (!_userService.isLogin) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.pleaseLoginFirst,
          type: MDToastType.error,
        ),
      );
      LoginService.showLogin();
      return;
    }

    setState(() => _isLoading = true);

    try {
      ApiResult result;
      if (_friendStatus == 'pending' || _friendStatus == 'friends') {
        result = await _userService.removeFriend(_currentUser.id);
      } else {
        result = await _userService.addFriend(_currentUser.id);
      }

      if (result.isSuccess) {
        // 重新获取朋友状态
        await _fetchFriendStatus();
        // 更新用户状态
        _currentUser = _currentUser.copyWith(
          friend: _friendStatus == 'friends',
        );
        widget.onUserUpdated?.call(_currentUser);
      } else {
        showToastWidget(
          MDToastWidget(
            message: result.message,
            type: MDToastType.error,
          ),
          position: ToastPosition.top,
        );
      }
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.failedToOperate,
          type: MDToastType.error,
        ),
        position: ToastPosition.top,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 