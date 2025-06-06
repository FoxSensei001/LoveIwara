import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/dto/user_dto.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../../common/enums/media_enums.dart';
import '../../../../models/user.model.dart';
import '../../video_detail/controllers/related_media_controller.dart';
class GalleryDetailController extends GetxController {
  final String imageModelId;
  final GalleryService _galleryService = Get.find();
  final UserPreferenceService _userPreferenceService = Get.find();
  final HistoryRepository _historyRepository = HistoryRepository();
  bool isInfoInitialized = false;

  GalleryDetailController(this.imageModelId);

  final Rxn<String> errorMessage = Rxn<String>(); // 错误信息
  final Rxn<ImageModel> imageModelInfo = Rxn<ImageModel>(); // 图片模型
  final RxBool isImageModelInfoLoading = true.obs; // 是否正在加载图片模型信息
  final RxBool isCommentSheetVisible = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final RxBool isHoveringHorizontalList = false.obs;

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

    } finally {
      LogUtils.d('图片详情信息加载完成', 'GalleryDetailController');
      isImageModelInfoLoading.value = false;
      isInfoInitialized = true;
    }
  }

  @override
  void onClose() {
    otherAuthorzImageModelsController?.dispose();
    super.onClose();
  }
}
