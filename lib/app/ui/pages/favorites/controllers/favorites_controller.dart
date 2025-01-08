import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/pages/favorites/repositories/favorite_image_repository.dart';
import 'package:i_iwara/app/ui/pages/favorites/repositories/favorite_video_repository.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:oktoast/oktoast.dart';

class FavoritesController extends GetxController {
  late FavoriteVideoRepository videoRepository;
  late FavoriteImageRepository imageRepository;
  final VideoService _videoService = Get.find();
  final GalleryService _galleryService = Get.find();

  // 用于记录已取消最爱的ID
  final RxSet<String> canceledFavoriteVideoIds = <String>{}.obs;
  final RxSet<String> canceledFavoriteGalleryIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    videoRepository = FavoriteVideoRepository();
    imageRepository = FavoriteImageRepository();
  }

  // 处理视频的最爱状态
  void toggleVideoFavorite(Video video) {
    if (canceledFavoriteVideoIds.contains(video.id)) {
      // 立即更新UI
      canceledFavoriteVideoIds.remove(video.id);
      // 后台处理API请求
      _videoService.setFavoriteVideo(video.id).then((result) {
        if (!result.isSuccess) {
          // 如果失败，恢复状态
          canceledFavoriteVideoIds.add(video.id);
          showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error));
        }
      });
    } else {
      // 立即更新UI
      canceledFavoriteVideoIds.add(video.id);
      // 后台处理API请求
      _videoService.cancelFavoriteVideo(video.id).then((result) {
        if (!result.isSuccess) {
          // 如果失败，恢复状态
          canceledFavoriteVideoIds.remove(video.id);
          showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error));
        }
      });
    }
  }

  // 处理图片的最爱状态
  void toggleImageFavorite(ImageModel image) {
    if (canceledFavoriteGalleryIds.contains(image.id)) {
      // 立即更新UI
      canceledFavoriteGalleryIds.remove(image.id);
      // 后台处理API请求
      _galleryService.setFavoriteImage(image.id).then((result) {
        if (!result.isSuccess) {
          // 如果失败，恢复状态
          canceledFavoriteGalleryIds.add(image.id);
          showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error));
        }
      });
    } else {
      // 立即更新UI
      canceledFavoriteGalleryIds.add(image.id);
      // 后台处理API请求
      _galleryService.cancelFavoriteImage(image.id).then((result) {
        if (!result.isSuccess) {
          // 如果失败，恢复状态
          canceledFavoriteGalleryIds.remove(image.id);
          showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error));
        }
      });
    }
  }

  @override
  void onClose() {
    videoRepository.dispose();
    imageRepository.dispose();
    super.onClose();
  }
}
