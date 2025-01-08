import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../common/constants.dart';
import '../../../../../models/user.model.dart';

class LikeAvatarsWidget extends StatefulWidget {
  final String mediaId;
  final MediaType mediaType;

  const LikeAvatarsWidget(
      {super.key, required this.mediaId, required this.mediaType});

  @override
  _LikeAvatarsWidgetState createState() => _LikeAvatarsWidgetState();
}

class _LikeAvatarsWidgetState extends State<LikeAvatarsWidget> {
  List<User> _users = [];
  bool _isLoading = true;
  int count = 0;

  final GalleryService _galleryService = Get.find();
  final VideoService _videoService = Get.find();

  @override
  void initState() {
    super.initState();
    _fetchLikes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchLikes() async {
    try {
      switch (widget.mediaType) {
        case MediaType.VIDEO:
          final response =
              await _videoService.fetchLikeVideoUsers(widget.mediaId);
          if (response.isSuccess) {
            _users = response.data!.results;
            count = response.data!.count;
          }
          break;
        case MediaType.IMAGE:
          final response =
              await _galleryService.fetchLikeImageUsers(widget.mediaId);
          if (response.isSuccess) {
            _users = response.data!.results;
            count = response.data!.count;
          }
          break;
      }

      if (!mounted) return; // 检查组件是否仍然挂载
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
          height: 40,
          width: _calculateStackWidth(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ...List.generate(_users.length, (index) {
                return Positioned(
                  left: index * 20.0,
                  child: _buildAvatarCircle(_users[index]),
                );
              }),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _calculateStackWidth() {
    return (_users.length - 1) * 20.0 + 40.0;
  }

  Widget _buildAvatarCircle(User user) {
    return AvatarWidget(
        avatarUrl: user.avatar?.avatarUrl,
        defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
        headers: const {'referer': CommonConstants.iwaraBaseUrl},
        radius: 20,
        isPremium: user.premium,
        isAdmin: user.isAdmin,
        onTap: () => NaviService.navigateToAuthorProfilePage(user.username));
  }
}

