import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/player_keybinding/keybinding_service.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_scope.dart';
import 'package:i_iwara/common/gallery_image_quality.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'video_player_widget.dart';
import 'image_widget.dart';
import 'gallery_controls.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/pages/settings/keybinding_settings_page.dart';
import 'package:i_iwara/app/ui/widgets/color_vision_filter_wrapper.dart';
import 'package:i_iwara/app/ui/widgets/color_vision_settings_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

class MyGalleryPhotoViewWrapper extends StatefulWidget {
  const MyGalleryPhotoViewWrapper({
    super.key,
    required this.galleryItems,
    this.initialIndex = 0,
    List<ImageItem>? standardGalleryItems,
    List<ImageItem>? originalGalleryItems,
    String? initialQuality,
    this.onQualityChanged,
    @Deprecated('Use standardGalleryItems instead')
    List<ImageItem>? standardImageItems,
    @Deprecated('Use originalGalleryItems instead')
    List<ImageItem>? originalImageItems,
    this.menuBuilder,
    this.menuItemsBuilder,
    this.enableMenu = true,
    this.heroTagBuilder,
  }) : standardGalleryItems = standardGalleryItems ?? standardImageItems,
       originalGalleryItems = originalGalleryItems ?? originalImageItems,
       initialQuality = initialQuality ?? galleryImageQualityStandard;

  final List<ImageItem> galleryItems;
  final int initialIndex;
  final List<ImageItem>? standardGalleryItems;
  final List<ImageItem>? originalGalleryItems;
  final String initialQuality;
  final ValueChanged<String>? onQualityChanged;
  final Widget Function(BuildContext, ImageItem, Offset)?
  menuBuilder; // 自定义菜单构建器
  final List<MenuItem> Function(BuildContext, ImageItem)?
  menuItemsBuilder; // 动态菜单项生成器
  final bool enableMenu; // 是否启用菜单和相关触发
  final Object? Function(ImageItem item)? heroTagBuilder;

  @override
  State<MyGalleryPhotoViewWrapper> createState() =>
      _MyGalleryPhotoViewWrapperState();
}

