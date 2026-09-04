import 'package:flutter/material.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/common/gallery_image_quality.dart';

Future<T?> pushPhotoViewWrapperOverlay<T>({
  required BuildContext context,
  required List<ImageItem> imageItems,
  required int initialIndex,
  required List<MenuItem> Function(BuildContext, ImageItem) menuItemsBuilder,
  List<ImageItem>? standardImageItems,
  List<ImageItem>? originalImageItems,
  String initialQuality = galleryImageQualityStandard,
  ValueChanged<String>? onQualityChanged,
  ValueChanged<int>? onIndexChanged,
  bool enableMenu = true,
  bool instant = false,
}) {
  if (!context.mounted) {
    return Future<T?>.value(null);
  }

  final extra = PhotoViewExtra(
    imageItems: imageItems,
    initialIndex: initialIndex,
    menuItemsBuilder: menuItemsBuilder,
    enableMenu: enableMenu,
    standardImageItems: standardImageItems,
    originalImageItems: originalImageItems,
    initialQuality: initialQuality,
    onQualityChanged: onQualityChanged,
    onIndexChanged: onIndexChanged,
    instant: instant,
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
        transitionDuration: instant
            ? Duration.zero
            : const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            buildPhotoViewWrapperChild(extra),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  return appRouter.push<T>('/photo_view_wrapper', extra: extra);
}
