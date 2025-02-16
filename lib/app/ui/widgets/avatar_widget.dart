// avatar_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/models/user.model.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final double radius;
  final Map<String, String>? headers;
  final String defaultAvatarUrl;
  final bool isPremium;
  final bool isAdmin;
  final String? role;
  final double borderWidth;
  final Function()? onTap;
  final User? user;

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    this.radius = 20,
    this.headers = const {'referer': CommonConstants.iwaraBaseUrl},
    required this.defaultAvatarUrl,
    this.isPremium = false,
    this.isAdmin = false,
    this.role,
    this.borderWidth = 2.0,
    this.onTap,
    this.user,
  });

  bool get _isOnline {
    if (user?.seenAt == null) return false;
    final difference = DateTime.now().difference(user!.seenAt!);
    return difference.inMinutes <= 5;
  }

  @override
  Widget build(BuildContext context) {
    final avatar = CachedNetworkImage(
      imageUrl: user?.avatar?.avatarUrl ?? avatarUrl ?? defaultAvatarUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius - borderWidth,
        backgroundImage: imageProvider,
      ),
      httpHeaders: headers,
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius - borderWidth,
        backgroundImage: NetworkImage(user?.avatar?.avatarUrl ?? defaultAvatarUrl),
        onBackgroundImageError: (exception, stackTrace) => Icon(
          Icons.person,
          size: radius - borderWidth,
        ),
      ),
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: CircleAvatar(
          radius: radius - borderWidth,
          backgroundColor: Colors.white,
        ),
      ),
    );

    Widget avatarWithBorder = user != null
        ? _buildBorderedAvatarFromUser(avatar)
        : _buildBorderedAvatarFromProps(avatar);

    if (_isOnline) {
      return Stack(
        children: [
          avatarWithBorder,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return avatarWithBorder;
  }

  Widget _buildBorderedAvatarFromUser(Widget avatar) {
    if (user!.premium) {
      return _buildBorderedAvatar(
        avatar,
        LinearGradient(
          colors: [
            Colors.purple.shade300,
            Colors.blue.shade300,
            Colors.pink.shade300,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else if (user!.isAdmin) {
      return _buildBorderedAvatar(
        avatar,
        LinearGradient(
          colors: [
            Colors.red.shade400,
            Colors.orange.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    switch (user!.role) {
      case 'officer':
      case 'moderator':
        return _buildBorderedAvatar(
          avatar,
          LinearGradient(
            colors: [
              Colors.green.shade400,
              Colors.teal.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'limited':
        return _buildBorderedAvatar(
          avatar,
          LinearGradient(
            colors: [
              Colors.grey.shade400,
              Colors.grey.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      default:
        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Padding(
            padding: EdgeInsets.all(borderWidth),
            child: onTap != null
                ? MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onTap,
                      child: avatar,
                    ),
                  )
                : avatar,
          ),
        );
    }
  }

  Widget _buildBorderedAvatarFromProps(Widget avatar) {
    if (isPremium) {
      return _buildBorderedAvatar(
        avatar,
        LinearGradient(
          colors: [
            Colors.purple.shade300,
            Colors.blue.shade300,
            Colors.pink.shade300,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else if (isAdmin) {
      return _buildBorderedAvatar(
        avatar,
        LinearGradient(
          colors: [
            Colors.red.shade400,
            Colors.orange.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    switch (role) {
      case 'officer':
      case 'moderator':
        return _buildBorderedAvatar(
          avatar,
          LinearGradient(
            colors: [
              Colors.green.shade400,
              Colors.teal.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'admin':
        return _buildBorderedAvatar(
          avatar,
          LinearGradient(
            colors: [
              Colors.red.shade400,
              Colors.orange.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'limited':
        return _buildBorderedAvatar(
          avatar,
          LinearGradient(
            colors: [
              Colors.grey.shade400,
              Colors.grey.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      default:
        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Padding(
            padding: EdgeInsets.all(borderWidth),
            child: onTap != null
                ? MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onTap,
                      child: avatar,
                    ),
                  )
                : avatar,
          ),
        );
    }
  }

  Widget _buildBorderedAvatar(Widget avatar, Gradient gradient) {
    final Widget container = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: avatar,
      ),
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: container,
        ),
      );
    }

    return container;
  }
}