class _MyGalleryPhotoViewWrapperState extends State<MyGalleryPhotoViewWrapper>
    with TickerProviderStateMixin {
  late int currentIndex;
  late String _activeQuality;
  late PageController pageController;
  late List<PhotoViewController> controllers;

  bool _isUiVisible = true;
  Timer? _uiHideTimer;

  // 跟随路由过渡切换系统 UI（侧边栏）用，见 _attachRouteAnimation
  ModalRoute<dynamic>? _observedRoute;
  Animation<double>? _routeAnimation;
  bool _suppressNextTapToggle = false;
  final FocusNode _keyboardFocusNode = FocusNode(debugLabel: 'GalleryViewer');

  // Telegram-like drag-to-dismiss state
  Offset _dismissOffset = Offset.zero;
  bool _isDraggingToDismiss = false;
  late final AnimationController _dismissResetController;
  Animation<Offset>? _dismissResetAnimation;

  // 记录当前屏幕宽度和左右点击区域宽度，用于轻量级指针监听
  double _screenWidth = 0;
  double _tapAreaWidth = 0;

  // 记录一次点击的按下位置和时间，用于区分点击与滑动
  Offset? _pointerDownPosition;
  DateTime? _pointerDownTime;
  int _edgeTapDirection = 0;
  bool _ignoreEdgeTapForCurrentPointer = false;

  final AppService? _appService = Get.isRegistered<AppService>()
      ? Get.find<AppService>()
      : null;
  late GalleryControls _galleryControls;
  final GlobalKey _closeButtonKey = GlobalKey();
  final GlobalKey _qualityButtonKey = GlobalKey();
  final GlobalKey _menuButtonKey = GlobalKey();

  // 使用Map存储每个图片的重新加载时间戳
  final Map<int, int> _reloadTimestamps = {};

  // 存储视频播放器的GlobalKey，用于控制播放状态
  final Map<int, GlobalKey<VideoPlayerWidgetState>> _videoPlayerKeys = {};

  // 预加载范围：当前图片前后各预加载多少张
  static const int _preloadRange = 3;

  // 记录已预加载的图片索引，避免重复预加载
  final Set<int> _preloadedImages = {};

  // 下拉/上滑返回：超过该位移（或够快的甩动）就 pop
  static const double _dismissTriggerDistance = 160.0;

  // 背景消隐参考距离：比触发阈值略大，松手前背景已淡到接近透明，
  // 接上路由自身的淡出不会有突兀跳变。
  static const double _dismissFadeDistance = 200.0;

  // 背景最多淡到的透明度（保留一点点压暗，避免下层页面直接刺眼地全亮）
  static const double _dismissMinBackgroundAlpha = 0.08;

  int get _controllerCount {
    var count = widget.galleryItems.length;
    final standardLength = widget.standardGalleryItems?.length ?? 0;
    final originalLength = widget.originalGalleryItems?.length ?? 0;
    if (standardLength > count) {
      count = standardLength;
    }
    if (originalLength > count) {
      count = originalLength;
    }
    return count;
  }

  bool get _hasUsableDualDatasets {
    final standardItems = widget.standardGalleryItems;
    final originalItems = widget.originalGalleryItems;
    if (standardItems == null || originalItems == null) {
      return false;
    }
    if (standardItems.length != originalItems.length) {
      return false;
    }
    for (var index = 0; index < standardItems.length; index++) {
      if (standardItems[index].data.id != originalItems[index].data.id) {
        return false;
      }
    }
    return true;
  }

  bool get _hasSwitchableQualityDifference {
    if (!_hasUsableDualDatasets) {
      return false;
    }
    final standardItems = widget.standardGalleryItems!;
    final originalItems = widget.originalGalleryItems!;
    for (var index = 0; index < standardItems.length; index++) {
      if (standardItems[index].data.originalUrl !=
          originalItems[index].data.originalUrl) {
        return true;
      }
    }
    return false;
  }

  bool get _canSwitchQuality =>
      _hasUsableDualDatasets && _hasSwitchableQualityDifference;

  List<ImageItem> get _activeGalleryItems {
    if (!_canSwitchQuality) {
      return widget.galleryItems;
    }
    return _activeQuality == galleryImageQualityOriginal
        ? widget.originalGalleryItems!
        : widget.standardGalleryItems!;
  }

  int _clampIndex(int index, int length) {
    if (length <= 0) {
      return 0;
    }
    if (index < 0) {
      return 0;
    }
    if (index >= length) {
      return length - 1;
    }
    return index;
  }

  // 检测媒体类型
  bool _isVideo(String url) {
    final extension = CommonUtils.getFileExtension(url).toLowerCase();
    return [
      'mp4',
      'webm',
      'mov',
      'avi',
      'mkv',
      'flv',
      'wmv',
      'm4v',
    ].contains(extension);
  }

  @override
  void initState() {
    super.initState();
    _activeQuality = normalizeGalleryImageQuality(widget.initialQuality);
    currentIndex = _clampIndex(widget.initialIndex, _activeGalleryItems.length);
    _appService?.hideSystemUI(hideTitleBar: false);
    pageController = PageController(initialPage: currentIndex);
    controllers = List.generate(
      _controllerCount,
      (index) => PhotoViewController(),
    );

    // 初始化控制器
    _galleryControls = GalleryControls(
      controllers: controllers,
      onNext: goToNextPage,
      onPrevious: goToPreviousPage,
    );
    _galleryControls.currentIndex = currentIndex;

    _dismissResetController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 180),
        )..addListener(() {
          final anim = _dismissResetAnimation;
          if (anim == null) return;
          setState(() {
            _dismissOffset = anim.value;
          });
        });

    // 延迟执行，确保所有视频组件都已创建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
      _pauseAllVideosExcept(currentIndex);
      // 根据初始页面是否是视频来决定是否启用音量键监听
      _updateVolumeKeyListener();
      // 预加载初始页面周围的图片
      _preloadNearbyImages(currentIndex);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachRouteAnimation();
  }

  /// 侧边栏（NavigationRail）的展开/收起是靠 AppService.showRailNavi 驱动的一段
  /// 240/200ms 动画（见 AnimatedNavigationRailSlot）。进入时在 initState 里收起没问题，
  /// 但退出如果只写在 dispose 里，路由退场动画（300ms）跑完、本页都已经被移除之后
  /// 侧边栏才开始展开 —— 看上去就是「先关页面，侧边栏再自己弹出来」，完全对不上，
  /// 和播放器全屏（点按钮当场切 showRailNavi，动画与画面同步）差了一个身位。
  ///
  /// 这里改成跟着路由自身的动画走：一开始 pop（status 变 reverse）就交还系统 UI，
  /// 让侧边栏展开与本页淡出同帧进行；iOS 侧滑取消（reverse -> forward）会再次收起。
  void _attachRouteAnimation() {
    final route = ModalRoute.of(context);
    if (identical(route, _observedRoute)) return;
    _detachRouteAnimation();
    _observedRoute = route;
    final animation = route?.animation;
    if (animation == null) return;
    _routeAnimation = animation..addStatusListener(_handleRouteAnimationStatus);
  }

  void _detachRouteAnimation() {
    _routeAnimation?.removeStatusListener(_handleRouteAnimationStatus);
    _routeAnimation = null;
    _observedRoute = null;
  }

  void _handleRouteAnimationStatus(AnimationStatus status) {
    if (!mounted) return;
    switch (status) {
      case AnimationStatus.reverse:
      case AnimationStatus.dismissed:
        _appService?.showSystemUI();
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        _appService?.hideSystemUI(hideTitleBar: false);
    }
  }

  @override
  void dispose() {
    // 释放所有视频播放器资源
    _releaseAllVideoPlayers();

    // 移除音量键监听
    _galleryControls.disableVolumeKeyListener();
    _detachRouteAnimation();
    // 兜底：无过渡动画的 pop（或路由没有 animation）时仍要恢复系统 UI。
    // 与上面的 reverse 分支重复调用是幂等的（Rx 同值不通知）。
    _appService?.showSystemUI();
    _uiHideTimer?.cancel();
    _dismissResetController.dispose();
    _keyboardFocusNode.dispose();
    pageController.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 释放所有视频播放器资源
  void _releaseAllVideoPlayers() {
    for (final key in _videoPlayerKeys.values) {
      if (key.currentState != null) {
        key.currentState!.releasePlayer();
      }
    }
    _videoPlayerKeys.clear();
  }

  /// 获取或创建视频播放器的GlobalKey
  GlobalKey<VideoPlayerWidgetState> _getVideoPlayerKey(int index) {
    if (!_videoPlayerKeys.containsKey(index)) {
      _videoPlayerKeys[index] = GlobalKey<VideoPlayerWidgetState>();
    }
    return _videoPlayerKeys[index]!;
  }

  bool _handleKeyPress(KeyEvent event) {
    // 保留 Esc 本地优先关闭评论抽屉（在 gallery_detail_page.dart），
    // 否则这里让它冒泡到全局 Esc。
    final service = Get.find<KeybindingService>();
    final action = service.resolve(event, ShortcutScope.gallery);
    if (action != null) {
      final didAct = _galleryControls.dispatch(action);
      if (didAct) {
        _showUiAndAutoHide();
        setState(() {});
        return true;
      }
    }
    // 未命中（包括 Esc）时返回 ignored，让它冒泡到根 global_back。
    return false;
  }

  void goToNextPage() {
    if (currentIndex < _activeGalleryItems.length - 1) {
      pageController.animateToPage(
        currentIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToPreviousPage() {
    if (currentIndex > 0) {
      pageController.animateToPage(
        currentIndex - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    // 暂停所有其他视频播放器
    _pauseAllVideosExcept(index);

    setState(() {
      currentIndex = index;
    });
    _galleryControls.updateCurrentIndex(index);

    // 根据当前页面是否是视频来决定是否启用音量键监听
    _updateVolumeKeyListener();

    // 预加载周围的图片
    _preloadNearbyImages(index);

    // Swiping between medias should show UI briefly like Telegram.
    _showUiAndAutoHide();
  }

  /// 暂停除指定索引外的所有视频
  void _pauseAllVideosExcept(int currentIndex) {
    final activeGalleryItems = _activeGalleryItems;
    for (int i = 0; i < activeGalleryItems.length; i++) {
      if (i != currentIndex &&
          _isVideo(activeGalleryItems[i].data.originalUrl)) {
        final key = _videoPlayerKeys[i];
        if (key?.currentState != null) {
          key!.currentState!.pauseVideo();
        }
      }
    }
  }

  /// 根据当前是否是视频来更新音量键监听状态
  void _updateVolumeKeyListener() {
    final activeGalleryItems = _activeGalleryItems;
    if (activeGalleryItems.isEmpty ||
        currentIndex >= activeGalleryItems.length) {
      _galleryControls.disableVolumeKeyListener();
      return;
    }

    final isCurrentVideo = _isVideo(
      activeGalleryItems[currentIndex].data.originalUrl,
    );

    if (isCurrentVideo) {
      // 如果当前是视频，禁用音量键监听，让系统处理音量调节
      _galleryControls.disableVolumeKeyListener();
    } else {
      // 如果当前是图片，启用音量键监听用于翻页
      _galleryControls.initVolumeKeyListener();
    }
  }

  /// 预加载当前索引周围的图片（不包括视频）
  void _preloadNearbyImages(int centerIndex) {
    if (!mounted) return;
    if (_activeGalleryItems.isEmpty) return;

    // 计算预加载范围
    final startIndex = (centerIndex - _preloadRange).clamp(
      0,
      _activeGalleryItems.length - 1,
    );
    final endIndex = (centerIndex + _preloadRange).clamp(
      0,
      _activeGalleryItems.length - 1,
    );

    for (int i = startIndex; i <= endIndex; i++) {
      // 跳过已经预加载的
      if (_preloadedImages.contains(i)) continue;

      final item = _activeGalleryItems[i];
      final imageUrl = item.data.originalUrl;

      // 只预加载图片，跳过视频
      if (_isVideo(imageUrl)) continue;

      // 跳过本地文件（file://）
      if (imageUrl.startsWith('file://')) continue;

      // 使用 CachedNetworkImage 预加载
      _preloadImage(i, imageUrl, item.headers);
    }
  }

  /// 预加载单张图片
  Future<void> _preloadImage(
    int index,
    String imageUrl,
    Map<String, String>? headers,
  ) async {
    if (!mounted) return;

    try {
      // 标记为已预加载（避免重复预加载）
      _preloadedImages.add(index);

      // 使用 CachedNetworkImage 的预缓存功能
      final imageProvider = CachedNetworkImageProvider(
        imageUrl,
        headers: headers,
      );

      // 预加载到缓存
      await precacheImage(imageProvider, context);

      LogUtils.d('预加载图片成功: 索引=$index', 'GalleryPreload');
    } catch (e) {
      LogUtils.e(
        '预加载图片失败: 索引=$index, URL=$imageUrl',
        tag: 'GalleryPreload',
        error: e,
      );
      // 预加载失败时从集合中移除，允许后续重试
      _preloadedImages.remove(index);
    }
  }

  void _handleQualityChanged(String quality) {
    if (!_canSwitchQuality) {
      return;
    }

    final normalizedQuality = normalizeGalleryImageQuality(quality);
    if (normalizedQuality == _activeQuality) {
      return;
    }

    final nextItems = normalizedQuality == galleryImageQualityOriginal
        ? widget.originalGalleryItems!
        : widget.standardGalleryItems!;
    final nextIndex = _clampIndex(currentIndex, nextItems.length);

    setState(() {
      _activeQuality = normalizedQuality;
      currentIndex = nextIndex;
    });

    _galleryControls.updateCurrentIndex(currentIndex);
    _galleryControls.resetZoom();
    _preloadedImages.clear();
    _pauseAllVideosExcept(currentIndex);
    _updateVolumeKeyListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !pageController.hasClients) {
        return;
      }
      pageController.jumpToPage(currentIndex);
      _preloadNearbyImages(currentIndex);
    });
    widget.onQualityChanged?.call(normalizedQuality);
    _showUiAndAutoHide();
  }

  void _showUiAndAutoHide() {
    if (!mounted) return;
    _uiHideTimer?.cancel();
    setState(() {
      _isUiVisible = true;
    });
  }

  void _scheduleAutoHideUi() {
    _uiHideTimer?.cancel();
  }

  void _toggleUiVisibility() {
    if (!mounted) return;
    if (_suppressNextTapToggle) {
      _suppressNextTapToggle = false;
      return;
    }
    if (!_isUiVisible) {
      _uiHideTimer?.cancel();
      setState(() {
        _isUiVisible = true;
      });
    }
  }

  bool _canStartDismissDrag() {
    final scale = controllers[currentIndex].scale ?? 1.0;
    return scale <= 1.01;
  }

  void _onDismissDragStart(DragStartDetails details) {
    _dismissResetController.stop();
    _dismissResetAnimation = null;
    _uiHideTimer?.cancel();
    setState(() {
      _isDraggingToDismiss = true;
    });
  }

  void _onDismissDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dismissOffset += details.delta;
    });
  }

  void _onDismissDragEnd(DragEndDetails details) {
    final dy = _dismissOffset.dy;
    final vy = details.velocity.pixelsPerSecond.dy;
    final shouldDismiss =
        dy.abs() > _dismissTriggerDistance || vy.abs() > 900;

    if (shouldDismiss) {
      Navigator.of(context).maybePop();
      return;
    }

    final begin = _dismissOffset;
    _dismissResetAnimation = Tween<Offset>(begin: begin, end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _dismissResetController,
            curve: Curves.easeOut,
          ),
        );
    _dismissResetController
      ..reset()
      ..forward().whenComplete(() {
        if (!mounted) return;
        setState(() {
          _dismissOffset = Offset.zero;
          _isDraggingToDismiss = false;
        });
        _scheduleAutoHideUi();
      });
  }

  /// 轻量级指针监听：只在「短按且位移很小」时，判断是否在左右边缘区域触发翻页
  void _onPointerDown(PointerDownEvent event) {
    _pointerDownPosition = event.position;
    _pointerDownTime = DateTime.now();
    _ignoreEdgeTapForCurrentPointer = _isPointerOnTopActionButton(
      event.position,
    );
    _edgeTapDirection = _resolveEdgeTapDirection(event.position.dx);
  }

  void _onPointerUp(PointerUpEvent event) {
    final pointerDownPosition = _pointerDownPosition;
    final pointerDownTime = _pointerDownTime;
    final edgeTapDirection = _edgeTapDirection;
    final shouldIgnoreEdgeTap = _ignoreEdgeTapForCurrentPointer;
    _resetEdgeTapTracking();

    if (pointerDownPosition == null || pointerDownTime == null) return;
    if (shouldIgnoreEdgeTap) return;
    if (edgeTapDirection == 0) return;

    final duration = DateTime.now().difference(pointerDownTime);
    final delta = event.position - pointerDownPosition;

    // 判定为「轻点」：时间短、移动距离小，避免与滑动/缩放手势冲突
    if (duration.inMilliseconds > 250) return;
    if (delta.distance > 20) return;

    // 左侧点击区域：上一张
    if (edgeTapDirection < 0) {
      _suppressNextTapToggle = true;
      goToPreviousPage();
      return;
    }

    // 右侧点击区域：下一张
    if (edgeTapDirection > 0) {
      _suppressNextTapToggle = true;
      goToNextPage();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _resetEdgeTapTracking();
  }

  void _resetEdgeTapTracking() {
    _pointerDownPosition = null;
    _pointerDownTime = null;
    _edgeTapDirection = 0;
    _ignoreEdgeTapForCurrentPointer = false;
  }

  int _resolveEdgeTapDirection(double dx) {
    if (dx <= _tapAreaWidth && currentIndex > 0) {
      return -1;
    }
    if (dx >= _screenWidth - _tapAreaWidth &&
        currentIndex < _activeGalleryItems.length - 1) {
      return 1;
    }
    return 0;
  }

  bool _isPointerOnTopActionButton(Offset globalPosition) {
    if (_isPointInsideWidget(_closeButtonKey, globalPosition)) {
      return true;
    }
    if (_canSwitchQuality &&
        _isPointInsideWidget(_qualityButtonKey, globalPosition)) {
      return true;
    }
    if (widget.enableMenu &&
        _isPointInsideWidget(_menuButtonKey, globalPosition)) {
      return true;
    }
    return false;
  }

  bool _isPointInsideWidget(GlobalKey key, Offset globalPosition) {
    final currentContext = key.currentContext;
    if (currentContext == null) {
      return false;
    }

    final renderObject = currentContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return false;
    }

    final localPosition = renderObject.globalToLocal(globalPosition);
    return localPosition.dx >= 0 &&
        localPosition.dy >= 0 &&
        localPosition.dx <= renderObject.size.width &&
        localPosition.dy <= renderObject.size.height;
  }

  void _showImageMenu(BuildContext context, ImageItem item) {
    // 如果禁用了菜单，直接返回
    if (!widget.enableMenu) return;

    final t = slang.Translations.of(context);

    // 动态生成菜单项
    final menuItems = widget.menuItemsBuilder != null
        ? widget.menuItemsBuilder!(context, item)
        : <MenuItem>[];

    // 使用 showAppDialog 显示菜单（末尾始终附带「图库色觉辅助」入口）
    showAppDialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 菜单项列表（每项后均带分隔线，因末尾还有色觉辅助入口）
              ...menuItems.map((menuItem) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(menuItem.icon),
                      title: Text(menuItem.title),
                      onTap: () {
                        AppService.tryPop(); // 关闭对话框
                        menuItem.onTap(); // 执行菜单项动作
                      },
                    ),
                    const Divider(height: 1),
                  ],
                );
              }),
              // 图库色觉辅助（独立于播放器色觉辅助开关）
              ListTile(
                leading: const Icon(Icons.invert_colors),
                title: Text(t.colorVisionAssist.title),
                subtitle: Text(t.colorVisionAssist.galleryDescription),
                onTap: () {
                  AppService.tryPop(); // 关闭菜单对话框
                  ColorVisionSettingsWidget.showSelectionDialog(
                    context,
                    configKey: ConfigKey.GALLERY_COLOR_VISION_FILTER_ID,
                    description: t.colorVisionAssist.galleryDescription,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true, // 点击外部关闭
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final activeGalleryItems = _activeGalleryItems;

    // 获取屏幕宽度
    _screenWidth = MediaQuery.of(context).size.width;
    // 计算点击区域宽度，宽屏和窄屏使用不同的比例
    _tapAreaWidth = _screenWidth > 600
        ? _screenWidth * 0.2
        : _screenWidth * 0.25;

    final dismissProgress = (_dismissOffset.dy.abs() / _dismissFadeDistance)
        .clamp(0.0, 1.0);
    // 拖得越远背景越透，露出下层页面（Telegram 观感）。
    // 曲线用 easeOut：刚起手就有明显反馈，尾段变化放缓。
    final backgroundAlpha =
        1.0 -
        Curves.easeOut.transform(dismissProgress) *
            (1.0 - _dismissMinBackgroundAlpha);
    final contentScale = (1.0 - dismissProgress * 0.12).clamp(0.88, 1.0);
    final chromeOpacity = (_isUiVisible && !_isDraggingToDismiss) ? 1.0 : 0.0;

    return RestoreRawMediaQueryInsets(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          gestures: {
            _ConditionalVerticalDragGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                  _ConditionalVerticalDragGestureRecognizer
                >(
                  () => _ConditionalVerticalDragGestureRecognizer(
                    isEnabled: _canStartDismissDrag,
                  ),
                  (instance) {
                    instance
                      ..onStart = _onDismissDragStart
                      ..onUpdate = _onDismissDragUpdate
                      ..onEnd = _onDismissDragEnd;
                  },
                ),
          },
          child: Container(
            color: Colors.black.withValues(alpha: backgroundAlpha),
            child: Transform.translate(
              offset: Offset(0, _dismissOffset.dy),
              child: Transform.scale(
                scale: contentScale,
                alignment: Alignment.center,
                child: Focus(
                  focusNode: _keyboardFocusNode,
                  autofocus: true,
                  onKeyEvent: (node, event) {
                    final handled = _handleKeyPress(event);
                    return handled
                        ? KeyEventResult.handled
                        : KeyEventResult.ignored;
                  },
                  child: Listener(
                    onPointerSignal: _galleryControls.handlePointerSignal,
                    onPointerDown: _onPointerDown,
                    onPointerUp: _onPointerUp,
                    onPointerCancel: _onPointerCancel,
                    child: GestureDetector(
                      onTap: _toggleUiVisibility,
                      onLongPressStart: (details) {
                        if (!widget.enableMenu) return;
                        _showImageMenu(
                          context,
                          activeGalleryItems[currentIndex],
                        );
                      },
                      onSecondaryTapDown: (details) {
                        if (!widget.enableMenu) return;
                        _showImageMenu(
                          context,
                          activeGalleryItems[currentIndex],
                        );
                      },
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          KeyedSubtree(
                            key: ValueKey(_activeQuality),
                            child: PhotoViewGallery.builder(
                              // PhotoView 默认会给每页铺一层不透明黑底，压在外层那层
                              // 会随拖拽淡出的黑背景之上 —— 不置空的话拖拽消隐完全看不见。
                              // 黑底统一由外层 Container 提供。
                              backgroundDecoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              scrollPhysics: const BouncingScrollPhysics(),
                              allowImplicitScrolling: false,
                              wantKeepAlive: false,
                              builder: (BuildContext context, int index) {
                                final activeItem = activeGalleryItems[index];
                                String imageUrl =
                                    _reloadTimestamps.containsKey(index)
                                    ? '${activeItem.data.originalUrl}?reload=${_reloadTimestamps[index]}'
                                    : activeItem.data.originalUrl;

                                // 检查是否为视频文件
                                bool isVideo = _isVideo(imageUrl);

                                final heroTag = widget.heroTagBuilder?.call(
                                  activeItem,
                                );

                                Widget mediaChild = KeyedSubtree(
                                  key: ValueKey(
                                    '${activeItem.data.id}_${_activeQuality}_${_reloadTimestamps[index] ?? 0}',
                                  ),
                                  child: isVideo
                                      ? VideoPlayerWidget(
                                          key: _getVideoPlayerKey(index),
                                          videoUrl: imageUrl,
                                          headers: activeItem.headers,
                                        )
                                      : imageUrl.startsWith('file://')
                                      ? Image.file(
                                          File(
                                            imageUrl.replaceFirst(
                                              'file://',
                                              '',
                                            ),
                                          ),
                                          fit: BoxFit.contain,
                                        )
                                      : ImageWidget(
                                          imageUrl: imageUrl,
                                          headers: activeItem.headers,
                                        ),
                                );

                                // 图片跟随「图库色觉辅助」独立开关（webm 由播放器
                                // 组件内部同键包装，此处仅处理静态图片，避免叠加）。
                                if (!isVideo) {
                                  mediaChild = ColorVisionFilterWrapper(
                                    configKey: ConfigKey
                                        .GALLERY_COLOR_VISION_FILTER_ID,
                                    child: mediaChild,
                                  );
                                }

                                if (!isVideo && heroTag != null) {
                                  mediaChild = Hero(
                                    tag: heroTag,
                                    child: mediaChild,
                                  );
                                }

                                return PhotoViewGalleryPageOptions.customChild(
                                  child: GestureDetector(
                                    onDoubleTap: () =>
                                        _galleryControls.handleDoubleTap(index),
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Center(child: mediaChild),
                                    ),
                                  ),
                                  minScale:
                                      PhotoViewComputedScale.contained * 0.5,
                                  maxScale: PhotoViewComputedScale.covered * 3,
                                  initialScale:
                                      PhotoViewComputedScale.contained,
                                  controller: controllers[index],
                                );
                              },
                              itemCount: activeGalleryItems.length,
                              pageController: pageController,
                              onPageChanged: _onPageChanged,
                            ),
                          ),
                          SafeArea(
                            child: AnimatedOpacity(
                              opacity: chromeOpacity,
                              duration: const Duration(milliseconds: 180),
                              child: IgnorePointer(
                                ignoring: chromeOpacity == 0,
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        key: _closeButtonKey,
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                      Row(
                                        children: [
                                          if (_canSwitchQuality)
                                            PopupMenuButton<String>(
                                              key: _qualityButtonKey,
                                              tooltip:
                                                  t.common.selectImageQuality,
                                              initialValue: _activeQuality,
                                              icon: const Icon(
                                                Icons.hd_outlined,
                                                color: Colors.white,
                                              ),
                                              onSelected: _handleQualityChanged,
                                              itemBuilder: (context) => [
                                                PopupMenuItem<String>(
                                                  enabled: false,
                                                  child: Text(
                                                    t.common.selectImageQuality,
                                                  ),
                                                ),
                                                const PopupMenuDivider(),
                                                CheckedPopupMenuItem<String>(
                                                  value:
                                                      galleryImageQualityStandard,
                                                  checked:
                                                      _activeQuality ==
                                                      galleryImageQualityStandard,
                                                  child: Text(
                                                    t
                                                        .common
                                                        .imageQualityStandard,
                                                  ),
                                                ),
                                                CheckedPopupMenuItem<String>(
                                                  value:
                                                      galleryImageQualityOriginal,
                                                  checked:
                                                      _activeQuality ==
                                                      galleryImageQualityOriginal,
                                                  child: Text(
                                                    t
                                                        .common
                                                        .imageQualityOriginal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          // 快捷键设置按钮
                                          IconButton(
                                            icon: const Icon(
                                              Icons.keyboard,
                                              color: Colors.white,
                                            ),
                                            tooltip:
                                                t.settings.keybinding.title,
                                            onPressed: () =>
                                                KeybindingSettingsPage.openSheet(
                                                  context,
                                                  scopeFilter:
                                                      ShortcutScope.gallery,
                                                ),
                                          ),
                                          // 三个点菜单按钮
                                          if (widget.enableMenu)
                                            IconButton(
                                              key: _menuButtonKey,
                                              icon: const Icon(
                                                Icons.more_vert,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                _showImageMenu(
                                                  context,
                                                  activeGalleryItems[currentIndex],
                                                );
                                                _showUiAndAutoHide();
                                              },
                                            ),
                                          // 页码显示
                                          const SizedBox(width: 8),
                                          Text(
                                            '${currentIndex + 1}/${activeGalleryItems.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConditionalVerticalDragGestureRecognizer
    extends VerticalDragGestureRecognizer {
  _ConditionalVerticalDragGestureRecognizer({required this.isEnabled});

  final bool Function() isEnabled;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (!isEnabled()) return;
    super.addAllowedPointer(event);
  }
}
