import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';

import 'history_feed.dart';

/// 历史页的状态：五个 tab 各一份 [HistoryFeed]，筛选与选择是整页共用的。
///
/// # 为什么筛选整页共用
///
/// 以前每个 tab 各有一份关键字 / 时间区间，搜索框切 tab 时要来回同步，还容易出现
/// 「在视频 tab 搜过、切到全部 tab 看到的却没过滤」。现在搜索、时间区间对五个
/// tab 同时生效；看不见的 tab 只打一个 [HistoryFeed.stale] 标记，切过去再查库。
///
/// # 为什么选择整页只有一份
///
/// 以前五个控制器各持一份选中集合、每次勾选都手动镜像到另外四份。选中只在当前
/// tab 里有意义（全选 = 本 tab 已加载的），切 tab 直接清掉，一份就够了。
class HistoryListController {
  HistoryListController({HistoryRepository? repository})
    : repository = repository ?? HistoryRepository() {
    feeds = [
      for (final tag in tags)
        HistoryFeed(repository: this.repository, itemType: tag),
    ];
  }

  static const List<String> tags = ['all', 'video', 'image', 'post', 'thread'];

  final HistoryRepository repository;
  late final List<HistoryFeed> feeds;

  final RxBool isMultiSelect = false.obs;
  final RxSet<int> selected = <int>{}.obs;
  final RxString keyword = ''.obs;
  final Rxn<DateTimeRange> dateRange = Rxn<DateTimeRange>();

  Timer? _searchDebounce;

  // ---------------------------------------------------------------- 选择

  void toggleMultiSelect() {
    isMultiSelect.value = !isMultiSelect.value;
    if (!isMultiSelect.value) selected.clear();
  }

  void enterMultiSelect() {
    if (!isMultiSelect.value) isMultiSelect.value = true;
  }

  void toggleSelection(int id) {
    if (!selected.remove(id)) selected.add(id);
  }

  void clearSelection() => selected.clear();

  void exitMultiSelect() {
    isMultiSelect.value = false;
    selected.clear();
  }

  // ---------------------------------------------------------------- 筛选

  /// 输入框每敲一个字都会来：300ms 防抖后再查。关键字对五个 tab 同时生效。
  void search(String value, {required int currentIndex}) {
    keyword.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _applyFilters(currentIndex);
    });
  }

  void setDateRange(DateTimeRange? range, {required int currentIndex}) {
    dateRange.value = range;
    _applyFilters(currentIndex);
  }

  void _applyFilters(int currentIndex) {
    for (var i = 0; i < feeds.length; i++) {
      final feed = feeds[i]
        ..keyword = keyword.value.trim()
        ..dateRange = dateRange.value;
      if (i == currentIndex) {
        feed.reload();
      } else {
        feed.stale = true;
      }
    }
    clearSelection();
  }

  /// 切到某个 tab：条件变过（或从没加载过）才查库。
  void ensureLoaded(int index) {
    final feed = feeds[index];
    if (feed.stale) feed.reload();
  }

  /// 从详情页回来：刚看的那条「最后浏览」变了，要浮到最上面。
  /// 前台 tab 保持长度重载，其余标脏。
  void refreshAfterReturn(int currentIndex) {
    for (var i = 0; i < feeds.length; i++) {
      if (i == currentIndex) {
        feeds[i].reload(keepExtent: true);
      } else {
        feeds[i].stale = true;
      }
    }
  }

  // ---------------------------------------------------------------- 删除

  /// 卡片退场动画的时长（收起 + 淡出），播完才真正从列表里拿掉。
  static const Duration removeAnimation = Duration(milliseconds: 220);

  /// 删掉这些行（连同视频进度），五个 tab 就地移除，不整表重载。
  ///
  /// [animate]：先让卡片播退场动画再删（逐条删除用；批量删除时卡片多半不在
  /// 眼前，直接拿掉）。
  Future<void> deleteRecords(Iterable<int> ids, {bool animate = false}) async {
    final set = ids.toSet();
    if (set.isEmpty) return;
    if (animate) {
      for (final feed in feeds) {
        feed.markRemoving(set);
      }
      await Future<void>.delayed(removeAnimation);
    }
    try {
      await repository.deleteRecords(set.toList());
    } catch (_) {
      for (final feed in feeds) {
        feed.unmarkRemoving(set);
      }
      rethrow;
    }
    for (final feed in feeds) {
      feed.removeIds(set);
    }
    selected.removeAll(set);
  }

  /// 撤销 [deleteRecords]：原样放回后重载（各 tab 的位置由时间决定，就地插回
  /// 反而容易插错组）。
  Future<void> restoreRecords(
    List<HistoryRecord> records, {
    required int currentIndex,
  }) async {
    await repository.restoreRecords(records);
    for (var i = 0; i < feeds.length; i++) {
      if (i == currentIndex) {
        feeds[i].reload(keepExtent: true);
      } else {
        feeds[i].stale = true;
      }
    }
  }

  /// 清空某个 tab（all = 全部）。
  Future<void> clearTab(String itemType, {required int currentIndex}) async {
    await repository.clearHistoryByType(itemType);
    _reloadAll(currentIndex);
  }

  /// 当前时间区间（按最后浏览时间）内、当前 tab 类型、当前搜索词命中的条数——
  /// 与列表眼前显示的是同一批，删的就是看到的。
  Future<int> countInRange(String itemType) async {
    final range = dateRange.value;
    if (range == null) return 0;
    return repository.countRecords(
      itemType: itemType,
      keyword: keyword.value.trim(),
      startDate: DateTime(range.start.year, range.start.month, range.start.day),
      endDate: DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
        23,
        59,
        59,
      ),
    );
  }

  Future<void> deleteInRange(
    String itemType, {
    required int currentIndex,
  }) async {
    final range = dateRange.value;
    if (range == null) return;
    await repository.deleteRecordsByTimeRange(
      itemType: itemType,
      keyword: keyword.value.trim(),
      startDate: DateTime(range.start.year, range.start.month, range.start.day),
      endDate: DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
        23,
        59,
        59,
      ),
    );
    _reloadAll(currentIndex);
  }

  void _reloadAll(int currentIndex) {
    clearSelection();
    for (var i = 0; i < feeds.length; i++) {
      if (i == currentIndex) {
        feeds[i].reload();
      } else {
        feeds[i].stale = true;
      }
    }
  }

  void dispose() {
    _searchDebounce?.cancel();
    for (final feed in feeds) {
      feed.dispose();
    }
  }
}
