import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:i_iwara/utils/common_utils.dart';
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
    if (!_userService.isAuthenticated) {
      showAppToast(t.errors.pleaseLoginFirst, type: AppToastType.error);
      LoginService.showLogin();
      return;
    }

    VibrateUtils.vibrate();

    setState(() {
      _isLoading = true;
    });

    // 方向在发请求前定死：请求期间父组件可能经 didUpdateWidget 改写 _isLiked
    // （同一视频的另一个点赞按钮先成功了），回来再取反就会算反。
    final bool wasLiked = _isLiked!;
    try {
      final bool success = wasLiked
          ? await widget.onUnlike(widget.mediaId)
          : await widget.onLike(widget.mediaId);

      if (success) {
        // 请求期间页面可能已退出：本地状态只在还挂着时改，
        // 但点赞已在服务端生效，仍要通知外部同步状态。
        final bool newLiked = !wasLiked;
        if (mounted) {
          setState(() {
            _isLiked = newLiked;
            _likeCount += newLiked ? 1 : -1;
          });
        }
        widget.onLikeChanged?.call(newLiked);
      }
    } catch (e) {
      // 使用 CommonUtils.parseExceptionMessage 来获取详细的错误信息
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      showAppToast(
        errorMessage,
        type: AppToastType.error,
        position: AppToastPosition.top,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              child: const Icon(Icons.favorite_border, color: Colors.grey),
            )
          : Icon(
              _isLiked! ? Icons.favorite : Icons.favorite_border,
              color: _isLiked! ? Colors.pink : null,
            ),
      label: Text(
        _likeCount.toString(),
        style: TextStyle(
          color: _isLiked == null
              ? Colors.grey
              : (_isLiked! ? Colors.pink : null),
        ),
      ),
    );
  }
}
