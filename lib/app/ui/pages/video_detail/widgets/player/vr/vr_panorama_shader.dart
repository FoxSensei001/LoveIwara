import 'dart:ui' as ui;

import 'package:i_iwara/utils/logger_utils.dart';

/// 平面环视用的片元着色器：加载一次、全应用共用一份 [ui.FragmentProgram]，
/// 并把「这台设备到底能不能跑」的探测收在一处。
///
/// # 为什么必须探测，不能假设
///
/// `ui.ImageFilter.shader` **只在 Impeller 上可用**，在 Skia 回退路径上直接抛
/// `UnsupportedError`。本项目没有显式关掉 Impeller，但 Skia 回退这条路客观存在
/// （老设备、特定 GPU 驱动黑名单、启动参数），所以不能拿「我们没关」当作恒真。
/// [isSupported] 是那个必须先问的问题，false 时调用方一律退回单眼裁切（①-a）：
/// 画面从「两个挤扁的半幅」变成「一个正常比例的单眼」，不惊艳但一定能用。
///
/// # 一份 program，每个播放器一只 shader
///
/// [ui.FragmentShader] 自己**带 uniform 状态**，两个播放器（内嵌 + 全屏路由、
/// 画中画）共用同一只会互相踩视角。所以 program 缓存共享、shader 实例由各自的
/// widget 自己 `program.fragmentShader()` 创建并在 dispose 时回收。
class VrPanoramaShader {
  const VrPanoramaShader._();

  static const String assetKey = 'assets/shaders/vr_equirect.frag';

  /// 本机能不能跑片元着色器滤镜（等价于「Impeller 是否启用」）。同步可读。
  static bool get isSupported => ui.ImageFilter.isShaderFilterSupported;

  static ui.FragmentProgram? _program;
  static Future<ui.FragmentProgram?>? _loading;

  /// 已经加载好的 program；还没加载完就是 null。给 build 里同步取用，避免每帧
  /// 都挂一个 FutureBuilder。
  static ui.FragmentProgram? get programOrNull => _program;

  /// 加载着色器。失败（不支持 / 资源缺失 / 编译不过）一律返回 null 而不是抛，
  /// 由调用方走降级——环视这条路失败不该让整个播放器崩掉。
  ///
  /// 重复调用共用同一个 Future；失败后 [_loading] 被清空，下次进 VR 视频时会
  /// 再试一次（可能是首帧时机问题，值得给第二次机会）。
  static Future<ui.FragmentProgram?> load() {
    if (_program != null) return Future.value(_program);
    if (!isSupported) return Future.value(null);
    return _loading ??= _load();
  }

  static Future<ui.FragmentProgram?> _load() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(assetKey);
      _program = program;
      return program;
    } catch (e) {
      LogUtils.e(
        '平面环视着色器加载失败，本次退回单眼裁切',
        tag: 'VrPanoramaShader',
        error: e,
      );
      _loading = null;
      return null;
    }
  }
}
