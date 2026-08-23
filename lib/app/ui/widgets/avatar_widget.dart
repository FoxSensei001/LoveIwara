// avatar_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/models/user.model.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final Map<String, String>? headers;
  final Function()? onTap;
  final User? user;
  final double? size;

  /// 在线绿点距头像外接方框右下角的内缩，默认 0（贴在圆周的 45° 上，
  /// 也就是绝大多数列表里那个位置）。
  ///
  /// **只有把头像塞进一个会裁成圆形的容器时才需要给正值**——例如
  /// header 上的玻璃身份圆钮：液态档的玻璃会按圆形裁掉 child，而 0 内缩时
  /// 绿点整只落在圆外，会被裁没。算法见
  /// [GlassTokens.circleBadgeInset]，调用点用它算出该传多少。
  final double indicatorInset;

  /// 在线绿点直径（含描边）。定位算内缩时要用同一个值。
  static const double onlineIndicatorSize = 12;

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    this.headers = const {'referer': CommonConstants.iwaraBaseUrl},
    this.onTap,
    this.user,
    this.size = 40,
    this.indicatorInset = 0,
  });

  bool get _isOnline {
    if (user?.seenAt == null) return false;
    final difference = DateTime.now().toUtc().difference(user!.seenAt!.toUtc());
    return difference.inMinutes <= 5;
  }

  String get finalAvatarUrl {
    return avatarUrl ??
        user?.avatar?.avatarUrl ??
        CommonConstants.defaultAvatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    // 确定边框颜色
    Color borderColor = Colors.transparent;
    if (user != null) {
      if (user!.role == 'admin' || user!.isAdmin) {
        borderColor = Colors.red;
      } else if (user!.role == 'officer' || user!.role == 'moderator') {
        borderColor = Colors.green.shade400;
      } else if (user!.role == 'limited') {
        borderColor = Colors.grey.shade400;
      }
    }

    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            if (user?.premium == true)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade300,
                      Colors.blue.shade300,
                      Colors.pink.shade300,
                    ],
                  ),
                ),
              ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: user?.premium == true
                      ? Colors.transparent
                      : borderColor,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: finalAvatarUrl,
                  httpHeaders: headers ?? {},
                  fit: BoxFit.cover,
                  memCacheWidth: (size! * 2).toInt(),
                  fadeInDuration: const Duration(milliseconds: 50),
                  placeholderFadeInDuration: const Duration(milliseconds: 0),
                  fadeOutDuration: const Duration(milliseconds: 0),
                  maxWidthDiskCache: 200,
                  maxHeightDiskCache: 200,
                  placeholder: (context, url) => _buildPlaceholder(),
                  errorWidget: (context, url, error) => CachedNetworkImage(
                    imageUrl: CommonConstants.defaultAvatarUrl,
                    httpHeaders: headers ?? {},
                    fit: BoxFit.cover,
                    memCacheWidth: (size! * 2).toInt(),
                    placeholder: (context, url) => _buildPlaceholder(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            if (_isOnline)
              Positioned(
                right: indicatorInset,
                bottom: indicatorInset,
                child: Container(
                  width: onlineIndicatorSize,
                  height: onlineIndicatorSize,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholder() {
    // 必须套 RepaintBoundary：Shimmer 内部每帧调 markNeedsPaint，而本组件自身
    // 没有重绘边界，脏标记会一路上抛到卡片级的 RepaintBoundary
    // （video_card_list_item_widget.dart:196），导致「整张卡片」每帧重新栅格化。
    // 头像是按列表项逐个实例化的，一屏 6~8 张卡即 6~8 个 60fps ticker 同时
    // 脏化整层——列表静止不动时也在持续重绘，直接表现为耗电发热。
    // 加上边界后重绘范围被限制在头像自身的几十个像素内。
    return RepaintBoundary(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }
}
