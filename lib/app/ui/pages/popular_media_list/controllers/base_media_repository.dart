import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/common_utils.dart' show CommonUtils;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

abstract class BaseMediaRepository<T> extends ExtendedLoadingMoreBase<T> {
  final String sortId;
  List<String> searchTagIds;
  String searchDate;
  String searchRating;

  BaseMediaRepository({
    required this.sortId,
    this.searchTagIds = const [],
    this.searchDate = '',
    this.searchRating = '',
  });

  int _pageIndex = 0;
  bool _hasMore = true;

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _pageIndex = 0;
    requestTotalCount = 0;
    forceRefresh = !notifyStateChanged;
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  Future<ApiResult<PageData<T>>> fetchData(
    Map<String, dynamic> params,
    int page,
    int limit,
  );

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    final params = <String, dynamic>{
      'sort': sortId,
      'tags': searchTagIds.join(','),
      'date': searchDate,
      'rating': searchRating,
    };

    final result = await fetchData(params, _pageIndex, 20);

    if (_pageIndex == 0) {
      clear();
    }

    if (result.isFail) {
      lastErrorMessage = CommonUtils.parseExceptionMessage(result.exception);
      isSuccess = false;
      return false;
    }

    if (result.isSuccess && result.data != null) {
      requestTotalCount = result.data!.count;
      final items = result.data!.results;
      for (final item in items) {
        add(item);
      }
      _hasMore = items.isNotEmpty;
      _pageIndex++;
      isSuccess = true;
    } else {
      throw result.message;
    }

    return isSuccess;
  }

  // 实现ExtendedLoadingMoreBase接口需要的方法
  @override
  Map<String, dynamic> buildQueryParams(int page, int limit) {
    return <String, dynamic>{
      'sort': sortId,
      'tags': searchTagIds.join(','),
      'date': searchDate,
      'rating': searchRating,
    };
  }

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final result = await fetchData(params, page, limit);

    if (result.isSuccess && result.data != null) {
      return {'success': true, 'data': result.data!};
    }

    // 存储错误消息
    lastErrorMessage = CommonUtils.parseExceptionMessage(result.exception);
    return {'success': false, 'error': result.message};
  }

  @override
  List<T> extractDataList(Map<String, dynamic> response) {
    if (response['success'] == true) {
      return response['data'].results as List<T>;
    }
    // 抛出异常而不是返回空列表，这样错误消息能正确传递
    throw response['error'] ?? slang.t.errors.errorWhileFetching;
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
    LogUtils.e(
      message,
      error: error,
      stack: stackTrace,
      tag: runtimeType.toString(),
    );
  }

  // 用于分页的loadPageData实现
  @override
  Future<List<T>> loadPageData(int pageKey, int pageSize) async {
    try {
      final params = buildQueryParams(pageKey, pageSize);
      final response = await fetchDataFromSource(params, pageKey, pageSize);

      requestTotalCount = extractTotalCount(response);
      return extractDataList(response);
    } catch (e, stack) {
      // 存储错误消息
      lastErrorMessage = CommonUtils.parseExceptionMessage(e);
      logError('加载分页数据失败', e, stack);
      rethrow;
    }
  }

  void updateSearchParams({
    List<String> searchTagIds = const [],
    String searchDate = '',
    String searchRating = '',
  }) {
    this.searchTagIds = searchTagIds;
    this.searchDate = searchDate;
    this.searchRating = searchRating;
    refresh(true);
  }
}
