import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vibration/vibration.dart';
import 'package:shimmer/shimmer.dart';

class LikeButtonWidget extends StatefulWidget {
  final String mediaId;
  final bool liked;
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
  late bool _isLiked;
  late int _likeCount;
  final UserService _userService = Get.find();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.liked;
    _likeCount = widget.likeCount;
  }

  Future<void> _handleLikeToggle() async {
    if (_isLoading) return;
    if (!_userService.isLogin) {
      showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error));
      Get.toNamed(Routes.LOGIN);
      return;
    }

    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: 50);
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bool success = _isLiked 
          ? await widget.onUnlike(widget.mediaId)
          : await widget.onLike(widget.mediaId);

      if (success) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
        widget.onLikeChanged?.call(_isLiked);
      }
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.errorOccurred, 
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
    return TextButton.icon(
      onPressed: _isLoading ? null : _handleLikeToggle,
      icon: _isLoading 
          ? Shimmer.fromColors(
              baseColor: _isLiked ? Colors.pink.shade200 : Colors.grey.shade300,
              highlightColor: _isLiked ? Colors.pink.shade100 : Colors.grey.shade100,
              child: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.pink : null,
              ),
            )
          : Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.pink : null,
            ),
      label: Text(
        _likeCount.toString(),
        style: TextStyle(
          color: _isLiked ? Colors.pink : null,
        ),
      ),
    );
  }
} 