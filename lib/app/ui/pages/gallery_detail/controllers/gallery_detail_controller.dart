import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../../common/enums/media_enums.dart';
import '../../video_detail/controllers/related_media_controller.dart';
class GalleryDetailController extends GetxController {
  final String imageModelId;
  final GalleryService _galleryService = Get.find();
  final HistoryRepository _historyRepository = HistoryRepository();
  bool isInfoInitialized = false;

  GalleryDetailController(this.imageModelId);

  final Rxn<String> errorMessage = Rxn<String>(); // 错误信息
  final Rxn<ImageModel> imageModelInfo = Rxn<ImageModel>(); // 图片模型
  final RxBool isImageModelInfoLoading = true.obs; // 是否正在加载图片模型信息
  final RxBool isCommentSheetVisible = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final RxBool isHoveringHorizontalList = false.obs;

  // 收藏状态
  final RxBool isInAnyFavorite = false.obs; // 图库是否在任何收藏夹中
  // 下载状态
  final RxBool hasAnyDownloadTask = false.obs; // 图库是否已有下载任务

  OtherAuthorzMediasController? otherAuthorzImageModelsController;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchGalleryDetail();
    // 添加历史记录
    try {
      if (imageModelInfo.value != null) {
        // 延迟3秒后再添加历史记录，确保用户真正在浏览内容
        await Future.delayed(const Duration(seconds: 3));
        if (isInfoInitialized) {  // 确保页面还在活跃状态
          ImageModel imageModel = imageModelInfo.value!.copyWith(files: []);
          final historyRecord = HistoryRecord.fromImageModel(imageModel);
          LogUtils.d('添加历史记录: ${historyRecord.toJson()}', 'GalleryDetailController');
          await _historyRepository.addRecordWithCheck(historyRecord);
        }
      }
    } catch (e) {
      LogUtils.e('添加历史记录失败', error: e, tag: 'GalleryDetailController');
    }
  }

  /// 获取图片详情
  Future<void> fetchGalleryDetail() async {
    try {
      isImageModelInfoLoading.value = true;
      errorMessage.value = null;

      // 获取视频基本信息
      ApiResult<ImageModel> res =
          await _galleryService.fetchGalleryDetail(imageModelId);
      if (!res.isSuccess) {
        errorMessage.value = res.message;
        showToastWidget(MDToastWidget(message: res.message, type: MDToastType.error), position: ToastPosition.bottom);
        return;
      }

      otherAuthorzImageModelsController ??= OtherAuthorzMediasController(
        mediaId: imageModelId,
        userId: res.data!.user!.id,
        mediaType: MediaType.IMAGE,
      );
      otherAuthorzImageModelsController?.fetchRelatedMedias();
      imageModelInfo.value = res.data;

      // 检查收藏状态
      checkFavoriteStatus();

      // 检查下载状态
      checkDownloadTaskStatus();

    } finally {
      LogUtils.d('图片详情信息加载完成', 'GalleryDetailController');
      isImageModelInfoLoading.value = false;
      isInfoInitialized = true;
    }
  }

  /// 检查图库的收藏状态
  Future<void> checkFavoriteStatus() async {
    if (imageModelId.isEmpty) return;

    try {
      final userService = Get.find<UserService>();
      // 只在用户已登录时检查状态
      if (!userService.isLogin) {
        isInAnyFavorite.value = false;
        return;
      }

      final favoriteService = Get.find<FavoriteService>();
      final favoriteFolders = await favoriteService.getItemFolders(imageModelId);

      // 检查收藏状态
      isInAnyFavorite.value = favoriteFolders.isNotEmpty;

      LogUtils.d(
        '检查图库收藏状态完成: isInAnyFavorite=${isInAnyFavorite.value}',
        'GalleryDetailController',
      );
    } catch (e) {
      LogUtils.w(
        '检查图库收藏状态失败: $e',
        'GalleryDetailController',
      );
      // 出错时重置状态
      isInAnyFavorite.value = false;
    }
  }

  /// 检查当前图库是否存在下载任务
  Future<void> checkDownloadTaskStatus() async {
    if (imageModelId.isEmpty) return;

    try {
      final hasTask =
          await DownloadService.to.hasAnyGalleryDownloadTask(imageModelId);
      hasAnyDownloadTask.value = hasTask;

      LogUtils.d(
        '检查图库下载状态完成: hasAnyDownloadTask=${hasAnyDownloadTask.value}',
        'GalleryDetailController',
      );
    } catch (e) {
      LogUtils.w(
        '检查图库下载状态失败: $e',
        'GalleryDetailController',
      );
      hasAnyDownloadTask.value = false;
    }
  }

  /// 标记当前图库已有下载任务
  void markGalleryHasDownloadTask() {
    hasAnyDownloadTask.value = true;
    LogUtils.d(
      '标记图库有下载任务: $imageModelId',
      'GalleryDetailController',
    );
  }

  @override
  void onClose() {
    otherAuthorzImageModelsController?.dispose();
    super.onClose();
  }
}
