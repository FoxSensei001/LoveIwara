import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/video_fullscreen_handoff.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/player_keybinding/player_action.dart';
import 'package:i_iwara/app/services/player_keybinding/player_keybinding_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/rapple_painter.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';

import 'bottom_toolbar_widget.dart';
import 'fullscreen_inner_playlist_drawer.dart';
import 'gesture_area_widget.dart';
import 'top_toolbar_widget.dart';
import 'video_zoom_view.dart';
import 'widgets/playback_speed_animation_widget.dart';
import 'widgets/loading_state_widget.dart';
import 'widgets/error_state_widget.dart';
import '../../controllers/my_video_state_controller.dart';
import '../../../../../../i18n/strings.g.dart' as slang;

class VideoDetailHorizontalDragSeekLogic {
  const VideoDetailHorizontalDragSeekLogic._();

  static Duration seedPreviewPosition(Duration dragStartPosition) {
    return dragStartPosition;
  }

  static Duration calculatePreviewPosition({
    required Duration dragStartPosition,
    required double dragDistance,
    required double screenWidth,
    required Duration totalDuration,
    required int maxSeekSeconds,
  }) {
    if (screenWidth <= 0) {
      return seedPreviewPosition(dragStartPosition);
    }

    final double ratio = dragDistance / screenWidth;
    final int offsetSeconds = (ratio * maxSeekSeconds).round();

    return Duration(
      seconds: (dragStartPosition.inSeconds + offsetSeconds).clamp(
        0,
        totalDuration.inSeconds,
      ),
    );
  }
}

class MyVideoScreen extends StatefulWidget {
  final bool isFullScreen;
  final MyVideoStateController myVideoStateController;
  final bool enableBottomSafeArea;
  final InnerPlaylistContext? innerPlaylistContext;

  const MyVideoScreen({
    super.key,
    this.isFullScreen = false,
    this.enableBottomSafeArea = false,
    required this.myVideoStateController,
    this.innerPlaylistContext,
  });

  @override
  State<MyVideoScreen> createState() => _MyVideoScreenState();
}

