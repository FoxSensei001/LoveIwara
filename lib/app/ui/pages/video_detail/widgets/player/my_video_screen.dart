import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/player_keybinding/keybinding_service.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_action.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_scope.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_target_registry.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/blurred_thumbnail_background.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/rapple_painter.dart';
import 'package:i_iwara/app/ui/widgets/color_vision_filter_wrapper.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

import 'bottom_toolbar_widget.dart';
import 'gesture_area_widget.dart';
import 'top_toolbar_widget.dart';
import 'video_zoom_view.dart';
import 'widgets/playback_speed_animation_widget.dart';
import 'widgets/loading_state_widget.dart';
import 'widgets/error_state_widget.dart';
import 'widgets/playback_issue_sheet.dart';
import 'widgets/player_notice_chip.dart';
import 'player_box_scope.dart';
import 'player_stack_builder.dart';
import 'seek_preview.dart';
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

  /// 抽屉里有没有东西可看。没有就连贴边把手都不出现——给用户开一扇通往空房间
  /// 的门比不给更糟。
  final bool hasPlaybackQueue;

  /// 打开「接着看」抽屉。抽屉本体是一条 root 路由（见 playback_queue_drawer.dart），
  /// 不再是播放器里那条横向列表，所以这里只负责发起。
  final VoidCallback? onOpenQueueDrawer;

  const MyVideoScreen({
    super.key,
    this.isFullScreen = false,
    this.enableBottomSafeArea = false,
    required this.myVideoStateController,
    this.innerPlaylistContext,
    this.hasPlaybackQueue = false,
    this.onOpenQueueDrawer,
  });

  @override
  State<MyVideoScreen> createState() => _MyVideoScreenState();
}

