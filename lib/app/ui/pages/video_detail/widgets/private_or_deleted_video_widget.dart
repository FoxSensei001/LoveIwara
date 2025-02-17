import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';

class PrivateOrDeletedVideoWidget extends StatefulWidget {
  final User? author;
  final bool isPrivate;

  const PrivateOrDeletedVideoWidget({
    super.key,
    this.author,
    required this.isPrivate,
  });

  @override
  State<PrivateOrDeletedVideoWidget> createState() => _PrivateOrDeletedVideoWidgetState();
}

class _PrivateOrDeletedVideoWidgetState extends State<PrivateOrDeletedVideoWidget> {
  final UserService _userService = Get.find();
  bool _isFriendRequestPending = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkRelationshipStatus();
  }

  Future<void> _checkRelationshipStatus() async {
    if (!_userService.isLogin || widget.author == null) return;

    try {
      final response = await Get.find<ApiService>()
          .get(ApiConstants.userRelationshipStatus(widget.author!.id));
      if (mounted) {
        setState(() {
          _isFriendRequestPending = response.data['status'] == 'pending';
        });
      }
    } catch (e) {
      LogUtils.e('获取关系状态失败', tag: 'PrivateVideoWidget', error: e);
    }
  }

  Future<void> _handleFriendRequest() async {
    if (_isLoading || widget.author == null) return;

    setState(() => _isLoading = true);
    try {
      if (_isFriendRequestPending) {
        final result = await _userService.cancelFriendRequest(widget.author!.id);
        if (result.isSuccess) {
          setState(() => _isFriendRequestPending = false);
        } else {
          showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error),position: ToastPosition.top);
        }
      } else {
        final result = await _userService.addFriend(widget.author!.id);
        if (result.isSuccess) {
          setState(() => _isFriendRequestPending = true);
        } else {
          showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error),position: ToastPosition.top);
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            // 作者名称和标签
            if (widget.author != null) AvatarWidget(user: widget.author, size: 70, onTap: () => NaviService.navigateToAuthorProfilePage(widget.author!.username),),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (widget.author != null)
                  buildUserName(context, widget.author!),
                if (widget.author != null && widget.author!.premium)
                  Tooltip(
                    message: t.common.premium,
                    preferBelow: false,
                    child: Icon(
                      Icons.verified,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
            // 用户名
            if (widget.author != null && widget.author!.username.isNotEmpty)
              SelectableText(
                '@${widget.author!.username}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            // 私密视频提示
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!widget.isPrivate) 
                  const Icon(
                    Icons.error_outline,
                    size: 24,
                    color: Colors.grey,
                  ),
                if (!widget.isPrivate) 
                  const SizedBox(width: 8),
                Text(
                  widget.isPrivate ? t.videoDetail.privateVideo : t.errors.notFound,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // 按钮行
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.author != null && _userService.currentUser.value?.id != widget.author!.id) ...[
                    _buildFriendButton(),
                    const SizedBox(width: 16),
                  ],
                  FilledButton.icon(
                    onPressed: () => AppService.tryPop(),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(t.common.back),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendButton() {
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Get.theme.colorScheme.primary.withOpacity(0.3),
        highlightColor: Get.theme.colorScheme.primary.withOpacity(0.6),
        child: FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.person_add),
          label: Text(_isFriendRequestPending ? t.common.cancelFriendRequest : t.common.addFriend),
        ),
      );
    }

    if (widget.author != null && widget.author!.friend) {
      return FilledButton.icon(
        onPressed: () async {
          final result = await _userService.removeFriend(widget.author!.id);
          if (!result.isSuccess) {
            showToastWidget(
              MDToastWidget(message: result.message, type: MDToastType.error),
              position: ToastPosition.top,
            );
          }
        },
        icon: const Icon(Icons.person_remove),
        label: Text(t.common.removeFriend),
      );
    }

    if (_isFriendRequestPending) {
      return FilledButton.icon(
        onPressed: _handleFriendRequest,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.orange,
        ),
        icon: const Icon(Icons.person_remove),
        label: Text(t.common.cancelFriendRequest),
      );
    }

    return FilledButton.icon(
      onPressed: _handleFriendRequest,
      icon: const Icon(Icons.person_add),
      label: Text(t.common.addFriend),
    );
  }
} 