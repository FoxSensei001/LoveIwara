import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/download/download_task_store.dart';
import 'package:i_iwara/app/services/download_notification_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/rx_ever.dart';

/// 安卓：有下载在跑时挂前台服务 + 进度常驻通知，熄屏 / 切到别的应用后下载不停
/// （issue #136）。
///
/// # 为什么需要
///
/// 下载全在 Dart 里跑。应用一离开前台、又没有前台服务时，进程会被系统降成「缓存
/// 进程」，几秒后被缓存应用冻结器冻住，下载随之停住；关掉电池优化也救不回来，因为
/// 豁免电池优化只管 Doze 断网，不管冻结。前台服务把进程状态抬上去，冻结和 Doze
/// 断网就都落不到它头上。原生那半见 `DownloadKeepAliveService.kt`。
///
/// # 启停只看一件事
///
/// 「下载中」或「等待中」不为空就起，两者都空了就停——直接订阅 [DownloadTaskStore]
/// 的两张分区表，不在下载流程的任何调用点里插启停代码：所有状态变化本来就都经过
/// Store，这里不可能漏掉某条路径。停之前留 [_stopGrace] 的余量，免得一条下完、下一条
/// 还没从队列里取出来的那一瞬间把服务拆了又起。
///
/// 只管「切走 / 熄屏」。从最近任务里划掉应用时 Dart 引擎跟着没了，不在本类范围内。
class DownloadKeepAlive {
  DownloadKeepAlive(this._store);

  static const MethodChannel _channel = MethodChannel(
    'i_iwara/download_keep_alive',
  );
  static const String _tag = 'DownloadKeepAlive';

  /// 通知刷新间隔。系统对同一条通知的刷新有限流，一秒一次足够。
  static const Duration _tickInterval = Duration(seconds: 1);

  /// 活干完到真正停服务之间的余量。
  static const Duration _stopGrace = Duration(seconds: 3);

  /// 原生进度条的满格值，与 `DownloadKeepAliveService.PROGRESS_MAX` 对齐。
  static const int _progressMax = 1000;

  final DownloadTaskStore _store;
  final List<Worker> _workers = <Worker>[];
  AppLifecycleListener? _lifecycle;
  Timer? _ticker;
  Timer? _stopTimer;

  /// 原生服务已经以前台身份跑起来。
  bool _nativeUp = false;
  bool _starting = false;
  bool _disposed = false;

  /// 宿主没注册这条通道（例如别的 Activity 承载的引擎）：此后一律不再尝试。
  bool _unsupported = false;
  Map<String, Object?>? _lastPayload;

  bool get _hasWork =>
      _store.downloadingIds.isNotEmpty || _store.pendingIds.isNotEmpty;

