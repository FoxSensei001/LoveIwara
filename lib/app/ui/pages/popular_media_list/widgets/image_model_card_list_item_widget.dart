import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/media_card_action_slot.dart';
import 'package:i_iwara/app/ui/widgets/media_card_meta.dart';
import 'package:i_iwara/app/ui/widgets/media_card_action_state.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/content_block_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/blocked_media_card_placeholder.dart';
import 'package:i_iwara/app/ui/widgets/base_card_list_item_widget.dart'
    show BaseTag;
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

class ImageModelCardListItemWidget extends StatefulWidget {
  final ImageModel imageModel;
  final double width;

  /// 是否处于多选模式
  final bool isMultiSelectMode;

  /// 是否被选中（多选模式下使用）
  final bool isSelected;

  /// 选中状态变化回调
  final VoidCallback? onSelect;

  /// 是否禁用内容屏蔽（如作者本人主页内不屏蔽其内容）。
  final bool disableBlock;

  /// 从**哪个池**点进来的（可选）。
  ///
  /// 给了它，图库详情页开局就带着这个池——「接着看」第一眼看到的就是你刚才那份
  /// 列表，而且定位在你点的这一条上（同视频那边的「从哪进来就定位到哪」）。
  ///
  /// 是回调而不是直接传 ref，为的是让调用页**点了才去登记池**：开页就登记等于
  /// 为一次可能不会发生的跳转白建一个池。
  final PlaybackQueueRef? Function(String galleryId)? playbackQueueRefBuilder;

  const ImageModelCardListItemWidget({
    super.key,
    required this.imageModel,
    required this.width,
    this.isMultiSelectMode = false,
    this.isSelected = false,
    this.onSelect,
    this.disableBlock = false,
    this.playbackQueueRefBuilder,
  });

  @override
  State<ImageModelCardListItemWidget> createState() =>
      _ImageModelCardListItemWidgetState();
}

