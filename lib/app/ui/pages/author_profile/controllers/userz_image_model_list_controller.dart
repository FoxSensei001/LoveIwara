import 'package:get/get.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../models/api_result.model.dart';
import '../../../../models/image.model.dart';

class UserzImageModelListController extends GetxController {
  late GalleryService _imageModelService;
  final Function({int? count})? onFetchFinished;

  /// 参数
  final Rxn<String> userId = Rxn<String>();
  final Rxn<String> sort = Rxn<String>();

  final RxInt page = 0.obs;
  final RxInt totalCnts = 0.obs;
  final RxList<ImageModel> imageModels = <ImageModel>[].obs;
  final RxBool isLoading = true.obs;
  var hasMore = true.obs;
  Worker? worker;

  UserzImageModelListController({this.onFetchFinished});

  @override
  void onInit() {
    super.onInit();
    _imageModelService = Get.find<GalleryService>();

    worker = ever(sort, (_) {
      // 当sort变化后，重置分页等参数
      fetchImageModels(refresh: true);
    });
  }

  @override
  void onClose() {
    worker?.dispose();
    super.onClose();
  }

  Future<void> fetchImageModels({bool refresh = false}) async {
    final tempPage = refresh ? 0 : page.value;

    if (!hasMore.value && !refresh) return;

    isLoading(true);
    try {
      ApiResult<PageData<ImageModel>> response = await _imageModelService
          .fetchImageModelsByParams(page: tempPage, limit: 20, params: {
        'sort': sort.value,
        'rating': 'all',
        'user': userId.value,
      });

      LogUtils.d(
          '[图片搜索controller] 查询参数: userId: ${userId.value}, sort: ${sort.value}, page: $tempPage');

      if (!response.isSuccess) {
        showToastWidget(MDToastWidget(message: response.message, type: MDToastType.error));
        return;
      }
      final newImageModels = response.data!.results;

      if (refresh) {
        imageModels.clear();
      }

      imageModels.addAll(newImageModels);
      page.value = tempPage + 1;
      hasMore.value = newImageModels.isNotEmpty;
      onFetchFinished?.call(count: response.data!.count);
    } finally {
      isLoading(false);
    }
  }
}
