import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';

class LikeButtonWidget extends StatefulWidget {
  final String mediaId;
  final bool? liked;
  final int likeCount;
  final Future<bool> Function(String mediaId) onLike;
  final Future<bool> Function(String mediaId) onUnlike;
  final Function(bool liked)? onLikeChanged;

  const LikeButtonWidget({
    super.key,
    required this.mediaId,
    required this.liked,
    required this.likeCount,
    required this.onLike,
    required this.onUnlike,
    this.onLikeChanged,
  });

  @override
  State<LikeButtonWidget> createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget> {
  bool _isLoading = false;
  late bool? _isLiked;
  late int _likeCount;
  final UserService _userService = Get.find();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.liked;
    _likeCount = widget.likeCount;
  }

  @override
  void didUpdateWidget(LikeButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.liked != widget.liked) {
      _isLiked = widget.liked;
    }
    if (oldWidget.likeCount != widget.likeCount) {
      _likeCount = widget.likeCount;
    }
  }

  Future<void> _handleLikeToggle() async {
    if (_isLoading) return;
    // 如果 liked 为 null，说明正在加载状态，不允许操作
    if (_isLiked == null) return;
    if (!_userService.isLogin) {
      showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error));
      LoginService.showLogin();
      return;
    }

    VibrateUtils.vibrate();

    setState(() {
      _isLoading = true;
    });

    try {
      final bool success = _isLiked!
          ? await widget.onUnlike(widget.mediaId)
          : await widget.onLike(widget.mediaId);

      if (success) {
        setState(() {
          _isLiked = !_isLiked!;
          _likeCount += _isLiked! ? 1 : -1;
        });
        widget.onLikeChanged?.call(_isLiked!);
      }
    } catch (e) {
      // 使用 CommonUtils.parseExceptionMessage 来获取详细的错误信息
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      showToastWidget(
        MDToastWidget(
          message: errorMessage,
          type: MDToastType.error,
        ),
        position: ToastPosition.top,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果 liked 为 null，显示 loading 状态
    final bool isLoadingState = _isLiked == null || _isLoading;

    return TextButton.icon(
      onPressed: isLoadingState ? null : _handleLikeToggle,
      icon: isLoadingState
          ? Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: const Icon(
                Icons.favorite_border,
                color: Colors.grey,
              ),
            )
          : Icon(
              _isLiked! ? Icons.favorite : Icons.favorite_border,
              color: _isLiked! ? Colors.pink : null,
            ),
      label: Text(
        _likeCount.toString(),
        style: TextStyle(
          color: _isLiked == null ? Colors.grey : (_isLiked! ? Colors.pink : null),
        ),
      ),
    );
  }
} 