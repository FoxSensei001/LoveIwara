import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/scheduler.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/utils/glass_perf_knobs.dart';

/// 帧耗时探针：把 build / raster 的分位数打到日志，用来给「液态玻璃开 vs 关」
/// 这类改动做**可复现的 A/B 对照**，而不是靠肉眼说「好像顺一点」。
///
/// 只在 `--dart-define=GLASS_PERF=1` 时启用，release 默认包里整只不装配
/// （[enabled] 是编译期常量，dart2native 会把调用点连同这个类一起摇掉）。
///
/// 用法：
/// ```sh
/// flutter run --profile --dart-define=GLASS_PERF=1
/// adb logcat -s flutter | grep GLASSPERF
/// ```
///
/// 读数说明：
///   - **build** = UI 线程（widget 构建 + 布局 + 绘制记录）。玻璃档位影响的是
///     它里头「多建多少 widget / 多算多少 settings」那一份。
///   - **raster** = 光栅线程（真正跑 shader 的地方）。折射玻璃的代价几乎全在
///     这一栏——每块 lens 一次 backdrop 采样 + 一趟 SDF shader。
///   - **jank** = raster 超过 [_budgetMs] 的帧数占比。高刷屏下预算更紧，
///     这里按屏幕实际刷新率算。
class FramePerfProbe {
  FramePerfProbe._();

  /// 编译期开关，见类注释。与旋钮共用同一个 dart-define，
  /// 出处收在 [GlassPerfKnobs.benchBuild]。
  static const bool enabled = GlassPerfKnobs.benchBuild;

  static const int _reportEveryFrames = 120;

  static bool _started = false;
  static String _label = 'start';
  static final List<int> _buildUs = <int>[];
  static final List<int> _rasterUs = <int>[];
  static double _budgetMs = 1000 / 60;