class _MyVideoScreenState extends State<MyVideoScreen>
    with TickerProviderStateMixin, WindowListener, WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  final ConfigService _configService = Get.find();
  final AppService _appService = Get.find();
  final PlayerKeybindingService _keybindingService = Get.find();
  // 静音切换前的音量，用于「取消静音」时恢复。
  double? _volumeBeforeMute;
  bool _isSyncingDesktopFullscreenExit = false;
  bool _innerPlaylistExpanded = false;
  bool _isSwitchingInnerPlaylistVideo = false;
  InnerPlaylistItemSnapshot? _loadingInnerPlaylistItem;

  Timer? _autoHideTimer;
  Timer? _volumeInfoTimer; // 添加音量提示计时器
  Timer? _playbackSpeedInfoTimer; // 倍速调整的临时提示计时器

  // 倍速调整可用档位（与底部工具栏 / 设置页保持一致）。
  static const List<double> _playbackSpeedSteps = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
    2.5,
    3.0,
  ];
  DateTime? _lastLeftKeyPressTime;
  DateTime? _lastRightKeyPressTime;
  static const Duration _debounceTime = Duration(milliseconds: 300);

  // 进度键长按倍速：按住超过阈值进入长按倍速模式，松开恢复。
  Timer? _seekHoldTimer;
  int? _heldSeekKeyId;
  PlayerAction? _heldSeekAction;
  bool _seekLongPressActive = false;
  static const Duration _seekLongPressThreshold = Duration(milliseconds: 350);

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

  // 底部预览 tooltip 状态：用于淡出时保持最后位置
  double? _bottomTooltipX;
  Duration? _bottomTooltipTime;
  bool _bottomTooltipVisible = false;

  // 添加缓存的模糊背景
  String? _lastThumbnailUrl;

  // 添加尺寸缓存
  Size? _lastSize;
  Widget? _sizedBlurredBackground;

  @override
  void initState() {
    LogUtils.d("[${widget.isFullScreen ? '全屏' : '内嵌'} 初始化]", 'MyVideoScreen');
    super.initState();
    // 监听焦点丢失与应用生命周期变化：按住进度键期间若失焦/切窗口/进入后台，
    // KeyUpEvent 可能不再回到本 KeyboardListener，需要主动收尾长按倍速，避免卡在倍速态。
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(_handleFocusChange);
    // 如果是全屏状态
    if (widget.isFullScreen) {
      _appService.hideSystemUI();
      if (GetPlatform.isDesktop) {
        windowManager.addListener(this);
      }
      // 继续播放
      // 如果当前是非全屏，则继续播放
      if (!widget.myVideoStateController.isFullscreen.value) {
        unawaited(widget.myVideoStateController.playFromUserAction());
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
    _orientationCheckTimer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (timer) {
        if (!mounted || !widget.isFullScreen) {
          timer.cancel();
          return;
        }
        _checkOrientationChange();
      },
    );
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
      // 路由内全屏接力时，不要在旧的 fullscreen overlay dispose 时闪回系统 UI。
      final suppressCleanup = widget.myVideoStateController
          .consumeFullscreenCleanupSuppression();
      if (!suppressCleanup) {
        _appService.showSystemUI();
      }
      if (GetPlatform.isDesktop) {
        windowManager.removeListener(this);
      }
      // 恢复播放
      // widget.myVideoStateController.player.play();
    }
    // 先摘除监听，避免下面 dispose 焦点节点触发 unfocus 回调，碰到已 dispose 的控制器。
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_handleFocusChange);
    // 清理进度键长按倍速状态（不经 _setLongPressing，避免触碰即将 dispose 的动画控制器）。
    _seekHoldTimer?.cancel();
    if (_seekLongPressActive) {
      final controller = widget.myVideoStateController;
      controller.isLongPressing.value = false;
      controller.setPlaybackSpeed(controller.playerPlaybackSpeed.value);
      _seekLongPressActive = false;
    }
    _focusNode.dispose();
    _leftRippleController1.dispose();
    _leftRippleController2.dispose();
    _rightRippleController1.dispose();
    _rightRippleController2.dispose();
    _infoMessageFadeController.dispose();
    _autoHideTimer?.cancel();
    _volumeInfoTimer?.cancel(); // 取消音量提示计时器
    _playbackSpeedInfoTimer?.cancel(); // 取消倍速提示计时器
    _blurUpdateTimer?.cancel(); // 清理模糊背景更新定时器
    _orientationCheckTimer?.cancel(); // 取消重力感应监听
    widget.myVideoStateController.setMouseHoverToolbarRevealSuppressed(false);
    super.dispose();
  }

  @override
  void onWindowLeaveFullScreen() {
    if (!GetPlatform.isDesktop || !widget.isFullScreen) return;
    if (_isSyncingDesktopFullscreenExit || !mounted) return;

    final currentRoute = ModalRoute.of(context);
    if (currentRoute == null || !currentRoute.isCurrent) {
      return;
    }

    _isSyncingDesktopFullscreenExit = true;
    LogUtils.d(
      'desktop leave native fullscreen -> sync state',
      'MyVideoScreen',
    );

    widget.myVideoStateController.isDesktopAppFullScreen.value = false;
    widget.myVideoStateController.isFullscreen.value = false;
    _appService.showSystemUI();
    unawaited(
      widget.myVideoStateController.restoreDesktopWindowGeometryAfterFullscreen(
        reason: 'windowListener.onWindowLeaveFullScreen',
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.myVideoStateController.isDesktopAppFullScreen.value = false;
      widget.myVideoStateController.isFullscreen.value = false;
      _appService.showSystemUI();
    });
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

  /// 播放器键盘事件入口：区分按下/松开，以支持进度键长按倍速。
  void _handlePlayerKeyEvent(KeyEvent event) {
    // 松开进度键：决定是点按 seek 还是退出长按倍速。
    if (event is KeyUpEvent) {
      if (_heldSeekKeyId != null &&
          event.logicalKey.keyId == _heldSeekKeyId) {
        _finishSeekHold();
      }
      return;
    }
    // 仅处理首次按下；KeyRepeatEvent 交给定时器判定长按。
    if (event is! KeyDownEvent) return;

    final action = _keybindingService.resolve(event);
    if (action == null) return;

    // 初始播放封面阶段只允许「播放/暂停」唤起首次播放。
    if (widget.myVideoStateController.shouldShowInitialPlaybackCover) {
      if (action == PlayerAction.playPause) {
        unawaited(widget.myVideoStateController.requestInitialPlayback());
      }
      return;
    }

    // 进度键：按下先挂起，松开时再区分点按/长按。
    if (action == PlayerAction.seekForward ||
        action == PlayerAction.seekBackward) {
      _beginSeekHold(action, event.logicalKey.keyId);
      return;
    }

    _dispatchKeybindingAction(action);
  }

  /// 将解析出的快捷键动作分派到对应的播放器行为。
  void _dispatchKeybindingAction(PlayerAction action) {
    final controller = widget.myVideoStateController;
    switch (action) {
      case PlayerAction.playPause:
        if (controller.videoPlaying.value) {
          controller.pausePlayback();
        } else {
          unawaited(controller.playFromUserAction());
        }
        break;
      case PlayerAction.speedUp:
        _adjustPlaybackSpeed(1);
        break;
      case PlayerAction.speedDown:
        _adjustPlaybackSpeed(-1);
        break;
      case PlayerAction.seekForward:
        _handleRightKeyPress();
        break;
      case PlayerAction.seekBackward:
        _handleLeftKeyPress();
        break;
      case PlayerAction.volumeUp:
        _adjustVolumeBy(0.1);
        break;
      case PlayerAction.volumeDown:
        _adjustVolumeBy(-0.1);
        break;
      case PlayerAction.toggleMute:
        _toggleMute();
        break;
      case PlayerAction.toggleFullscreen:
        _toggleFullscreen();
        break;
    }
  }

  void _adjustVolumeBy(double delta) {
    final double currentVolume = _configService[ConfigKey.VOLUME_KEY];
    final double newVolume = (currentVolume + delta).clamp(0.0, 1.0);
    widget.myVideoStateController.setVolume(newVolume);
    if (newVolume > 0) _volumeBeforeMute = null;
    _showVolumeInfo();
  }

  void _toggleMute() {
    final double currentVolume = _configService[ConfigKey.VOLUME_KEY];
    if (currentVolume > 0) {
      _volumeBeforeMute = currentVolume;
      widget.myVideoStateController.setVolume(0.0);
    } else {
      final double restore = (_volumeBeforeMute ?? 0.4).clamp(0.0, 1.0);
      widget.myVideoStateController.setVolume(restore > 0 ? restore : 0.4);
      _volumeBeforeMute = null;
    }
    _showVolumeInfo();
  }

  void _toggleFullscreen() {
    final controller = widget.myVideoStateController;
    if (controller.isFullscreen.value) {
      unawaited(controller.exitFullscreen());
    } else {
      unawaited(controller.enterFullscreen());
    }
  }

  // ---------------------------------------------------------------------------
  // 进度键的「点按 = 单次快进/快退，长按 = 长按倍速」处理
  // ---------------------------------------------------------------------------

  /// 进度键按下：先记录待定状态，松开时再区分点按/长按。
  void _beginSeekHold(PlayerAction action, int keyId) {
    // 异常情况下已有按住的进度键，先收尾。
    if (_heldSeekKeyId != null) {
      _cancelSeekHold();
    }
    _heldSeekAction = action;
    _heldSeekKeyId = keyId;
    _seekLongPressActive = false;
    _seekHoldTimer?.cancel();
    _seekHoldTimer = Timer(_seekLongPressThreshold, _enterSeekLongPress);
  }

  /// 按住超过阈值：进入长按倍速模式（复用手势长按的同一套逻辑）。
  void _enterSeekLongPress() {
    final controller = widget.myVideoStateController;
    // 暂停/缓冲时不进入倍速，保持为「松开即单次 seek」。
    if (!controller.videoPlaying.value || controller.videoBuffering.value) {
      return;
    }
    _seekLongPressActive = true;
    _setLongPressing(LongPressType.normal, true);
  }

  /// 进度键松开：长按则退出倍速，否则执行一次快进/快退。
  void _finishSeekHold() {
    _seekHoldTimer?.cancel();
    _seekHoldTimer = null;
    final action = _heldSeekAction;
    final wasLongPress = _seekLongPressActive;
    _heldSeekKeyId = null;
    _heldSeekAction = null;
    _seekLongPressActive = false;

    if (wasLongPress) {
      _exitSeekLongPress();
    } else if (action == PlayerAction.seekForward) {
      _handleRightKeyPress();
    } else if (action == PlayerAction.seekBackward) {
      _handleLeftKeyPress();
    }
  }

  /// 退出长按倍速并恢复正常倍速（对齐手势 _onLongPressEnd 的恢复逻辑）。
  void _exitSeekLongPress() {
    _setLongPressing(LongPressType.normal, false);
    Timer(const Duration(milliseconds: 50), () {
      if (mounted) {
        final controller = widget.myVideoStateController;
        controller.setPlaybackSpeed(controller.playerPlaybackSpeed.value);
      }
    });
  }

  /// 焦点丢失（切窗口、系统弹窗、被路由遮挡等）时，KeyUpEvent 可能不再到达，
  /// 主动收尾长按倍速，避免卡在倍速态。
  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _cancelSeekHold();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 进入后台/失活时同样收尾，避免回前台后仍停留在长按倍速。
    if (state != AppLifecycleState.resumed) {
      _cancelSeekHold();
    }
  }

  /// 收尾进度键按住状态（如切换按键、失焦、生命周期变化、销毁时）。
  void _cancelSeekHold() {
    _seekHoldTimer?.cancel();
    _seekHoldTimer = null;
    if (_seekLongPressActive) {
      _exitSeekLongPress();
    }
    _heldSeekKeyId = null;
    _heldSeekAction = null;
    _seekLongPressActive = false;
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
    Duration currentPosition = widget.myVideoStateController.currentPosition;
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
    Duration currentPosition = widget.myVideoStateController.currentPosition;
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
    // 双指捏合进行中时忽略单击，避免误触发显隐控件
    if (widget.myVideoStateController.isPinchingVideo) {
      return;
    }
    if (widget.myVideoStateController.isToolbarsLocked.value) {
      widget.myVideoStateController.showLockButton();
    } else {
      widget.myVideoStateController.toggleToolbars();
    }
  }

  /// 按档位调整「当前视频」的播放倍速（不写入默认配置，因此不影响其它视频），
  /// 并在播放器上弹出临时提示。
  void _adjustPlaybackSpeed(int direction) {
    final controller = widget.myVideoStateController;
    final double current = controller.playerPlaybackSpeed.value;
    final double next = direction > 0
        ? _playbackSpeedSteps.firstWhere(
            (s) => s > current + 0.001,
            orElse: () => _playbackSpeedSteps.last,
          )
        : _playbackSpeedSteps.lastWhere(
            (s) => s < current - 0.001,
            orElse: () => _playbackSpeedSteps.first,
          );
    if (next != current) {
      // persistAsDefault 默认 false：仅作用于当前视频，不改写默认倍速。
      controller.setPlaybackSpeed(next);
    }
    _showPlaybackSpeedInfo();
  }

  // 显示倍速调整的临时提示（屏幕中央偏上，约 1 秒后淡出）。
  void _showPlaybackSpeedInfo() {
    _playbackSpeedInfoTimer?.cancel();
    final controller = widget.myVideoStateController;
    controller.isShowingPlaybackSpeedInfo.value = true;
    // 与音量/亮度提示共用同一组淡入淡出动画。
    controller.isSlidingVolumeZone.value = false;
    controller.isSlidingBrightnessZone.value = false;
    _infoMessageFadeController.forward();

    _playbackSpeedInfoTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        _infoMessageFadeController.reverse().whenComplete(() {
          controller.isShowingPlaybackSpeedInfo.value = false;
        });
      }
    });
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

  InnerPlaylistContext? get _effectiveInnerPlaylistContext {
    final context = widget.innerPlaylistContext;
    final currentVideo = widget.myVideoStateController.videoInfo.value;
    if (context == null || currentVideo == null) {
      return context;
    }

    final liked = currentVideo.liked;
    final numLikes = currentVideo.numLikes;
    if (liked == null || numLikes == null) {
      return context;
    }

    return context.copyWithVideoLikeState(
      videoId: currentVideo.id,
      liked: liked,
      numLikes: numLikes,
    );
  }

  List<InnerPlaylistItemSnapshot> get _orderedInnerPlaylistItems {
    return _effectiveInnerPlaylistContext?.itemsStartingAfterCurrent() ??
        const <InnerPlaylistItemSnapshot>[];
  }

  bool _canShowInnerPlaylistOverlay() {
    final hintEnabled =
        _configService[ConfigKey.SHOW_FULLSCREEN_UP_NEXT_HINT] as bool;
    // 竖屏全屏视频同样需要保留“接着看”入口，不能只在横屏时渲染。
    return widget.isFullScreen &&
        _orderedInnerPlaylistItems.isNotEmpty &&
        (_innerPlaylistExpanded || hintEnabled);
  }

  void _syncMouseHoverToolbarSuppression() {
    widget.myVideoStateController.setMouseHoverToolbarRevealSuppressed(
      _innerPlaylistExpanded,
    );
  }

  void _openInnerPlaylistDrawer() {
    if (_orderedInnerPlaylistItems.isEmpty || _isSwitchingInnerPlaylistVideo) {
      return;
    }

    setState(() {
      _innerPlaylistExpanded = true;
    });
    _syncMouseHoverToolbarSuppression();
    widget.myVideoStateController.hideToolbars();
  }

  void _closeInnerPlaylistDrawer({bool restoreToolbars = true}) {
    if (!_innerPlaylistExpanded) {
      return;
    }

    setState(() {
      _innerPlaylistExpanded = false;
    });
    _syncMouseHoverToolbarSuppression();

    if (restoreToolbars) {
      widget.myVideoStateController.showToolbars();
    }
  }

  void _showInnerPlaylistErrorToast(String message) {
    if (message.trim().isEmpty) {
      return;
    }
    showToastWidget(
      MDToastWidget(message: message, type: MDToastType.error),
      position: ToastPosition.top,
    );
  }

  Future<void> _handleInnerPlaylistSelection(
    InnerPlaylistItemSnapshot item,
  ) async {
    if (_isSwitchingInnerPlaylistVideo ||
        item.id == widget.myVideoStateController.videoId) {
      return;
    }

    setState(() {
      _isSwitchingInnerPlaylistVideo = true;
      _innerPlaylistExpanded = true;
      _loadingInnerPlaylistItem = item;
    });

    // 不再阻塞式预加载视频详情：直接用侧边栏快照携带的原始视频信息立即跳转。
    // 目标页用 initialVideoInfo 先渲染缩略图/标题等播放器框架，播放源在后台加载；
    // 站内/站外的判断也直接复用快照里的 isExternalVideo，无需联网。
    final targetVideo = item.sourceVideo;
    final nextContext = _effectiveInnerPlaylistContext?.copyForSelection(
      item.id,
    );

    try {
      late final Future<Object?> navigationFuture;
      if (item.isExternalVideo) {
        await widget.myVideoStateController.exitFullscreen();
        navigationFuture = NaviService.navigateToVideoDetailPage(
          item.id,
          innerPlaylistContext: nextContext,
          initialVideoInfo: targetVideo,
        );
      } else {
        final VideoFullscreenHandoff? fullscreenHandoff = widget
            .myVideoStateController
            .buildFullscreenHandoff();
        navigationFuture = NaviService.navigateToVideoDetailPage(
          item.id,
          innerPlaylistContext: nextContext,
          forceAutoPlay: true,
          forceEnterFullscreen: true,
          initialVideoInfo: targetVideo,
          fullscreenHandoff: fullscreenHandoff,
        );
        widget.myVideoStateController.relinquishFullscreenForRouteHandoff();
      }

      unawaited(
        navigationFuture.whenComplete(() {
          if (!mounted) {
            return;
          }
          setState(() {
            _isSwitchingInnerPlaylistVideo = false;
            _loadingInnerPlaylistItem = null;
          });
        }),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showInnerPlaylistErrorToast(CommonUtils.parseExceptionMessage(e));
      setState(() {
        _isSwitchingInnerPlaylistVideo = false;
        _loadingInnerPlaylistItem = null;
      });
    }
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
    final playerScaffold = Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 剧院模式背景
          Obx(() {
            final isTheaterMode =
                _configService[ConfigKey.THEATER_MODE_KEY] as bool;
            if (!isTheaterMode) {
              return const SizedBox.shrink();
            }

            // 使用 LayoutBuilder 获取精确尺寸
            return LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final thumbnailUrl =
                    widget.myVideoStateController.videoInfo.value?.thumbnailUrl;
                return _createBlurredBackground(thumbnailUrl, size);
              },
            );
          }),
          // 主要内容
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // 计算可用尺寸一次获得，避免重复调用 MediaQuery
              final Size screenSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final double playPauseIconSize = (screenSize.width * 0.15).clamp(
                40.0,
                100.0,
              );
              final double bufferingSize = playPauseIconSize * 0.8;
              final double maxRadius = (screenSize.height - paddingTop) * 2 / 3;

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
                    onKeyEvent: _handlePlayerKeyEvent,
                    child: Container(
                      padding: EdgeInsets.only(top: paddingTop),
                      // 画面缩放/平移手势层：作为整个播放器栈的祖先，可靠侦测双指捏合
                      child: Obx(() {
                        final zoomEnabled =
                            _configService[ConfigKey
                                    .ENABLE_VIDEO_GESTURE_ZOOM] ==
                                true;
                        return VideoZoomGestureLayer(
                          controller: widget.myVideoStateController,
                          enabled: zoomEnabled,
                          child: _buildPlayerStack(
                            screenSize,
                            playPauseIconSize,
                            bufferingSize,
                            maxRadius,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    // 内嵌播放器不参与系统 back 链，避免与页面级返回处理叠加。
    // 全屏返回由视频详情页的 PopScope 统一处理（先退出全屏，再正常返回）。
    return playerScaffold;
  }

  Widget _buildPlayerStack(
    Size screenSize,
    double playPauseIconSize,
    double bufferingSize,
    double maxRadius,
  ) {
    return Obx(() {
      final controller = widget.myVideoStateController;
      final showInitialPlaybackCover =
          controller.shouldShowInitialPlaybackCover;
      final showPlaybackChrome = controller.shouldShowPlaybackChrome;

      return Stack(
        children: [
          // 视频播放区域
          _buildVideoPlayer(),
          if (showInitialPlaybackCover) _buildInitialPlaybackCover(),
          // 手势监听区域（抽取后减少整体重绘）
          if (showPlaybackChrome) ..._buildGestureAreas(screenSize),
          // 工具栏部分
          if (showPlaybackChrome) ..._buildToolbars(),
          // 双击波纹动画等效果
          if (showPlaybackChrome) _buildRippleEffects(screenSize, maxRadius),
          // 中央控制面板，比如播放/暂停按钮
          _buildVideoControlOverlay(playPauseIconSize, bufferingSize),
          if (controller.shouldShowLoadingBackButton) _buildLoadingBackButton(),
          // InfoMessage 提示区域
          if (controller.shouldShowOverlayHud) _buildInfoMessage(),
          // 播放速度信息提示（左下角）
          if (controller.shouldShowOverlayHud) _buildPlaybackSpeedInfoMessage(),
          // 添加底部进度条
          if (controller.shouldShowOverlayHud) _buildBottomProgressBar(),
          // 添加遮罩层
          if (showPlaybackChrome) _buildMaskLayer(),
          // 添加锁定按钮
          if (showPlaybackChrome) _buildLockButton(),
          if (controller.shouldShowOverlayHud)
            _buildInnerPlaylistOverlay(screenSize),
        ],
      );
    });
  }

  Widget _buildVideoPlayer() {
    return ClipRect(
      child: Center(
        child: Obx(() {
          final controller = widget.myVideoStateController;
          final scale = controller.videoZoomScale.value;
          final offset = controller.videoZoomOffset.value;
          final rotation = controller.videoZoomRotation.value;
          Widget video = AspectRatio(
            aspectRatio: controller.aspectRatio.value,
            child: Video(
              controller: controller.videoController,
              controls: null,
            ),
          );
          // 仅在缩放/平移/旋转时套用 Transform，未变换时保持原始渲染路径
          if (scale != 1.0 || offset != Offset.zero || rotation != 0.0) {
            video = Transform.translate(
              offset: offset,
              child: Transform.rotate(
                angle: rotation,
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: video,
                ),
              ),
            );
          }
          return video;
        }),
      ),
    );
  }

  Widget _buildLoadingBackButton() {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double toolbarHeight = widget.isFullScreen ? 60.0 : 48.0;
    final double iconSize = widget.isFullScreen ? 24.0 : 20.0;
    return Positioned(
      top: -statusBarHeight,
      left: 0,
      child: SizedBox(
        height: toolbarHeight + statusBarHeight,
        child: Padding(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: IconButton(
            tooltip: t.common.back,
            icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
            onPressed: () {
              if (widget.isFullScreen) {
                unawaited(widget.myVideoStateController.exitFullscreen());
              } else {
                AppService.tryPop(context: context);
              }
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGestureAreas(Size screenSize) {
    return [
      Obx(
        () => Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width:
              screenSize.width *
              _configService[ConfigKey.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO],
          child: GestureArea(
            setLongPressing: _setLongPressing,
            onTap: _onTap,
            region: GestureRegion.left,
            myVideoStateController: widget.myVideoStateController,
            onDoubleTapLeft: _triggerLeftRipple,
            screenSize: screenSize,
            onHorizontalDragStart:
                _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                ? (details) {
                    _horizontalDragStartX = details.localPosition.dx;
                    _horizontalDragStartPosition =
                        widget.myVideoStateController.currentPosition;
                    widget.myVideoStateController.setInteracting(true);
                    widget.myVideoStateController.showSeekPreview(true);
                    widget.myVideoStateController.updateSeekPreview(
                      VideoDetailHorizontalDragSeekLogic.seedPreviewPosition(
                        _horizontalDragStartPosition!,
                      ),
                    );
                    widget.myVideoStateController.isHorizontalDragging.value =
                        true;
                  }
                : null,
            onHorizontalDragUpdate:
                _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                ? (details) {
                    if (_horizontalDragStartX == null ||
                        _horizontalDragStartPosition == null) {
                      return;
                    }

                    // 检查是否从边缘区域开始滑动
                    const edgeThreshold =
                        CommonConstants.videoPlayerEdgeGestureThreshold;
                    final screenWidth = screenSize.width;

                    // 从左侧边缘向右滑动,忽略
                    if (_horizontalDragStartX! < edgeThreshold &&
                        details.localPosition.dx - _horizontalDragStartX! > 0) {
                      if (widget.myVideoStateController.isFullscreen.value) {
                        return;
                      }
                    }

                    // 从右侧边缘向左滑动,忽略
                    if (_horizontalDragStartX! > screenWidth - edgeThreshold &&
                        details.localPosition.dx - _horizontalDragStartX! < 0) {
                      if (widget.myVideoStateController.isFullscreen.value) {
                        return;
                      }
                    }

                    double dragDistance =
                        details.localPosition.dx - _horizontalDragStartX!;
                    final Duration targetPosition =
                        VideoDetailHorizontalDragSeekLogic.calculatePreviewPosition(
                          dragStartPosition: _horizontalDragStartPosition!,
                          dragDistance: dragDistance,
                          screenWidth: screenSize.width,
                          totalDuration:
                              widget.myVideoStateController.totalDuration.value,
                          maxSeekSeconds: maxSeekSeconds,
                        );

                    widget.myVideoStateController.updateSeekPreview(
                      targetPosition,
                    );
                  }
                : null,
            onHorizontalDragEnd:
                _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
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
        ),
      ),
      Obx(
        () => Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width:
              screenSize.width *
              _configService[ConfigKey.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO],
          child: GestureArea(
            setLongPressing: _setLongPressing,
            onTap: _onTap,
            region: GestureRegion.right,
            myVideoStateController: widget.myVideoStateController,
            onDoubleTapRight: _triggerRightRipple,
            screenSize: screenSize,
            onVolumeChange: (volume) =>
                widget.myVideoStateController.setVolume(volume, save: false),
            onHorizontalDragStart:
                _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                ? (details) {
                    _horizontalDragStartX = details.localPosition.dx;
                    _horizontalDragStartPosition =
                        widget.myVideoStateController.currentPosition;
                    widget.myVideoStateController.setInteracting(true);
                    widget.myVideoStateController.showSeekPreview(true);
                    widget.myVideoStateController.updateSeekPreview(
                      VideoDetailHorizontalDragSeekLogic.seedPreviewPosition(
                        _horizontalDragStartPosition!,
                      ),
                    );
                    widget.myVideoStateController.isHorizontalDragging.value =
                        true;
                  }
                : null,
            onHorizontalDragUpdate:
                _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                ? (details) {
                    if (_horizontalDragStartX == null ||
                        _horizontalDragStartPosition == null) {
                      return;
                    }

                    // 检查是否从边缘区域开始滑动
                    const edgeThreshold =
                        CommonConstants.videoPlayerEdgeGestureThreshold;
                    final screenWidth = screenSize.width;

                    // 从左侧边缘向右滑动,忽略
                    if (_horizontalDragStartX! < edgeThreshold &&
                        details.localPosition.dx - _horizontalDragStartX! > 0) {
                      if (widget.myVideoStateController.isFullscreen.value) {
                        return;
                      }
                    }

                    // 从右侧边缘向左滑动,忽略
                    if (_horizontalDragStartX! > screenWidth - edgeThreshold &&
                        details.localPosition.dx - _horizontalDragStartX! < 0) {
                      if (widget.myVideoStateController.isFullscreen.value) {
                        return;
                      }
                    }

                    double dragDistance =
                        details.localPosition.dx - _horizontalDragStartX!;
                    final Duration targetPosition =
                        VideoDetailHorizontalDragSeekLogic.calculatePreviewPosition(
                          dragStartPosition: _horizontalDragStartPosition!,
                          dragDistance: dragDistance,
                          screenWidth: screenSize.width,
                          totalDuration:
                              widget.myVideoStateController.totalDuration.value,
                          maxSeekSeconds: maxSeekSeconds,
                        );

                    widget.myVideoStateController.updateSeekPreview(
                      targetPosition,
                    );
                  }
                : null,
            onHorizontalDragEnd:
                _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
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
        ),
      ),
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
                widget.myVideoStateController.pausePlayback();
              } else {
                unawaited(widget.myVideoStateController.playFromUserAction());
              }
            },
            region: GestureRegion.center,
            myVideoStateController: widget.myVideoStateController,
            screenSize: screenSize,
            onHorizontalDragStart:
                _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                ? (details) {
                    _horizontalDragStartX = details.localPosition.dx;
                    _horizontalDragStartPosition =
                        widget.myVideoStateController.currentPosition;
                    widget.myVideoStateController.setInteracting(true);
                    widget.myVideoStateController.showSeekPreview(true);
                    widget.myVideoStateController.updateSeekPreview(
                      VideoDetailHorizontalDragSeekLogic.seedPreviewPosition(
                        _horizontalDragStartPosition!,
                      ),
                    );
                    widget.myVideoStateController.isHorizontalDragging.value =
                        true;
                  }
                : null,
            onHorizontalDragUpdate:
                _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
                ? (details) {
                    if (_horizontalDragStartX == null ||
                        _horizontalDragStartPosition == null) {
                      return;
                    }

                    // 检查是否从边缘区域开始滑动
                    const edgeThreshold =
                        CommonConstants.videoPlayerEdgeGestureThreshold;
                    final screenWidth = screenSize.width;

                    // 从左侧边缘向右滑动,忽略
                    if (_horizontalDragStartX! < edgeThreshold &&
                        details.localPosition.dx - _horizontalDragStartX! > 0) {
                      if (widget.myVideoStateController.isFullscreen.value) {
                        return;
                      }
                    }

                    // 从右侧边缘向左滑动,忽略
                    if (_horizontalDragStartX! > screenWidth - edgeThreshold &&
                        details.localPosition.dx - _horizontalDragStartX! < 0) {
                      if (widget.myVideoStateController.isFullscreen.value) {
                        return;
                      }
                    }

                    double dragDistance =
                        details.localPosition.dx - _horizontalDragStartX!;
                    final Duration targetPosition =
                        VideoDetailHorizontalDragSeekLogic.calculatePreviewPosition(
                          dragStartPosition: _horizontalDragStartPosition!,
                          dragDistance: dragDistance,
                          screenWidth: screenSize.width,
                          totalDuration:
                              widget.myVideoStateController.totalDuration.value,
                          maxSeekSeconds: maxSeekSeconds,
                        );

                    widget.myVideoStateController.updateSeekPreview(
                      targetPosition,
                    );
                  }
                : null,
            onHorizontalDragEnd:
                _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true
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
    final bottomToolbar = BottomToolbar(
      myVideoStateController: widget.myVideoStateController,
      currentScreenIsFullScreen: widget.isFullScreen,
      applyBottomSafeAreaPadding:
          (!widget.isFullScreen && widget.enableBottomSafeArea),
    );

    return [
      Positioned(
        top: -MediaQuery.paddingOf(context).top,
        left: 0,
        right: 0,
        child: TopToolbar(
          myVideoStateController: widget.myVideoStateController,
          currentScreenIsFullScreen: widget.isFullScreen,
        ),
      ),
      Positioned(bottom: 0, left: 0, right: 0, child: bottomToolbar),
    ];
  }

  Widget _buildInnerPlaylistOverlay(Size screenSize) {
    if (!_canShowInnerPlaylistOverlay()) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final showResumePositionTip =
          widget.myVideoStateController.showResumePositionTip.value;

      return AnimatedBuilder(
        animation: widget.myVideoStateController.animationController,
        builder: (context, child) {
          final toolbarVisibility =
              (1 - widget.myVideoStateController.bottomBarAnimation.value.dy)
                  .clamp(0.0, 1.0);

          return FullscreenInnerPlaylistDrawer(
            items: _orderedInnerPlaylistItems,
            isExpanded: _innerPlaylistExpanded,
            showHint:
                (_configService[ConfigKey.SHOW_FULLSCREEN_UP_NEXT_HINT]
                    as bool) &&
                !_innerPlaylistExpanded &&
                !_isSwitchingInnerPlaylistVideo,
            isBusy: _isSwitchingInnerPlaylistVideo,
            loadingItemId: _isSwitchingInnerPlaylistVideo
                ? _loadingInnerPlaylistItem?.id
                : null,
            onExpand: _openInnerPlaylistDrawer,
            onCollapse: _closeInnerPlaylistDrawer,
            onDismiss: () => _closeInnerPlaylistDrawer(restoreToolbars: false),
            toolbarVisibility: toolbarVisibility,
            showResumePositionTip: showResumePositionTip,
            onSelectItem: (item) {
              unawaited(_handleInnerPlaylistSelection(item));
            },
          );
        },
      );
    });
  }

  Widget _buildRippleEffects(Size screenSize, double maxRadius) {
    return Positioned.fill(
      child: Stack(
        children: [
          if (_isLeftRippleActive1)
            _buildRipple(
              _leftRippleController1,
              Offset(0, screenSize.height / 2),
              maxRadius,
            ),
          if (_isLeftRippleActive2)
            _buildRipple(
              _leftRippleController2,
              Offset(0, screenSize.height / 2),
              maxRadius,
            ),
          if (_isRightRippleActive1)
            _buildRipple(
              _rightRippleController1,
              Offset(screenSize.width, screenSize.height / 2),
              maxRadius,
            ),
          if (_isRightRippleActive2)
            _buildRipple(
              _rightRippleController2,
              Offset(screenSize.width, screenSize.height / 2),
              maxRadius,
            ),
        ],
      ),
    );
  }

  Widget _buildRipple(
    AnimationController controller,
    Offset origin,
    double maxRadius,
  ) {
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
    double playPauseIconSize,
    double bufferingSize,
  ) {
    return Obx(
      () => Positioned.fill(
        child: _buildLoadingOrControlContent(playPauseIconSize, bufferingSize),
      ),
    );
  }

  // 构建加载或控制内容
  Widget _buildLoadingOrControlContent(
    double playPauseIconSize,
    double bufferingSize,
  ) {
    final controller = widget.myVideoStateController;
    switch (controller.centerOverlayState) {
      case VideoCenterOverlayState.sourceError:
        return Center(
          child: ErrorStateWidget(
            controller: controller,
            size: playPauseIconSize,
          ),
        );
      case VideoCenterOverlayState.loadingVideoInfo:
        return Center(child: _buildCenterOnlySpinner(playPauseIconSize));
      case VideoCenterOverlayState.initialPlaybackCover:
        return const SizedBox.shrink();
      case VideoCenterOverlayState.initialPlaybackLoading:
      case VideoCenterOverlayState.preparingPlayer:
        return Center(
          child: LoadingStateWidget(
            controller: controller,
            size: playPauseIconSize,
          ),
        );
      case VideoCenterOverlayState.seeking:
      case VideoCenterOverlayState.rebufferingWhilePlaying:
        return Center(
          child: _buildBufferingAnimation(controller, bufferingSize),
        );
      case VideoCenterOverlayState.playbackControls:
        if (_configService[ConfigKey.SHOW_CENTER_PLAY_PAUSE_BUTTON] != true) {
          return const SizedBox.shrink();
        }
        return Center(
          child: _buildPlayPauseIcon(controller, playPauseIconSize),
        );
    }
  }

  Widget _buildCenterOnlySpinner(double size) {
    final indicatorSize = (size * 0.32).clamp(18.0, 34.0);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildInitialPlaybackCover() {
    final controller = widget.myVideoStateController;
    final videoInfo = controller.videoInfo.value;
    final coverUrl = videoInfo?.thumbnailUrl;
    final canTapToStart = !controller.hasRequestedInitialPlayback.value;

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: canTapToStart
            ? () {
                VibrateUtils.vibrate();
                unawaited(controller.requestInitialPlayback());
              }
            : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (coverUrl != null && coverUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const ColoredBox(color: Colors.black),
                errorWidget: (context, url, error) =>
                    const ColoredBox(color: Colors.black),
              )
            else
              const ColoredBox(color: Colors.black),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                ),
              ),
            ),
            if (canTapToStart)
              Positioned(
                right: 18,
                bottom: 18,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayPauseIcon(
    MyVideoStateController myVideoStateController,
    double size,
  ) {
    return Obx(
      () => AnimatedOpacity(
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
                // 双指捏合进行中时忽略，避免误触发暂停/播放
                if (myVideoStateController.isPinchingVideo) {
                  return;
                }
                // 添加震动反馈
                VibrateUtils.vibrate();

                if (myVideoStateController.videoPlaying.value) {
                  myVideoStateController.pausePlayback();
                } else {
                  await myVideoStateController.playFromUserAction();
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
      ),
    );
  }

  /// 构建缓冲动画，尺寸自适应
  Widget _buildBufferingAnimation(
    MyVideoStateController myVideoStateController,
    double size,
  ) {
    return Obx(
      () => myVideoStateController.videoBuffering.value
          ? LoadingStateWidget(controller: myVideoStateController, size: size)
          : const SizedBox.shrink(),
    );
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
      child: Center(child: _buildInfoContent()),
    );
  }

  Widget _buildInfoContent() {
    final controller = widget.myVideoStateController;
    return Obx(() {
      if (controller.isSlidingVolumeZone.value) {
        return _buildFadeTransition(child: _buildVolumeInfoMessage());
      } else if (controller.isSlidingBrightnessZone.value) {
        return _buildFadeTransition(child: _buildBrightnessInfoMessage());
      } else if (controller.isShowingPlaybackSpeedInfo.value) {
        return _buildFadeTransition(child: _buildPlaybackSpeedInfoContent());
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
        // 使用控制器中的当前长按速度（可以通过横向滑动调整）
        double rate = widget.myVideoStateController.currentLongPressSpeed.value;
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
    return FadeTransition(opacity: _infoMessageOpacity, child: child);
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

  // 倍速展示格式化：去掉多余的小数 0（1.0 -> 1，1.5 -> 1.5）。
  static String _formatPlaybackSpeed(double speed) {
    final String s = speed.toStringAsFixed(2);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  // 倍速调整的提示内容（图标 + 当前倍速）。
  Widget _buildPlaybackSpeedInfoContent() {
    return Obx(() {
      final double speed = widget.myVideoStateController.playerPlaybackSpeed.value;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '${_formatPlaybackSpeed(speed)}x',
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

  // 在类中添加新的方法
  Widget _buildBottomProgressBar() {
    return Obx(() {
      if (!_configService[ConfigKey
          .SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN]) {
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
              final toolbarValue =
                  widget.myVideoStateController.animationController.value;
              double opacity = 1.0 - toolbarValue;

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
                        final currentPosition = widget
                            .myVideoStateController
                            .toShowCurrentPosition
                            .value;
                        final totalDuration =
                            widget.myVideoStateController.totalDuration.value;
                        final buffers = widget.myVideoStateController.buffers;
                        final isHorizontalDragging = widget
                            .myVideoStateController
                            .isHorizontalDragging
                            .value;
                        final previewPosition =
                            widget.myVideoStateController.previewPosition.value;

                        // 计算当前进度的宽度
                        // 如果正在横向拖拽，使用预览位置；否则使用当前播放位置
                        final Duration positionToShow = isHorizontalDragging
                            ? previewPosition
                            : currentPosition;
                        double progressWidth = totalDuration.inMilliseconds > 0
                            ? (positionToShow.inMilliseconds /
                                      totalDuration.inMilliseconds) *
                                  totalWidth
                            : 0.0;

                        // 计算 tooltip 的位置（仅在横向拖拽且 toolbar 隐藏时显示）
                        double? tooltipX;
                        Duration? tooltipTime;
                        final isPreviewReady = widget
                            .myVideoStateController
                            .isPreviewPlayerReady
                            .value;
                        // 工具栏完全展开时不渲染底部预览 tooltip
                        final bool isToolbarExpanded = toolbarValue >= 1.0;

                        if (!isToolbarExpanded &&
                            isHorizontalDragging &&
                            opacity > 0.5) {
                          // toolbar 隐藏时（opacity > 0.5 表示进度条可见）
                          tooltipX = progressWidth;
                          tooltipTime = previewPosition;

                          // 更新预览播放器位置（限流）
                          if (isPreviewReady) {
                            widget.myVideoStateController.updatePreviewSeek(
                              previewPosition,
                            );
                          }
                        }

                        // 底部 tooltip 也保持最后位置，消失时原地淡出
                        if (tooltipX != null && tooltipTime != null) {
                          _bottomTooltipX = tooltipX;
                          _bottomTooltipTime = tooltipTime;
                          _bottomTooltipVisible = true;
                        } else if (_bottomTooltipX != null &&
                            _bottomTooltipTime != null) {
                          tooltipX = _bottomTooltipX;
                          tooltipTime = _bottomTooltipTime;
                          _bottomTooltipVisible = false;
                        }

                        return Stack(
                          clipBehavior: Clip.none, // 允许 tooltip 溢出
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
                            // Tooltip（仅在横向拖拽且 toolbar 隐藏时显示，并带有淡入淡出效果）
                            if (tooltipX != null && tooltipTime != null)
                              Positioned(
                                left: tooltipX,
                                bottom: 3 + 12, // 距离底部进度条 12px
                                child: _buildPreviewTooltip(
                                  tooltipTime,
                                  isPreviewReady,
                                  visible: _bottomTooltipVisible,
                                  tooltipX: tooltipX,
                                  totalWidth: totalWidth,
                                ),
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

  // Tooltip 宽度常量
  static const double _tooltipWidth = 160.0;

  /// 构建预览 tooltip（包含预览视频画面，带淡入淡出效果）
  Widget _buildPreviewTooltip(
    Duration time,
    bool isPreviewReady, {
    bool visible = true,
    required double tooltipX,
    required double totalWidth,
  }) {
    final controller = widget.myVideoStateController;

    // 计算 tooltip 的水平偏移量，确保不超出屏幕边界
    // tooltip 宽度的一半
    const double halfTooltipWidth = _tooltipWidth / 2;
    // 默认居中偏移 -0.5
    double horizontalOffset = -0.5;

    // 左边界检查：如果 tooltip 左边会超出屏幕
    if (tooltipX < halfTooltipWidth) {
      // 计算需要的偏移量，使 tooltip 左边缘对齐到屏幕左边缘（留 4px 边距）
      horizontalOffset = -(tooltipX - 4) / _tooltipWidth;
      horizontalOffset = horizontalOffset.clamp(-1.0, 0.0);
    }
    // 右边界检查：如果 tooltip 右边会超出屏幕
    else if (tooltipX > totalWidth - halfTooltipWidth) {
      // 计算需要的偏移量，使 tooltip 右边缘对齐到屏幕右边缘（留 4px 边距）
      horizontalOffset = -1.0 + (totalWidth - tooltipX - 4) / _tooltipWidth;
      horizontalOffset = horizontalOffset.clamp(-1.0, 0.0);
    }

    return FractionalTranslation(
      // 根据位置动态调整水平偏移，确保 tooltip 不超出边界
      translation: Offset(horizontalOffset, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: visible ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
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
                // 优先使用预览视频画面；如果暂不可用，则仅展示时间信息
                if (isPreviewReady && controller.previewVideoController != null)
                  Container(
                    width: 160,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Video(
                      controller: controller.previewVideoController!,
                      controls: null,
                      fit: BoxFit.cover,
                    ),
                  ),
                // 时间文本（无论是否有预览视频都展示）
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    CommonUtils.formatDuration(time),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaskLayer() {
    return Obx(
      () => widget.myVideoStateController.isToolbarsLocked.value
          ? Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  widget.myVideoStateController.showLockButton();
                },
                child: Container(color: Colors.transparent),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildLockButton() {
    final leftInset = MediaQuery.paddingOf(context).left + 16;

    return Positioned(
      left: leftInset,
      top: 0,
      bottom: 0,
      child: Center(
        child: Obx(() {
          final isVisible =
              widget.myVideoStateController.isLockButtonVisible.value;
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
                        unawaited(
                          widget.myVideoStateController.playFromUserAction(),
                        );
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

      stream.addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info.image);
        }),
      );

      final ui.Image originalImage = await completer.future;

      // 2. 计算适当的绘制尺寸以保持宽高比
      final double imageAspectRatio =
          originalImage.width / originalImage.height;
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
        Rect.fromLTWH(
          0,
          0,
          originalImage.width.toDouble(),
          originalImage.height.toDouble(),
        ),
        Rect.fromLTWH(offsetX, offsetY, targetWidth, targetHeight),
        paint,
      );

      // 5. 将模糊后的图片转换为图像
      final blurredImage = await recorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt(),
      );

      // 6. 转换为字节数据
      final byteData = await blurredImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final buffer = byteData!.buffer.asUint8List();

      // 7. 创建新的缓存Widget
      if (mounted) {
        setState(() {
          _sizedBlurredBackground = Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.black)),
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
    final shouldUpdate =
        _sizedBlurredBackground == null ||
        _lastSize != size ||
        _lastThumbnailUrl != thumbnailUrl;
    if (shouldUpdate) {
      _updateBlurredBackground(thumbnailUrl, size);
    }

    final placeholder = Container(
      width: size.width,
      height: size.height,
      color: Colors.black,
    );

    final child = _sizedBlurredBackground ?? placeholder;
    final key = ValueKey(_sizedBlurredBackground == null ? 'black' : 'blur');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: KeyedSubtree(key: key, child: child),
    );
  }
}

/// 长按类型 [滑动也属于长按]
enum LongPressType { brightness, volume, normal }
