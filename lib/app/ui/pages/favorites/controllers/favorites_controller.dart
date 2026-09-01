import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/pages/favorites/repositories/favorite_image_repository.dart';
import 'package:i_iwara/app/ui/pages/favorites/repositories/favorite_video_repository.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';

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
          showAppToast(
            result.message,
            type: AppToastType.error,
            position: AppToastPosition.bottom,
          );
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
          showAppToast(
            result.message,
            type: AppToastType.error,
            position: AppToastPosition.bottom,
          );
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
          showAppToast(
            result.message,
            type: AppToastType.error,
            position: AppToastPosition.bottom,
          );
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
          showAppToast(
            result.message,
            type: AppToastType.error,
            position: AppToastPosition.bottom,
          );
        }
      });
    }
  }

  /// 批量取消视频最爱。返回 (成功数, 失败数)。
  ///
  /// 语义与单个取消保持一致：成功的进 [canceledFavoriteVideoIds]，卡片仍留在
  /// 列表里显示「点击恢复最爱」蒙层，所以这是一次可撤销的操作，不需要二次
  /// 确认之外的兜底。
  Future<({int success, int failed})> batchCancelVideoFavorites(
    Iterable<String> videoIds,
  ) {
    return _batchCancel(
      videoIds,
      _videoService.cancelFavoriteVideo,
      canceledFavoriteVideoIds,
    );
  }

  /// 批量取消图库最爱。返回 (成功数, 失败数)。
  Future<({int success, int failed})> batchCancelImageFavorites(
    Iterable<String> imageIds,
  ) {
    return _batchCancel(
      imageIds,
      _galleryService.cancelFavoriteImage,
      canceledFavoriteGalleryIds,
    );
  }

  /// 分批并发地取消最爱。
  ///
  /// 逐个串行在选了几十项时要等到天荒地老，一次性全发又等于对服务端做一次小型
  /// 压测（还容易撞 429），所以按 [_batchChunkSize] 一组滚动发送。
  Future<({int success, int failed})> _batchCancel(
    Iterable<String> ids,
    Future<ApiResult<void>> Function(String id) cancel,
    RxSet<String> canceledIds,
  ) async {
    // 已经处于「已取消」状态的不再重复发请求，直接算成功（幂等）。
    final pending = ids.where((id) => !canceledIds.contains(id)).toList();
    int success = ids.length - pending.length;
    int failed = 0;

    for (int i = 0; i < pending.length; i += _batchChunkSize) {
      final chunk = pending.skip(i).take(_batchChunkSize).toList();
      final results = await Future.wait(chunk.map(cancel));
      for (int j = 0; j < chunk.length; j++) {
        if (results[j].isSuccess) {
          canceledIds.add(chunk[j]);
          success++;
        } else {
          failed++;
        }
      }
    }

    return (success: success, failed: failed);
  }

  static const int _batchChunkSize = 4;

  @override
  void onClose() {
    videoRepository.dispose();
    imageRepository.dispose();
    super.onClose();
  }
}
