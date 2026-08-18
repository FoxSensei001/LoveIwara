import 'package:get/get.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/loading_more_refresh_guard.dart';

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
          .fetchImageModelsByParams(
            page: tempPage,
            limit: 20,
            params: {'sort': sort.value, 'rating': 'all', 'user': userId.value},
          );

      LogUtils.d(
        '[图片搜索controller] 查询参数: userId: ${userId.value}, sort: ${sort.value}, page: $tempPage',
      );

      if (!response.isSuccess) {
        showToastWidget(
          MDToastWidget(message: response.message, type: MDToastType.error),
          position: ToastPosition.bottom,
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

class UserzImageModelListRepository extends LoadingMoreBase<ImageModel>
    with LoadingMoreRefreshGuard<ImageModel> {
  final GalleryService _imageModelService = Get.find<GalleryService>();
  final String userId;
  final String sortType; // 使用 sortType 避免命名冲突
  final Function({int? count})? onFetchFinished;

  UserzImageModelListRepository({
    required this.userId,
    required this.sortType,
    this.onFetchFinished,
  });

  int _pageIndex = 0;

  bool _hasMore = true;
  bool forceRefresh = false;

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  void resetPagingState() {
    super.resetPagingState(); // 代际自增，作废在途回写
    _hasMore = true;
    _pageIndex = 0;
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    return runGuardedRefresh(() async {
      forceRefresh = !notifyStateChanged;
      try {
        return await super.refresh(notifyStateChanged);
      } finally {
        forceRefresh = false;
      }
    });
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    // 代际 + 页码快照必须在 await 之前取：await 期间可能发生 refresh()，
    // 那样回来的第 N 页会被当成第 0 页写进列表，页码也跟着错位。
    final int generation = currentGeneration;
    final int page = _pageIndex;
    try {
      final response = await _imageModelService.fetchImageModelsByParams(
        page: page,
        limit: 20,
        params: {'sort': sortType, 'rating': 'all', 'user': userId},
      );

      LogUtils.d(
        '[图片列表Repository] 查询参数: userId: $userId, sort: $sortType, page: $page',
      );

      if (!response.isSuccess) {
        throw Exception(response.message);
      }

      final images = response.data!.results;

      // await 期间已被 refresh() 作废 → 丢弃本次结果。必须返回 true：
      // 返回 false 会被 loading_more_list 映射成一个假的错误页。
      if (isStaleGeneration(generation)) {
        return true;
      }

      if (page == 0) {
        clear();
        onFetchFinished?.call(count: response.data!.count);
      }

      for (final image in images) {
        add(image);
      }

      _hasMore = images.isNotEmpty;
      _pageIndex = page + 1;
      isSuccess = true;
    } catch (exception, stack) {
      if (isStaleGeneration(generation)) {
        return true;
      }
      isSuccess = false;
      LogUtils.e('加载图片列表失败', error: exception, stack: stack);
    }
    return isSuccess;
  }
}
