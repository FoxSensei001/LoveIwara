import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart'; // Assuming ImageModel path, adjust if necessary
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/controllers/gallery_detail_controller.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/photo_view_wrapper_overlay.dart';
import 'package:i_iwara/common/gallery_image_quality.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/utils/image_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:shimmer/shimmer.dart';

RectTween _createGalleryCoverRectTween(Rect? begin, Rect? end) {
  return MaterialRectArcTween(begin: begin, end: end);
}

Widget _galleryCoverFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final fromHero = fromHeroContext.widget as Hero;
  final toHero = toHeroContext.widget as Hero;
  final fadeIn = CurvedAnimation(
    parent: animation,
    curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
  );
  return Stack(
    fit: StackFit.expand,
    children: [
      FadeTransition(opacity: ReverseAnimation(fadeIn), child: fromHero.child),
      FadeTransition(opacity: fadeIn, child: toHero.child),
    ],
  );
}

class GalleryImageScrollerWidget extends StatelessWidget {
  final GalleryDetailController controller;
  final double maxHeight; // Max height constraint for the image area
  final String coverHeroTag;
  final int? initialImageCount;

  const GalleryImageScrollerWidget({
    super.key,
    required this.controller,
    required this.maxHeight,
    required this.coverHeroTag,
    this.initialImageCount,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    return Obx(() {
      // Display Error if exists
      if (controller.errorMessage.value != null) {
        return SizedBox(
          height: maxHeight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                controller.errorMessage.value ??
                    t.errors.errorWhileLoadingGallery,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      // Handle Loading and Empty States
      ImageModel? im = controller.imageModelInfo.value;
      if (im == null || im.files.isEmpty) {
        return SizedBox(
          height: maxHeight,
          child: controller.isImageModelInfoLoading.value
              ? MouseRegion(
                  onEnter: (_) =>
                      controller.isHoveringHorizontalList.value = true,
                  onExit: (_) =>
                      controller.isHoveringHorizontalList.value = false,
                  child: _GalleryHorizontalListSkeleton(
                    height: maxHeight,
                    coverHeroTag: coverHeroTag,
                    itemCount: _resolveSkeletonItemCount(
                      initialImageCount: initialImageCount,
                    ),
                    reduceMotion: reduceMotion,
                  ),
                )
              : Center(
                  child: MyEmptyWidget(
                    message: t.errors.howCouldThereBeNoDataItCantBePossible,
                  ),
                ),
        );
      }

      final List<ImageItem> imageItems = buildGalleryImageItems(im);

      // Build Constrained Horizontal Image List
      final String? coverFileId = _resolveCoverFileId(imageItems);
      final BorderRadius radius8 = BorderRadius.circular(8);
      final BorderRadius coverRadius = BorderRadius.circular(14);
      bool isCoverItem(ImageItem item) =>
          coverFileId != null && item.data.id == coverFileId;

      return SizedBox(
        height: maxHeight,
        child: MouseRegion(
          onEnter: (_) => controller.isHoveringHorizontalList.value = true,
          onExit: (_) => controller.isHoveringHorizontalList.value = false,
          child: HorizontalImageList(
            images: imageItems,
            defaultAspectRatio: 16 / 9,
            onItemTap: (item) => _onImageTap(context, item, imageItems),
            heroTagBuilder: (item) => galleryImageHeroTag(
              item,
              coverFileId: coverFileId,
              imageModelId: controller.imageModelId,
              coverHeroTag: coverHeroTag,
            ),
            heroCreateRectTween: _createGalleryCoverRectTween,
            heroFlightShuttleBuilder: _galleryCoverFlightShuttleBuilder,
            heroTransitionOnUserGestures: true,
            clipBorderRadius: BorderRadius.zero,
            itemBorderRadiusBuilder: (item) =>
                isCoverItem(item) ? coverRadius : radius8,
            aspectRatioBuilder: (item, defaultAspectRatio, loadedAspectRatio) =>
                loadedAspectRatio ?? defaultAspectRatio,
            menuItemsBuilder: (context, item) =>
                _buildImageMenuItems(context, item),
            listController: controller.imageListController,
          ),
        ),
      );
    });
  }

  // --- Helper methods moved/adapted from ImageModelDetailContent ---

  void _onImageTap(
    BuildContext context,
    ImageItem item,
    List<ImageItem> imageItems,
  ) {
    LogUtils.d('点击了图片：${item.data.id}', 'GalleryImageScrollerWidget');
    int index = imageItems.indexWhere((element) => element.url == item.url);
    if (index == -1) {
      index = imageItems.indexWhere(
        (element) => element.data.id == item.data.id,
      );
    }
    openGalleryImageViewer(
      context,
      imageItems: imageItems,
      index: index,
      imageModelId: controller.imageModelId,
      coverHeroTag: coverHeroTag,
      onIndexChanged: controller.imageListController.revealIndex,
    );
  }

  List<MenuItem> _buildImageMenuItems(BuildContext context, ImageItem item) =>
      buildGalleryImageMenuItems(context, item);
}

/// 这条图库摆出来的那份清单。
///
/// ⛔ **首图会被提到最前**：图库里偶尔混着视频文件，`files` 的第 0 条可能就是
/// 一条视频，而封面（以及 Hero）说的恒是第一张**图**。所以这份清单的顺序不等于
/// `files` 的顺序 —— 跨页说「开到第几张」时必须传文件 id，别传下标
/// （见 [openGalleryImageViewerByFileId]）。
List<ImageItem> buildGalleryImageItems(ImageModel imageModel) {
  ImageItem? coverItem;
  final List<ImageItem> restItems = [];

  for (final file in imageModel.files) {
    final largeUrl = file.getLargeImageUrl();
    final item = ImageItem(
      url: largeUrl,
      data: ImageItemData(
        id: file.id,
        title: file.name,
        url: largeUrl,
        originalUrl: file.getOriginalImageUrl(),
      ),
      headers: {},
    );

    if (coverItem == null && !item.isVideo) {
      coverItem = item;
    } else {
      restItems.add(item);
    }
  }

  return <ImageItem>[?coverItem, ...restItems];
}

/// 这一张在大图页里的 Hero 标签。封面那张用页面给的 [coverHeroTag]，其余的按
/// 「图库 id + 文件 id」拼——横向清单与大图页两边必须算出同一个值。
Object? galleryImageHeroTag(
  ImageItem item, {
  required String? coverFileId,
  required String imageModelId,
  required String coverHeroTag,
}) {
  if (item.isVideo) return null;
  if (coverFileId != null && item.data.id == coverFileId) return coverHeroTag;
  return 'gallery:$imageModelId:${item.data.id}';
}

/// 把 [imageItems] 的第 [index] 张开成大图页。
///
/// 画质三档（标准 / 原图）在这里成型：`standardImageItems` 把每一条的
/// `originalUrl` 换成 large 地址，大图页据此在两份清单之间切。
void openGalleryImageViewer(
  BuildContext context, {
  required List<ImageItem> imageItems,
  required int index,
  required String imageModelId,
  required String coverHeroTag,
  bool instant = false,
  ValueChanged<int>? onIndexChanged,
}) {
  final configService = Get.find<ConfigService>();
  final initialQuality = normalizeGalleryImageQuality(
    configService[ConfigKey.GALLERY_VIEWER_DEFAULT_IMAGE_QUALITY],
  );
  final standardImageItems = imageItems
      .map(
        (imageItem) => ImageItem(
          url: imageItem.url,
          width: imageItem.width,
          height: imageItem.height,
          data: ImageItemData(
            id: imageItem.data.id,
            title: imageItem.data.title,
            url: imageItem.data.url,
            originalUrl: imageItem.data.url,
          ),
          headers: imageItem.headers == null
              ? null
              : Map<String, String>.from(imageItem.headers!),
          mediaType: imageItem.mediaType,
        ),
      )
      .toList();
  final String? coverFileId = _resolveCoverFileId(imageItems);
  pushPhotoViewWrapperOverlay(
    context: context,
    imageItems: imageItems,
    standardImageItems: standardImageItems,
    originalImageItems: imageItems,
    initialQuality: initialQuality,
    onQualityChanged: (quality) {
      final normalizedQuality = normalizeGalleryImageQuality(quality);
      configService[ConfigKey.GALLERY_VIEWER_DEFAULT_IMAGE_QUALITY] =
          normalizedQuality;
    },
    initialIndex: index < 0 ? 0 : index,
    menuItemsBuilder: buildGalleryImageMenuItems,
    instant: instant,
    // 大图页里翻到第几张，底下这条清单就跟到第几张：退出来落在的是刚才看的
    // 那张，不是当初点进去的那张。
    onIndexChanged: onIndexChanged,
    // ⛔ [instant] 那一路**不挂 Hero**：那条路上屏幕已经被一帧「和大图页长得
    // 一模一样」的画面钉住了，底下再飞一段「缩略图长成大图」只会在撤帧那一刻
    // 露出来——用户看到的就是「详情页闪一下、图又展开一次」。
    heroTagBuilder: instant
        ? null
        : (item) => galleryImageHeroTag(
            item,
            coverFileId: coverFileId,
            imageModelId: imageModelId,
            coverHeroTag: coverHeroTag,
          ),
  );
}

/// 直接把 [imageModel] 里 id 为 [fileId] 的那一张开成大图页。
///
/// 给「预览弹窗点了某一张图 / 把它往下拖出来」用：那边手上是文件 id，而详情页
/// 这份清单的下标另有讲究（见 [buildGalleryImageItems]）。找不到就返回 false，
/// 调用方照常只开详情页。
bool openGalleryImageViewerByFileId(
  BuildContext context, {
  required ImageModel imageModel,
  required String imageModelId,
  required String coverHeroTag,
  required String fileId,
  bool instant = false,
  ValueChanged<int>? onIndexChanged,
}) {
  final List<ImageItem> imageItems = buildGalleryImageItems(imageModel);
  final int index = imageItems.indexWhere((item) => item.data.id == fileId);
  if (index < 0) return false;
  // 这条路（预览弹窗直接开大图）落地时清单还停在第 0 张，大图页却已经在第
  // [index] 张上——先播一次种，之后翻页由大图页自己回报。
  onIndexChanged?.call(index);
  openGalleryImageViewer(
    context,
    imageItems: imageItems,
    index: index,
    imageModelId: imageModelId,
    coverHeroTag: coverHeroTag,
    instant: instant,
    onIndexChanged: onIndexChanged,
  );
  return true;
}

List<MenuItem> buildGalleryImageMenuItems(
  BuildContext context,
  ImageItem item,
) {
  final t = slang.Translations.of(context);
  // Assuming ImageUtils and GetPlatform are accessible
  return [
    MenuItem(
      title: t.galleryDetail.copyLink,
      icon: Icons.copy,
      onTap: () => ImageUtils.copyLink(item),
    ),
    MenuItem(
      title: t.galleryDetail.copyImage,
      icon: Icons.copy,
      onTap: () => ImageUtils.copyImage(item),
    ),
    if (GetPlatform.isDesktop)
      MenuItem(
        title: t.galleryDetail.saveAs,
        icon: Icons.download,
        onTap: () => ImageUtils.downloadImageForDesktop(item),
      ),
    MenuItem(
      title: t.galleryDetail.saveToAlbum,
      icon: Icons.save,
      onTap: () => ImageUtils.downloadImageToAppDirectory(item),
    ),
  ];
}

int _resolveSkeletonItemCount({required int? initialImageCount}) {
  const int fallback = 6;
  const int maxItems = 12;
  final resolved = (initialImageCount ?? fallback).clamp(1, maxItems);
  return resolved;
}

String? _resolveCoverFileId(List<ImageItem> imageItems) {
  for (final item in imageItems) {
    if (!item.isVideo) return item.data.id;
  }
  return null;
}

class _GalleryHorizontalListSkeleton extends StatelessWidget {
  final double height;
  final String coverHeroTag;
  final int itemCount;
  final bool reduceMotion;

  const _GalleryHorizontalListSkeleton({
    required this.height,
    required this.coverHeroTag,
    required this.itemCount,
    required this.reduceMotion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.6,
    );
    final highlightColor = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.35,
    );

    Widget skeletonBox() {
      final box = DecoratedBox(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(8),
        ),
      );

      if (reduceMotion) return box;

      return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: box,
      );
    }

    Widget coverItem() {
      final placeholder = skeletonBox();

      return Hero(
        tag: coverHeroTag,
        createRectTween: _createGalleryCoverRectTween,
        flightShuttleBuilder: _galleryCoverFlightShuttleBuilder,
        transitionOnUserGestures: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: placeholder,
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: height,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: index == 0 ? coverItem() : skeletonBox(),
            ),
          ),
        );
      },
    );
  }
}
