import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart'; // Assuming ImageModel path, adjust if necessary
import 'package:i_iwara/app/ui/pages/gallery_detail/controllers/gallery_detail_controller.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/photo_view_wrapper_overlay.dart';
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

      // Prepare Image Items
      ImageItem? coverItem;
      final List<ImageItem> restItems = [];

      for (final file in im.files) {
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

      final List<ImageItem> imageItems = [
        if (coverItem != null) coverItem,
        ...restItems,
      ];

      // Build Constrained Horizontal Image List
      final String? coverFileId = coverItem?.data.id;
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
            heroTagBuilder: (item) =>
                _buildHeroTag(item, coverFileId: coverFileId),
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
    ImageItemData iid = item.data;
    LogUtils.d('点击了图片：${iid.id}', 'GalleryImageScrollerWidget');
    int index = imageItems.indexWhere((element) => element.url == item.url);
    if (index == -1) {
      index = imageItems.indexWhere((element) => element.data.id == iid.id);
    }
    pushPhotoViewWrapperOverlay(
      context: context,
      imageItems: imageItems,
      initialIndex: index,
      menuItemsBuilder: (context, item) => _buildImageMenuItems(context, item),
      heroTagBuilder: (item) =>
          _buildHeroTag(item, coverFileId: _resolveCoverFileId(imageItems)),
    );
  }

  Object? _buildHeroTag(ImageItem item, {required String? coverFileId}) {
    if (item.isVideo) return null;
    if (coverFileId != null && item.data.id == coverFileId) {
      return coverHeroTag;
    }
    return 'gallery:${controller.imageModelId}:${item.data.id}';
  }

  List<MenuItem> _buildImageMenuItems(BuildContext context, ImageItem item) {
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
