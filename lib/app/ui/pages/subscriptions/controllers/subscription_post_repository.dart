import 'package:get/get.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class SubscriptionPostRepository extends ExtendedLoadingMoreBase<PostModel> {
  final PostService _postService = Get.find<PostService>();
  final String userId;
  
  SubscriptionPostRepository({required this.userId});

  @override
  Map<String, dynamic> buildQueryParams(int page, int limit) {
    return <String, dynamic>{
      if (userId.isNotEmpty) 'user': userId,
      if (userId.isEmpty) 'subscribed': true,
    };
  }

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(Map<String, dynamic> params, int page, int limit) async {
    final result = await _postService.fetchPostList(
      params: params,
      page: page,
      limit: limit,
    );
    
    if (result.isSuccess && result.data != null) {
      return {
        'success': true,
        'data': result.data!,
      };
    }
    
    return {
      'success': false,
      'error': result.message,
    };
  }
  
  @override
  List<PostModel> extractDataList(Map<String, dynamic> response) {
    if (response['success'] == true) {
      return response['data'].results as List<PostModel>;
    }
    return [];
  }
  
  @override
  int extractTotalCount(Map<String, dynamic> response) {
    if (response['success'] == true) {
      return response['data'].count as int;
    }
    return 0;
  }
  
  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e(message, error: error, stack: stackTrace, tag: 'SubscriptionPostRepository');
  }
} 