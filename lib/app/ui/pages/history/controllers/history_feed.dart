import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 历史页一个 tab 的数据：本地库分页、可就地删改。
///
/// 不再继承 `ExtendedLoadingMoreBase`：那边的翻页按 `page * limit` 算偏移，
/// 列表里就地删掉几条之后，下一页会整段跳过同样多条——所以以前删一条就只能
/// 整表重载（丢滚动位置、闪一下）。这里的偏移就是**已加载的条数**，删了就是
/// 少了，下一页自然接得上。
///
/// 历史是本地 SQLite，查一页亚毫秒级，没有网络那一套取消/重试的必要；
/// 只留代际号防「重载撞上翻页」时旧结果回写。
class HistoryFeed extends ChangeNotifier {
  HistoryFeed({required this.repository, required this.itemType});

  final HistoryRepository repository;

  /// all / video / image / post / thread
  final String itemType;

  static const int pageSize = 40;

  String keyword = '';
  DateTimeRange? dateRange;

  final List<HistoryRecord> items = <HistoryRecord>[];
  bool hasMore = true;
  bool isLoading = false;
  Object? error;

  /// 至少成功加载过一次（区分「还没加载」与「真的是空」）。
  bool loadedOnce = false;

  /// 筛选条件变了但本 tab 不在前台：切过来时再重载，不为看不见的 tab 查库。
  bool stale = true;

  int _generation = 0;
  bool _disposed = false;

  DateTime? get _rangeStart {
    final start = dateRange?.start;
    if (start == null) return null;
    return DateTime(start.year, start.month, start.day);
  }

  /// 结束边界补到当天 23:59:59，否则选到「今天」会漏掉今天的记录。
  DateTime? get _rangeEnd {
    final end = dateRange?.end;
    if (end == null) return null;
    return DateTime(end.year, end.month, end.day, 23, 59, 59);
  }

  Future<List<HistoryRecord>> _fetch(int offset, int limit) =>
      repository.listRecords(
        itemType: itemType,
        keyword: keyword,
        startDate: _rangeStart,
        endDate: _rangeEnd,
        limit: limit,
        offset: offset,
      );

  /// 从头重载。[keepExtent]：至少取回当前已加载的条数——从详情页回来刷新
  /// 「最后浏览」顺序时，列表长度不缩，滚动位置不会被截断。
  Future<void> reload({bool keepExtent = false}) async {
    final gen = ++_generation;
    final limit = keepExtent ? math.max(items.length, pageSize) : pageSize;
    stale = false;
    isLoading = true;
    error = null;
    _notify();
    try {
      final rows = await _fetch(0, limit);
      if (gen != _generation || _disposed) return;
      items
        ..clear()
        ..addAll(rows);
      hasMore = rows.length == limit;
      loadedOnce = true;
    } catch (e, st) {
      if (gen != _generation || _disposed) return;
      error = e;
      LogUtils.e('加载历史记录失败', tag: 'HistoryFeed', error: e, stack: st);
    } finally {
      if (gen == _generation && !_disposed) {
        isLoading = false;
        _notify();
      }
    }
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore || error != null || !loadedOnce) return;
    final gen = _generation;
    isLoading = true;
    _notify();
    try {
      final rows = await _fetch(items.length, pageSize);
      if (gen != _generation || _disposed) return;
      final known = {for (final r in items) r.id};
      items.addAll(rows.where((r) => !known.contains(r.id)));
      hasMore = rows.length == pageSize;
    } catch (e, st) {
      if (gen != _generation || _disposed) return;
      error = e;
      LogUtils.e('加载更多历史记录失败', tag: 'HistoryFeed', error: e, stack: st);
    } finally {
      if (gen == _generation && !_disposed) {
        isLoading = false;
        _notify();
      }
    }
  }

  /// 出错后重试：翻页失败就接着翻，首屏失败就重载。
  Future<void> retry() {
    if (!loadedOnce) return reload();
    error = null;
    return loadMore();
  }

  /// 正在播退场动画、马上要删的那几条（卡片据此收起淡出）。
  final Set<int> removing = <int>{};

  void markRemoving(Set<int> ids) {
    final before = removing.length;
    removing.addAll(ids);
    if (removing.length != before) _notify();
  }

  void unmarkRemoving(Set<int> ids) {
    final before = removing.length;
    removing.removeAll(ids);
    if (removing.length != before) _notify();
  }

  /// 就地移除（库里已经删掉了）。
  void removeIds(Set<int> ids) {
    final before = items.length;
    items.removeWhere((r) => ids.contains(r.id));
    removing.removeAll(ids);
    if (items.length != before) _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
