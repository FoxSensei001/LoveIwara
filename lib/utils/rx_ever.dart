import 'dart:async';

import 'package:get/get.dart';

/// GetX `ever()` 的替代品：订阅一个可观察值的变化。
///
/// # 为什么全站不许再用 `ever()`
///
/// GetX 5 rc 的 `ever()` 走的是 Rx 的 **stream**，而 stream 在
/// 「订阅 → 取消 → 再订阅」之后**永远收不到值**。祸根在 `GetListenable.subject`
/// （get/lib/get_state_manager/src/rx_flutter/rx_notifier.dart）：
///
/// ```dart
/// StreamController<T> get subject {
///   if (_controller == null) {
///     _controller = StreamController<T>.broadcast(
///       onCancel: addListener(_streamListener),   // ← 注意 onCancel 是「取消订阅时」跑
///     );
///   }
///   return _controller!;
/// }
/// ```
///
/// `_streamListener` 是「把新值推进 stream」的那个内部监听者。broadcast 控制器的
/// `onCancel` 在**最后一个订阅者取消**时触发，于是它被摘掉；而 `_controller` 此后
/// 不再为 null，下一次 `ever()` 拿到的是同一个控制器，`_streamListener` 却再也不会
/// 被加回去——新订阅者从此**静默失聪**，既不报错也没有任何迹象。
///
/// `Obx` 走的是另一条路（`addListener`），不受影响。所以症状永远是这一种：
/// **同一个可观察值，界面上 Obx 那部分好好的，`ever()` 那部分一动不动**，
/// 而且只在「第二次进这个页面」之后才出现。
///
/// 2026-08-26 的实例：下载完成后任务从「下载中」区消失（Obx 正常），却不出现在
/// 历史区（`ever(store.completedRevision)` 已失聪）。真机日志里
/// `DownloadState emit ...` 有、配对的 `recv` 一条都没有。
///
/// # 这里怎么做
///
/// 直接挂 `addListener`（Obx 用的同一条路），不碰 stream。语义与 `ever()` 对齐：
/// - 回调在**微任务**里执行（`ever()` 靠 stream 也是异步的），因此不会在
///   `refresh()` 的同步栈里跑，`setState` / 帧回调都安全；
/// - 取值放在微任务里，避开 `value` getter 的 `reportRead()`——同步读有可能被
///   正在 build 的 `Obx` 当成依赖登记进去；
/// - 返回 GetX 的 [Worker]，`dispose()` / `call()` 用法与 `ever()` 完全一致，
///   调用点连字段类型都不用改。
Worker rxEver<T>(GetListenable<T> listenable, void Function(T value) callback) {
  var disposed = false;
  final void Function() removeListener = listenable.addListener(() {
    if (disposed) return;
    scheduleMicrotask(() {
      if (disposed) return;
      callback(listenable.value);
    });
  });
  return Worker(() async {
    if (disposed) return;
    disposed = true;
    removeListener();
  }, '[rxEver]');
}
