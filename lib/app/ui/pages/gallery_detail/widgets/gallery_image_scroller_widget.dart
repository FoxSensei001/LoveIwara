import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart'; // Assuming ImageModel path, adjust if necessary
import 'package:i_iwara/app/ui/pages/gallery_detail/controllers/gallery_detail_controller.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/services/app_service.dart'; // Ensure this import is present
import 'package:i_iwara/utils/image_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class GalleryImageScrollerWidget extends StatelessWidget {
 final GalleryDetailController controller;
 final double maxHeight; // Max height constraint for the image area

 const GalleryImageScrollerWidget({
    super.key,
    required this.controller,
    required this.maxHeight,
 });

 @override
 Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      // Display Error if exists
      if (controller.errorMessage.value != null) {
        return SizedBox(
          height: maxHeight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                controller.errorMessage.value ?? t.errors.errorWhileLoadingGallery,
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
            child: Center(
              child: controller.isImageModelInfoLoading.value
                ? const CircularProgressIndicator()
                : MyEmptyWidget(message: t.errors.howCouldThereBeNoDataItCantBePossible) // Try another defined key
            )
         );
      }

      // Prepare Image Items
      List<ImageItem> imageItems = im.files
          .map((e) => ImageItem(
                url: e.getLargeImageUrl(),
                data: ImageItemData(
                  id: e.id,
                  title: e.name,
                  url: e.getLargeImageUrl(),
                  originalUrl: e.getOriginalImageUrl(),
                ),
                headers: {},
              ))
          .toList();

      // Build Constrained Horizontal Image List
      return SizedBox(
        height: maxHeight,
        child: MouseRegion(
          onEnter: (_) => controller.isHoveringHorizontalList.value = true,
          onExit: (_) => controller.isHoveringHorizontalList.value = false,
          child: HorizontalImageList(
            images: imageItems,
            onItemTap: (item) => _onImageTap(context, item, imageItems),
            menuItemsBuilder: (context, item) => _buildImageMenuItems(context, item),
          ),
        ).paddingHorizontal(12), // Apply horizontal padding here
      );
    });
 }

 // --- Helper methods moved/adapted from ImageModelDetailContent ---

 void _onImageTap(BuildContext context, ImageItem item, List<ImageItem> imageItems) {
      ImageItemData iid = item.data;
      LogUtils.d('点击了图片：${iid.id}', 'GalleryImageScrollerWidget');
      int index = imageItems.indexWhere((element) => element.url == item.url);
      if (index == -1) {
          index = imageItems.indexWhere((element) => element.data.id == iid.id);
      }
      // Use the helper NaviService or your actual navigation service
      NaviService.navigateToPhotoViewWrapper(
          imageItems: imageItems,
          initialIndex: index,
          menuItemsBuilder: (context, item) => _buildImageMenuItems(context, item),
      );
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
          if (GetPlatform.isDesktop && !GetPlatform.isWeb)
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