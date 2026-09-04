import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/color_vision_filter_wrapper.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../../utils/common_utils.dart';
import 'player_box_scope.dart';

/// # Seek Preview —— 进度条上方那扇预览窗口
///
/// 悬停或拖动播放进度时浮出来的小窗口：上半是该时间点的画面，下半是时间戳。
/// 术语见 `CONTEXT.md`；它**不是** Preview Detail Modal（列表里长按弹出的那张图片卡）。
///
/// ## 为什么收成一份
///
/// 改造前它被实现了两遍——主进度条（`custom_slider_bar_shape_widget.dart`）
/// 和工具栏收起时的底部细进度条（`my_video_screen.dart`）各写了一套，
/// 连 `160 / 90` 这两个魔数和整段边界钳制都是照抄的。这正是本工作流反复踩到的
/// 同一种缺陷形状：同一件事实现在多处，然后各自漂移。所以先合并，再谈响应式——
/// 否则「响应式」只会变成要维护两份的两套算法。
///
/// 现在几何全部由 [resolveSeekPreviewFrameSize] 一处算出，渲染全部由
/// [SeekPreview] 一处负责，调用方只提供锚点与可见性。

/// 预览窗口的尺寸档位。
///
/// 刻意**不**把像素尺寸做成设置项：像素在竖屏手机的内嵌播放器和横屏平板的
/// 全屏播放器之间没有共同意义。档位只是一个乘在自动尺寸上的系数，
/// [SeekPreviewSize.standard] 就是自动推导出来的尺寸本身。
enum SeekPreviewSize {
  small(0.78),
  standard(1.0),
  large(1.28);

  const SeekPreviewSize(this.scale);

  /// 相对自动尺寸的倍数。
  final double scale;
}

/// 把配置里存的字符串还原成档位；认不出来一律回到默认档。
SeekPreviewSize seekPreviewSizeFromConfig(dynamic value) {
  return SeekPreviewSize.values.firstWhere(
    (mode) => mode.name == value,
    orElse: () => SeekPreviewSize.standard,
  );
}

/// 画面宽度取播放器短边的这个比例。取短边而不是宽度，是因为竖屏全屏时
/// 宽度才是那条「小」的边，按高度算会得到一扇几乎顶满屏幕的窗口。
const double kSeekPreviewBaseFactor = 0.34;

/// 自动尺寸的上下限。下限保证画面还看得出内容，上限防止在超宽屏上变成第二个播放器。
const double kSeekPreviewMinWidth = 96.0;
const double kSeekPreviewMaxWidth = 320.0;

/// 高度封顶之后允许跌到的绝对下限。竖屏视频 + 小播放器时高度限制会把宽度压得很窄，
/// 窄到一定程度画面就没有信息量了，这时宁可略微越过高度上限。
const double kSeekPreviewFloorWidth = 64.0;

/// 窗口不得高过播放器的这个比例——竖屏视频（9:16）按宽高比推出来的高度会非常夸张。
const double kSeekPreviewMaxHeightFraction = 0.45;

/// 也不得宽过播放器的这个比例，否则拖到两端时窗口会盖住大半个画面。
const double kSeekPreviewMaxWidthFraction = 0.5;

/// 宽高比拿不到（刚打开还没解出流）时的兜底值。
const double kSeekPreviewFallbackAspectRatio = 16 / 9;

/// 极端宽高比的钳制范围。真实视频不会超出这个区间，超出的多半是解析出的脏数据。
const double kSeekPreviewMinAspectRatio = 0.2;
const double kSeekPreviewMaxAspectRatio = 5.0;

/// 时间戳左右内边距。
const double kSeekPreviewLabelHPad = 8.0;
const double kSeekPreviewLabelVPad = 4.0;
const double kSeekPreviewLabelFontSize = 12.0;

/// 窗口贴边时与进度条两端保留的距离。
const double kSeekPreviewEdgeMargin = 4.0;

const double kSeekPreviewRadius = 4.0;

/// 画面区域的定位 key，供测试直接量它的尺寸。
const Key kSeekPreviewFrameKey = ValueKey('seek-preview-frame');

