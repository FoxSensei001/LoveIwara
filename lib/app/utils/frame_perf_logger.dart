import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// 帧耗时采集的总开关。
///
/// ⛔ 用 `bool.fromEnvironment` 而不是运行时读配置：它是**编译期常量**，关掉时
/// 下面每一处 `if (!kFramePerfLogEnabled)` 都会被整段摇树掉，正式包里一行不留、
/// 一个字节不加。打开方式是构建时给一个 define：
///
/// ```
/// flutter build apk --profile --dart-define=PERF_LOG=true
/// ```
///
/// 只在 profile 模式下测。debug 构建的性能官方明写「严重劣化」，拿它测出来的
/// 数字没有意义（android/app/build.gradle 里给 profile 单独加 `.profile` 后缀，
/// 就是为了让它可以和正式版并排装、专门用来做性能测量）。
const bool kFramePerfLogEnabled = bool.fromEnvironment('PERF_LOG');

/// 单帧耗时超过这个值就算「卡」。
///
/// 60Hz 的预算是 16.7ms、120Hz 是 8.3ms。取 16ms 当统一口径：两种刷新率下都能
/// 表达「这一帧超了」，而且和 `FrameTiming` 自己的口径不冲突。
const int _kJankThresholdMicros = 16000;

/// 攒够这么多帧就输出一次汇总。
///
/// 180 帧约等于 60Hz 下的 3 秒。窗口太短会被单帧抖动主导，太长则看不出
/// 「滚动中」和「静止」的差别。
const int _kReportWindowFrames = 180;

/// 用 [SchedulerBinding.addTimingsCallback] 采集真实帧耗时，并按窗口汇总输出。
///
/// # 为什么不用 post-frame 回调数帧
///
/// 这个仓库原先有一个 `PerformanceMonitor`（在 `media_list_view.dart` 里），
/// 它靠 `addPostFrameCallback` 自递归数帧、每 2 秒打一次平均 FPS。两个问题：
///
/// 1. **平均值掩盖卡顿**。卡顿从来不是平均值问题——一次 200ms 的掉帧会被 12 个
///    正常帧平均掉，最后打出来的还是「55 FPS，看着还行」。
/// 2. **分不出是构建卡还是光栅卡**。`addPostFrameCallback` 只能在 build 阶段末尾
///    回调，拿不到 raster 线程的耗时；而这两者要修的地方完全不同（前者是
///    widget 树太胖 / 重建太多，后者是图层、模糊、大图缩放）。
///
/// [FrameTiming] 两样都给：`buildDuration` 与 `rasterDuration` 分开计，所以汇总里
/// 两个 jank 计数是分开的——**这一行就是判断该往哪边修的判据**。
///
/// # 生命周期
///
/// 全局单例 + 引用计数。[MediaListView] 每个实例在 initState 里 attach、dispose
/// 里 detach；热门页有 6 个 keepAlive 的 tab，不去重就会挂 6 份回调、每个窗口
/// 打印 6 遍。
class FramePerfLogger {
  FramePerfLogger._();

  static final FramePerfLogger instance = FramePerfLogger._();

  int _refCount = 0;
  bool _registered = false;
  String _label = '';

  final List<int> _buildMicros = <int>[];
  final List<int> _rasterMicros = <int>[];

  /// 挂上采集。可重入：只有第一个调用者真正注册回调。
  void attach({String label = ''}) {
    if (!kFramePerfLogEnabled) return;
    _refCount++;
    if (_registered) return;
    _registered = true;
    _label = label;
    _buildMicros.clear();
    _rasterMicros.clear();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    debugPrint('PERF|start|label=$label');
  }

  /// 摘掉采集。引用计数归零时才真正反注册，并补打一次尾窗。
  void detach() {
    if (!kFramePerfLogEnabled) return;
    if (_refCount > 0) _refCount--;
    if (_refCount > 0 || !_registered) return;
    _registered = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _flush();
    debugPrint('PERF|stop|label=$_label');
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      _buildMicros.add(timing.buildDuration.inMicroseconds);
      _rasterMicros.add(timing.rasterDuration.inMicroseconds);
    }
    if (_buildMicros.length >= _kReportWindowFrames) _flush();
  }

  void _flush() {
    final int n = _buildMicros.length;
    if (n == 0) return;

    final build = _summarize(_buildMicros);
    final raster = _summarize(_rasterMicros);

    // 单行、固定字段顺序、带 PERF| 前缀：用 `adb logcat | grep PERF` 直接捞，
    // 也能整段贴进表格里对比改动前后。
    debugPrint(
      'PERF|n=$n'
      ' build avg=${_ms(build.avg)} p50=${_ms(build.p50)} '
      'p90=${_ms(build.p90)} p99=${_ms(build.p99)} max=${_ms(build.max)} '
      'jank=${build.jank}(${_pct(build.jank, n)})'
      ' raster avg=${_ms(raster.avg)} p50=${_ms(raster.p50)} '
      'p90=${_ms(raster.p90)} p99=${_ms(raster.p99)} max=${_ms(raster.max)} '
      'jank=${raster.jank}(${_pct(raster.jank, n)})',
    );

    _buildMicros.clear();
    _rasterMicros.clear();
  }

  _FrameStats _summarize(List<int> samples) {
    final sorted = List<int>.of(samples)..sort();
    int total = 0;
    int jank = 0;
    for (final v in sorted) {
      total += v;
      if (v > _kJankThresholdMicros) jank++;
    }
    return _FrameStats(
      avg: total ~/ sorted.length,
      p50: _percentile(sorted, 0.50),
      p90: _percentile(sorted, 0.90),
      p99: _percentile(sorted, 0.99),
      max: sorted.last,
      jank: jank,
    );
  }

  static int _percentile(List<int> sorted, double p) {
    if (sorted.isEmpty) return 0;
    final int index = ((sorted.length - 1) * p).round();
    return sorted[math.min(index, sorted.length - 1)];
  }

  static String _ms(int micros) => (micros / 1000).toStringAsFixed(1);

  static String _pct(int part, int total) =>
      total == 0 ? '0.0%' : '${(part * 100 / total).toStringAsFixed(1)}%';
}

class _FrameStats {
  const _FrameStats({
    required this.avg,
    required this.p50,
    required this.p90,
    required this.p99,
    required this.max,
    required this.jank,
  });

  final int avg;
  final int p50;
  final int p90;
  final int p99;
  final int max;
  final int jank;
}
