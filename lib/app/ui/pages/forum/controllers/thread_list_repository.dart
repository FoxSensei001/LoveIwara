import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/forum_thread_section_dto.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/common_utils.dart';

/// 线程列表数据源，支持瀑布流和分页模式
class ThreadListRepository extends ExtendedLoadingMoreBase<ForumThreadModel> {
  final ForumService _forumService = Get.find<ForumService>();
  final String categoryId;
  final Function(dynamic name, dynamic description)? updateCategoryName;
  final int maxLength;
  
  ThreadListRepository({required this.categoryId, this.updateCategoryName, this.maxLength = 300});
  
  @override
  bool get hasMore => (super.hasMore && length < maxLength) || forceRefresh;
  
  @override
  Future<Map<String, dynamic>> fetchDataFromSource(Map<String, dynamic> params, int page, int limit) async {
    final result = await _forumService.fetchForumThreads(
      categoryId,
      page: page,
      limit: limit,
    );

    if (!result.isSuccess) {
      // 存储错误消息到当前实例
      lastErrorMessage = result.message;
      throw Exception(result.message);
    }

    final section = result.data?['section'] as ForumThreadSectionDto;
    updateCategoryName?.call(section.name, section.description);
    
    return result.data!;
  }
  
  @override
  Future<List<ForumThreadModel>> loadPageData(int pageKey, int pageSize) async {
    try {
      final params = buildQueryParams(pageKey, pageSize);
      final response = await fetchDataFromSource(params, pageKey, pageSize);

      requestTotalCount = extractTotalCount(response);
      final data = extractDataList(response);

      return data;
    } catch (e, stack) {
      // 存储具体的错误消息
      lastErrorMessage = CommonUtils.parseExceptionMessage(e);
      logError('加载分页数据失败', e, stack);
      rethrow;
    }
  }

  @override
  Map<String, dynamic> buildQueryParams(int page, int limit) {
    return <String, dynamic>{
      'page': page,
      'limit': limit
    };
  }
  
  @override
  List<ForumThreadModel> extractDataList(Map<String, dynamic> response) {
    return response['results'] as List<ForumThreadModel>;
  }
  
  @override
  int extractTotalCount(Map<String, dynamic> response) {
    final threads = response['results'] as List<ForumThreadModel>;
    return response['count'] as int? ?? threads.length;
  }
  
  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e(message, error: error, stack: stackTrace, tag: 'ThreadListRepository');
  }
} 
