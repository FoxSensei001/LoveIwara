import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';

abstract class BaseMediaRepository<T> extends LoadingMoreBase<T> {
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
  bool forceRefresh = false;

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _pageIndex = 0;
    forceRefresh = !notifyStateChanged;
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  Future<ApiResult<PageData<T>>> fetchData(Map<String, dynamic> params, int page, int limit);

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    try {
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

      if (result.isSuccess && result.data != null) {
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
    } catch (exception, stack) {
      isSuccess = false;
      LogUtils.e('加载数据失败',
          error: exception, stack: stack, tag: runtimeType.toString());
    }
    return isSuccess;
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