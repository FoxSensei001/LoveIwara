import 'package:get/get.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:loading_more_list/loading_more_list.dart';

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
        showToastWidget(MDToastWidget(message: response.message, type: MDToastType.error), position: ToastPosition.bottom);
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

class UserzImageModelListRepository extends LoadingMoreBase<ImageModel> {
  final GalleryService _imageModelService = Get.find<GalleryService>();
  final String userId;
  final String sortType; // 使用 sortType 避免命名冲突
  final Function({int? count})? onFetchFinished;

  UserzImageModelListRepository({
    required this.userId,
    required this.sortType,
    this.onFetchFinished,
    this.maxLength = 300,
  });

  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;
  final int maxLength;

  @override
  bool get hasMore => (_hasMore && length < maxLength) || forceRefresh;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _pageIndex = 0;
    forceRefresh = !notifyStateChanged;
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    try {
      final response = await _imageModelService.fetchImageModelsByParams(
        page: _pageIndex,
        limit: 20,
        params: {
          'sort': sortType,
          'rating': 'all',
          'user': userId,
        },
      );

      LogUtils.d('[图片列表Repository] 查询参数: userId: $userId, sort: $sortType, page: $_pageIndex');

      if (!response.isSuccess) {
        throw Exception(response.message);
      }

      final images = response.data!.results;

      if (_pageIndex == 0) {
        clear();
        onFetchFinished?.call(count: response.data!.count);
      }

      for (final image in images) {
        add(image);
      }

      _hasMore = images.isNotEmpty;
      _pageIndex++;
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      LogUtils.e('加载图片列表失败', error: exception, stack: stack);
    }
    return isSuccess;
  }
}
