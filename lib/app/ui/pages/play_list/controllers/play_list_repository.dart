import 'package:get/get.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_controller.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class PlayListRepository extends ExtendedLoadingMoreBase<PlaylistModel> {
  final PlayListService _playListService = Get.find<PlayListService>();
  final String userId;

  /// 搜索快照：浏览时加载到的每一页都喂给它，「已加载」范围的搜索就靠这些。
  /// 作者主页的播放列表 tab 没有搜索，不传。
  final PagedSearchController<PlaylistModel>? search;

  PlayListRepository({required this.userId, this.search});

  @override
  void resetPagingState() {
    super.resetPagingState();
    search?.reset();
  }

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final generation = currentGeneration;
    final result = await _playListService.getPlaylists(
      userId: userId,
      page: page,
      limit: limit,
      cancelToken: cancelToken,
    );
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.message);
    }
    if (!isStaleGeneration(generation)) search?.recordLoaded(result.data!);
    return {'data': result.data!};
  }

  @override
  List<PlaylistModel> extractDataList(Map<String, dynamic> response) =>
      (response['data'] as PageData<PlaylistModel>).results;

  @override
  int extractTotalCount(Map<String, dynamic> response) =>
      (response['data'] as PageData<PlaylistModel>).count;

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e(
      '加载播放列表失败: $message',
      error: error,
      stack: stackTrace,
      tag: 'PlayListRepository',
    );
  }
}
