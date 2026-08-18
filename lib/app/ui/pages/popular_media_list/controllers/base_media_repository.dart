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

  /// 分页状态的重置统一交给基类在「等待在途请求落地之后」调用，
  /// 不再在 refresh() 里提前重置（否则会被在途请求的回写覆盖）。
  @override
  void resetPagingState() {
    super.resetPagingState();
    _hasMore = true;
    _pageIndex = 0;
    requestTotalCount = 0;
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

    // 代际 + 页码快照必须在 await 之前取：await 期间可能发生 refresh()，
    // 那样回来的第 N 页会被当成第 0 页写进列表，页码也跟着错位。
    final int generation = currentGeneration;
    final int page = _pageIndex;

    // 整个函数体必须包在 try 里：框架的 _innerloadData 是
    //     isLoading = true;
    //     final isSuccess = await loadData(...);   // ← 没有 try/finally
    //     isLoading = false;
    // 一旦异常逃出 loadData，isLoading 会**永久**停在 true，这个数据源就废了
    // ——之后每次 refresh 都得先在等待循环里空烧满时限，再放弃。
    try {
      final result = await fetchData(params, page, 20);

      // await 期间已被 refresh() 作废 → 丢弃本次结果。
      // 必须返回 true：返回 false 会被 loading_more_list 映射成假的错误页。
      if (isStaleGeneration(generation)) {
        return true;
      }

      if (result.isFail) {
        lastErrorMessage = CommonUtils.parseExceptionMessage(result.exception);
        return false;
      }

      if (result.isSuccess && result.data != null) {
        // clear() 必须放在失败判断「之后」。原先放在前面，导致一次失败的下拉
        // 刷新会先把已有内容清空，用户看到的是空列表 + 错误页。
        if (page == 0) {
          clear();
        }
        requestTotalCount = result.data!.count;
        final items = result.data!.results;
        for (final item in items) {
          add(item);
        }
        _hasMore = items.isNotEmpty;
        _pageIndex = page + 1;
        // 成功即清除历史错误，否则「真的没有数据」会被渲染成过期的错误页。
        lastErrorMessage = null;
        isSuccess = true;
      } else {
        // 原先这里是 `throw result.message;`——把一个 String 直接抛出
        // loadData，正好命中上面说的「异常逃逸」。改为按失败返回。
        lastErrorMessage = result.message;
        return false;
      }
    } catch (e, stack) {
      if (isStaleGeneration(generation)) {
        return true;
      }
      lastErrorMessage = CommonUtils.parseExceptionMessage(e);
      logError('加载数据列表失败', e, stack);
      return false;
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
    final generation = currentGeneration;
    try {
      final params = buildQueryParams(pageKey, pageSize);
      final response = await fetchDataFromSource(params, pageKey, pageSize);

      if (isStaleGeneration(generation)) {
        throw const StalePageLoadException();
      }
      requestTotalCount = extractTotalCount(response);
      return extractDataList(response);
    } catch (e, stack) {
      if (isStaleGeneration(generation)) rethrow;
      lastErrorMessage = CommonUtils.parseExceptionMessage(e);
      logError('加载分页数据失败', e, stack);
      rethrow;
    }
  }

  void updateSearchParams({
    List<String> searchTagIds = const [],
    String searchDate = '',
    String searchRating = '',
    bool refreshImmediately = true,
  }) {
    this.searchTagIds = searchTagIds;
    this.searchDate = searchDate;
    this.searchRating = searchRating;
    if (refreshImmediately) {
      refresh(true);
    }
  }

  void resetState({
    List<String> searchTagIds = const [],
    String searchDate = '',
    String searchRating = '',
  }) {
    updateSearchParams(
      searchTagIds: searchTagIds,
      searchDate: searchDate,
      searchRating: searchRating,
      refreshImmediately: false,
    );
    // 必须走 resetPagingState()（内部会 _generation++ 作废在途回写），
    // 不能直接摸字段：这条路径由「内容源切换」触发
    // （base_media_controller.resetState → popular_media_list_base_page
    // ._resetForContentChange），若不作废代际，第 N 页在途请求落地时
    // 代际没变 → 守卫放行 → 旧筛选条件的结果被追加进刚清空的列表，
    // 页码还会跳到 N+1。这正是 refresh() 路径已经修掉的那个竞态。
    resetPagingState();
    forceRefresh = false;
    clear();
  }
}
