import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class SubscriptionVideoRepository extends ExtendedLoadingMoreBase<Video> {
  final VideoService _videoService = Get.find<VideoService>();
  final String userId;
  
  SubscriptionVideoRepository({required this.userId});

  @override
  Map<String, dynamic> buildQueryParams(int page, int limit) {
    return <String, dynamic>{
      if (userId.isNotEmpty) 'user': userId,
      if (userId.isEmpty) 'subscribed': true,
    };
  }

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(Map<String, dynamic> params, int page, int limit) async {
    try {
      final result = await _videoService.fetchVideosByParams(
        params: params,
        page: page,
        limit: limit,
      );
      
      if (result.isSuccess && result.data != null) {
        return {
          'success': true,
          'data': result.data!,
        };
      } else {
        // 存储错误消息到当前实例
        lastErrorMessage = result.message;
        throw Exception(result.message);
      }
    } catch (e) {
      // 存储错误消息到当前实例
      lastErrorMessage = e.toString();
      rethrow; // 重新抛出异常以便被ExtendedLoadingMoreBase捕获
    }
  }
  
  @override
  List<Video> extractDataList(Map<String, dynamic> response) {
    // 由于我们在 fetchDataFromSource 中已经处理了错误情况
    // 这里只会收到成功的响应
    return response['data'].results as List<Video>;
  }
  
  @override
  int extractTotalCount(Map<String, dynamic> response) {
    // 由于我们在 fetchDataFromSource 中已经处理了错误情况
    // 这里只会收到成功的响应
    return response['data'].count as int;
  }
  
  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e(message, error: error, stack: stackTrace, tag: 'SubscriptionVideoRepository');
  }
}