  void attach() {
    if (!Platform.isAndroid || _workers.isNotEmpty) return;
    _workers
      ..add(rxEver(_store.downloadingIds, (_) => _sync()))
      ..add(rxEver(_store.pendingIds, (_) => _sync()));
    // 从后台起前台服务会被 Android 12+ 拒掉；回到前台时补起一次。清掉去重快照是为了
    // 强制推一次：服务若已被系统停掉（dataSync 时长上限），这一推才能发现并重起。
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _lastPayload = null;
        _sync();
      },
    );
    // 上一个引擎（同一进程里被销毁的 Activity）可能留下了还在跑的服务，而这边的
    // _nativeUp 从 false 起步，永远不会去停它。没活的话先无条件停一次，停是幂等的。
    if (!_hasWork) unawaited(_invoke('stop'));
    _sync();
  }

  void dispose() {
    _disposed = true;
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    _lifecycle?.dispose();
    _lifecycle = null;
    _ticker?.cancel();
    _ticker = null;
    _stopTimer?.cancel();
    _stopTimer = null;
    if (_nativeUp) {
      _nativeUp = false;
      unawaited(_invoke('stop'));
    }
  }

  void _sync() {
    if (_unsupported || _workers.isEmpty) return;
    if (_hasWork) {
      _stopTimer?.cancel();
      _stopTimer = null;
      if (_nativeUp) {
        unawaited(_push());
      } else {
        unawaited(_start());
      }
    } else if (_nativeUp && _stopTimer == null) {
      _stopTimer = Timer(_stopGrace, _stop);
    }
  }

  Future<void> _start() async {
    if (_starting) return;
    _starting = true;
    try {
      final payload = _buildPayload();
      final ok = await _invoke('start', payload);
      if (_disposed) {
        // 等结果的这段时间里 dispose 已经跑过，没人会再来收这只服务。
        if (ok == true) unawaited(_invoke('stop'));
        return;
      }
      if (ok == true) {
        _lastPayload = payload;
        _nativeUp = true;
        _ticker ??= Timer.periodic(_tickInterval, (_) => _push());
        LogUtils.i('下载保活已开启', _tag);
        unawaited(_ensureNotificationPermission());
        // 起服务的这一小段异步里活可能已经干完了。
        if (!_hasWork) _sync();
      } else if (ok == false) {
        LogUtils.w('系统拒绝开启下载保活（应用可能已在后台），回到前台时重试', _tag);
      }
    } finally {
      _starting = false;
    }
  }

  /// 没有通知权限时前台服务照样保活，只是进度通知不显示——此刻用户刚点了下载、
  /// 应用在前台，正是要权限的时机。拿到后清掉去重快照，下一拍就把通知补出来。
  Future<void> _ensureNotificationPermission() async {
    if (!Get.isRegistered<DownloadNotificationService>()) return;
    final granted = await DownloadNotificationService.to
        .ensureAndroidPermission();
    if (granted) _lastPayload = null;
  }

  void _stop() {
    _stopTimer = null;
    if (_hasWork) return;
    _ticker?.cancel();
    _ticker = null;
    _lastPayload = null;
    if (!_nativeUp) return;
    _nativeUp = false;
    unawaited(_invoke('stop'));
    LogUtils.i('下载保活已关闭', _tag);
  }

  Future<void> _push() async {
    if (!_nativeUp || !_hasWork) return;
    final payload = _buildPayload();
    if (mapEquals(payload, _lastPayload)) return;
    _lastPayload = payload;
    final ok = await _invoke('update', payload);
    if (ok == false) {
      // 原生那边已经停了（Android 15+ 的 dataSync 时长上限到点）。
      LogUtils.w('下载保活服务已被系统停止', _tag);
      _nativeUp = false;
      _ticker?.cancel();
      _ticker = null;
      _lastPayload = null;
      // 应用在前台时能当场重起；在后台会被拒，等回到前台再试。
      _sync();
    }
  }

  Map<String, Object?> _buildPayload() {
    final t = slang.t.downloadNotifications;
    final downloading = _store.downloadingIds
        .map(_store.taskOf)
        .whereType<DownloadTask>()
        .toList();
    final queued = _store.pendingIds.length;

    final titleParts = <String>[
      if (downloading.isNotEmpty) t.ongoingTitle(count: downloading.length),
      if (queued > 0) t.ongoingQueued(count: queued),
    ];

    String text = '';
    if (downloading.isNotEmpty) {
      final first = downloading.first;
      final fraction = _fractionOf(first);
      text = fraction == null
          ? _displayName(first)
          : '${_displayName(first)} · ${(fraction * 100).floor()}%';
    }

    // 总进度：各条已知进度的平均值；一条都不知道总量就显示不确定进度条。
    final known = downloading.map(_fractionOf).whereType<double>().toList();
    final int? progress = known.isEmpty
        ? null
        : (known.reduce((a, b) => a + b) / known.length * _progressMax)
              .round()
              .clamp(0, _progressMax);

    return <String, Object?>{
      'channelName': t.progressChannelName,
      'channelDescription': t.progressChannelDescription,
      'title': titleParts.join(' · '),
      'text': text,
      'progress': progress,
    };
  }

  /// 图库任务的 total/downloaded 存的是图片张数，比值语义一样。
  static double? _fractionOf(DownloadTask task) {
    if (task.totalBytes <= 0) return null;
    return (task.downloadedBytes / task.totalBytes).clamp(0.0, 1.0);
  }

  static String _displayName(DownloadTask task) {
    final title = task.extData?.data['title'];
    if (title is String && title.trim().isNotEmpty) return title.trim();
    return task.fileName;
  }

  Future<bool?> _invoke(String method, [Map<String, Object?>? args]) async {
    try {
      return await _channel.invokeMethod<bool>(method, args);
    } on MissingPluginException {
      _unsupported = true;
      _nativeUp = false;
      _ticker?.cancel();
      _ticker = null;
      return null;
    } catch (e) {
      LogUtils.w('下载保活调用 $method 失败: $e', _tag);
      return null;
    }
  }
}
