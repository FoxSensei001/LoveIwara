import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:loading_more_list/loading_more_list.dart';

/// 给 [LoadingMoreBase] 补上「刷新与加载更多并发」的防护。
///
/// ## 为什么需要它
///
/// `loading_more_list_library` 的 `LoadingMoreBase` **没有**并发串行化，
/// 只有一道互斥闸门（`_innerloadData` 首行）：
///
/// ```dart
/// if (isLoading || !hasMore) { return true; }   // 静默丢弃，还返回 true 伪装成功
/// ```
///
/// 而 `refresh()` 会在撞上这道闸门**之前**先 `clear()` 并把状态置成
/// `fullScreenBusying`。也就是说，在 loadMore 在途时调 refresh 等于：
///
/// > 列表被清空 + 请求根本没发出去 + 谎报成功 + UI 卡在全屏 loading
///
/// 而且提前 return 时不会再 `_onStateChanged`，那个全屏 loading 不会自己消失。
/// 框架非但没防这类竞态，它本身就是成因。
///
/// ## 防护由两部分组成，缺一不可
///
/// 1. **代际快照**：[loadData] 覆写里必须在 await **之前**取
///    [currentGeneration] 与页码快照，await 返回后用 [isStaleGeneration]
///    判断结果是否已作废。
///    ⚠️ 作废时必须 `return true` —— 返回 `false` 会被框架映射成
///    `error`/`fullScreenError`，用户会看到一个假的错误页。
///
/// 2. **刷新串行化**：`refresh()` 覆写必须把真正的刷新交给
///    [runGuardedRefresh]。它会依次等待已有刷新和 loadMore 落地，再原子地重置
///    分页状态并启动下一次请求；调用方不得自行拆开这些步骤。
mixin LoadingMoreRefreshGuard<T> on LoadingMoreBase<T> {
  int _generation = 0;
  bool _disposed = false;
  Future<bool> _refreshTail = Future<bool>.value(true);
  final Completer<void> _disposedSignal = Completer<void>();

  /// 当前请求代际。覆写 [loadData] 时在 await 之前取快照。
  @protected
  int get currentGeneration => _generation;

  /// 本数据源是否已被 dispose。
  bool get isDisposed => _disposed;

  /// 某次请求（以其发起时的代际为准）是否已作废。
  @protected
  bool isStaleGeneration(int generation) =>
      generation != _generation || _disposed;

  /// 把分页状态打回初始态，并作废所有在途请求的回写。
  ///
  /// 子类若维护自己的分页字段，**必须覆写本方法**来重置，而不要在 `refresh()`
  /// 里重置：那样重置会发生在等待之前，随后被在途请求的回写覆盖。
  ///
  /// 代际自增放在这里而不是 `refresh()` 里，是为了让**任何**「把列表打回初始态」
  /// 的入口（refresh、resetState、内容源切换…）都自动作废在途回写——收进钩子
  /// 里就没法忘。
  @protected
  @mustCallSuper
  void resetPagingState() {
    _generation++;
  }

  /// 等待在途请求落地。没有网络时长上限；dispose 会立即唤醒等待。
  @protected
  Future<bool> awaitInFlightSettled() async {
    while (isLoading && !_disposed) {
      await Future.any<void>([
        Future<void>.delayed(const Duration(milliseconds: 16)),
        _disposedSignal.future,
      ]);
    }
    return !_disposed;
  }

  /// 原子地等待 loadMore、重置分页状态并启动刷新。
  ///
  /// 操作异常会原样传给调用方，但不会破坏队列，后续刷新仍可继续。
  @protected
  Future<bool> runGuardedRefresh(Future<bool> Function() refresh) {
    final operation = _refreshTail.then((_) async {
      if (_disposed || !await awaitInFlightSettled()) return false;
      resetPagingState();
      return refresh();
    });
    _refreshTail = operation.then((_) => true, onError: (_) => true);
    return operation;
  }

  @override
  void dispose() {
    _disposed = true;
    if (!_disposedSignal.isCompleted) _disposedSignal.complete();
    super.dispose();
  }
}
