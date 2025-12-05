import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import '../../../../../models/user.model.dart';

class LikeAvatarsWidget extends StatefulWidget {
  final String mediaId;
  final MediaType mediaType;

  const LikeAvatarsWidget(
      {super.key, required this.mediaId, required this.mediaType});

  @override
  State<LikeAvatarsWidget> createState() => _LikeAvatarsWidgetState();
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
        _buildCounter(context),
      ],
    );
  }

  Widget _buildCounter(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    if (count > 1) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _openLikedUsersDialog,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.visibility_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Text(
      '$count',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  double _calculateStackWidth() {
    if (_users.isEmpty) return 40.0;
    return (_users.length - 1) * 20.0 + 40.0;
  }

  Widget _buildAvatarCircle(User user) {
    return AvatarWidget(
        user: user,
        size: 40,
        onTap: () => NaviService.navigateToAuthorProfilePage(user.username));
  }

  Future<void> _openLikedUsersDialog() async {
    if (!mounted) return;
    await Get.dialog(
      _LikedUsersDialog(
        mediaId: widget.mediaId,
        mediaType: widget.mediaType,
        videoService: _videoService,
        galleryService: _galleryService,
        totalCount: count,
      ),
      barrierDismissible: true,
    );
  }
}

class _LikedUsersDialog extends StatefulWidget {
  final String mediaId;
  final MediaType mediaType;
  final VideoService videoService;
  final GalleryService galleryService;
  final int totalCount;

  const _LikedUsersDialog({
    required this.mediaId,
    required this.mediaType,
    required this.videoService,
    required this.galleryService,
    required this.totalCount,
  });

  @override
  State<_LikedUsersDialog> createState() => _LikedUsersDialogState();
}

class _LikedUsersDialogState extends State<_LikedUsersDialog> {
  static const int _limit = 12;

  int _page = 0;
  bool _loading = true;
  String? _error;
  int _total = 0;
  List<User> _users = const [];

  @override
  void initState() {
    super.initState();
    _loadPage(0);
  }

  Future<void> _loadPage(int page) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = switch (widget.mediaType) {
      MediaType.VIDEO => await widget.videoService
          .fetchLikeVideoUsers(widget.mediaId, page: page, limit: _limit),
      MediaType.IMAGE => await widget.galleryService
          .fetchLikeImageUsers(widget.mediaId, page: page, limit: _limit),
    };

    if (!mounted) return;

    if (result.isSuccess) {
      _users = result.data!.results;
      _total = result.data!.count;
      _page = result.data!.page;
    } else {
      _error = result.message;
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalPages = (_total / _limit).ceil().clamp(1, 9999);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = MediaQuery.of(context).size.height * 0.85;
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 760,
              maxHeight: maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(context, colorScheme),
                        const SizedBox(height: 16),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: _loading
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: CircularProgressIndicator.adaptive(),
                                )
                              : _error != null
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Column(
                                        children: [
                                          Text(
                                            _error!,
                                            style: TextStyle(
                                                color: colorScheme.error,
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 12),
                                          FilledButton.tonal(
                                            onPressed: () => _loadPage(_page),
                                            child: Text(slang.t.common.retry),
                                          ),
                                        ],
                                      ),
                                    )
                                  : _users.isEmpty
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 24),
                                          child: Text(slang.t.videoDetail.likeAvatars.noLikesYet),
                                        )
                                      : _buildUserGrid(context),
                        ),
                        const SizedBox(height: 12),
                        _buildPagination(context, totalPages),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.12),
            colorScheme.secondary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.visibility_rounded, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slang.t.videoDetail.likeAvatars.dialogTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slang.t.videoDetail.likeAvatars.dialogDescription,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.totalCount}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
            ),
          ),
          IconButton(
            tooltip: slang.t.videoDetail.likeAvatars.closeTooltip,
            onPressed: () => AppService.tryPop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildUserGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            constraints.maxWidth > 640 ? constraints.maxWidth / 3 - 18 : 240.0;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (int i = 0; i < _users.length; i++)
              Transform.rotate(
                angle: i.isEven ? -0.05 : 0.05,
                child: _buildUserCard(context, _users[i], colorScheme, cardWidth,
                    highlight: Random().nextBool()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, User user,
      ColorScheme colorScheme, double width,
      {bool highlight = false}) {
    return InkWell(
      onTap: () {
        AppService.tryPop();
        NaviService.navigateToAuthorProfilePage(user.username);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: highlight
                ? [
                    colorScheme.primary.withValues(alpha: 0.12),
                    colorScheme.secondary.withValues(alpha: 0.08),
                  ]
                : [
                    colorScheme.surfaceContainerHighest,
                    colorScheme.surface,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarWidget(user: user, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isNotEmpty == true
                            ? user.name
                            : user.username,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).textTheme.bodySmall?.color ??
                                  Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(BuildContext context, int totalPages) {
    final canPrev = _page > 0 && !_loading;
    final canNext = _page < totalPages - 1 && !_loading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          slang.t.videoDetail.likeAvatars.pageInfo(page: _page + 1, totalPages: totalPages, totalCount: _total),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        Row(
          children: [
            IconButton(
              tooltip: slang.t.videoDetail.likeAvatars.prevPage,
              onPressed: canPrev ? () => _loadPage(_page - 1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: slang.t.videoDetail.likeAvatars.nextPage,
              onPressed: canNext ? () => _loadPage(_page + 1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}

