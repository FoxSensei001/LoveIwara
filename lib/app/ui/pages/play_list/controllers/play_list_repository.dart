import 'package:get/get.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class PlayListRepository extends ExtendedLoadingMoreBase<PlaylistModel> {
  final PlayListService _playListService = Get.find<PlayListService>();
  final String userId;

  PlayListRepository({required this.userId});
  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final result = await _playListService.getPlaylists(
      userId: userId,
      page: page,
      limit: limit,
    );
    if (result.isSuccess && result.data != null) {
      return {'data': result.data!};
    }
    throw Exception(result.message);
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
