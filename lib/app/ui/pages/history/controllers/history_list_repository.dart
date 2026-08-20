import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 历史记录列表数据源。
///
/// 继承 [ExtendedLoadingMoreBase]（而不是裸的 LoadingMoreBase）才能同时喂
/// 瀑布流与分页两种模式：分页模式走 `loadPageData()` 直接取某一页。
class HistoryListRepository extends ExtendedLoadingMoreBase<HistoryRecord> {
  final HistoryRepository _historyRepository;
  final String? itemType;
  String keyword = '';
  DateTimeRange? dateRange;
  // true: 按更新时间倒序；false: 按创建时间倒序
  bool orderByUpdated = false;

  HistoryListRepository({
    required HistoryRepository historyRepository,
    this.itemType,
  }) : _historyRepository = historyRepository;

  /// 时间区间的结束边界补到当天 23:59:59，否则选到「今天」会漏掉今天的记录。
  DateTime? get _rangeEnd {
    final end = dateRange?.end;
    if (end == null) return null;
    return DateTime(end.year, end.month, end.day, 23, 59, 59);
  }

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final int offset = page * limit;
    List<HistoryRecord> records;

    if (keyword.isEmpty) {
      records = await _historyRepository.getRecordsByTypeAndTimeRange(
        itemType ?? 'all',
        startDate: dateRange?.start,
        endDate: _rangeEnd,
        limit: limit,
        offset: offset,
        orderByUpdated: orderByUpdated,
      );
      // 兜底：极端情况下如果未取到数据且无任何筛选条件，退回到基础查询
      if (records.isEmpty && dateRange == null && itemType == null) {
        records = await _historyRepository.getRecordsByType(
          'all',
          limit: limit,
          offset: offset,
        );
      }
    } else {
      records = await _historyRepository.searchByTitleAndTimeRange(
        keyword,
        itemType: itemType == 'all' ? null : itemType,
        startDate: dateRange?.start,
        endDate: _rangeEnd,
        limit: limit,
        offset: offset,
        orderByUpdated: orderByUpdated,
      );
    }

    final int total = await _historyRepository.countRecordsForList(
      itemType: itemType ?? 'all',
      keyword: keyword,
      startDate: dateRange?.start,
      endDate: _rangeEnd,
    );

    return {'records': records, 'count': total};
  }

  @override
  List<HistoryRecord> extractDataList(Map<String, dynamic> response) =>
      response['records'] as List<HistoryRecord>;

  @override
  int extractTotalCount(Map<String, dynamic> response) =>
      response['count'] as int;

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e(
      '加载历史记录列表失败: $message',
      error: error,
      stack: stackTrace,
      tag: 'HistoryListRepository',
    );
  }
}