  /// 挂上回调。重复调用无副作用。
  static void start() {
    if (!enabled || _started) return;
    _started = true;
    _registerExtensions();
    final double hz = SchedulerBinding.instance.platformDispatcher.views.isEmpty
        ? 60
        : SchedulerBinding
              .instance
              .platformDispatcher
              .views
              .first
              .display
              .refreshRate;
    _budgetMs = 1000 / (hz <= 0 ? 60 : hz);
    _log(
      'probe started · refreshRate=${hz.toStringAsFixed(1)}Hz '
      'budget=${_budgetMs.toStringAsFixed(2)}ms',
    );
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  /// 给接下来的帧打个场景标签（如 `home-scroll` / `glass-off`），
  /// 并把当前这一段先结算掉。
  static void mark(String label) {
    if (!enabled) return;
    _flush();
    _label = label;
    _log('--- mark: $label ---');
  }

  static void _onTimings(List<FrameTiming> timings) {
    for (final FrameTiming t in timings) {
      _buildUs.add(t.buildDuration.inMicroseconds);
      _rasterUs.add(t.rasterDuration.inMicroseconds);
    }
    if (_buildUs.length >= _reportEveryFrames) _flush();
  }

  static void _flush() {
    if (_buildUs.isEmpty) return;
    final String build = _summarize(_buildUs);
    final String raster = _summarize(_rasterUs);
    final int budgetUs = (_budgetMs * 1000).round();
    final int janky = _rasterUs.where((int us) => us > budgetUs).length;
    final int n = _rasterUs.length;
    _log(
      '[$_label] n=$n jank=$janky(${(janky * 100 / n).toStringAsFixed(1)}%) '
      'build{$build} raster{$raster}',
    );
    _buildUs.clear();
    _rasterUs.clear();
  }

  static String _summarize(List<int> samplesUs) {
    final List<int> sorted = List<int>.of(samplesUs)..sort();
    String at(double q) {
      final int i = ((sorted.length - 1) * q).round();
      return (sorted[i] / 1000).toStringAsFixed(2);
    }

    return 'p50=${at(0.5)} p90=${at(0.9)} p99=${at(0.99)} max=${at(1.0)}';
  }

  /// 把「打标签」和「切玻璃档」暴露成 VM service 扩展，让基准测试可以脚本化：
  ///
  /// ```sh
  /// curl "$BASE/ext.glassperf.mark?label=home-scroll"
  /// curl "$BASE/ext.glassperf.mode?value=plain"   # 或 liquid
  /// ```
  ///
  /// profile 包是 AOT，`evaluate` 那条路走不通（Debugger is disabled in AOT
  /// mode），service extension 是唯一能远程驱动的入口。
  static void _registerExtensions() {
    developer.registerExtension('ext.glassperf.mark', (
      String method,
      Map<String, String> params,
    ) async {
      mark(params['label'] ?? 'unnamed');
      return developer.ServiceExtensionResponse.result('{"ok":true}');
    });
    // 场景脚本的**自检与复位**入口。
    //
    // 为什么需要：视频页那套编排（开关评论弹窗、进出全屏）里，只要有一下点空，
    // 后面的按键就会落在别的地方——实测过一次「全屏没进去 → 返回键把详情页整个
    // 弹掉 → 剩下几段全在首页上跑」，而读数看起来完全正常（假玻璃那一轮整轮都在
    // 测首页）。所以脚本必须能问「我现在在哪」，也必须能不靠点击回到起点。
    developer.registerExtension('ext.glassperf.state', (
      String method,
      Map<String, String> params,
    ) async {
      String route = '?';
      try {
        route = appRouter.state.uri.toString();
      } catch (_) {
        // 路由树还没建好（启动早期），报个占位值即可。
      }
      return developer.ServiceExtensionResponse.result(
        '{"route":${_json(route)},"glass":"${glassMaterialMode.value.name}"}',
      );
    });
    developer.registerExtension('ext.glassperf.nav', (
      String method,
      Map<String, String> params,
    ) async {
      final String? video = params['video'];
      if (video != null && video.isNotEmpty) {
        appRouter.go('/');
        await Future<void>.delayed(const Duration(milliseconds: 400));
        appRouter.push('/video_detail/$video');
      } else {
        appRouter.go('/');
      }
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return developer.ServiceExtensionResponse.result('{"ok":true}');
    });
    developer.registerExtension('ext.glassperf.knob', (
      String method,
      Map<String, String> params,
    ) async {
      final String? name = params['name'];
      final String? value = params['value'];
      final bool ok =
          name != null && value != null && GlassPerfKnobs.apply(name, value);
      if (ok) await _forceGlassRebuild();
      _log('knob ${GlassPerfKnobs.describe()}');
      return developer.ServiceExtensionResponse.result(
        '{"ok":$ok,"state":"${GlassPerfKnobs.describe()}"}',
      );
    });
    developer.registerExtension('ext.glassperf.mode', (
      String method,
      Map<String, String> params,
    ) async {
      final String? value = params['value'];
      if (value == 'plain' || value == 'liquid') {
        glassMaterialMode.value = value == 'liquid'
            ? GlassMaterialMode.liquid
            : GlassMaterialMode.plain;
        // 换档要重建整棵树，等两帧再让基准继续，免得把重建那一下算进读数。
        await Future<void>.delayed(const Duration(milliseconds: 300));
        mark('mode=$value');
      }
      return developer.ServiceExtensionResponse.result(
        '{"mode":"${glassMaterialMode.value.name}"}',
      );
    });
  }

  /// 旋钮是普通静态字段，改了不会有人重建。玻璃档位那只 notifier 是全站
  /// chrome 的共同祖先，来回打一次就能把所有玻璃逼着重建一遍。
  static Future<void> _forceGlassRebuild() async {
    final GlassMaterialMode current = glassMaterialMode.value;
    final GlassMaterialMode other = current == GlassMaterialMode.liquid
        ? GlassMaterialMode.plain
        : GlassMaterialMode.liquid;
    glassMaterialMode.value = other;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    glassMaterialMode.value = current;
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  /// 极简 JSON 字符串转义——只够把一条路由塞进响应里，别拿它当通用序列化器。
  static String _json(String value) =>
      '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';

  static void _log(String message) {
    // print 而不是 LogUtils：探针要在日志服务起来之前就能用，也不该进落盘队列。
    developer.log(message, name: 'GLASSPERF');
    // ignore: avoid_print
    print('GLASSPERF $message');
  }
}
