import 'package:flutter/material.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/my_gallery_photo_view_wrapper.dart';
import 'package:i_iwara/common/gallery_image_quality.dart';

Future<T?> pushPhotoViewWrapperOverlay<T>({
  required BuildContext context,
  required List<ImageItem> imageItems,
  required int initialIndex,
  required List<MenuItem> Function(BuildContext, ImageItem) menuItemsBuilder,
  Object? Function(ImageItem item)? heroTagBuilder,
  List<ImageItem>? standardImageItems,
  List<ImageItem>? originalImageItems,
  String initialQuality = galleryImageQualityStandard,
  ValueChanged<String>? onQualityChanged,
  bool enableMenu = true,
}) {
  if (!context.mounted) {
    return Future<T?>.value(null);
  }

  final extra = PhotoViewExtra(
    imageItems: imageItems,
    initialIndex: initialIndex,
    menuItemsBuilder: menuItemsBuilder,
    enableMenu: enableMenu,
    heroTagBuilder: heroTagBuilder,
    standardImageItems: standardImageItems,
    originalImageItems: originalImageItems,
    initialQuality: initialQuality,
    onQualityChanged: onQualityChanged,
  );

  // If triggered from a dialog/bottom sheet (PopupRoute), pushing via GoRouter
  // would update the page stack *under* the popup route, which looks like
  // "nothing happened". Use an imperative push so the viewer appears above.
  final currentRoute = ModalRoute.of(context);
  if (currentRoute is PopupRoute) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _buildPhotoViewWrapperOverlayChild(extra),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  return appRouter.push<T>('/photo_view_wrapper', extra: extra);
}

Widget _buildPhotoViewWrapperOverlayChild(PhotoViewExtra extra) {
  final normalizedInitialQuality = normalizeGalleryImageQuality(
    extra.initialQuality,
  );

  try {
    return Function.apply(MyGalleryPhotoViewWrapper.new, const [], {
          #galleryItems: extra.imageItems,
          #initialIndex: extra.initialIndex,
          #menuItemsBuilder: extra.menuItemsBuilder,
          #enableMenu: extra.enableMenu,
          #heroTagBuilder: extra.heroTagBuilder,
          #standardImageItems: extra.standardImageItems,
          #originalImageItems: extra.originalImageItems,
          #initialQuality: normalizedInitialQuality,
          #onQualityChanged: extra.onQualityChanged,
        })
        as Widget;
  } on NoSuchMethodError {
    return MyGalleryPhotoViewWrapper(
      galleryItems: extra.imageItems,
      initialIndex: extra.initialIndex,
      menuItemsBuilder: extra.menuItemsBuilder,
      enableMenu: extra.enableMenu,
      heroTagBuilder: extra.heroTagBuilder,
    );
  } on ArgumentError {
    return MyGalleryPhotoViewWrapper(
      galleryItems: extra.imageItems,
      initialIndex: extra.initialIndex,
      menuItemsBuilder: extra.menuItemsBuilder,
      enableMenu: extra.enableMenu,
      heroTagBuilder: extra.heroTagBuilder,
    );
  }
}
