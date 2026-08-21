import 'package:i_iwara/utils/logger_utils.dart';

/// 下载状态通道的诊断埋点。
///
/// 存在的理由：下载模块的故障几乎全是时序性的——「点了暂停没反应、必须重进页面」
/// 这类症状，静态读代码看不出任何问题（广播发了、监听也挂了），真因藏在运行时：
/// 广播方与订阅方是不是同一个服务实例、订阅它的 State 是不是屏幕上正在显示的那个、
/// 事件到了之后有没有真的走到 setState。这三件事只有日志能回答。
///
/// 因此这套埋点是**长期保留**的，不是排查期间的临时脚手架：
/// - 复现要靠运气，等出问题再加日志就晚了；
/// - 输出走统一的 [LogUtils]，release 下由 LogService 的日志等级策略统一裁剪，
///   不额外加设置开关（要求用户在出问题之前先想到去打开开关是不现实的）。
///
/// 读日志的方法：`adb logcat | grep DownloadState`，然后核对三个数字——
/// 1. `svc#` 广播方与订阅方是否一致（不一致 = 服务实例被换过，监听挂在死实例上）；
/// 2. `sub#` 收到事件的订阅者实例，是否就是当前可见页面的那个（不一致 = 页面有两份 State）；
/// 3. `emit` 之后有没有配对的 `recv` / `apply`（缺失 = 事件没送达或回调没执行）。
class DownloadStateLog {
  DownloadStateLog._();

  static const String tag = 'DownloadState';

  /// 状态变更广播发出时调用（服务侧）。
  ///
  /// [source] 传广播方实例（通常是 `this`），用于打印实例身份。
  static void emit(
    Object source,
    String event, {
    String? taskId,
    String? detail,
  }) {
    LogUtils.d(
      'emit  svc#${identityHashCode(source)} $event'
      '${taskId == null ? '' : ' task=$taskId'}'
      '${detail == null ? '' : ' | $detail'}',
      tag,
    );
  }

  /// 订阅方收到事件时调用（页面/组件侧）。
  ///
  /// [subscriber] 传订阅方实例（通常是 State 的 `this`），
  /// [source] 传事件来源服务实例，用于比对二者是否同一条通道。
  static void receive(
    Object subscriber,
    Object source,
    String event, {
    String? detail,
  }) {
    LogUtils.d(
      'recv  sub#${identityHashCode(subscriber)} '
      'svc#${identityHashCode(source)} $event'
      '${detail == null ? '' : ' | $detail'}',
      tag,
    );
  }

  /// 订阅方真正把事件落到 UI（setState / Store 写入）时调用。
  ///
  /// `recv` 有而 `apply` 没有，说明事件送达了但被守卫吞掉或回调没跑完。
  static void apply(Object subscriber, String action, {String? detail}) {
    LogUtils.d(
      'apply sub#${identityHashCode(subscriber)} $action'
      '${detail == null ? '' : ' | $detail'}',
      tag,
    );
  }

  /// 订阅方发现自己订阅的服务实例已经不是当前注册实例（断链）时调用。
  static void staleBinding(Object subscriber, Object stale, Object current) {
    LogUtils.w(
      'STALE sub#${identityHashCode(subscriber)} 订阅的服务实例已失效: '
      'svc#${identityHashCode(stale)} -> svc#${identityHashCode(current)}，已重新绑定',
      tag,
    );
  }
}