/// 计算预览画面区域的尺寸。
///
/// 三条约束，按优先级：
/// 1. 宽度来自**播放器**的短边（不是窗口），所以内嵌小播放器上它是小的，
///    全屏平板上它是大的；再夹在 [kSeekPreviewMinWidth]/[kSeekPreviewMaxWidth] 之间。
/// 2. 高度由**视频自己的宽高比**决定——竖屏视频得到一扇竖的窗口，而不是被塞进
///    16:9 的黑边里（改造前就是这样，画面只占中间窄窄一条）。
/// 3. 高度不得超过播放器高度的 [kSeekPreviewMaxHeightFraction]；超了就反过来压宽度。
///    只有压到 [kSeekPreviewFloorWidth] 以下才允许略微越过高度上限。
///
/// 纯函数：所有退化输入（0、负数、NaN、Infinity）都必须有确定的结果，
/// 调用方在 build 里拿到什么都不会崩。
Size resolveSeekPreviewFrameSize({
  required Size playerBox,
  required double videoAspectRatio,
  required SeekPreviewSize preference,
}) {
  final double aspectRatio = (videoAspectRatio.isFinite && videoAspectRatio > 0)
      ? videoAspectRatio.clamp(
          kSeekPreviewMinAspectRatio,
          kSeekPreviewMaxAspectRatio,
        )
      : kSeekPreviewFallbackAspectRatio;

  final double boxWidth = (playerBox.width.isFinite && playerBox.width > 0)
      ? playerBox.width
      : 640.0;
  final double boxHeight = (playerBox.height.isFinite && playerBox.height > 0)
      ? playerBox.height
      : 360.0;

  final double shortSide = math.min(boxWidth, boxHeight);

  // 先算「自动尺寸」并夹在上下限之间，**再**乘档位系数。
  // 顺序反过来的话，大播放器上自动值早就顶到上限，小档与大档会算出同一个数字
  // ——设置项看起来毫无作用。
  final double autoWidth = (shortSide * kSeekPreviewBaseFactor).clamp(
    kSeekPreviewMinWidth,
    kSeekPreviewMaxWidth,
  );
  double width = autoWidth * preference.scale;
  width = math.min(width, boxWidth * kSeekPreviewMaxWidthFraction);

  double height = width / aspectRatio;
  final double maxHeight = boxHeight * kSeekPreviewMaxHeightFraction;
  if (height > maxHeight) {
    width = maxHeight * aspectRatio;
  }

  width = math.max(width, kSeekPreviewFloorWidth);
  height = width / aspectRatio;
  return Size(width, height);
}

/// 计算窗口相对锚点的水平偏移（[FractionalTranslation] 的 dx，单位是窗口宽度）。
///
/// 默认让窗口在锚点上居中（-0.5）；拖到两端时改为贴边，
/// 使窗口整体留在进度条范围内，并保留 [kSeekPreviewEdgeMargin] 的边距。
/// 窗口比进度条还宽时（极窄播放器）无解，此时居中让它两边对称溢出。
///
/// 结果**不再**像改造前那样夹在 `[-1, 0]`：那个夹子会把最左端那一点边距吃掉
/// （偏移需要为正才推得回来），窗口只能勉强贴齐 0。位置本身已经被钳进进度条了，
/// 再夹一次偏移只会让边距失效。
double seekPreviewFractionalOffset({
  required double anchorX,
  required double trackWidth,
  required double previewWidth,
  double margin = kSeekPreviewEdgeMargin,
}) {
  if (previewWidth <= 0 || !previewWidth.isFinite) return -0.5;

  final double minLeft = margin;
  final double maxLeft = trackWidth - previewWidth - margin;
  final double left = maxLeft < minLeft
      ? (trackWidth - previewWidth) / 2
      : (anchorX - previewWidth / 2).clamp(minLeft, maxLeft);

  return (left - anchorX) / previewWidth;
}

