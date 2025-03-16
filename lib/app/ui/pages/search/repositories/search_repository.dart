import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/search_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 搜索仓库基类，处理搜索查询和分页
abstract class SearchRepository<T> extends ExtendedLoadingMoreBase<T> {
  final SearchService searchService = Get.find<SearchService>();
  final String query;
  final String segment;
  
  SearchRepository({
    required this.query,
    required this.segment,
  });
  
  @override
  Map<String, dynamic> buildQueryParams(int page, int limit) {
    return {
      'query': query,
    };
  }
  
  @override
  Future<Map<String, dynamic>> fetchDataFromSource(Map<String, dynamic> params, int page, int limit) async {
    try {
      ApiResult response = await fetchSearchResults(page, limit, params['query']);
      
      if (response.isSuccess && response.data != null) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': response.message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// 根据搜索类型获取搜索结果
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword);
  
  @override
  List<T> extractDataList(Map<String, dynamic> response) {
    if (response['success'] == true) {
      return response['data'].results as List<T>;
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
    LogUtils.e('SearchRepository($segment): $message', 
      error: error, 
      stack: stackTrace,
      tag: 'SearchRepository'
    );
  }
} 