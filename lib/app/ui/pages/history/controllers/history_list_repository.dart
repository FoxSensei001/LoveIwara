import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:loading_more_list/loading_more_list.dart';

class HistoryListRepository extends LoadingMoreBase<HistoryRecord> {
  final HistoryRepository _historyRepository;
  final String? itemType;
  String keyword = '';
  DateTimeRange? dateRange;
  
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
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _pageIndex = 0;
    forceRefresh = !notifyStateChanged;
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    try {
      final List<HistoryRecord> records;
      
      if (keyword.isEmpty) {
        records = await _historyRepository.getRecordsByTypeAndTimeRange(
          itemType ?? 'all',
          startDate: dateRange?.start,
          endDate: dateRange?.end != null ? DateTime(
            dateRange!.end.year,
            dateRange!.end.month,
            dateRange!.end.day,
            23,
            59,
            59,
          ) : null,
          limit: _pageSize,
          offset: _pageIndex * _pageSize,
        );
      } else {
        records = await _historyRepository.searchByTitleAndTimeRange(
          keyword,
          itemType: itemType == 'all' ? null : itemType,
          startDate: dateRange?.start,
          endDate: dateRange?.end != null ? DateTime(
            dateRange!.end.year,
            dateRange!.end.month,
            dateRange!.end.day,
            23,
            59,
            59,
          ) : null,
          limit: _pageSize,
          offset: _pageIndex * _pageSize,
        );
      }

      if (_pageIndex == 0) {
        clear();
      }

      addAll(records);
      
      _hasMore = records.length >= _pageSize;
      _pageIndex++;
      isSuccess = true;
    } catch (e) {
      isSuccess = false;
    }
    return isSuccess;
  }
} 