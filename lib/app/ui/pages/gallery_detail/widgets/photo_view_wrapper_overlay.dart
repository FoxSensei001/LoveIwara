import 'package:flutter/material.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/my_gallery_photo_view_wrapper.dart';

Future<T?> pushPhotoViewWrapperOverlay<T>({
  required BuildContext context,
  required List<ImageItem> imageItems,
  required int initialIndex,
  required List<MenuItem> Function(BuildContext, ImageItem) menuItemsBuilder,
  Object? Function(ImageItem item)? heroTagBuilder,
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
            MyGalleryPhotoViewWrapper(
              galleryItems: extra.imageItems,
              initialIndex: extra.initialIndex,
              menuItemsBuilder: extra.menuItemsBuilder,
              enableMenu: extra.enableMenu,
              heroTagBuilder: extra.heroTagBuilder,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  return appRouter.push<T>('/photo_view_wrapper', extra: extra);
}
