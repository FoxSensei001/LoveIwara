// avatar_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/models/user.model.dart';

class AvatarWidget extends StatefulWidget {
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

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isOnline {
    if (widget.user?.seenAt == null) return false;
    final difference = DateTime.now().difference(widget.user!.seenAt!);
    return difference.inMinutes <= 5;
  }

  @override
  Widget build(BuildContext context) {
    final avatar = CachedNetworkImage(
      imageUrl: widget.user?.avatar?.avatarUrl ?? widget.avatarUrl ?? widget.defaultAvatarUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: widget.radius - widget.borderWidth,
        backgroundImage: imageProvider,
      ),
      httpHeaders: widget.headers,
      errorWidget: (context, url, error) => CircleAvatar(
        radius: widget.radius - widget.borderWidth,
        backgroundImage: NetworkImage(widget.defaultAvatarUrl),
        onBackgroundImageError: (exception, stackTrace) => Icon(
          Icons.person,
          size: widget.radius - widget.borderWidth,
        ),
      ),
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: CircleAvatar(
          radius: widget.radius - widget.borderWidth,
          backgroundColor: Colors.white,
        ),
      ),
    );

    Widget avatarWithBorder = widget.user != null
        ? _buildBorderedAvatarFromUser(avatar)
        : _buildBorderedAvatarFromProps(avatar);

    if (_isOnline) {
      return Stack(
        children: [
          avatarWithBorder,
          Positioned(
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => Container(
                width: widget.radius * 0.4,
                height: widget.radius * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(_animation.value),
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
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
    if (widget.user!.premium) {
      return _buildBorderedAvatar(
        avatar,
        LinearGradient(
          colors: [
            Colors.purple.shade200,
            Colors.blue.shade200,
            Colors.pink.shade200,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else if (widget.user!.isAdmin) {
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

    switch (widget.user!.role) {
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
          width: widget.radius * 2,
          height: widget.radius * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: avatar,
          ),
        );
    }
  }

  Widget _buildBorderedAvatarFromProps(Widget avatar) {
    if (widget.isPremium) {
      return _buildBorderedAvatar(
        avatar,
        LinearGradient(
          colors: [
            Colors.purple.shade200,
            Colors.blue.shade200,
            Colors.pink.shade200,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else if (widget.isAdmin) {
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

    switch (widget.role) {
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
          width: widget.radius * 2,
          height: widget.radius * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: avatar,
          ),
        );
    }
  }

  Widget _buildBorderedAvatar(Widget avatar, Gradient gradient) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.borderWidth),
          child: avatar,
        ),
      ),
    );
  }
}
