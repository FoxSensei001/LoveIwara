import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/loading_more_refresh_guard.dart';

class HistoryListRepository extends LoadingMoreBase<HistoryRecord>
    with LoadingMoreRefreshGuard<HistoryRecord> {
  final HistoryRepository _historyRepository;
  final String? itemType;
  String keyword = '';
  DateTimeRange? dateRange;
  // true: 按更新时间倒序；false: 按创建时间倒序
  bool orderByUpdated = false;

  int _pageIndex = 0;
  static const int _pageSize = 20;
  bool _hasMore = true;
  bool forceRefresh = false;

  HistoryListRepository({
    required HistoryRepository historyRepository,
    this.itemType,
  }) : _historyRepository = historyRepository;

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  void resetPagingState() {
    super.resetPagingState(); // 代际自增，作废在途回写
    _hasMore = true;
    _pageIndex = 0;
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    return runGuardedRefresh(() async {
      forceRefresh = !notifyStateChanged;
      try {
        return await super.refresh(notifyStateChanged);
      } finally {
        forceRefresh = false;
      }
    });
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    // 代际 + 页码快照必须在 await 之前取：await 期间可能发生 refresh()，
    // 那样回来的第 N 页会被当成第 0 页写进列表，页码也跟着错位。
    final int generation = currentGeneration;
    final int page = _pageIndex;
    try {
      List<HistoryRecord> records;

      if (keyword.isEmpty) {
        records = await _historyRepository.getRecordsByTypeAndTimeRange(
          itemType ?? 'all',
          startDate: dateRange?.start,
          endDate: dateRange?.end != null
              ? DateTime(
                  dateRange!.end.year,
                  dateRange!.end.month,
                  dateRange!.end.day,
                  23,
                  59,
                  59,
                )
              : null,
          limit: _pageSize,
          offset: page * _pageSize,
          orderByUpdated: orderByUpdated,
        );
        // 兜底：极端情况下如果未取到数据且无任何筛选条件，退回到基础查询
        if (records.isEmpty && (dateRange == null) && (itemType == null)) {
          records = await _historyRepository.getRecordsByType(
            'all',
            limit: _pageSize,
            offset: page * _pageSize,
          );
        }
      } else {
        records = await _historyRepository.searchByTitleAndTimeRange(
          keyword,
          itemType: itemType == 'all' ? null : itemType,
          startDate: dateRange?.start,
          endDate: dateRange?.end != null
              ? DateTime(
                  dateRange!.end.year,
                  dateRange!.end.month,
                  dateRange!.end.day,
                  23,
                  59,
                  59,
                )
              : null,
          limit: _pageSize,
          offset: page * _pageSize,
          orderByUpdated: orderByUpdated,
        );
      }

      // await 期间已被 refresh() 作废 → 丢弃本次结果。必须返回 true：
      // 返回 false 会被 loading_more_list 映射成一个假的错误页。
      if (isStaleGeneration(generation)) {
        return true;
      }

      if (page == 0) {
        clear();
      }

      addAll(records);

      _hasMore = records.length >= _pageSize;
      _pageIndex = page + 1;
      isSuccess = true;
    } catch (e, stack) {
      if (isStaleGeneration(generation)) {
        return true;
      }
      isSuccess = false;
      LogUtils.e('加载历史记录列表失败', error: e, stack: stack);
    }
    return isSuccess;
  }
}