class _MyVideoScreenState extends State<MyVideoScreen>
    with TickerProviderStateMixin, WindowListener, WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  // 帧末焦点回收是否已排队，避免同一帧多次 didChangeDependencies 排重复回调。
  bool _focusReclaimScheduled = false;
  final ConfigService _configService = Get.find();
  final AppService _appService = Get.find();
  final KeybindingService _keybindingService = Get.find();
  // 静音切换前的音量，用于「取消静音」时恢复。
  double? _volumeBeforeMute;
  bool _isSyncingDesktopFullscreenExit = false;

  /// 底部细进度条上那扇预览窗口的最后位置。留着是为了让它**原地淡出**——
  /// 直接把组件摘掉就成了硬切，出现与消失都要有过渡。
  double? _bottomSeekPreviewX;
  Duration? _bottomSeekPreviewTime;

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
  ShortcutAction? _heldSeekAction;
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

  @override
  void initState() {
    LogUtils.d("[${widget.isFullScreen ? '全屏' : '内嵌'} 初始化]", 'MyVideoScreen');
    super.initState();
    // 监听焦点丢失与应用生命周期变化：按住进度键期间若失焦/切窗口/进入后台，
    // KeyUpEvent 可能不再回到本 KeyboardListener，需要主动收尾长按倍速，避免卡在倍速态。
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(_handleFocusChange);
    // 视频域按键不再依赖「焦点恰好落在本子树」——那会让快捷键在绝大多数时候
    // 静默失效（真机实测：新开视频页 20 秒内注入 5 次按键一条都收不到）。
    // 改由应用根部统一收键后询问本表，见 ShortcutTargetRegistry 的说明。
    ShortcutTargetRegistry.instance.register(
      owner: this,
      scope: ShortcutScope.video,
      handle: _handlePlayerKeyEvent,
      isEligible: _acceptsShortcutsNow,
    );
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
    }

    _initializeAnimationControllers();
    _initializeInfoMessageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 依赖变化（主题、尺寸、安全区…）后把键盘焦点拿回播放器，保证快捷键继续可用。
    //
    // 但**只能在焦点本来就在播放器所在的 FocusScope 里时**才抢：尺寸、安全区或
    // 主题变化仍会走到这里，而此时焦点可能正落在弹层的输入框上
    // （登录弹窗、评论回复框…），无条件 requestFocus 会把它顶掉 —— 表现为输入法
    // 刚弹出就被立刻关闭、输入框失焦，并在「弹出→失焦→收起→再次布局」之间反复。
    // 弹层挂在 root navigator 上、播放器在 shell 路由里，两边的 ModalRoute 各自
    // 都是 current，所以路由层面拦不住这次抢焦点，只能按 FocusScope 判断。
    _scheduleFocusReclaim();
  }

  /// 把焦点回收推迟到本帧末尾再做。
  ///
  /// didChangeDependencies 完全可能发生在「旧播放器子树刚被 deactivate、新子树
  /// 正在 mount」的同一帧里（布局宽窄切换、全屏叠加层进出、Obx 换掉整棵
  /// MyVideoScreen 都会这样）。此刻 FocusManager.primaryFocus 仍指向那个**已
  /// deactivate 但还没 unmount** 的 Focus 元素，对它做祖先查找会直接抛
  /// “Looking up a deactivated widget's ancestor is unsafe”——`Element.mounted`
  /// 只有 unmount 之后才变 false，拦不住 inactive 态，所以查不出来也躲不掉。
  ///
  /// 帧末（buildOwner.finalizeTree() 之后）再判断即可安全：inactive 的元素这时
  /// 要么已被 GlobalKey 复用回活跃态，要么已 unmount（mounted == false）。
  void _scheduleFocusReclaim() {
    if (_focusReclaimScheduled) return;
    _focusReclaimScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusReclaimScheduled = false;
      if (!mounted) return;
      _reclaimFocusIfStillOwned();
    });
  }

  /// 仅当焦点仍属于播放器所在的 FocusScope 时才重新请求焦点。
  void _reclaimFocusIfStillOwned() {
    if (_focusNode.hasFocus) return;
    // 任何文本输入正在编辑（不论它在弹层还是在本路由内）都不抢，
    // 否则等于替用户关掉输入法。
    if (_isTextInputFocused()) return;
    // createDependency: false —— 只读当前 scope，不给这棵重子树再加一条
    // 会随焦点变化重建的依赖。
    if (!FocusScope.of(context, createDependency: false).hasFocus) return;
    _focusNode.requestFocus();
  }

  /// 当前主焦点是否落在某个 [EditableText] 上（TextField / TextFormField 等）。
  bool _isTextInputFocused() {
    final BuildContext? focusedContext =
        FocusManager.instance.primaryFocus?.context;
    // 只在帧末调用（见 [_scheduleFocusReclaim]），此时 mounted 才足以区分
    // “已随子树销毁”的元素，祖先查找是安全的。
    if (focusedContext == null || !focusedContext.mounted) return false;
    return focusedContext.findAncestorWidgetOfExactType<EditableText>() != null;
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

  @override
  void dispose() {
    ShortcutTargetRegistry.instance.unregister(this);
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
    _volumeInfoTimer?.cancel(); // 取消音量提示计时器
    _playbackSpeedInfoTimer?.cancel(); // 取消倍速提示计时器
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

    widget.myVideoStateController.exitDesktopAppFullscreen();
    widget.myVideoStateController.isFullscreen.value = false;
    _appService.showSystemUI();
    unawaited(
      widget.myVideoStateController.restoreDesktopWindowGeometryAfterFullscreen(
        reason: 'windowListener.onWindowLeaveFullScreen',
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.myVideoStateController.exitDesktopAppFullscreen();
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

  /// 本层此刻是否应该接管视频域按键。
  ///
  /// 每次派发都实时求值（不能用事件标记：本项目已踩过「RouteObserver 不把
  /// removeRoute / pushReplacement 转成 didPopNext，事件标记会永久冻结」的坑）。
  /// 四道闸门缺一不可：
  /// 1. 本层与当前全屏态一致——内嵌层与全屏叠加层会**同时挂载**，只能有一个接；
  /// 2. 本页仍是所在 Navigator 的栈顶——视频页可层层叠加（A 在播→push B），
  ///    被盖住的 A 不能抢 B 的按键；本应用所有页面路由都在 shell navigator 上，
  ///    因此这一条对「另一个视频页 / 作者页 / 设置页压上来」全部成立；
  /// 3. 没有弹窗浮层——对话框/底部弹层开着时按键不该被播放器吃掉；
  /// 4. 应用在前台——PiP / 后台时不响应。
  bool _acceptsShortcutsNow() {
    if (!mounted) return false;
    if (widget.isFullScreen !=
        widget.myVideoStateController.isFullscreen.value) {
      return false;
    }
    if (ModalRoute.isCurrentOf(context) != true) return false;
    if (OverlayTracker.instance.hasOverlay) return false;
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return false;
    }
    return true;
  }

  /// 播放器键盘事件入口：区分按下/松开，以支持进度键长按倍速。
  ///
  /// 由 [ShortcutTargetRegistry] 从应用根部派发进来，不再是 Focus 回调。
  KeyEventResult _handlePlayerKeyEvent(KeyEvent event) {
    // 松开进度键：决定是点按 seek 还是退出长按倍速。
    if (event is KeyUpEvent) {
      if (_heldSeekKeyId != null && event.logicalKey.keyId == _heldSeekKeyId) {
        _finishSeekHold();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    // 按下与「按住不放」的重复事件都要看；其余（如 KeyUpEvent 未命中）忽略。
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final action = _keybindingService.resolve(event, ShortcutScope.video);
    if (event is KeyDownEvent) {
      // 诊断：与设置页「[录入]」那行打同样的字段。自定义键不生效时，对比两行的
      // keyId / 修饰键即可分家——keyId 不同＝录入与运行时拿到的逻辑键不是一个；
      // keyId 相同但 matched=false＝修饰键状态对不上（_modifiersMatch 要求完全一致）。
      // 只在按下时打：重复事件每秒几十条，跟着打会把日志淹掉。
      final keyboard = HardwareKeyboard.instance;
      LogUtils.d(
        '[按下] keyId=${event.logicalKey.keyId} '
        'debugName=${event.logicalKey.debugName} '
        'ctrl=${keyboard.isControlPressed} shift=${keyboard.isShiftPressed} '
        'alt=${keyboard.isAltPressed} meta=${keyboard.isMetaPressed} '
        'matched=${action?.id}',
        'Keybinding',
      );
    }
    if (action == null) {
      // 这次不执行，不代表可以放它走：如果这个键**确实**绑在视频域上（典型是
      // 按住方向键产生的重复事件，而进度/音量另有长按逻辑或不可重复），放过去
      // 会一路冒泡到 WidgetsApp 的默认快捷键，被翻译成 DirectionalFocusIntent
      // 把焦点挪走——表现就是「按住方向键之后播放器忽然不听话了」。
      final matched = _keybindingService.matchIgnoringRepeatPolicy(
        event,
        ShortcutScope.video,
      );
      return matched != null
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    // 命中视频域绑定即视为已消费，阻止事件冒泡到全局快捷键层造成重复触发。
    _dispatchVideoShortcut(
      action,
      // 长按倍速只属于键盘的首次按下：重复事件由 _beginSeekHold 自己的定时器
      // 判定，鼠标侧键则是一次性点按 seek。
      seekHoldKeyId: event is KeyDownEvent ? event.logicalKey.keyId : null,
    );
    return KeyEventResult.handled;
  }

  /// 解析出视频域动作之后的**唯一**分派出口，键盘与鼠标两条入口共用。
  ///
  /// 收成一个出口是有前情的：锁定闸门、封面放行名单、长按倍速这三件事原本各自
  /// 散在两条入口里，于是同一个缺陷总是「键盘好了鼠标还坏着」（Work Item 1 就是
  /// 这么来的）。新增任何「要不要执行」的判断都放这里，两条入口自动同步。
  void _dispatchVideoShortcut(ShortcutAction action, {int? seekHoldKeyId}) {
    // 锁定闸门：与触摸走同一条规则（见 [_onTap]）——不执行动作，只把锁按钮
    // 亮出来告诉用户「现在是锁着的」。
    //
    // 锁定是**整个播放器的输入闸门**，不是「只挡手指」。之前只有 onTap 检查了
    // 锁定态、遮罩层也只吃 onTap，于是锁上之后空格照样暂停、鼠标侧键照样跳转，
    // 用户报的正是这个。
    if (widget.myVideoStateController.isToolbarsLocked.value) {
      widget.myVideoStateController.showLockButton();
      return;
    }

    // 初始播放封面阶段只放行不依赖「已打开媒体」的动作。
    if (widget.myVideoStateController.shouldShowInitialPlaybackCover) {
      _dispatchOnInitialPlaybackCover(action);
      return;
    }

    // 进度键：按下先挂起，松开时再区分点按/长按。
    if (seekHoldKeyId != null &&
        (action == ShortcutAction.seekForward ||
            action == ShortcutAction.seekBackward)) {
      _beginSeekHold(action, seekHoldKeyId);
      return;
    }

    _dispatchKeybindingAction(action);
  }

  /// 播放器鼠标按下入口：仅处理鼠标侧键/中键绑定（左右键留给点按/手势系统）。
  ///
  /// 鼠标按键不参与「长按倍速」，进度动作走一次性点按 seek（[_dispatchKeybindingAction]
  /// 内部对 seek 调用的就是点按处理）。
  void _handlePlayerPointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.mouse) return;
    final action = _keybindingService.resolvePointer(
      event,
      ShortcutScope.video,
    );
    if (action == null) return;
    _dispatchVideoShortcut(action);
  }

  /// 初始播放封面阶段的动作分派：键盘与鼠标两条入口共用这一处。
  ///
  /// 放行名单由 [isShortcutAllowedOnInitialPlaybackCover] 单点持有，两条入口不再
  /// 各自判断，避免出现「一边能用一边被静默吞掉」的不对称。
  void _dispatchOnInitialPlaybackCover(ShortcutAction action) {
    if (!isShortcutAllowedOnInitialPlaybackCover(action)) return;
    final controller = widget.myVideoStateController;
    switch (action) {
      case ShortcutAction.playPause:
        // 封面上的「播放/暂停」也必须是**开关**，不能只会往一个方向走。
        //
        // 关掉「首次进入自动播放」之后，点了播放就会停在封面上转圈
        // （正在添加监听器…）。此刻再按一次，用户的意思显然是「别播了」，
        // 而原来这里无条件再调一次 requestInitialPlayback()——在媒体已经打开、
        // videoPlayerReady 还没置位的那个窗口里，它会第二次 player.open 同一个
        // 地址，于是转圈从头再来，怎么按都停不下来。真机复现过。
        unawaited(controller.togglePlayback());
        break;
      case ShortcutAction.toggleFullscreen:
        // 只切换呈现方式，不打开媒体、不开始播放：全屏不是播放意图。
        _toggleFullscreen();
        break;
      default:
        // 名单里新增了动作却没在这里接线时暴露出来，别静默吞掉。
        assert(false, '初始播放封面放行名单新增了 $action 但未接线');
        break;
    }
  }

  /// 将解析出的快捷键动作分派到对应的播放器行为。
  ///
  /// 解析时已限定 [ShortcutScope.video]，故只会收到视频域动作；其余动作（全局/图库）
  /// 由对应层处理，这里 default 兜底忽略。
  void _dispatchKeybindingAction(ShortcutAction action) {
    final controller = widget.myVideoStateController;
    switch (action) {
      case ShortcutAction.playPause:
        unawaited(controller.togglePlayback());
        break;
      case ShortcutAction.speedUp:
        _adjustPlaybackSpeed(1);
        break;
      case ShortcutAction.speedDown:
        _adjustPlaybackSpeed(-1);
        break;
      case ShortcutAction.seekForward:
        _handleRightKeyPress();
        break;
      case ShortcutAction.seekBackward:
        _handleLeftKeyPress();
        break;
      case ShortcutAction.volumeUp:
        _adjustVolumeBy(0.1);
        break;
      case ShortcutAction.volumeDown:
        _adjustVolumeBy(-0.1);
        break;
      case ShortcutAction.toggleMute:
        _toggleMute();
        break;
      case ShortcutAction.toggleFullscreen:
        _toggleFullscreen();
        break;
      default:
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
  void _beginSeekHold(ShortcutAction action, int keyId) {
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
    } else if (action == ShortcutAction.seekForward) {
      _handleRightKeyPress();
    } else if (action == ShortcutAction.seekBackward) {
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

  // ---------------------------------------------------------------------------
  // 快进 / 快退：跳转与波纹动画是两件事，必须分开
  //
  // 此前两者揉在一处，且「动画还在放就 return」的闸门写在跳转**之前**——波纹活跃
  // 窗口约 1 秒（800ms 控制器 + 200ms 错峰），于是这 1 秒内连按会把跳转连同动画
  // 一起丢掉，表现为「方向键/双击连按不累加，第 2、3 次毫无反应」。
  //
  // 现在：跳转永远执行；只有动画受闸门节流（动画正在放就不重起，避免闪烁）。
  // ---------------------------------------------------------------------------

  void _triggerLeftRipple() {
    _seekByConfiguredStep(forward: false);
    _playSeekRipple(forward: false);
  }

  void _triggerRightRipple() {
    _seekByConfiguredStep(forward: true);
    _playSeekRipple(forward: true);
  }

  /// 按设置里的步长跳一步。
  ///
  /// [MyVideoStateController.handleSeek] 会**同步**推进 `currentPosition`，
  /// 所以连按时后一次是从前一次的新位置继续累加，而不是都从同一个基准算。
  void _seekByConfiguredStep({required bool forward}) {
    final controller = widget.myVideoStateController;
    final Duration current = controller.currentPosition;

    final int seconds = forward
        ? _configService[ConfigKey.FAST_FORWARD_SECONDS_KEY]
        : _configService[ConfigKey.REWIND_SECONDS_KEY];
    final Duration target = MyVideoStateController.resolveSeekStepTarget(
      current: current,
      total: controller.totalDuration.value,
      stepSeconds: seconds,
      forward: forward,
    );

    // 不传 startPlayback：暂停态跳转就该保持暂停。
    unawaited(controller.handleSeek(target));
  }

  /// 播放快进/快退的双层波纹。纯装饰，正在放就不重起。
  void _playSeekRipple({required bool forward}) {
    final bool active = forward
        ? (_isRightRippleActive1 || _isRightRippleActive2)
        : (_isLeftRippleActive1 || _isLeftRippleActive2);
    if (active) return;

    setState(() {
      if (forward) {
        _isRightRippleActive1 = true;
        _isRightRippleActive2 = false;
      } else {
        _isLeftRippleActive1 = true;
        _isLeftRippleActive2 = false;
      }
    });
    (forward ? _rightRippleController1 : _leftRippleController1).forward(
      from: 0,
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        if (forward) {
          _isRightRippleActive2 = true;
        } else {
          _isLeftRippleActive2 = true;
        }
      });
      (forward ? _rightRippleController2 : _leftRippleController2).forward(
        from: 0,
      );
    });
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

  /// 贴边把手要不要在场。
  ///
  /// ⛔ 与旧版的两处不同：
  /// 1. **不再只在全屏时出现**——抽屉改成了整页的侧边抽屉，非全屏一样能开；
  /// 2. **跟着播放控制栏一起显隐**（`shouldShowOverlayHud` 那条），而不是常驻
  ///    压着画面右侧——横屏移动端播放器的垂直空间本来就小。
  bool _canShowInnerPlaylistOverlay() {
    final hintEnabled =
        _configService[ConfigKey.SHOW_FULLSCREEN_UP_NEXT_HINT] as bool;
    return widget.hasPlaybackQueue &&
        widget.onOpenQueueDrawer != null &&
        hintEnabled;
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
      body: ColorVisionFilterWrapper(
        child: Video(
          controller: widget.myVideoStateController.videoController,
          controls: null,
        ),
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

            final thumbnailUrl =
                widget.myVideoStateController.videoInfo.value?.thumbnailUrl;
            return Positioned.fill(
              child: BlurredThumbnailBackground(thumbnailUrl: thumbnailUrl),
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
                  child: Listener(
                    onPointerDown: _handlePlayerPointerDown,
                    // 这只 Focus 只保留「焦点归属」用途（长按倍速要靠失焦收尾），
                    // **不再挂 onKeyEvent**：按键统一从应用根部经
                    // ShortcutTargetRegistry 派发进来，两处都收会双触发。
                    child: Focus(
                      focusNode: _focusNode,
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
                            // 播放器画面区域的真实尺寸只有这里算得到，
                            // 供给栈内需要按「播放器多大」自适应的浮层
                            // （Seek Preview 是第一个）。高度要减掉状态栏那一段：
                            // 外层 Container 带 padding.top = paddingTop。
                            child: PlayerBoxScope(
                              size: Size(
                                screenSize.width,
                                (screenSize.height - paddingTop).clamp(
                                  0.0,
                                  double.infinity,
                                ),
                              ),
                              child: _buildPlayerStack(
                                screenSize,
                                paddingTop,
                                playPauseIconSize,
                                bufferingSize,
                                maxRadius,
                              ),
                            ),
                          );
                        }),
                      ),
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
    double paddingTop,
    double playPauseIconSize,
    double bufferingSize,
    double maxRadius,
  ) {
    final controller = widget.myVideoStateController;
    return PlayerStackBuilder(
      // In local mode every visibility getter below is constant because it
      // short-circuits on isLocalVideoMode. Wrapping that path in Obx leaves
      // GetX with no dependency to track and throws before Video is mounted.
      observeChanges: !controller.isLocalVideoMode,
      builder: () {
        final showInitialPlaybackCover =
            controller.shouldShowInitialPlaybackCover;
        final showPlaybackChrome = controller.shouldShowPlaybackChrome;

        return Stack(
          children: [
            // 视频播放区域
            _buildVideoPlayer(),
            if (showInitialPlaybackCover) _buildInitialPlaybackCover(),
            // 播放提示胶囊：刻意排在手势层之前。后面的兄弟节点天然画在它上面，
            // 双击快进胶囊、音量/亮度 HUD、错误浮层因此都会盖住它，不用额外处理。
            if (controller.shouldShowOverlayHud)
              _buildPlayerNotice(screenSize, paddingTop),
            // 手势监听区域（抽取后减少整体重绘）
            if (showPlaybackChrome) ..._buildGestureAreas(screenSize),
            // 工具栏部分
            if (showPlaybackChrome) ..._buildToolbars(),
            // 双击波纹动画等效果
            if (showPlaybackChrome) _buildRippleEffects(screenSize, maxRadius),
            // 中央控制面板，比如播放/暂停按钮
            _buildVideoControlOverlay(
              screenSize,
              paddingTop,
              playPauseIconSize,
              bufferingSize,
            ),
            if (controller.shouldShowLoadingBackButton)
              _buildLoadingBackButton(),
            // InfoMessage 提示区域
            if (controller.shouldShowOverlayHud) _buildInfoMessage(),
            // 播放速度信息提示（左下角）
            if (controller.shouldShowOverlayHud)
              _buildPlaybackSpeedInfoMessage(),
            // 添加底部进度条
            if (controller.shouldShowOverlayHud) _buildBottomProgressBar(),
            // 添加遮罩层
            if (showPlaybackChrome) _buildMaskLayer(),
            // 添加锁定按钮
            if (showPlaybackChrome) _buildLockButton(),
            if (controller.shouldShowOverlayHud) _buildInnerPlaylistOverlay(),
          ],
        );
      },
    );
  }

  /// 播放提示胶囊的锚点。几何全部在这里算好，胶囊只管渲染，
  /// 这样图库那两个小播放器可以复用同一个组件配另一套几何。
  Widget _buildPlayerNotice(Size screenSize, double paddingTop) {
    final Size displaySize = MediaQuery.sizeOf(context);
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    // 顶部工具栏是 Positioned(top: -paddingTop) 配 height: toolbarHeight + 状态栏，
    // 所以不论状态栏内边距是多少，它的下边缘在 Stack 坐标系里恰好等于 toolbarHeight。
    final double toolbarHeight = playerTopToolbarHeight(widget.isFullScreen);
    const double gap = 8.0; // 纯设计留白，这里唯一的自由数字

    // 要的是 Stack 的高度而不是窗口高度：外层 Container 带 padding.top = paddingTop。
    final double stackH = screenSize.height - paddingTop;
    final double stackW = screenSize.width;

    // 中央播放/暂停按钮的上边缘。它的尺寸只由宽度推导，宽而扁的画面里会异常大。
    final double centreSize = (stackW * 0.15).clamp(40.0, 100.0);
    final double centreTop = (stackH - centreSize) / 2;

    // 工具栏与中央按钮之间这一条才是提示条的地盘，别处都已经有主人了。
    final double band = centreTop - (toolbarHeight + gap);

    // 胶囊高度 = 上下各 6 的内边距 + max(图标 16, 行数 × 行盒)。
    // 字号看播放器实际宽度而不是 widget.isFullScreen：桌面端「应用内全屏」传的是
    // isFullScreen: false，但它其实占满整个窗口。
    final double fontSize = stackW >= 900 ? 13.0 : 12.0;
    final double line = textScaler.scale(fontSize) * 1.45; // 中日韩最坏行高比
    final double oneLine = 12.0 + math.max(16.0, line);
    final double twoLine = 12.0 + math.max(16.0, line * 2);

    // 暂停后下滑看评论时播放器会折叠到 56px，此时 band 为负。Stack 默认
    // Clip.hardEdge，硬画只会被整条裁掉，提示的停留时间在看不见的地方白烧完，
    // 之后也没有补发，所以宁可不渲染并让中枢先挂起这条提示。
    if (band < oneLine) {
      widget.myVideoStateController.noticeCenter.setSurfaceAvailable(false);
      return const SizedBox.shrink();
    }
    widget.myVideoStateController.noticeCenter.setSurfaceAvailable(true);

    // 水平内边距按本仓库惯例是「安全区 + 外边距」而不是取 max。沉浸式下 padding
    // 会漏报，所以和 computeBottomSafeInset 一样再兜一层 viewPadding；并且只有
    // 播放器真的贴到屏幕边缘时才让位 —— 宽屏分栏里右侧是 350px 的信息栏。
    final bool spansDisplayEdge =
        widget.isFullScreen || stackW >= displaySize.width - 1.0;
    final double safeRight = spansDisplayEdge
        ? math.max(padding.right, viewPadding.right)
        : 0.0;
    const double margin = 12.0; // 与全屏播放列表抽屉的右边距保持一致

    // 让开全屏「接着看」把手：它宽 64、右移 14，占的正是同一条横带，
    // 而且是 Stack 的最后一个孩子，不让位就会被它的不透明缩略图盖住。
    final double hintReserve = _canShowInnerPlaylistOverlay()
        ? (64.0 - 14.0) + 8.0
        : 0.0;

    final double right = safeRight + margin + hintReserve;

    return Positioned(
      top: toolbarHeight + gap,
      right: right,
      child: PlayerNoticeChip(
        center: widget.myVideoStateController.noticeCenter,
        fontSize: fontSize,
        maxLines: band >= twoLine ? 2 : 1,
        // 只给 top/right 的 Positioned 子节点拿到的是无界约束，这个夹取是它唯一的
        // 宽度上限；超宽会被从「左」边裁掉（x = 宽 - right - 子宽），图标先没。
        // 320 是可读性上限：一行更长只会更难读。
        maxWidth: math.max(0.0, math.min(320.0, stackW - right - margin)),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return ClipRect(
      child: Center(
        child: Obx(() {
          final controller = widget.myVideoStateController;
          final scale = controller.videoZoomScale.value;
          final offset = controller.videoZoomOffset.value;
          final rotation = controller.videoZoomRotation.value;
          Widget video = _buildFittedVideo(controller);
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

  /// 按「画面尺寸」模式构建视频画面（外层已有 ClipRect + Center 提供裁剪与居中）。
  Widget _buildFittedVideo(MyVideoStateController controller) {
    final fitMode = controller.screenFitMode.value;
    final Widget videoWidget = ColorVisionFilterWrapper(
      child: Video(
        controller: controller.videoController,
        controls: null,
        fit: switch (fitMode) {
          // 适应：帧比例即视频比例，contain 恰好铺满且不裁剪
          PlayerScreenFitMode.fit => BoxFit.contain,
          // 填充：保持比例铺满播放区域；Video 内部自带 FittedBox+ClipRect，
          // 溢出在其自身盒内裁剪（外层 ClipRect 只负责兜住缩放 Transform 的越界绘制）
          PlayerScreenFitMode.cover => BoxFit.cover,
          // 拉伸 / 强制比例：把画面拉伸到目标帧
          PlayerScreenFitMode.stretch ||
          PlayerScreenFitMode.ratio16x9 ||
          PlayerScreenFitMode.ratio4x3 => BoxFit.fill,
        },
      ),
    );
    switch (fitMode) {
      case PlayerScreenFitMode.fit:
        return AspectRatio(
          aspectRatio: controller.aspectRatio.value,
          child: videoWidget,
        );
      case PlayerScreenFitMode.stretch:
      case PlayerScreenFitMode.cover:
        return SizedBox.expand(child: videoWidget);
      case PlayerScreenFitMode.ratio16x9:
        return AspectRatio(aspectRatio: 16 / 9, child: videoWidget);
      case PlayerScreenFitMode.ratio4x3:
        return AspectRatio(aspectRatio: 4 / 3, child: videoWidget);
    }
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
          // 独立透明 Material：该按钮在加载完成瞬间会被整体卸载，若墨水
          // 效果（桌面端 hover 高亮）注册在外层 Scaffold 的 Material 上，
          // 卸载后残留的 InkFeature 会在 paint 时触发
          // 'referenceBox.attached' 断言；独立 Material 让墨水随按钮同生共死。
          child: Material(
            type: MaterialType.transparency,
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
      ),
    );
  }

  bool get _horizontalDragSeekEnabled =>
      _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] == true;

  void _handleHorizontalDragStart(DragStartDetails details) {
    VibrateUtils.vibrate();
    final controller = widget.myVideoStateController;
    _horizontalDragStartX = details.localPosition.dx;
    _horizontalDragStartPosition = controller.currentPosition;
    controller.setInteracting(true);
    controller.showSeekPreview(true);
    controller.updateSeekPreview(_horizontalDragStartPosition!);
    controller.isHorizontalDragging.value = true;
  }

  void _handleHorizontalDragUpdate(
    DragUpdateDetails details,
    double screenWidth,
  ) {
    final startX = _horizontalDragStartX;
    final startPosition = _horizontalDragStartPosition;
    if (startX == null || startPosition == null) return;

    final dragDistance = details.localPosition.dx - startX;
    const edgeThreshold = CommonConstants.videoPlayerEdgeGestureThreshold;
    final startedAtEdge =
        (startX < edgeThreshold && dragDistance > 0) ||
        (startX > screenWidth - edgeThreshold && dragDistance < 0);
    if (startedAtEdge && widget.myVideoStateController.isFullscreen.value) {
      return;
    }

    widget.myVideoStateController.updateSeekPreview(
      VideoDetailHorizontalDragSeekLogic.calculatePreviewPosition(
        dragStartPosition: startPosition,
        dragDistance: dragDistance,
        screenWidth: screenWidth,
        totalDuration: widget.myVideoStateController.totalDuration.value,
        maxSeekSeconds: maxSeekSeconds,
      ),
    );
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final controller = widget.myVideoStateController;
    if (_horizontalDragStartPosition != null) {
      unawaited(controller.handleSeek(controller.previewPosition.value));
    }
    _horizontalDragStartX = null;
    _horizontalDragStartPosition = null;
    controller.setInteracting(false);
    controller.showSeekPreview(false);
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
            onHorizontalDragStart: _horizontalDragSeekEnabled
                ? _handleHorizontalDragStart
                : null,
            onHorizontalDragUpdate: _horizontalDragSeekEnabled
                ? (details) =>
                      _handleHorizontalDragUpdate(details, screenSize.width)
                : null,
            onHorizontalDragEnd: _horizontalDragSeekEnabled
                ? _handleHorizontalDragEnd
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
            onHorizontalDragStart: _horizontalDragSeekEnabled
                ? _handleHorizontalDragStart
                : null,
            onHorizontalDragUpdate: _horizontalDragSeekEnabled
                ? (details) =>
                      _handleHorizontalDragUpdate(details, screenSize.width)
                : null,
            onHorizontalDragEnd: _horizontalDragSeekEnabled
                ? _handleHorizontalDragEnd
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
            onDoubleTap: () =>
                unawaited(widget.myVideoStateController.togglePlayback()),
            region: GestureRegion.center,
            myVideoStateController: widget.myVideoStateController,
            screenSize: screenSize,
            onHorizontalDragStart: _horizontalDragSeekEnabled
                ? _handleHorizontalDragStart
                : null,
            onHorizontalDragUpdate: _horizontalDragSeekEnabled
                ? (details) =>
                      _handleHorizontalDragUpdate(details, screenSize.width)
                : null,
            onHorizontalDragEnd: _horizontalDragSeekEnabled
                ? _handleHorizontalDragEnd
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

  /// 「接着看」的贴边把手。
  ///
  /// 老版本这里是一整条横向列表（还只在全屏时存在）；现在它只是一枚**发起
  /// 按钮**，抽屉本体是一条 root 路由的竖排侧边抽屉。这么改的直接好处是横屏
  /// 移动端不必再为一条横向列表让出垂直空间。
  ///
  /// 跟着播放控制栏一起显隐：控制栏藏起来的时候画面右侧就该是干净的。
  Widget _buildInnerPlaylistOverlay() {
    return Obx(() {
      if (!_canShowInnerPlaylistOverlay()) {
        return const SizedBox.shrink();
      }
      return AnimatedBuilder(
        animation: widget.myVideoStateController.animationController,
        builder: (context, child) {
          final visibility = widget
              .myVideoStateController
              .animationController
              .value
              .clamp(0.0, 1.0);
          if (visibility <= 0.01) return const SizedBox.shrink();
          return Opacity(
            opacity: visibility,
            child: IgnorePointer(ignoring: visibility < 0.5, child: child),
          );
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(
              right: MediaQuery.paddingOf(context).right + 4,
            ),
            child: _QueueEdgeHandle(onTap: widget.onOpenQueueDrawer),
          ),
        ),
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
    Size screenSize,
    double paddingTop,
    double playPauseIconSize,
    double bufferingSize,
  ) {
    return Obx(
      () => Positioned.fill(
        child: _buildLoadingOrControlContent(
          screenSize,
          paddingTop,
          playPauseIconSize,
          bufferingSize,
        ),
      ),
    );
  }

  // 构建加载或控制内容
  Widget _buildLoadingOrControlContent(
    Size screenSize,
    double paddingTop,
    double playPauseIconSize,
    double bufferingSize,
  ) {
    final controller = widget.myVideoStateController;
    switch (controller.centerOverlayState) {
      case VideoCenterOverlayState.sourceError:
        return _buildSourceErrorOverlay(
          screenSize,
          paddingTop,
          playPauseIconSize,
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

  /// 视频源致命错误的浮层。这一层比工具栏更早被命中测试，所以它的每一处几何
  /// 都要按「宁可少显示，也不能溢出到播放条上」来算。
  Widget _buildSourceErrorOverlay(
    Size screenSize,
    double paddingTop,
    double playPauseIconSize,
  ) {
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);
    final EdgeInsets systemGestureInsets = MediaQuery.systemGestureInsetsOf(
      context,
    );
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final double stackH = screenSize.height - paddingTop;

    final double band = bottomToolbarEstimatedHeight(
      isFullScreen: widget.isFullScreen,
      isSmallScreen: screenSize.width < 600,
      showResumeTip: widget.myVideoStateController.showResumePositionTip.value,
      showQuickActions:
          widget.isFullScreen && Get.find<UserService>().hasLoadedProfile,
      bottomInset: (!widget.isFullScreen && widget.enableBottomSafeArea)
          ? math.max(
              padding.bottom,
              math.max(viewPadding.bottom, systemGestureInsets.bottom),
            )
          : 0.0,
      textScaler: textScaler,
    );

    // 预留绝不能超过播放器给得起的量：BoxConstraints.deflate 会把负数夹到 0，
    // 超额预留于是安静地变成 RenderFlex 溢出，而 Flex 的 clipBehavior 是 Clip.none，
    // 子组件照样画到播放条上，ElevatedButton 把那一片点击全吃掉 —— 正是 issue #110
    // 的翻版，而且发生在为了修它才加的这一层上。0.25 是取舍：250px 的竖屏播放器
    // 至少要留 3/4 给内容。
    final double reserved = math.min(band, stackH * 0.25);
    final double available = math.max(0.0, stackH - reserved);

    // ErrorStateWidget = 图标 + 16 + 标题行 + 12 + 按钮行。按钮行在移动端是 48
    // （M3 最小 40，再被点击热区撑到 kMinInteractiveDimension），桌面端 32。
    final double buttonRow = switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.fuchsia => kMinInteractiveDimension,
      _ => 32.0,
    };
    final double headline = textScaler.scale(16.0) * 1.45 * 2; // 按两行预留
    final double chromeH = 16.0 + headline + 12.0 + buttonRow;

    // 先缩图标：playPauseIconSize 只由宽度推导，852x200 这种多窗口比例会要求
    // 在 92px 的空间里画一个 100px 的圆。
    final double iconSize = math.max(
      0.0,
      math.min(playPauseIconSize, available - chromeH - 8.0),
    );

    return Padding(
      // Padding 放在 DecoratedBox 外面：遮罩不盖住播放条，用户想拖回进度时
      // 不必隔着一层 55% 的黑。
      padding: EdgeInsets.only(bottom: reserved),
      child: DecoratedBox(
        // 只能用 DecoratedBox，不能用 ColoredBox / Container(color:)：
        // _RenderColoredBox 是以 HitTestBehavior.opaque 构造的，而这一层比工具栏
        // 更早被命中测试，会直接重演 issue #110。RenderDecoratedBox 只是普通的
        // RenderProxyBox，hitTestSelf 为 false；Padding/Center 同理，
        // 真正会吃掉点击的只有里面那两个按钮。
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55)),
        child: Center(
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: available < chromeH + 8.0
                // 图标缩到 0 都放不下完整形态：退到一行结论、不给按钮。
                // 被裁掉一半的按钮比没有按钮更糟，详情与重试仍可从顶部工具栏进。
                ? _buildCompactSourceError()
                : ErrorStateWidget(
                    controller: widget.myVideoStateController,
                    size: iconSize,
                    onShowErrorDetail: () => showPlaybackIssueSheet(
                      widget.myVideoStateController.noticeCenter,
                    ),
                    // 本地视频模式下默认的 onRetry 是 fetchVideoSource()，
                    // 它在 fileUrl == null 时直接返回，等于一个死按钮。
                    onRetry: widget.myVideoStateController.isLocalVideoMode
                        ? () => widget.myVideoStateController.refreshPlayer(
                            seekTo:
                                widget.myVideoStateController.currentPosition,
                          )
                        : null,
                  ),
          ),
        ),
      ),
    );
  }

  /// 极窄播放器（多窗口、折叠屏外屏、暂停后折叠到 56px）下的降级形态。
  Widget _buildCompactSourceError() {
    final String message =
        widget.myVideoStateController.videoSourceErrorMessage.value ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
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

                await myVideoStateController.togglePlayback();
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
      top: MediaQuery.paddingOf(context).top + 100,
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
      final double speed =
          widget.myVideoStateController.playerPlaybackSpeed.value;
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

                        // 预览窗口（仅在横向拖拽且 toolbar 隐藏时显示）
                        final isPreviewReady = widget
                            .myVideoStateController
                            .isPreviewPlayerReady
                            .value;
                        // 预览窗口的高度按视频自身宽高比推，必须在 Obx 里读
                        final videoAspectRatio =
                            widget.myVideoStateController.aspectRatio.value;
                        // 工具栏完全展开时不渲染底部预览窗口
                        final bool isToolbarExpanded = toolbarValue >= 1.0;
                        final bool previewVisible =
                            !isToolbarExpanded &&
                            isHorizontalDragging &&
                            opacity > 0.5;

                        // 记住最后一次有效位置，让它**原地淡出**而不是直接消失。
                        if (previewVisible) {
                          _bottomSeekPreviewX = progressWidth;
                          _bottomSeekPreviewTime = previewPosition;
                        }
                        final double? tooltipX = _bottomSeekPreviewX;
                        final Duration? tooltipTime = _bottomSeekPreviewTime;

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
                            // 预览窗口：与主进度条上的那扇是同一只组件
                            if (tooltipX != null && tooltipTime != null)
                              Positioned(
                                left: tooltipX,
                                bottom: 3 + 12, // 距离底部进度条 12px
                                child: SeekPreview(
                                  time: tooltipTime,
                                  videoAspectRatio: videoAspectRatio,
                                  anchorX: tooltipX,
                                  trackWidth: totalWidth,
                                  visible: previewVisible,
                                  showFrame:
                                      isPreviewReady &&
                                      widget
                                              .myVideoStateController
                                              .previewVideoController !=
                                          null,
                                  previewController: widget
                                      .myVideoStateController
                                      .previewVideoController,
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
}

/// 长按类型 [滑动也属于长按]
enum LongPressType { brightness, volume, normal }

/// 播放器右缘那枚「接着看」把手。
///
/// 刻意做得很窄（一条 28×72 的圆角片）：它常驻在画面上，宽一点就开始碍事。
/// 点它打开侧边抽屉；不做"按住拖出"——抽屉现在是一条 root 路由，跟手拖出要
/// 自己重做一整套转场，收益不抵成本。
class _QueueEdgeHandle extends StatelessWidget {
  const _QueueEdgeHandle({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassTapArea(
      onTap: onTap,
      opensOverlay: true,
      child: Semantics(
        // 纯图标按钮，读屏只念得出"按钮"。它是抽屉的唯一入口，必须有名字。
        label: slang.t.playbackQueue.openQueue,
        button: true,
        child: Container(
        width: 28,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(14),
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.chevron_left,
            size: 20,
            color: Colors.white,
          ),
        ),
        ),
      ),
    );
  }
}
