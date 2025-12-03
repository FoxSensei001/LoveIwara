import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/rapple_painter.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'bottom_toolbar_widget.dart';
import 'gesture_area_widget.dart';
import 'top_toolbar_widget.dart';
import 'widgets/playback_speed_animation_widget.dart';
import 'widgets/loading_state_widget.dart';
import 'widgets/error_state_widget.dart';
import '../../controllers/my_video_state_controller.dart';
import '../../../../../../i18n/strings.g.dart' as slang;

class MyVideoScreen extends StatefulWidget {
  final bool isFullScreen;
  final MyVideoStateController myVideoStateController;

  const MyVideoScreen({
    super.key,
    this.isFullScreen = false,
    required this.myVideoStateController,
  });

  @override
  State<MyVideoScreen> createState() => _MyVideoScreenState();
}

class _MyVideoScreenState extends State<MyVideoScreen>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  final ConfigService _configService = Get.find();
  final AppService _appService = Get.find();

  Timer? _autoHideTimer;
  Timer? _volumeInfoTimer; // 添加音量提示计时器
  DateTime? _lastLeftKeyPressTime;
  DateTime? _lastRightKeyPressTime;
  static const Duration _debounceTime = Duration(milliseconds: 300);

  late AnimationController _leftRippleController1;
  late AnimationController _leftRippleController2;
  bool _isLeftRippleActive1 = false;
  bool _isLeftRippleActive2 = false;

  late AnimationController _rightRippleController1;
  late AnimationController _rightRippleController2;
  bool _isRightRippleActive1 = false;
  bool _isRightRippleActive2 = false;

  // 控制InfoMessage的显示与淡入淡出动画
  late AnimationController _infoMessageFadeController;
  late Animation<double> _infoMessageOpacity;

  double? _horizontalDragStartX;
  Duration? _horizontalDragStartPosition;
  static const int maxSeekSeconds = 90;

  // 添加缓存的模糊背景
  String? _lastThumbnailUrl;

  // 添加尺寸缓存
  Size? _lastSize;
  Widget? _sizedBlurredBackground;

  @override
  void initState() {
    LogUtils.d("[${widget.isFullScreen ? '全屏' : '内嵌'} 初始化]", 'MyVideoScreen');
    super.initState();
    // 如果是全屏状态
    if (widget.isFullScreen) {
      _appService.hideSystemUI();
      // 继续播放
      // 如果当前是非全屏，则继续播放
      if (!widget.myVideoStateController.isFullscreen.value) {
        widget.myVideoStateController.player.play();
      }
      // 确保在全屏状态下获取焦点
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
      
      // 在全屏状态下监听重力感应变化
      _startGravityOrientationListener();
    }

    _initializeAnimationControllers();
    _initializeInfoMessageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在依赖变化时重新请求焦点
    _focusNode.requestFocus();
  }

  void _initializeAnimationControllers() {
    _leftRippleController1 = _createAnimationController();
    _leftRippleController2 = _createAnimationController();
    _rightRippleController1 = _createAnimationController();
    _rightRippleController2 = _createAnimationController();
  }

  AnimationController _createAnimationController({int duration = 800}) {
    return AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isLeftRippleActive1 = false;
            _isLeftRippleActive2 = false;
            _isRightRippleActive1 = false;
            _isRightRippleActive2 = false;
          });
        }
      });
  }

  void _initializeInfoMessageController() {
    _infoMessageFadeController = AnimationController(
      duration: const Duration(milliseconds: 0),
      vsync: this,
    );

    _infoMessageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _infoMessageFadeController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // 重力感应监听相关变量
  Timer? _orientationCheckTimer;
  Orientation? _lastOrientation;

  /// 开始监听重力感应变化
  void _startGravityOrientationListener() {
    // 仅在移动端启用
    if (!GetPlatform.isAndroid && !GetPlatform.isIOS) {
      return;
    }

    // 使用定时器定期检查方向变化
    _orientationCheckTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted || !widget.isFullScreen) {
        timer.cancel();
        return;
      }
      _checkOrientationChange();
    });
  }

  /// 检查方向变化
  void _checkOrientationChange() {
    if (!mounted || !widget.isFullScreen) {
      return;
    }

    // 获取当前方向
    final currentOrientation = MediaQuery.of(context).orientation;
    
    // 检查方向是否发生变化
    if (_lastOrientation != currentOrientation) {
      _lastOrientation = currentOrientation;
      
      // 只在横屏状态下处理
      if (currentOrientation == Orientation.landscape) {
        LogUtils.d('进入横屏模式 jui', 'MyVideoScreen');
        // 可以在这里添加横屏状态下的处理逻辑
      }
    }
  }

  @override
  void dispose() {
    if (widget.isFullScreen) {
      // 恢复系统UI和竖屏模式
      _appService.showSystemUI();
      // 恢复播放
      // widget.myVideoStateController.player.play();
    }
    _focusNode.dispose();
    _leftRippleController1.dispose();
    _leftRippleController2.dispose();
    _rightRippleController1.dispose();
    _rightRippleController2.dispose();
    _infoMessageFadeController.dispose();
    _autoHideTimer?.cancel();
    _volumeInfoTimer?.cancel(); // 取消音量提示计时器
    _blurUpdateTimer?.cancel(); // 清理模糊背景更新定时器
    _orientationCheckTimer?.cancel(); // 取消重力感应监听
    super.dispose();
  }

  /// 处理左键按下
  void _handleLeftKeyPress() {
    // 检查是否需要防抖
    if (_lastLeftKeyPressTime != null) {
      final timeDiff = DateTime.now().difference(_lastLeftKeyPressTime!);
      if (timeDiff < _debounceTime) {
        // 如果距离上次按键时间太短，则忽略此次按键
        return;
      }
    }

    // 更新最后按键时间
    _lastLeftKeyPressTime = DateTime.now();

    // 触发后退效果
    _triggerLeftRipple();
  }

  /// 处理右键按下
  void _handleRightKeyPress() {
    // 检查是否需要防抖
    if (_lastRightKeyPressTime != null) {
      final timeDiff = DateTime.now().difference(_lastRightKeyPressTime!);
      if (timeDiff < _debounceTime) {
        // 如果距离上次按键时间太短，则忽略此次按键
        return;
      }
    }

    // 更新最后按键时间
    _lastRightKeyPressTime = DateTime.now();

    // 触发快进效果
    _triggerRightRipple();
  }

  void _triggerLeftRipple() {
    if (_isLeftRippleActive1 || _isLeftRippleActive2) return;
    setState(() {
      _isLeftRippleActive1 = true;
      _isLeftRippleActive2 = false;
    });
    _leftRippleController1.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isLeftRippleActive2 = true;
        });
        _leftRippleController2.forward(from: 0);
      }
    });

    // 获取当前的时间
    Duration currentPosition =
        widget.myVideoStateController.currentPosition;
    int seconds = _configService[ConfigKey.REWIND_SECONDS_KEY] as int;
    if (currentPosition.inSeconds - seconds > 0) {
      currentPosition = Duration(seconds: currentPosition.inSeconds - seconds);
    } else {
      currentPosition = Duration.zero;
    }

    widget.myVideoStateController.handleSeek(currentPosition);
  }

  void _triggerRightRipple() {
    if (_isRightRippleActive1 || _isRightRippleActive2) return;
    setState(() {
      _isRightRippleActive1 = true;
      _isRightRippleActive2 = false;
    });
    _rightRippleController1.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isRightRippleActive2 = true;
        });
        _rightRippleController2.forward(from: 0);
      }
    });

    // 获取当前的时间
    Duration currentPosition =
        widget.myVideoStateController.currentPosition;
    Duration totalDuration = widget.myVideoStateController.totalDuration.value;
    int seconds = _configService[ConfigKey.FAST_FORWARD_SECONDS_KEY] as int;
    if (currentPosition.inSeconds + seconds < totalDuration.inSeconds) {
      currentPosition = Duration(seconds: currentPosition.inSeconds + seconds);
    } else {
      currentPosition = totalDuration;
    }
    widget.myVideoStateController.handleSeek(currentPosition);
  }

  // 单击事件
  void _onTap() {
    if (widget.myVideoStateController.isToolbarsLocked.value) {
      widget.myVideoStateController.showLockButton();
    } else {
      widget.myVideoStateController.toggleToolbars();
    }
  }

  // 添加显示音量提示的方法
  void _showVolumeInfo() {
    // 取消之前的计时器
    _volumeInfoTimer?.cancel();

    widget.myVideoStateController.isSlidingVolumeZone.value = true;
    _infoMessageFadeController.forward();

    // 设置新的计时器
    _volumeInfoTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _infoMessageFadeController.reverse().whenComplete(() {
          widget.myVideoStateController.isSlidingVolumeZone.value = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.myVideoStateController.isPiPMode.value) {
        return _buildPiPLayout(context);
      }
      return _buildNormalLayout(context);
    });
  }

  Widget _buildPiPLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Video(
        controller: widget.myVideoStateController.videoController,
        controls: null,
      ),
    );
  }

  Widget _buildNormalLayout(BuildContext context) {
    // 缓存屏幕内边距
    final double paddingTop = MediaQuery.paddingOf(context).top;
    return PopScope(
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (widget.isFullScreen) {
          await defaultExitNativeFullscreen();
          widget.myVideoStateController.isFullscreen.value = false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
            children: [
              // 剧院模式背景
              Obx(() {
                final isTheaterMode = _configService[ConfigKey.THEATER_MODE_KEY] as bool;
                if (!isTheaterMode) {
                  return const SizedBox.shrink();
                }

                // 使用 LayoutBuilder 获取精确尺寸
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    final thumbnailUrl = widget.myVideoStateController.videoInfo.value?.thumbnailUrl;
                    return _createBlurredBackground(thumbnailUrl, size);
                  },
                );
              }),
              // 主要内容
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // 计算可用尺寸一次获得，避免重复调用 MediaQuery
                  final Size screenSize =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  final double playPauseIconSize =
                      (screenSize.width * 0.15).clamp(40.0, 100.0);
                  final double bufferingSize = playPauseIconSize * 0.8;
                  final double maxRadius =
                      (screenSize.height - paddingTop) * 2 / 3;

                  return FocusScope(
                    autofocus: true,
                    canRequestFocus: true,
                    child: MouseRegion(
                      onEnter: (_) {
                        // 鼠标进入播放器区域
                        widget.myVideoStateController.setMouseHoveringPlayer(true);
                      },
                      onExit: (_) {
                        // 鼠标离开播放器区域
                        widget.myVideoStateController.setMouseHoveringPlayer(false);
                      },
                      onHover: (_) {
                        // 鼠标在播放器区域内移动时，处理移动事件
                        widget.myVideoStateController.onMouseMoveInPlayer();
                      },
                      child: KeyboardListener(
                        focusNode: _focusNode,
                        onKeyEvent: (KeyEvent event) {
                          if (event is KeyDownEvent) {
                            if (event.logicalKey ==
                                LogicalKeyboardKey.arrowLeft) {
                              _handleLeftKeyPress();
                            } else if (event.logicalKey ==
                                LogicalKeyboardKey.arrowRight) {
                              _handleRightKeyPress();
                            } else if (event.logicalKey ==
                                LogicalKeyboardKey.space) {
                              if (widget
                                  .myVideoStateController.videoPlaying.value) {
                                widget.myVideoStateController.player.pause();
                              } else {
                                widget.myVideoStateController.player.play();
                                widget.myVideoStateController.animateToTop();
                              }
                            } else if (event.logicalKey ==
                                LogicalKeyboardKey.arrowUp) {
                              // 获取当前音量
                              double currentVolume =
                                  _configService[ConfigKey.VOLUME_KEY];
                              // 增加音量，每次增加0.1，最大为1.0
                              double newVolume =
                                  (currentVolume + 0.1).clamp(0.0, 1.0);
                              widget.myVideoStateController.setVolume(newVolume);
                              // 显示音量提示
                              _showVolumeInfo();
                            } else if (event.logicalKey ==
                                LogicalKeyboardKey.arrowDown) {
                              // 获取当前音量
                              double currentVolume =
                                  _configService[ConfigKey.VOLUME_KEY];
                              // 减少音量，每次减少0.1，最小为0.0
                              double newVolume =
                                  (currentVolume - 0.1).clamp(0.0, 1.0);
                              widget.myVideoStateController.setVolume(newVolume);
                              // 显示音量提示
                              _showVolumeInfo();
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: paddingTop),
                          child: Stack(
                            children: [
                              // 视频播放区域
                              _buildVideoPlayer(),
                              // 手势监听区域（抽取后减少整体重绘）
                              ..._buildGestureAreas(screenSize),
                              // 工具栏部分
                              ..._buildToolbars(),
                              // 双击波纹动画等效果
                              _buildRippleEffects(screenSize, maxRadius),
                              // 中央控制面板，比如播放/暂停按钮
                              _buildVideoControlOverlay(
                                  playPauseIconSize, bufferingSize),
                              // InfoMessage 提示区域
                              _buildInfoMessage(),
                              // 播放速度信息提示（左下角）
                              _buildPlaybackSpeedInfoMessage(),
                              _buildSeekPreview(),
                              // 添加底部进度条
                              _buildBottomProgressBar(),
                              // 添加遮罩层
                              _buildMaskLayer(),
                              // 添加锁定按钮
                              _buildLockButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Center(
      child: Obx(() => AspectRatio(
            aspectRatio: widget.myVideoStateController.aspectRatio.value,
            child: Video(
              controller: widget.myVideoStateController.videoController,
              controls: null,
            ),
          )),
    );
  }

  List<Widget> _buildGestureAreas(Size screenSize) {
    return [
      Obx(() => Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: screenSize.width *
                _configService[
                    ConfigKey.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO],
            child: GestureArea(
              setLongPressing: _setLongPressing,
              onTap: _onTap,
              region: GestureRegion.left,
              myVideoStateController: widget.myVideoStateController,
              onDoubleTapLeft: _triggerLeftRipple,
              screenSize: screenSize,
              onHorizontalDragStart: _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                  ? (details) {
                      _horizontalDragStartX = details.localPosition.dx;
                      _horizontalDragStartPosition =
                          widget.myVideoStateController.currentPosition;
                      widget.myVideoStateController.setInteracting(true);
                      widget.myVideoStateController.showSeekPreview(true);
                      widget.myVideoStateController.isHorizontalDragging.value = true;
                    }
                  : null,
              onHorizontalDragUpdate: _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                  ? (details) {
                      if (_horizontalDragStartX == null ||
                          _horizontalDragStartPosition == null) {
                        return;
                      }

                      double dragDistance =
                          details.localPosition.dx - _horizontalDragStartX!;
                      double ratio = dragDistance / screenSize.width;

                      int offsetSeconds = (ratio * maxSeekSeconds).round();

                      Duration targetPosition = Duration(
                          seconds: (_horizontalDragStartPosition!.inSeconds +
                                  offsetSeconds)
                              .clamp(
                                  0,
                                  widget.myVideoStateController.totalDuration.value
                                      .inSeconds));

                      widget.myVideoStateController.updateSeekPreview(targetPosition);
                    }
                  : null,
              onHorizontalDragEnd: _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                  ? (details) {
                      if (_horizontalDragStartPosition != null) {
                        Duration targetPosition =
                            widget.myVideoStateController.previewPosition.value;
                        widget.myVideoStateController.handleSeek(targetPosition);
                      }

                      _horizontalDragStartX = null;
                      _horizontalDragStartPosition = null;
                      widget.myVideoStateController.setInteracting(false);
                      widget.myVideoStateController.showSeekPreview(false);
                    }
                  : null,
            ),
          )),
      Obx(() => Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: screenSize.width *
                _configService[
                    ConfigKey.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO],
            child: GestureArea(
              setLongPressing: _setLongPressing,
              onTap: _onTap,
              region: GestureRegion.right,
              myVideoStateController: widget.myVideoStateController,
              onDoubleTapRight: _triggerRightRipple,
              screenSize: screenSize,
              onVolumeChange: (volume) =>
                  widget.myVideoStateController.setVolume(volume, save: false),
              onHorizontalDragStart: _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                  ? (details) {
                      _horizontalDragStartX = details.localPosition.dx;
                      _horizontalDragStartPosition =
                          widget.myVideoStateController.currentPosition;
                      widget.myVideoStateController.setInteracting(true);
                      widget.myVideoStateController.showSeekPreview(true);
                      widget.myVideoStateController.isHorizontalDragging.value = true;
                    }
                  : null,
              onHorizontalDragUpdate: _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                  ? (details) {
                      if (_horizontalDragStartX == null ||
                          _horizontalDragStartPosition == null) {
                        return;
                      }

                      double dragDistance =
                          details.localPosition.dx - _horizontalDragStartX!;
                      double ratio = dragDistance / screenSize.width;

                      int offsetSeconds = (ratio * maxSeekSeconds).round();

                      Duration targetPosition = Duration(
                          seconds: (_horizontalDragStartPosition!.inSeconds +
                                  offsetSeconds)
                              .clamp(
                                  0,
                                  widget.myVideoStateController.totalDuration.value
                                      .inSeconds));

                      widget.myVideoStateController.updateSeekPreview(targetPosition);
                    }
                  : null,
              onHorizontalDragEnd: _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                  ? (details) {
                      if (_horizontalDragStartPosition != null) {
                        Duration targetPosition =
                            widget.myVideoStateController.previewPosition.value;
                        widget.myVideoStateController.handleSeek(targetPosition);
                      }

                      _horizontalDragStartX = null;
                      _horizontalDragStartPosition = null;
                      widget.myVideoStateController.setInteracting(false);
                      widget.myVideoStateController.showSeekPreview(false);
                    }
                  : null,
            ),
          )),
      Obx(() {
        double ratio =
            _configService[ConfigKey.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO]
                as double;
        double position = screenSize.width * ratio;
        return Positioned(
          left: position,
          right: position,
          top: 0,
          bottom: 0,
          child: GestureArea(
            setLongPressing: _setLongPressing,
            onTap: _onTap,
            onDoubleTap: () {
              if (widget.myVideoStateController.videoPlaying.value) {
                widget.myVideoStateController.player.pause();
              } else {
                widget.myVideoStateController.player.play();
                widget.myVideoStateController.animateToTop();
              }
            },
            region: GestureRegion.center,
            myVideoStateController: widget.myVideoStateController,
            screenSize: screenSize,
            onHorizontalDragStart: _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                ? (details) {
                    _horizontalDragStartX = details.localPosition.dx;
                    _horizontalDragStartPosition =
                        widget.myVideoStateController.currentPosition;
                    widget.myVideoStateController.setInteracting(true);
                    widget.myVideoStateController.showSeekPreview(true);
                  }
                : null,
            onHorizontalDragUpdate: _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                ? (details) {
                    if (_horizontalDragStartX == null ||
                        _horizontalDragStartPosition == null) {
                      return;
                    }

                    double dragDistance =
                        details.localPosition.dx - _horizontalDragStartX!;
                    double ratio = dragDistance / screenSize.width;

                    int offsetSeconds = (ratio * maxSeekSeconds).round();

                    Duration targetPosition = Duration(
                        seconds:
                            (_horizontalDragStartPosition!.inSeconds + offsetSeconds)
                                .clamp(
                                    0,
                                    widget.myVideoStateController.totalDuration.value
                                        .inSeconds));

                    widget.myVideoStateController.updateSeekPreview(targetPosition);
                  }
                : null,
            onHorizontalDragEnd: _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                ? (details) {
                    if (_horizontalDragStartPosition != null) {
                      Duration targetPosition =
                          widget.myVideoStateController.previewPosition.value;
                      widget.myVideoStateController.handleSeek(targetPosition);
                    }

                    _horizontalDragStartX = null;
                    _horizontalDragStartPosition = null;
                    widget.myVideoStateController.setInteracting(false);
                    widget.myVideoStateController.showSeekPreview(false);
                  }
                : null,
          ),
        );
      }),
    ];
  }

  List<Widget> _buildToolbars() {
    return [
      Positioned(
        top: -MediaQuery.paddingOf(context).top,
        left: 0,
        right: 0,
        child: TopToolbar(
            myVideoStateController: widget.myVideoStateController,
            currentScreenIsFullScreen: widget.isFullScreen),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: BottomToolbar(
            myVideoStateController: widget.myVideoStateController,
            currentScreenIsFullScreen: widget.isFullScreen),
      ),
    ];
  }

  Widget _buildRippleEffects(Size screenSize, double maxRadius) {
    return Positioned.fill(
      child: Stack(
        children: [
          if (_isLeftRippleActive1)
            _buildRipple(_leftRippleController1,
                Offset(0, screenSize.height / 2), maxRadius),
          if (_isLeftRippleActive2)
            _buildRipple(_leftRippleController2,
                Offset(0, screenSize.height / 2), maxRadius),
          if (_isRightRippleActive1)
            _buildRipple(_rightRippleController1,
                Offset(screenSize.width, screenSize.height / 2), maxRadius),
          if (_isRightRippleActive2)
            _buildRipple(_rightRippleController2,
                Offset(screenSize.width, screenSize.height / 2), maxRadius),
        ],
      ),
    );
  }

  Widget _buildRipple(
      AnimationController controller, Offset origin, double maxRadius) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: RipplePainter(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            animationValue: controller.value,
            origin: origin,
            maxRadius: maxRadius,
          ),
        );
      },
    );
  }

  Widget _buildVideoControlOverlay(
      double playPauseIconSize, double bufferingSize) {
    return Obx(
      () => Positioned.fill(
        child: _buildLoadingOrControlContent(playPauseIconSize, bufferingSize),
      ),
    );
  }

  // 构建加载或控制内容
  Widget _buildLoadingOrControlContent(double playPauseIconSize, double bufferingSize) {
    final controller = widget.myVideoStateController;

     // 如果视频源有错误，显示错误状态
    if (controller.videoSourceErrorMessage.value != null) {
      return Center(
        child: ErrorStateWidget(
          controller: controller,
          size: playPauseIconSize,
        ),
      );
    }
    
    // 如果播放器未准备好，显示加载状态
    if (!controller.videoPlayerReady.value) {
      return Center(
        child: LoadingStateWidget(
          controller: controller,
          size: playPauseIconSize,
        ),
      );
    }
    
    // 正常状态：显示缓冲动画或播放/暂停按钮
    return controller.videoBuffering.value
        ? Center(
            child: _buildBufferingAnimation(controller, bufferingSize),
          )
        : Center(
            child: _buildPlayPauseIcon(controller, playPauseIconSize),
          );
  }



  Widget _buildPlayPauseIcon(
      MyVideoStateController myVideoStateController, double size) {
    return Obx(() => AnimatedOpacity(
          opacity: myVideoStateController.videoPlaying.value ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  // 添加震动反馈
                  VibrateUtils.vibrate();

                  if (myVideoStateController.videoPlaying.value) {
                    myVideoStateController.player.pause();
                  } else {
                    myVideoStateController.player.play();
                    myVideoStateController.animateToTop();
                  }
                },
                customBorder: const CircleBorder(),
                child: AnimatedScale(
                  scale: myVideoStateController.videoPlaying.value ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    myVideoStateController.videoPlaying.value
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: size * 0.6, // 图标大小为容器的60%
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black.withValues(alpha: 0.5),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  /// 构建缓冲动画，尺寸自适应
  Widget _buildBufferingAnimation(
      MyVideoStateController myVideoStateController, double size) {
    return Obx(() => myVideoStateController.videoBuffering.value
        ? Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(size * 0.2), // 内边距为尺寸的20%
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: size * 0.08, // 线条宽度为尺寸的8%
              ).animate(onPlay: (controller) => controller.repeat()).rotate(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.linear,
                  ),
            ),
          )
        : const SizedBox.shrink());
  }

  void _setLongPressing(LongPressType? longPressType, bool value) async {
    if (value) {
      switch (longPressType) {
        case LongPressType.brightness:
          widget.myVideoStateController.isSlidingBrightnessZone.value = true;
          widget.myVideoStateController.isSlidingVolumeZone.value = false;
          widget.myVideoStateController.isLongPressing.value = false;
          _infoMessageFadeController.forward();
          break;
        case LongPressType.volume:
          widget.myVideoStateController.isSlidingVolumeZone.value = true;
          widget.myVideoStateController.isSlidingBrightnessZone.value = false;
          widget.myVideoStateController.isLongPressing.value = false;
          _infoMessageFadeController.forward();
          break;
        case LongPressType.normal:
          widget.myVideoStateController.isLongPressing.value = true;
          widget.myVideoStateController.isSlidingBrightnessZone.value = false;
          widget.myVideoStateController.isSlidingVolumeZone.value = false;
          widget.myVideoStateController
              .setLongPressPlaybackSpeedByConfiguration();
          _infoMessageFadeController.forward();
          break;
        default:
          _infoMessageFadeController.reverse();
          break;
      }
    } else {
      _infoMessageFadeController.reverse().whenComplete(() {
        widget.myVideoStateController.isLongPressing.value = false;
        widget.myVideoStateController.isSlidingBrightnessZone.value = false;
        widget.myVideoStateController.isSlidingVolumeZone.value = false;
      });
    }
  }

  // 音量和亮度信息提示（屏幕中心偏上）
  Widget _buildInfoMessage() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 100,
      left: 0,
      right: 0,
      child: Center(
        child: _buildInfoContent(),
      ),
    );
  }

  Widget _buildInfoContent() {
    final controller = widget.myVideoStateController;
    return Obx(() {
      if (controller.isSlidingVolumeZone.value) {
        return _buildFadeTransition(child: _buildVolumeInfoMessage());
      } else if (controller.isSlidingBrightnessZone.value) {
        return _buildFadeTransition(child: _buildBrightnessInfoMessage());
      }
      return const SizedBox.shrink();
    });
  }

  // 播放速度信息提示（屏幕左下角）
  Widget _buildPlaybackSpeedInfoMessage() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Obx(() {
        if (!widget.myVideoStateController.isLongPressing.value) {
          return const SizedBox.shrink();
        }
        double rate =
            _configService[ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY] as double;
        return _buildFadeTransitionNoBg(
          child: PlaybackSpeedAnimationWidget(
            playbackSpeed: rate,
            isVisible: widget.myVideoStateController.isLongPressing.value,
          ),
        );
      }),
    );
  }

  Widget _buildFadeTransition({required Widget child}) {
    return FadeTransition(
      opacity: _infoMessageOpacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      ),
    );
  }

  Widget _buildFadeTransitionNoBg({required Widget child}) {
    return FadeTransition(
      opacity: _infoMessageOpacity,
      child: child,
    );
  }



  Widget _buildBrightnessInfoMessage() {
    return Obx(() {
      var curBrightness = _configService[ConfigKey.BRIGHTNESS_KEY] as double;
      IconData brightnessIcon;
      String brightnessText;

      if (curBrightness <= 0.0) {
        brightnessIcon = Icons.brightness_3_rounded;
        brightnessText = slang.t.videoDetail.brightnessLowest;
      } else if (curBrightness > 0.0 && curBrightness <= 0.2) {
        brightnessIcon = Icons.brightness_2_rounded;
        brightnessText =
            '${slang.t.videoDetail.brightness}: ${(curBrightness * 100).toInt()}%';
      } else if (curBrightness > 0.2 && curBrightness <= 0.5) {
        brightnessIcon = Icons.brightness_5_rounded;
        brightnessText =
            '${slang.t.videoDetail.brightness}: ${(curBrightness * 100).toInt()}%';
      } else if (curBrightness > 0.5 && curBrightness <= 0.8) {
        brightnessIcon = Icons.brightness_4_rounded;
        brightnessText =
            '${slang.t.videoDetail.brightness}: ${(curBrightness * 100).toInt()}%';
      } else if (curBrightness > 0.8 && curBrightness <= 1.0) {
        brightnessIcon = Icons.brightness_7_rounded;
        brightnessText =
            '${slang.t.videoDetail.brightness}: ${(curBrightness * 100).toInt()}%';
      } else {
        // 处理意外情况，例如亮度超过范围
        brightnessIcon = Icons.brightness_3_rounded;
        brightnessText =
            '${slang.t.videoDetail.brightness}: ${(curBrightness * 100).toInt()}%';
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(brightnessIcon, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            brightnessText,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      );
    });
  }

  Widget _buildVolumeInfoMessage() {
    return Obx(() {
      var curVolume = _configService[ConfigKey.VOLUME_KEY] as double;
      IconData volumeIcon;
      String volumeText;

      if (curVolume == 0.0) {
        volumeIcon = Icons.volume_off;
        volumeText = slang.t.videoDetail.volumeMuted;
      } else if (curVolume > 0.0 && curVolume <= 0.3) {
        volumeIcon = Icons.volume_down;
        volumeText =
            '${slang.t.videoDetail.volume}: ${(curVolume * 100).toInt()}%';
      } else if (curVolume > 0.3 && curVolume <= 1.0) {
        volumeIcon = Icons.volume_up;
        volumeText =
            '${slang.t.videoDetail.volume}: ${(curVolume * 100).toInt()}%';
      } else {
        // 处理意外情况，例如音量超过范围
        volumeIcon = Icons.volume_off;
        volumeText =
            '${slang.t.videoDetail.volume}: ${(curVolume * 100).toInt()}%';
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(volumeIcon, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            volumeText,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      );
    });
  }

  Widget _buildSeekPreview() {
    return Obx(() {
      if (!widget.myVideoStateController.isSeekPreviewVisible.value) {
        return const SizedBox.shrink();
      }

      Duration previewPosition =
          widget.myVideoStateController.previewPosition.value;
      Duration totalDuration =
          widget.myVideoStateController.totalDuration.value;

      // 计算进度百分比
      double progress = totalDuration.inMilliseconds > 0
          ? previewPosition.inMilliseconds / totalDuration.inMilliseconds
          : 0.0;

      return Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            width: 200, // 设置固定宽度
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[700],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 8),
                // 时间对比
                Text(
                  '${CommonUtils.formatDuration(previewPosition)} / ${CommonUtils.formatDuration(totalDuration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // 在类中添加新的方法
  Widget _buildBottomProgressBar() {
    return Obx(() {
      if (!_configService[
          ConfigKey.SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN]) {
        return const SizedBox.shrink();
      }

      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: widget.myVideoStateController.animationController,
            builder: (context, child) {
              // 当工具栏显示时（animationController.value = 1），进度条透明度为0
              // 当工具栏隐藏时（animationController.value = 0），进度条透明度为1
              double opacity =
                  1.0 - widget.myVideoStateController.animationController.value;

              return Opacity(
                opacity: opacity,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      final colorTheme = Theme.of(context).colorScheme.primary;

                      return Obx(() {
                        final currentPosition =
                            widget.myVideoStateController.toShowCurrentPosition.value;
                        final totalDuration =
                            widget.myVideoStateController.totalDuration.value;
                        final buffers = widget.myVideoStateController.buffers;

                        // 计算当前进度的宽度
                        double progressWidth = totalDuration.inMilliseconds > 0
                            ? (currentPosition.inMilliseconds /
                                    totalDuration.inMilliseconds) *
                                totalWidth
                            : 0.0;

                        return Stack(
                          children: [
                            // 背景层
                            Container(
                              width: totalWidth,
                              height: 3,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            // 缓冲层
                            ...buffers.map((buffer) {
                              double startX = totalDuration.inMilliseconds > 0
                                  ? (buffer.start.inMilliseconds /
                                          totalDuration.inMilliseconds) *
                                      totalWidth
                                  : 0.0;
                              double endX = totalDuration.inMilliseconds > 0
                                  ? (buffer.end.inMilliseconds /
                                          totalDuration.inMilliseconds) *
                                      totalWidth
                                  : 0.0;

                              return Positioned(
                                left: startX,
                                child: Container(
                                  width: endX - startX,
                                  height: 3,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              );
                            }),
                            // 进度层
                            Container(
                              width: progressWidth,
                              height: 3,
                              color: colorTheme,
                            ),
                          ],
                        );
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildMaskLayer() {
    return Obx(() => widget.myVideoStateController.isToolbarsLocked.value
        ? Positioned.fill(
            child: GestureDetector(
              onTap: () {
                widget.myVideoStateController.showLockButton();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          )
        : const SizedBox.shrink());
  }

  Widget _buildLockButton() {
    final lockButtonPosition = _configService[ConfigKey.VIDEO_TOOLBAR_LOCK_BUTTON_POSITION] as int;
    
    return Stack(
      children: [
        // 左侧按钮
        if (lockButtonPosition == 1 || lockButtonPosition == 2)
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Obx(() {
                final isVisible = widget.myVideoStateController.isLockButtonVisible.value;
                final isLocked = widget.myVideoStateController.isToolbarsLocked.value;

                return IgnorePointer(
                  ignoring: !isVisible,
                  child: AnimatedOpacity(
                    opacity: isVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            widget.myVideoStateController.toggleLockState();
                            // 添加震动反馈
                            VibrateUtils.vibrate();
                            // 如果当前处于未锁定，且视频暂停，则播放视频
                            if (!isLocked &&
                                !widget.myVideoStateController.videoPlaying.value) {
                              widget.myVideoStateController.player.play();
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Icon(
                            isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        
        // 右侧按钮
        if (lockButtonPosition == 1 || lockButtonPosition == 3)
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Obx(() {
                final isVisible = widget.myVideoStateController.isLockButtonVisible.value;
                final isLocked = widget.myVideoStateController.isToolbarsLocked.value;

                return IgnorePointer(
                  ignoring: !isVisible,
                  child: AnimatedOpacity(
                    opacity: isVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            widget.myVideoStateController.toggleLockState();
                            // 添加震动反馈
                            VibrateUtils.vibrate();
                            // 如果当前处于未锁定，且视频暂停，则播放视频
                            if (!isLocked &&
                                !widget.myVideoStateController.videoPlaying.value) {
                              widget.myVideoStateController.player.play();
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Icon(
                            isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  // 优化模糊背景创建方法
  void _updateBlurredBackground(String? thumbnailUrl, Size size) async {
    // 如果尺寸和URL都没变，不需要更新
    if (_lastSize == size && _lastThumbnailUrl == thumbnailUrl) {
      return;
    }

    _lastSize = size;
    _lastThumbnailUrl = thumbnailUrl;

    if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
      _sizedBlurredBackground = Container(
        width: size.width,
        height: size.height,
        color: Colors.black,
      );
      return;
    }

    // 添加防抖机制，避免频繁的图像处理
    if (_blurUpdateTimer?.isActive ?? false) {
      _blurUpdateTimer!.cancel();
    }

    _blurUpdateTimer = Timer(const Duration(milliseconds: 300), () {
      _performBlurUpdate(thumbnailUrl, size);
    });
  }

  Timer? _blurUpdateTimer;

  void _performBlurUpdate(String thumbnailUrl, Size size) async {

    try {
      // 1. 首先加载原始图片，使用较小的分辨率减少内存占用
      final NetworkImage networkImage = NetworkImage(thumbnailUrl);
      final ImageConfiguration config = ImageConfiguration(
        size: Size(size.width * 0.5, size.height * 0.5), // 使用一半分辨率
      );
      final ImageStream stream = networkImage.resolve(config);
      final Completer<ui.Image> completer = Completer<ui.Image>();

      stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }));

      final ui.Image originalImage = await completer.future;

      // 2. 计算适当的绘制尺寸以保持宽高比
      final double imageAspectRatio = originalImage.width / originalImage.height;
      final double screenAspectRatio = size.width / size.height;
      
      double targetWidth = size.width;
      double targetHeight = size.height;
      double offsetX = 0;
      double offsetY = 0;

      if (imageAspectRatio > screenAspectRatio) {
        // 图片比屏幕更宽，以高度为基准
        targetWidth = size.height * imageAspectRatio;
        offsetX = -(targetWidth - size.width) / 2;
      } else {
        // 图片比屏幕更高，以宽度为基准
        targetHeight = size.width / imageAspectRatio;
        offsetY = -(targetHeight - size.height) / 2;
      }

      // 3. 创建一个自定义画布，使用目标尺寸
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // 4. 绘制图片并应用模糊效果
      final paint = Paint()
        ..imageFilter = ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20);
      
      // 使用计算后的偏移量和尺寸绘制图片
      canvas.drawImageRect(
        originalImage,
        Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
        Rect.fromLTWH(offsetX, offsetY, targetWidth, targetHeight),
        paint,
      );
      
      // 5. 将模糊后的图片转换为图像
      final blurredImage = await recorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt()
      );
      
      // 6. 转换为字节数据
      final byteData = await blurredImage.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // 7. 创建新的缓存Widget
      if (mounted) {
        setState(() {
          _sizedBlurredBackground = Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.black),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0.2,
                  child: Image.memory(
                    buffer,
                    fit: BoxFit.cover,
                    width: size.width,
                    height: size.height,
                  ),
                ),
              ),
            ],
          );
        });
      }

    } catch (e) {
      LogUtils.e('创建模糊背景失败: $e', tag: 'MyVideoScreen');
      _sizedBlurredBackground = Container(
        width: size.width,
        height: size.height,
        color: Colors.black,
      );
    }
  }

  // 修改 _createBlurredBackground 方法
  Widget _createBlurredBackground(String? thumbnailUrl, Size size) {
    // 如果缓存不存在，触发异步更新
    if (_sizedBlurredBackground == null || 
        _lastSize != size || 
        _lastThumbnailUrl != thumbnailUrl) {
      _updateBlurredBackground(thumbnailUrl, size);
      
      // 返回一个占位的黑色背景
      return Container(
        width: size.width,
        height: size.height,
        color: Colors.black,
      );
    }
    
    // 返回缓存的模糊背景
    return _sizedBlurredBackground!;
  }
}

/// 长按类型 [滑动也属于长按]
enum LongPressType {
  brightness,
  volume,
  normal,
}
