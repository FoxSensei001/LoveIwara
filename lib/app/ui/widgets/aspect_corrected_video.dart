import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// media_kit 的 [Video] 外面套一层「纹理比例矫正」，**播放器一律用这只**。
///
/// ## 为什么需要
///
/// Windows / Linux 上 media_kit 走**软件渲染**时（ANGLE / OpenGL 初始化失败，
/// 或用户在设置里关掉了硬件加速），会把纹理钳到 1080p 以内。那段钳位是**逐边
/// 独立**做的，还带一处整数除法，比例根本保不住
/// （`media_kit_video/windows/video_output.cc` 的 `GetVideoWidth/Height`）：
///
/// ```text
/// if (width  >= 1920) return 1920;             // 先返回就不再看高
/// if (height >= 1080) return width / height * 1080;   // 整数除法，竖屏恒为 0
/// ```
///
/// 于是 2160×3840 的竖屏片拿到的纹理是 **1920×1080**——mpv 按 keepaspect 把画面
/// letterbox 进这张横纹理里，**黑边是烤进像素的**。Flutter 这边再按视频真比例
/// （0.5625）开一只盒子、用 `BoxFit.contain` 把整张纹理放进去，黑边跟着一起等比
/// 缩，画面就缩成正中间一小块：竖屏视频选「适应」时那个「很小一个框」正是这么来的
/// （用户 2026-09-08 报的 Windows 现象）。横屏 16:9 片钳位后比例正好没变，所以
/// 只有竖屏（以及 4:3、超宽这些非 16:9 比例）会露馅。macOS / iOS / Android 没有
/// 这条软件渲染路径，天然复现不了。
///
/// ## 怎么矫正
///
/// 纹理比例与视频真比例对不上时，先用 `BoxFit.cover` 把烤进去的黑边**裁掉**——
/// letterbox 是居中等比的，cover 裁掉的正好就是那圈黑边——得到一只「恰好被画面
/// 铺满、且比例正确」的内容盒，再按调用方要的 [fit] 缩放这只内容盒。
/// 画面的真实像素数一格没少（黑边本来就不占画面像素），画质与钳位前一致。
///
/// 比例一致时（硬件渲染、移动端、macOS）走原路，零额外开销。
class AspectCorrectedVideo extends StatefulWidget {
  const AspectCorrectedVideo({
    super.key,
    required this.controller,
    this.controls,
    this.fit = BoxFit.contain,
    this.fill = const Color(0xFF000000),
  });

  final VideoController controller;

  /// 与 [Video.controls] 同义。默认 `null` 即不挂任何控件——本项目的播放控件
  /// 全是自绘的，没有一处用 media_kit 自带的那套。
  final VideoControlsBuilder? controls;

  /// 画面相对于**本组件盒子**的填充方式，语义与 [Video.fit] 一致。
  final BoxFit fit;

  final Color fill;

  @override
  State<AspectCorrectedVideo> createState() => _AspectCorrectedVideoState();
}

class _AspectCorrectedVideoState extends State<AspectCorrectedVideo> {
  /// 只有这两个平台的 media_kit 有「软件渲染钳位」那段代码，别的平台不必绕路。
  ///
  /// 不缓存成 `static final`：那会把 `debugDefaultTargetPlatformOverride` 冻在
  /// 第一次读到的值上，测试里换平台就失灵了。这只 getter 本身没有开销。
  static bool get _platformClampsSoftwareTexture =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  /// 视频的真实显示尺寸（已按 `rotate` 交换过宽高），拿不到时为 null。
  Size? _displaySize;

  /// 纹理尺寸。media_kit 把它塞在 [VideoController.rect] 里。
  Rect? _textureRect;

  StreamSubscription<VideoParams>? _paramsSubscription;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  @override
  void didUpdateWidget(covariant AspectCorrectedVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detach();
      _attach();
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  void _attach() {
    if (!_platformClampsSoftwareTexture) return;
    final controller = widget.controller;
    _displaySize = _displaySizeOf(controller.player.state.videoParams);
    _textureRect = controller.rect.value;
    controller.rect.addListener(_onTextureRectChanged);
    _paramsSubscription = controller.player.stream.videoParams.listen((params) {
      final size = _displaySizeOf(params);
      if (!mounted || size == _displaySize) return;
      setState(() => _displaySize = size);
    });
  }

  void _detach() {
    if (!_platformClampsSoftwareTexture) return;
    _paramsSubscription?.cancel();
    _paramsSubscription = null;
    widget.controller.rect.removeListener(_onTextureRectChanged);
  }

  void _onTextureRectChanged() {
    final rect = widget.controller.rect.value;
    if (!mounted || rect == _textureRect) return;
    setState(() => _textureRect = rect);
  }

  /// 解码器报上来的显示尺寸。`dw/dh` 已经做过像素宽高比修正，这里只需要再按
  /// `rotate` 把 90°/270° 的宽高换个位——与 media_kit 自己算 `state.width/height`
  /// 的口径完全一致。
  static Size? _displaySizeOf(VideoParams params) {
    final int? dw = params.dw;
    final int? dh = params.dh;
    if (dw == null || dh == null || dw <= 0 || dh <= 0) return null;
    final int rotate = params.rotate ?? 0;
    final bool swapped = rotate == 90 || rotate == 270;
    return Size(
      (swapped ? dh : dw).toDouble(),
      (swapped ? dw : dh).toDouble(),
    );
  }

  /// 需要矫正时返回「内容盒」的尺寸（即视频真实显示尺寸），否则返回 null。
  Size? _contentBoxSize() {
    if (!_platformClampsSoftwareTexture) return null;
    final Size? display = _displaySize;
    final Rect? rect = _textureRect;
    if (display == null || rect == null) return null;
    // 首帧前 media_kit 挂的是 1×1 占位纹理，那会儿的比例不作数。
    if (rect.width <= 1 || rect.height <= 1) return null;
    final double textureAspect = rect.width / rect.height;
    final double videoAspect = display.width / display.height;
    if ((textureAspect - videoAspect).abs() <= videoAspect * 0.01) return null;
    _logCorrectionOnce(rect, display);
    return display;
  }

  /// 报障时唯一能证明「这台机器落在软件渲染上」的线索——media_kit 那句
  /// `Using S/W rendering.` 只进 stdout，打包后的客户端谁也看不到。
  bool _correctionLogged = false;

  void _logCorrectionOnce(Rect rect, Size display) {
    if (_correctionLogged) return;
    _correctionLogged = true;
    LogUtils.w(
      '[纹理比例矫正] 纹理 ${rect.width.toInt()}x${rect.height.toInt()} 与视频 '
      '${display.width.toInt()}x${display.height.toInt()} 比例不符，'
      '判定为软件渲染的 1080p 钳位，已按内容盒裁掉烤进纹理的黑边',
      'AspectCorrectedVideo',
    );
  }

  Widget _video(BoxFit fit) => Video(
    controller: widget.controller,
    controls: widget.controls,
    fit: fit,
    fill: widget.fill,
  );

  @override
  Widget build(BuildContext context) {
    final Size? content = _contentBoxSize();
    if (content == null) return _video(widget.fit);
    return ClipRect(
      child: FittedBox(
        fit: widget.fit,
        // cover 把纹理自带的黑边裁掉，内容盒因此恰好被画面铺满；外层再按调用方
        // 要的 fit 缩放这只已经「干净」的内容盒。
        child: SizedBox(
          width: content.width,
          height: content.height,
          child: _video(BoxFit.cover),
        ),
      ),
    );
  }
}
