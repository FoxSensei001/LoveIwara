import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_controller.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 最爱图库列表数据源。继承理由同 [FavoriteVideoRepository]：分页模式需要
/// [ExtendedLoadingMoreBase.loadPageData]。
class FavoriteImageRepository extends ExtendedLoadingMoreBase<ImageModel> {
  final GalleryService _galleryService = Get.find<GalleryService>();

  /// 搜索快照：浏览时加载到的每一页都喂给它，「已加载」范围的搜索就靠这些。
  final PagedSearchController<ImageModel> search;

  FavoriteImageRepository({required this.search});

  @override
  void resetPagingState() {
    super.resetPagingState();
    search.reset();
  }

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final generation = currentGeneration;
    final result = await _galleryService.fetchFavoriteImages(
      page: page,
      limit: limit,
      cancelToken: cancelToken,
    );
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.message);
    }
    if (!isStaleGeneration(generation)) search.recordLoaded(result.data!);
    return {'data': result.data!};
  }

  @override
  List<ImageModel> extractDataList(Map<String, dynamic> response) =>
      (response['data'] as PageData<ImageModel>).results;

  @override
  int extractTotalCount(Map<String, dynamic> response) =>
      (response['data'] as PageData<ImageModel>).count;

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e('加载最爱图库列表失败: $message', error: error, stack: stackTrace);
  }
}