/// 量时间戳实际要占的宽度。
///
/// 用实测值而不是拍脑袋的常数：系统字体放大之后 `1:23:45` 可以比画面还宽，
/// 那时窗口必须跟着变宽，否则要么溢出、要么把时间截掉。续播提示条用的是同一招。
double measureSeekPreviewLabelWidth({
  required String text,
  required TextScaler textScaler,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(
        fontSize: kSeekPreviewLabelFontSize,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
    maxLines: 1,
  )..layout();
  final double width = painter.width;
  painter.dispose();
  return width;
}

/// Seek Preview 的唯一渲染实现。
///
/// 调用方只负责三件事：把它 [Positioned] 到锚点上、告诉它锚点在进度条上的位置、
/// 以及现在该不该看得见。几何、边界钳制、出入场过渡都在这里。
class SeekPreview extends StatelessWidget {
  const SeekPreview({
    super.key,
    required this.time,
    required this.videoAspectRatio,
    required this.anchorX,
    required this.trackWidth,
    required this.visible,
    required this.showFrame,
    this.previewController,
  });

  /// 要显示的时间点。
  final Duration time;

  /// 视频自身的宽高比（`MyVideoStateController.aspectRatio`）。
  ///
  /// 必须由调用方在 `Obx` 的同步作用域里读出来再传进来：`LayoutBuilder` /
  /// `AnimatedBuilder` 的 builder 在 layout 阶段执行，在里面读 Rx 不会被追踪。
  final double videoAspectRatio;

  /// 锚点在进度条上的横向像素位置。
  final double anchorX;

  /// 进度条总宽度，用于把窗口钳在里面。
  final double trackWidth;

  /// 现在该不该看得见。false 时**原地淡出**而不是直接消失——出现与消失都要有过渡。
  final bool visible;

  /// 是否展示画面区域。预览播放器还没就绪时只显示时间戳。
  final bool showFrame;

  /// 预览播放器。为空时画面区域是纯黑（就绪与拿到首帧之间的空档，
  /// 以及不依赖 media_kit 的组件测试）。
  final VideoController? previewController;

  static const Duration kFade = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    // 档位是全局设置，改完要立刻生效，所以走 Obx 而不是一次性读。
    // 配置服务没注册时（纯组件测试）没有可追踪的 Rx，Obx 会抛「improper use」，
    // 因此那条路径直接按默认档渲染。
    if (!Get.isRegistered<ConfigService>()) {
      return _build(context, SeekPreviewSize.standard);
    }
    final ConfigService configService = Get.find<ConfigService>();
    return Obx(
      () => _build(
        context,
        seekPreviewSizeFromConfig(
          configService[ConfigKey.SEEK_PREVIEW_SIZE_KEY],
        ),
      ),
    );
  }

  Widget _build(BuildContext context, SeekPreviewSize preference) {
    final Size playerBox = PlayerBoxScope.sizeOf(context);
    final Size frame = resolveSeekPreviewFrameSize(
      playerBox: playerBox,
      videoAspectRatio: videoAspectRatio,
      preference: preference,
    );

    final String label = CommonUtils.formatDuration(time);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final double labelWidth =
        measureSeekPreviewLabelWidth(text: label, textScaler: textScaler) +
        kSeekPreviewLabelHPad * 2;
    // 没有画面时窗口只装一个时间戳，宽度就该只有时间戳那么宽——跟着画面宽度走
    // 会得到一条又长又空的黑条。有画面时才由两者取大：时间戳比画面还宽时由它
    // 撑开窗口，宁可窗口宽一点，也不要把时间截掉。
    final double boxWidth = showFrame
        ? math.max(frame.width, labelWidth)
        : labelWidth;

    final bool reduced = MediaQuery.disableAnimationsOf(context);

    return FractionalTranslation(
      translation: Offset(
        seekPreviewFractionalOffset(
          anchorX: anchorX,
          trackWidth: trackWidth,
          previewWidth: boxWidth,
        ),
        0,
      ),
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: reduced ? Duration.zero : kFade,
          curve: Curves.easeOut,
          opacity: visible ? 1.0 : 0.0,
          child: AnimatedScale(
            duration: reduced ? Duration.zero : kFade,
            curve: Curves.easeOutCubic,
            // 只缩 4%：出现时像是「浮上来」，而不是弹出来。
            scale: visible ? 1.0 : 0.96,
            alignment: Alignment.bottomCenter,
            child: _buildBox(boxWidth, frame),
          ),
        ),
      ),
    );
  }

  Widget _buildBox(double boxWidth, Size frame) {
    return Container(
      width: boxWidth,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(kSeekPreviewRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showFrame)
            SizedBox(
              key: kSeekPreviewFrameKey,
              width: frame.width,
              height: frame.height,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(kSeekPreviewRadius),
                ),
                child: ColoredBox(
                  color: Colors.black,
                  child: previewController == null
                      ? const SizedBox.expand()
                      : ColorVisionFilterWrapper(
                          child: Video(
                            controller: previewController!,
                            controls: null,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kSeekPreviewLabelHPad,
              vertical: kSeekPreviewLabelVPad,
            ),
            child: Text(
              CommonUtils.formatDuration(time),
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: kSeekPreviewLabelFontSize,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
