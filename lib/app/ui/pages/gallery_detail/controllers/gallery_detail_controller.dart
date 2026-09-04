import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontal_image_list_controller.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/utils/iwara_different_site_recovery.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import '../../../../../common/enums/media_enums.dart';
import '../../video_detail/controllers/related_media_controller.dart';

class GalleryDetailController extends GetxController {
  final String imageModelId;
  final Map<String, dynamic>? extData;
  final GalleryService _galleryService = Get.find();
  final HistoryRepository _historyRepository = HistoryRepository();
  bool isInfoInitialized = false;

  /// 别人已经拉好、交到手上的那份详情（预览弹窗为了摆出整本图本来就走过一趟）。
  ///
  /// 只认一次：用掉就置空，之后的刷新 / 重试照常走网络。⛔ 只能是**详情接口**
  /// 那份 —— 列表接口的 `files` 恒为空、`body` 恒为 null，拿它开局等于把图和描述
  /// 整片抹掉。
  ImageModel? _preloadedDetail;

  GalleryDetailController(
    this.imageModelId, {
    this.extData,
    ImageModel? preloadedDetail,
  }) : _preloadedDetail = preloadedDetail;

  final Rxn<String> errorMessage = Rxn<String>(); // 错误信息
  final Rxn<ImageModel> imageModelInfo = Rxn<ImageModel>(); // 图片模型
  final RxBool isImageModelInfoLoading = true.obs; // 是否正在加载图片模型信息
  final RxBool isCommentSheetVisible = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final RxBool isHoveringHorizontalList = false.obs;

  /// 横向清单的「跟到第几张」把手。
  ///
  /// 大图页盖在这一页之上，用户在里面翻到第几张，就经这只把手把底下的清单滚到
  /// 第几张——退出来落在的正是刚才看的那张，而不是当初点进去的第一张。
  /// 见 [HorizontalImageListController]。
  final HorizontalImageListController imageListController =
      HorizontalImageListController();

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
        if (isInfoInitialized) {
          // 确保页面还在活跃状态
          ImageModel imageModel = imageModelInfo.value!.copyWith(files: []);
          final historyRecord = HistoryRecord.fromImageModel(imageModel);
          LogUtils.d(
            '添加历史记录: ${historyRecord.toJson()}',
            'GalleryDetailController',
          );
          await _historyRepository.addRecordWithCheck(historyRecord);
        }
      }
    } catch (e) {
      LogUtils.e('添加历史记录失败', error: e, tag: 'GalleryDetailController');
    }
  }

  /// 获取图片详情
  /// 在稍后再看里的话，把这条图库标成已看。不在里面就更新 0 行，无副作用。
  void _markWatchLaterOpened() {
    final id = imageModelId;
    if (id.isEmpty) return;
    try {
      WatchLaterService.to.markGalleryOpened(id);
    } catch (e) {
      // 稍后再看是附属能力，它出问题不该影响图库浏览。
      LogUtils.w('标记图库已看失败: $e', 'GalleryDetailController');
    }
  }

  Future<void> fetchGalleryDetail() async {
    try {
      isImageModelInfoLoading.value = true;
      errorMessage.value = null;

      // 手上已经有一份现成的详情就直接用：从预览弹窗点进来时那份刚拉过，
      // 再发一次请求只会让这一页先白一下再显示同样的东西。
      final ImageModel? preloaded = _preloadedDetail;
      if (preloaded != null) {
        _preloadedDetail = null;
        _applyLoadedDetail(preloaded);
        return;
      }

      // 获取视频基本信息
      ApiResult<ImageModel> res = await _galleryService.fetchGalleryDetail(
        imageModelId,
      );
      if (!res.isSuccess) {
        // 跨站资源：切站会退回首页并重建整棵树，本页作废，由 reopen 在新站点重新
        // 开一张干净的详情页，这里直接 return。
        if (await IwaraDifferentSiteRecovery.recover(
          res.exception,
          resourceKey: 'image:$imageModelId',
          reopen: () => NaviService.navigateToGalleryDetailPage(imageModelId),
        )) {
          return;
        }

        errorMessage.value = res.message;
        showAppToast(
          res.message,
          type: AppToastType.error,
          position: AppToastPosition.bottom,
        );
        return;
      }

      IwaraDifferentSiteRecovery.markResolved('image:$imageModelId');

      _applyLoadedDetail(res.data!);
    } finally {
      LogUtils.d('图片详情信息加载完成', 'GalleryDetailController');
      isImageModelInfoLoading.value = false;
      isInfoInitialized = true;
    }
  }

  /// 详情到手之后的那一串收尾。网络拉回来的与预载交过来的走同一条。
  void _applyLoadedDetail(ImageModel imageModel) {
    final String? userId = imageModel.user?.id;
    if (userId != null) {
      otherAuthorzImageModelsController ??= OtherAuthorzMediasController(
        mediaId: imageModelId,
        userId: userId,
        mediaType: MediaType.IMAGE,
      );
      otherAuthorzImageModelsController?.fetchRelatedMedias();
    }
    imageModelInfo.value = imageModel;

    // 图库没有连续进度可言，**打开详情页即算已看**——这是它在稍后再看的
    // 「未看完」筛选里的唯一判据。前台闸门在 WatchLaterService 里。
    _markWatchLaterOpened();

    // 检查收藏状态
    checkFavoriteStatus();

    // 检查下载状态
    checkDownloadTaskStatus();
  }

  /// 检查图库的收藏状态
  Future<void> checkFavoriteStatus() async {
    if (imageModelId.isEmpty) return;

    try {
      final userService = Get.find<UserService>();
      // 只在用户已登录时检查状态
      if (!userService.isAuthenticated) {
        isInAnyFavorite.value = false;
        return;
      }

      final favoriteService = Get.find<FavoriteService>();
      final favoriteFolders = await favoriteService.getItemFolders(
        imageModelId,
      );

      // 检查收藏状态
      isInAnyFavorite.value = favoriteFolders.isNotEmpty;

      LogUtils.d(
        '检查图库收藏状态完成: isInAnyFavorite=${isInAnyFavorite.value}',
        'GalleryDetailController',
      );
    } catch (e) {
      LogUtils.w('检查图库收藏状态失败: $e', 'GalleryDetailController');
      // 出错时重置状态
      isInAnyFavorite.value = false;
    }
  }

  /// 检查当前图库是否存在下载任务
  Future<void> checkDownloadTaskStatus() async {
    if (imageModelId.isEmpty) return;

    try {
      final hasTask = await DownloadService.to.hasAnyGalleryDownloadTask(
        imageModelId,
      );
      hasAnyDownloadTask.value = hasTask;

      LogUtils.d(
        '检查图库下载状态完成: hasAnyDownloadTask=${hasAnyDownloadTask.value}',
        'GalleryDetailController',
      );
    } catch (e) {
      LogUtils.w('检查图库下载状态失败: $e', 'GalleryDetailController');
      hasAnyDownloadTask.value = false;
    }
  }

  /// 标记当前图库已有下载任务
  void markGalleryHasDownloadTask() {
    hasAnyDownloadTask.value = true;
    LogUtils.d('标记图库有下载任务: $imageModelId', 'GalleryDetailController');
  }

  @override
  void onClose() {
    otherAuthorzImageModelsController?.dispose();
    super.onClose();
  }
}
