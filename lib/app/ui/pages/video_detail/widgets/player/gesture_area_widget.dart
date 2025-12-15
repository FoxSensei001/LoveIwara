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
  GestureAreaState createState() => GestureAreaState();
}

class GestureAreaState extends State<GestureArea>
    with SingleTickerProviderStateMixin {
  final ConfigService _configService = Get.find();
  ScreenBrightness? _screenBrightness;

  // 提示信息
  String? _infoMessage;

  // 拖动的距离
  late AnimationController _infoMessageFadeController;
  late Animation<double> _infoMessageOpacity;

  // 缓存计算结果
  bool? _isVerticalDragProcessable;

  // 长按时横向拖动相关状态
  double? _longPressStartX; // 长按开始时的X坐标
  double _baseLongPressSpeed = 1.0; // 长按开始时的配置速度

  // 垂直拖动起始位置(用于边缘检测)
  double? _verticalDragStartY; // 垂直拖动开始时的Y坐标

  @override
  void initState() {
    super.initState();
    _initializeInfoMessageController();

    if (!GetPlatform.isLinux) {
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
        if (_configService[ConfigKey.ENABLE_RIGHT_DOUBLE_TAP_FAST_FORWARD] ==
            true) {
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
      message = slang.t.videoDetail.rewindSeconds(
        num: _configService[ConfigKey.REWIND_SECONDS_KEY],
      );
    } else {
      // message = '快进${_configService[ConfigKey.FAST_FORWARD_SECONDS_KEY]}秒';
      message = slang.t.videoDetail.fastForwardSeconds(
        num: _configService[ConfigKey.FAST_FORWARD_SECONDS_KEY],
      );
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

    // 记录长按开始时的X坐标和配置速度
    _longPressStartX = details.localPosition.dx;
    _baseLongPressSpeed =
        _configService[ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY] as double;

    widget.setLongPressing?.call(LongPressType.normal, true);
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    // 检查长按快进配置
    if (_configService[ConfigKey.ENABLE_LONG_PRESS_FAST_FORWARD] != true) {
      return;
    }

    // 如果没有记录开始位置或者不在长按状态，则不处理
    if (_longPressStartX == null ||
        !widget.myVideoStateController.isLongPressing.value) {
      return;
    }

    // 计算横向拖动距离（像素）
    final double dragDistance = details.localPosition.dx - _longPressStartX!;
    final double absDragDistance = dragDistance.abs();

    // 根据拖动距离计算速度变化的增量（0.1 到 0.5）
    // 距离越远，每单位距离的变化幅度越大
    // 阈值设定（像素）：
    // 0-30px: 增量 0.1
    // 30-60px: 增量 0.2
    // 60-90px: 增量 0.3
    // 90-120px: 增量 0.4
    // 120px+: 增量 0.5
    double speedIncrement;
    if (absDragDistance < 60) {
      speedIncrement = 0.1;
    } else if (absDragDistance < 90) {
      speedIncrement = 0.2;
    } else if (absDragDistance < 120) {
      speedIncrement = 0.3;
    } else {
      speedIncrement = 0.4;
    }

    // 根据累计拖动距离计算总的速度变化
    // 每 30 像素算一个速度变化单位
    const double pixelsPerSpeedUnit = 30.0;
    final int speedUnits = (absDragDistance / pixelsPerSpeedUnit).floor();

    // 计算总速度变化量
    double totalSpeedDelta = speedUnits * speedIncrement;

    // 根据方向确定是增加还是减少
    if (dragDistance < 0) {
      totalSpeedDelta = -totalSpeedDelta;
    }

    // 计算新速度（向右增加，向左减少）
    double newSpeed = _baseLongPressSpeed + totalSpeedDelta;

    // 限制速度范围 0.1 - 4.0
    newSpeed = newSpeed.clamp(0.1, 4.0);
    // 保留一位小数
    newSpeed = (newSpeed * 10).roundToDouble() / 10;

    // 使用节流控制更新频率
    EasyThrottle.throttle(
      '${widget.myVideoStateController.randomId}_long_press_speed_update',
      const Duration(milliseconds: 50),
      () {
        widget.myVideoStateController.updateLongPressSpeed(newSpeed);
      },
    );
  }

  void _onLongPressEnd(LongPressEndDetails details) async {
    // 检查长按快进配置
    if (_configService[ConfigKey.ENABLE_LONG_PRESS_FAST_FORWARD] != true) {
      return;
    }

    // 震动
    VibrateUtils.vibrate(type: HapticFeedback.lightImpact);

    // 重置长按相关状态
    _longPressStartX = null;

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

    // 检查左侧亮度调节配置，PC设备不处理亮度调节
    if (widget.region == GestureRegion.left) {
      if (GetPlatform.isDesktop) {
        return false;
      }
      return _configService[ConfigKey.ENABLE_LEFT_VERTICAL_SWIPE_BRIGHTNESS] ==
          true;
    }

    // 检查右侧音量调节配置
    if (widget.region == GestureRegion.right) {
      return _configService[ConfigKey.ENABLE_RIGHT_VERTICAL_SWIPE_VOLUME] ==
          true;
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
      _configService.setSetting(
        ConfigKey.BRIGHTNESS_KEY,
        _configService[ConfigKey.BRIGHTNESS_KEY],
        save: true,
      );
      // 保存亮度设置
      CommonConstants.isSetBrightness = true;
    } else if (widget.region == GestureRegion.right) {
      type = LongPressType.volume;
      // 在音量调节结束时保存设置
      _configService.setSetting(
        ConfigKey.VOLUME_KEY,
        _configService[ConfigKey.VOLUME_KEY],
        save: true,
      );
    }

    widget.setLongPressing?.call(type, false);

    // 结束时让信息提示淡出
    _infoMessageFadeController.reverse().whenComplete(() {
      if (mounted) {
        // 添加mounted检查
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

    // 检查是否从边缘区域开始滑动
    if (_verticalDragStartY != null) {
      const edgeThreshold = CommonConstants.videoPlayerEdgeGestureThreshold;
      final screenHeight = widget.screenSize.height;

      // 从顶部边缘向下滑动,忽略
      if (_verticalDragStartY! < edgeThreshold && details.primaryDelta! > 0) {
        return;
      }

      // 从底部边缘向上滑动,忽略
      if (_verticalDragStartY! > screenHeight - edgeThreshold &&
          details.primaryDelta! < 0) {
        return;
      }
    }

    // 缩放因子，调低因子以加快调整速度：音量区域设置为0.3，亮度区域设置为0.2
    var scalingFactor = widget.region == GestureRegion.left ? 0.3 : 0.2;
    final double max = widget.screenSize.height * scalingFactor;

    if (widget.region == GestureRegion.left &&
        !GetPlatform.isLinux &&
        !GetPlatform.isWindows &&
        !GetPlatform.isMacOS) {
      // 左侧只在移动设备上调整亮度
      double rx =
          _configService[ConfigKey.BRIGHTNESS_KEY] -
          details.primaryDelta! / max;
      rx = rx.clamp(0.0, 1.0);

      // 使用节流控制亮度调节
      EasyThrottle.throttle(
        '${widget.myVideoStateController.randomId}_setBrightness',
        const Duration(milliseconds: 20),
        () {
          _configService.setSetting(ConfigKey.BRIGHTNESS_KEY, rx, save: false);
          _screenBrightness?.setApplicationScreenBrightness(rx);
        },
      );

      widget.setLongPressing?.call(LongPressType.brightness, true);
    } else if (widget.region == GestureRegion.right) {
      // 右侧调整音量
      double rx =
          _configService[ConfigKey.VOLUME_KEY] - details.primaryDelta! / max;
      rx = rx.clamp(0.0, 1.0);

      // 使用节流控制音量调节
      EasyThrottle.throttle(
        '${widget.myVideoStateController.randomId}_setVolume',
        const Duration(milliseconds: 20),
        () {
          widget.onVolumeChange?.call(rx);
        },
      );

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
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                          color: Colors.white,
                          fontSize: 16,
                        ),
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
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      onVerticalDragStart: (details) {
        // 记录垂直拖动开始时的Y坐标
        _verticalDragStartY = details.localPosition.dy;
        widget.myVideoStateController.setInteracting(true);
      },
      onVerticalDragEnd: (details) {
        // 重置垂直拖动起始位置
        _verticalDragStartY = null;
        widget.myVideoStateController.setInteracting(false);
        _onVerticalDragEnd(details);
      },
      onVerticalDragUpdate:
          (widget.region == GestureRegion.left ||
              widget.region == GestureRegion.right)
          ? _onVerticalDragUpdate
          : null,
      // 所有区域都添加横向拖动手势（需要检查配置）
      onHorizontalDragStart:
          _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
          ? (details) {
              widget.myVideoStateController.setInteracting(true);
              widget.myVideoStateController.isHorizontalDragging.value = true;
              widget.onHorizontalDragStart?.call(details);
            }
          : null,
      onHorizontalDragUpdate:
          _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
          ? (details) {
              // 使用节流控制横向滑动更新频率，避免频繁更新进度条
              EasyThrottle.throttle(
                '${widget.myVideoStateController.randomId}_horizontal_drag_update',
                const Duration(milliseconds: 16),
                () {
                  widget.onHorizontalDragUpdate?.call(details);
                },
              );
            }
          : null,
      onHorizontalDragEnd:
          _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
          ? (details) {
              widget.myVideoStateController.setInteracting(false);
              // 触发震动
              VibrateUtils.vibrate(type: HapticFeedback.lightImpact);
              widget.onHorizontalDragEnd?.call(details);
            }
          : null,
      child: Container(
        /// 如果不用transparent的Container包裹，会导致center区域无法触发手势，GTP给出的解释是
        /// "当你使用一个没有颜色（即 color: null）的 Container 时，如果它没有子组件绘制任何内容，Flutter 可能不会为这个区域分配绘制层。这意味这个区域在视觉上是透明的，但在命中测试中也是"不可命中"的，因为没有实际的绘制内容。"
        /// 离谱奥
        color: Colors.transparent,
        child: Stack(
          children: [if (infoMessageWidget != null) infoMessageWidget],
        ),
      ),
    );
  }
}
