
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:i_iwara/utils/easy_throttle.dart';

import '../../../../../services/config_service.dart';
import '../../controllers/my_video_state_controller.dart';
import 'my_video_screen.dart';
import '../../../../../../i18n/strings.g.dart' as slang;

/// 视频播放器的手势区域
enum GestureRegion { left, right, center }

class GestureArea extends StatefulWidget {
  final GestureRegion region;
  final MyVideoStateController myVideoStateController;
  final Size screenSize;

  // 添加回调函数
  final VoidCallback? onDoubleTapLeft;
  final VoidCallback? onDoubleTapRight;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onTap;
  final Function(LongPressType?, bool)? setLongPressing;
  final Function(double)? onVolumeChange;

  // 添加新的回调
  final Function(DragStartDetails)? onHorizontalDragStart;
  final Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final Function(DragEndDetails)? onHorizontalDragEnd;

  const GestureArea({
    super.key,
    required this.region,
    required this.myVideoStateController,
    this.onDoubleTapLeft,
    this.onDoubleTapRight,
    this.onDoubleTap,
    this.onTap,
    required this.screenSize,
    this.setLongPressing,
    this.onVolumeChange,
    // 添加新的参数
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
  });

  @override
  _GestureAreaState createState() => _GestureAreaState();
}

class _GestureAreaState extends State<GestureArea>
    with SingleTickerProviderStateMixin {
  final ConfigService _configService = Get.find();
  ScreenBrightness? _screenBrightness;

  // 提示信息
  String? _infoMessage;

  // 拖动的距离
  late AnimationController _infoMessageFadeController;
  late Animation<double> _infoMessageOpacity;

  static const int MAX_SEEK_SECONDS = 90; // 最大滑动秒数为90秒

  // 缓存计算结果
  bool? _isVerticalDragProcessable;

  @override
  void initState() {
    super.initState();
    _initializeInfoMessageController();

    if (!GetPlatform.isLinux && !GetPlatform.isWeb) {
      _screenBrightness = ScreenBrightness();
    }
    
    // 预计算垂直拖动是否可处理
    _isVerticalDragProcessable = _checkLeftAndCenterVerticalDragProcessable();
  }

  void _onDoubleTap() {
    VibrateUtils.vibrate();

    switch (widget.region) {
      case GestureRegion.center:
        // 检查双击暂停配置
        if (_configService[ConfigKey.ENABLE_DOUBLE_TAP_PAUSE] == true) {
          widget.onDoubleTap?.call();
        }
        break;
      case GestureRegion.left:
        // 检查左侧双击后退配置
        if (_configService[ConfigKey.ENABLE_LEFT_DOUBLE_TAP_REWIND] == true) {
          // 触发左侧波纹动画
          widget.onDoubleTapLeft?.call();
          _showInfoMessage();
        }
        break;
      case GestureRegion.right:
        // 检查右侧双击快进配置
        if (_configService[ConfigKey.ENABLE_RIGHT_DOUBLE_TAP_FAST_FORWARD] == true) {
          // 触发右侧波纹动画
          widget.onDoubleTapRight?.call();
          _showInfoMessage();
        }
        break;
    }
  }

  void _initializeInfoMessageController() {
    _infoMessageFadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _infoMessageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _infoMessageFadeController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _showInfoMessage() {
    String message;
    if (widget.region == GestureRegion.left) {
      // message = '后退${_configService[ConfigKey.REWIND_SECONDS_KEY]}秒';
      message = slang.t.videoDetail.rewindSeconds(num:_configService[ConfigKey.REWIND_SECONDS_KEY]);
    } else {
      // message = '快进${_configService[ConfigKey.FAST_FORWARD_SECONDS_KEY]}秒';
      message = slang.t.videoDetail.fastForwardSeconds(num:_configService[ConfigKey.FAST_FORWARD_SECONDS_KEY]);
    }

    setState(() {
      _infoMessage = message;
    });
    _infoMessageFadeController.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _infoMessageFadeController.reverse();
      }
    });
  }

  void _onLongPressStart(LongPressStartDetails details) async {
    // 检查长按快进配置
    if (_configService[ConfigKey.ENABLE_LONG_PRESS_FAST_FORWARD] != true) {
      return;
    }

    VibrateUtils.vibrate(type: HapticFeedback.vibrate);
    // 如果视频在暂停或buffering状态，不处理
    if (!widget.myVideoStateController.videoPlaying.value ||
        widget.myVideoStateController.videoBuffering.value) {
      return;
    }
    widget.setLongPressing?.call(LongPressType.normal, true);
  }

  void _onLongPressEnd(LongPressEndDetails details) async {
    // 检查长按快进配置
    if (_configService[ConfigKey.ENABLE_LONG_PRESS_FAST_FORWARD] != true) {
      return;
    }

    // 震动
    VibrateUtils.vibrate(type: HapticFeedback.lightImpact);

    widget.setLongPressing?.call(LongPressType.normal, false);
    
    // 使用防抖机制恢复正常播放速度，避免频繁调用
    Timer(const Duration(milliseconds: 50), () {
      if (mounted) {
        widget.myVideoStateController.player.setRate(1.0);
      }
    });
  }

  // 检查左侧和中心区域是否可以处理垂直拖动
  bool _checkLeftAndCenterVerticalDragProcessable() {
    // 中心区域不处理
    if (widget.region == GestureRegion.center) {
      return false;
    }

    // 检查左侧亮度调节配置，PC设备和Web不处理亮度调节
    if (widget.region == GestureRegion.left) {
      if (GetPlatform.isDesktop || GetPlatform.isWeb) {
        return false;
      }
      return _configService[ConfigKey.ENABLE_LEFT_VERTICAL_SWIPE_BRIGHTNESS] == true;
    }

    // 检查右侧音量调节配置
    if (widget.region == GestureRegion.right) {
      return _configService[ConfigKey.ENABLE_RIGHT_VERTICAL_SWIPE_VOLUME] == true;
    }

    return false;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!(_isVerticalDragProcessable ?? false)) {
      return;
    }

    LongPressType? type;
    if (widget.region == GestureRegion.left) {
      type = LongPressType.brightness;
      // 在亮度调节结束时保存设置
      _configService.setSetting(ConfigKey.BRIGHTNESS_KEY, _configService[ConfigKey.BRIGHTNESS_KEY], save: true);
      // 保存亮度设置
      CommonConstants.isSetBrightness = true;
    } else if (widget.region == GestureRegion.right) {
      type = LongPressType.volume;
      // 在音量调节结束时保存设置
      _configService.setSetting(ConfigKey.VOLUME_KEY, _configService[ConfigKey.VOLUME_KEY], save: true);
    }

    widget.setLongPressing?.call(type, false);

    // 结束时让信息提示淡出
    _infoMessageFadeController.reverse().whenComplete(() {
      if (mounted) {  // 添加mounted检查
        setState(() {
          _infoMessage = null;
        });
      }
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!(_isVerticalDragProcessable ?? false)) {
      return;
    }

    // 缩放因子，调低因子以加快调整速度：音量区域设置为0.3，亮度区域设置为0.2
    var scalingFactor = widget.region == GestureRegion.left ? 0.3 : 0.2;
    final double max = widget.screenSize.height * scalingFactor;

    if (widget.region == GestureRegion.left &&
        !GetPlatform.isWeb &&
        !GetPlatform.isLinux &&
        !GetPlatform.isWindows &&
        !GetPlatform.isMacOS) {
      // 左侧只在移动设备上调整亮度
      double rx = _configService[ConfigKey.BRIGHTNESS_KEY] -
          details.primaryDelta! / max;
      rx = rx.clamp(0.0, 1.0);

      // 使用节流控制亮度调节
      EasyThrottle.throttle('setBrightness', const Duration(milliseconds: 20), () {
        _configService.setSetting(ConfigKey.BRIGHTNESS_KEY, rx, save: false);
        _screenBrightness?.setApplicationScreenBrightness(rx);
      });

      widget.setLongPressing?.call(LongPressType.brightness, true);
    } else if (widget.region == GestureRegion.right) {
      // 右侧调整音量
      double rx = _configService[ConfigKey.VOLUME_KEY] -
          details.primaryDelta! / max;
      rx = rx.clamp(0.0, 1.0);

      // 使用节流控制音量调节
      EasyThrottle.throttle('setVolume', const Duration(milliseconds: 20), () {
        widget.onVolumeChange?.call(rx);
      });

      widget.setLongPressing?.call(LongPressType.volume, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用const优化子组件
    final infoMessageWidget = _infoMessage != null
        ? Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _infoMessageOpacity,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _infoMessage!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : null;

    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: _onDoubleTap,
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onVerticalDragStart: (_) {
        widget.myVideoStateController.setInteracting(true);
      },
      onVerticalDragEnd: (details) {
        widget.myVideoStateController.setInteracting(false);
        _onVerticalDragEnd(details);
      },
      onVerticalDragUpdate: (widget.region == GestureRegion.left ||
              widget.region == GestureRegion.right)
          ? _onVerticalDragUpdate
          : null,
      // 所有区域都添加横向拖动手势
      onHorizontalDragStart: (details) {
        widget.myVideoStateController.setInteracting(true);
        widget.onHorizontalDragStart?.call(details);
      },
      onHorizontalDragUpdate: (details) {
        widget.onHorizontalDragUpdate?.call(details);
      },
      onHorizontalDragEnd: (details) {
        widget.myVideoStateController.setInteracting(false);
        // 触发震动
        VibrateUtils.vibrate(type: HapticFeedback.lightImpact);
        widget.onHorizontalDragEnd?.call(details);
      },
      child: Container(
        /// 如果不用transparent的Container包裹，会导致center区域无法触发手势，GTP给出的解释是
        /// "当你使用一个没有颜色（即 color: null）的 Container 时，如果它没有子组件绘制任何内容，Flutter 可能不会为这个区域分配绘制层。这意味这个区域在视觉上是透明的，但在命中测试中也是"不可命中"的，因为没有实际的绘制内容。"
        /// 离谱奥
        color: Colors.transparent,
        child: Stack(
          children: [
            if (infoMessageWidget != null) infoMessageWidget,
          ],
        ),
      ),
    );
  }
}
