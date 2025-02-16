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

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    this.headers = const {'referer': CommonConstants.iwaraBaseUrl},
    this.onTap,
    this.user,
    this.size = 40,
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
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => CachedNetworkImage(
                    imageUrl: CommonConstants.defaultAvatarUrl,
                    httpHeaders: headers ?? {},
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            if (_isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
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
}
