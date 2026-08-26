import 'package:get/get.dart';
import 'package:i_iwara/utils/rx_ever.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';

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

    worker = rxEver(sort, (_) {
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
          .fetchImageModelsByParams(
            page: tempPage,
            limit: 20,
            params: {'sort': sort.value, 'rating': 'all', 'user': userId.value},
          );

      LogUtils.d(
        '[图片搜索controller] 查询参数: userId: ${userId.value}, sort: ${sort.value}, page: $tempPage',
      );

      if (!response.isSuccess) {
        showGlassToast(
          response.message,
          type: GlassToastType.error,
          position: GlassToastPosition.bottom,
        );
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

class UserzImageModelListRepository
    extends ExtendedLoadingMoreBase<ImageModel> {
  final GalleryService _imageModelService = Get.find<GalleryService>();
  final String userId;
  final String sortType; // 使用 sortType 避免命名冲突

  /// 标签筛选（`tags=a,b`，服务端按「同时含有」处理）。
  final List<String> searchTagIds;

  /// 日期筛选，'' / 'YYYY' / 'YYYY-MM'。
  final String searchDate;

  final Function({int? count})? onFetchFinished;

  UserzImageModelListRepository({
    required this.userId,
    required this.sortType,
    this.searchTagIds = const [],
    this.searchDate = '',
    this.onFetchFinished,
  });

  @override
  Map<String, dynamic> buildQueryParams(int page, int limit) => {
    'sort': sortType,
    'rating': 'all',
    'user': userId,
    if (searchTagIds.isNotEmpty) 'tags': searchTagIds.join(','),
    if (searchDate.isNotEmpty) 'date': searchDate,
  };

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final response = await _imageModelService.fetchImageModelsByParams(
      page: page,
      limit: limit,
      params: params,
    );
    LogUtils.d(
      '[图片列表Repository] 查询参数: userId: $userId, sort: $sortType, '
      'tags: ${searchTagIds.join(',')}, date: $searchDate, page: $page',
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message);
    }
    return {'data': response.data!};
  }

  @override
  Future<List<ImageModel>> loadPageData(int pageKey, int pageSize) async {
    final images = await super.loadPageData(pageKey, pageSize);
    if (pageKey == 0) onFetchFinished?.call(count: requestTotalCount);
    return images;
  }

  @override
  List<ImageModel> extractDataList(Map<String, dynamic> response) =>
      (response['data'] as PageData<ImageModel>).results;

  @override
  int extractTotalCount(Map<String, dynamic> response) =>
      (response['data'] as PageData<ImageModel>).count;

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e('加载图片列表失败: $message', error: error, stack: stackTrace);
  }
}
