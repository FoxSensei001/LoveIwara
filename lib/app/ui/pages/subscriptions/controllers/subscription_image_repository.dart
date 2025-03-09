import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class SubscriptionImageRepository extends ExtendedLoadingMoreBase<ImageModel> {
  final GalleryService _galleryService = Get.find<GalleryService>();
  final String userId;

  SubscriptionImageRepository({required this.userId});

  @override
  Map<String, dynamic> buildQueryParams(int page, int limit) {
    return <String, dynamic>{
      if (userId.isNotEmpty) 'user': userId,
      if (userId.isEmpty) 'subscribed': true,
    };
  }

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(Map<String, dynamic> params, int page, int limit) async {
    final result = await _galleryService.fetchImageModelsByParams(
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
  List<ImageModel> extractDataList(Map<String, dynamic> response) {
    if (response['success'] == true) {
      return response['data'].results as List<ImageModel>;
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
    LogUtils.e(message, error: error, stack: stackTrace, tag: 'SubscriptionImageRepository');
  }
} 