class _ImageModelCardListItemWidgetState
    extends State<ImageModelCardListItemWidget>
    with MediaCardActionState<ImageModelCardListItemWidget> {
  static const double _titleFontSize = 14;
  static const double _titleLineHeight = 1.22;
  static const double _titleHeight = _titleFontSize * _titleLineHeight * 2;

  bool _isHovering = false;
  bool _revealed = false;
  static const Duration _hoverAnimationDuration = Duration(milliseconds: 220);

  @override
  ImageModel get actionGallery => widget.imageModel;
  @override
  String get actionMediaId => widget.imageModel.id;
  @override
  bool get baseLiked => widget.imageModel.liked;
  @override
  int get baseLikeCount => widget.imageModel.numLikes;

  String get _displayTitle {
    final title = widget.imageModel.title.trim();
    if (title.isEmpty) {
      return slang.t.common.noTitle;
    }
    return title;
  }

  Map<String, dynamic> _buildGalleryDetailExtData() => <String, dynamic>{};

  Future<void> _openGalleryDetail({
    ImageModel? preloadedDetail,
    String? initialImageId,
  }) async {
    final extData = _buildGalleryDetailExtData();
    await NaviService.navigateToGalleryDetailPage(
      widget.imageModel.id,
      preloadedDetail: preloadedDetail,
      initialImageId: initialImageId,
      coverUrl: widget.imageModel.thumbnailUrl,
      title: widget.imageModel.title,
      imageCount: widget.imageModel.numImages,
      authorId: widget.imageModel.user?.id,
      authorName: widget.imageModel.user?.name,
      authorUsername: widget.imageModel.user?.username,
      authorAvatarUrl: widget.imageModel.user?.avatar?.avatarUrl,
      authorRole: widget.imageModel.user?.role,
      authorPremium: widget.imageModel.user?.premium,
      extData: extData,
      playbackQueueRef: widget.playbackQueueRefBuilder?.call(
        widget.imageModel.id,
      ),
    );
    if (!mounted) return;
    applyLikePatchFromExtData(extData);
  }

  @override
  Future<void> openMediaDetail() => _openGalleryDetail();

  /// 预览弹窗里点开 / 拖出某一张图：详情页直接开到那张大图，顺手把预览已经拉到
  /// 手的那份详情一起交过去。见 [MediaCardActionState.openGalleryImage]。
  @override
  Future<void> openGalleryImage(ImageModel gallery, String fileId) =>
      _openGalleryDetail(preloadedDetail: gallery, initialImageId: fileId);

  /// 卡片整只起飞，所以 Hero 盒子里不是「整只都是封面」，圆角也是卡片自己的。
  /// 见 [MediaCardActionState.previewHeroBoxIsAllCover]。
  @override
  bool get previewHeroBoxIsAllCover => false;

  @override
  double get previewHeroRadius => 14;

  @override
  Widget build(BuildContext context) {
    if (widget.disableBlock ||
        widget.isMultiSelectMode ||
        !Get.isRegistered<ContentBlockService>()) {
      return _buildCard(context);
    }
    return Obx(() {
      final match = Get.find<ContentBlockService>().check(
        title: widget.imageModel.title,
        authorId: widget.imageModel.user?.id,
      );
      final blocked = match != null && !_revealed;
      // 真实卡片与磨砂遮罩同时常驻，遮罩以淡入淡出 + 缩放过渡显隐，
      // 保证与普通卡片完全等高，同时避免揭示/重新屏蔽时的瞬间硬切。
      return Stack(
        children: [
          IgnorePointer(
            ignoring: blocked,
            child: _buildCard(context, showReblock: match != null && !blocked),
          ),
          Positioned.fill(
            child: BlockedMediaOverlayFade(
              match: match,
              visible: blocked,
              onReveal: () => setState(() => _revealed = true),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCard(BuildContext context, {bool showReblock = false}) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(14);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: _titleFontSize,
      fontWeight: FontWeight.w700,
      height: _titleLineHeight,
    );
    final bool enableHover = !widget.isMultiSelectMode && _isDesktopPlatform();
    final bool showHoverState = enableHover && _isHovering;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        child: MouseRegion(
          onEnter: enableHover
              ? (_) => setState(() => _isHovering = true)
              : null,
          onExit: enableHover
              ? (_) => setState(() => _isHovering = false)
              : null,
          // ⭐ 「卡片 → 预览弹窗」那段 Hero 的起点是**整张卡片**，不是缩略图。
          //
          // 只飞缩略图的话，卡片的轮廓（这张带圆角和投影的白底）原地消失、弹窗
          // 面板凭空出现，读起来是两件事；整只包住之后飞的是「这张卡片变成了
          // 这张面板」。包在投影这一层而不是里面那只 Material 上：不然飞行期间
          // 列表里会留下一圈无主的投影。
          // HeroMode 的开关见 [previewHeroEnabled]。
          child: HeroMode(
            enabled: previewHeroEnabled,
            child: Hero(
              tag: previewHeroTag,
              child: AnimatedContainer(
                duration: _hoverAnimationDuration,
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(
                        alpha: showHoverState ? 0.2 : 0.08,
                      ),
                      blurRadius: showHoverState ? 18 : 8,
                      offset: Offset(0, showHoverState ? 8 : 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: radius,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: radius,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: radius,
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(
                                      alpha: showHoverState ? 0.6 : 0.3,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: radius,
                        onTap:
                            widget.isMultiSelectMode && widget.onSelect != null
                            ? widget.onSelect!
                            : _openGalleryDetail,
                        // 长按 / 右键 → 预览弹窗；三点钮 → 操作菜单（菜单第一条又
                        // 能回到预览）。与视频卡片一致，见
                        // media_preview_dialog.dart 文件头。
                        onSecondaryTap: widget.isMultiSelectMode
                            ? null
                            : openPreview,
                        onLongPress: widget.isMultiSelectMode
                            ? null
                            : openPreview,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Thumbnail(
                              imageModel: widget.imageModel,
                              width: widget.width,
                              isHovering: showHoverState,
                              reblockVisible: showReblock,
                              onReblock: () =>
                                  setState(() => _revealed = false),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: _titleHeight,
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        _displayTitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        strutStyle: const StrutStyle(
                                          fontSize: _titleFontSize,
                                          height: _titleLineHeight,
                                          forceStrutHeight: true,
                                        ),
                                        style: titleStyle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ImageModelCardMetaLine(
                                    imageModel: widget.imageModel,
                                    isLiked: effectiveLiked,
                                    likeCount: effectiveLikeCount,
                                  ),
                                  const SizedBox(height: 8),
                                  MediaCardAuthorLine(
                                    user: widget.imageModel.user,
                                    isMultiSelectMode: widget.isMultiSelectMode,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 三点钮：压在整张卡片的右下角。
                      MediaCardActionSlot(
                        gallery: widget.imageModel,
                        isMultiSelectMode: widget.isMultiSelectMode,
                        likedOverride: effectiveLiked,
                        onLikeChanged: applyLikeToggle,
                        onPreview: openPreview,
                        duration: _hoverAnimationDuration,
                      ),
                      // 多选态：勾选片 + 描边包住**整张卡片**（含标题与作者行），
                      // 而不是只框住缩略图——框到一半读起来像被裁断了。常驻挂载，
                      // 进出选择态两个方向都有淡入淡出。
                      Positioned.fill(
                        child: GlassSelectableOverlay(
                          selectionMode: widget.isMultiSelectMode,
                          selected: widget.isSelected,
                          borderRadius: radius,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isDesktopPlatform() {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }
}

class _Thumbnail extends StatelessWidget {
  final ImageModel imageModel;
  final double width;

  final bool isHovering;
  final bool reblockVisible;
  final VoidCallback onReblock;

  const _Thumbnail({
    required this.imageModel,
    required this.width,
    required this.isHovering,
    required this.reblockVisible,
    required this.onReblock,
  });

  @override
  Widget build(BuildContext context) {
    // 贴在上沿两角的标签（R18 / 统计组）要照着同一个圆角走，所以这里用共享常量。
    const radius = BorderRadius.vertical(
      top: Radius.circular(kMediaCardThumbnailRadius),
    );
    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageModel.thumbnailUrl,
              fit: BoxFit.cover,
              memCacheWidth: (width * 1.5).toInt(),
              fadeInDuration: const Duration(milliseconds: 50),
              placeholderFadeInDuration: const Duration(milliseconds: 0),
              fadeOutDuration: const Duration(milliseconds: 0),
              maxWidthDiskCache: 400,
              maxHeightDiskCache: 400,
              placeholder: _buildPlaceholder,
              errorWidget: (context, url, error) => _buildErrorPlaceholder(),
            ),
            ..._buildTags(context),
            // 播放量 / 评论数聚成一组压在右上角；「重新屏蔽」占同一个槽位，
            // 它出现时这组先收走。
            MediaCardStatsOverlay(
              views: imageModel.numViews,
              comments: imageModel.numComments,
              visible: !reblockVisible,
            ),
            ReblockChip(visible: reblockVisible, onTap: onReblock),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String url) {
    return const SizedBox.expand(
      child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFE0E0E0))),
    );
  }

  Widget _buildErrorPlaceholder() {
    return const SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 32,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTags(BuildContext context) {
    final List<Widget> tags = [];
    tags.add(
      Positioned(
        right: 0,
        bottom: 0,
        child: BaseTag(
          text: CommonUtils.formatFriendlyNumber(imageModel.numImages),
          icon: Icons.image,
          backgroundColor: Colors.black54,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            bottomRight: Radius.circular(4),
          ),
        ),
      ),
    );

    if (imageModel.rating == 'ecchi') {
      tags.add(
        Positioned(
          left: 0,
          bottom: 0,
          child: BaseTag(
            text: 'R18',
            backgroundColor: Colors.red,
            textColor: Theme.of(context).colorScheme.onSecondary,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(6),
              bottomLeft: Radius.zero,
            ),
          ),
        ),
      );
    }

    return tags;
  }
}

class ImageModelCardMetaLine extends StatelessWidget {
  final ImageModel imageModel;
  final bool? isLiked;
  final int? likeCount;

  const ImageModelCardMetaLine({
    super.key,
    required this.imageModel,
    this.isLiked,
    this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    return MediaCardMetaRow(
      isLiked: isLiked ?? imageModel.liked,
      likeCount: likeCount ?? imageModel.numLikes,
      createdAt: imageModel.createdAt,
    );
  }
}
