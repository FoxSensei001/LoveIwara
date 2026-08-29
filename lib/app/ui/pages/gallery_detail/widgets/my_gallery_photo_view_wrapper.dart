import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/player_keybinding/keybinding_service.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_scope.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_target_registry.dart';
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
    // 图库域按键与视频域走同一条路：不依赖「焦点恰好落在本子树」。
    // 这只 Focus 原本自己 onKeyEvent 收键，于是任何一次焦点外移（顶栏按钮、
    // 弹层、宽屏里的任意可聚焦控件）都会让图库快捷键静默失效——与播放器当初
    // 真机实测到的是同一个缺陷，见 ShortcutTargetRegistry 的说明。
    ShortcutTargetRegistry.instance.register(
      owner: this,
      scope: ShortcutScope.gallery,
      handle: _handlePlayerKeyEventFromRegistry,
      isEligible: _acceptsShortcutsNow,
    );
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
    ShortcutTargetRegistry.instance.unregister(this);
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

  /// 本层此刻是否应该接管图库域按键。判据与播放器一致，逐次实时求值。
  ///
  /// 少一条「与全屏态一致」——图库查看器没有内嵌/全屏两份同时挂载的情况。
  bool _acceptsShortcutsNow() {
    if (!mounted) return false;
    if (ModalRoute.isCurrentOf(context) != true) return false;
    if (OverlayTracker.instance.hasOverlay) return false;
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return false;
    }
    return true;
  }

  /// [ShortcutTargetRegistry] 的派发入口。
  KeyEventResult _handlePlayerKeyEventFromRegistry(KeyEvent event) {
    return _handleKeyPress(event)
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
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
    // 这次不执行，但如果这个键确实绑在图库域上（按住不放产生的重复事件、或
    // 当前位置执行不了的动作），仍要消费掉：放过去会被 WidgetsApp 的默认快捷键
    // 翻译成 DirectionalFocusIntent 把焦点挪走——图库默认键位正是方向键。
    if (service.matchIgnoringRepeatPolicy(event, ShortcutScope.gallery) !=
        null) {
      return true;
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

  /// 画质选择：全站统一的玻璃菜单。原来是 `PopupMenuButton` + 一条
  /// `enabled: false` 的假标题 + `CheckedPopupMenuItem`；标题现在走
  /// [GlassMenuSectionHeader]，勾选态走 [GlassMenuOption.selected]。
  Future<void> _openQualityMenu(BuildContext anchorContext) async {
    final t = slang.Translations.of(anchorContext);
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        GlassMenuSectionHeader(t.common.selectImageQuality),
        // 标题与选项之间压一条分隔线：线之上是「这张菜单在问什么」，之下才是
        // 能点的东西。少了它，小标题和两条选项一样是三行左对齐文字，读起来像
        // 三个平级条目。
        const GlassMenuSeparator(),
        GlassMenuOption<String>(
          value: galleryImageQualityStandard,
          label: t.common.imageQualityStandard,
          selected: _activeQuality == galleryImageQualityStandard,
        ),
        GlassMenuOption<String>(
          value: galleryImageQualityOriginal,
          label: t.common.imageQualityOriginal,
          selected: _activeQuality == galleryImageQualityOriginal,
        ),
      ],
    );
    if (picked != null) _handleQualityChanged(picked);
  }

  /// 画质触发钮的钮面：**当前处在哪一档必须一眼看出来**。
  ///
  /// 原来两档共用一枚白色 `hd_outlined`，钮上没有任何东西随画质变化——切成原画
  /// 之后顶栏和之前一模一样，只能靠再打开一次菜单看对勾才知道自己在哪档。
  ///
  /// 现在三处一起变，并且都在同一段时值里过渡（颜色也是形变，见
  /// [GlassAnimatedColors]）：
  ///   - 底色：标清是半透明白的"未点亮"胶囊，原画整枚翻成实白（亮起来）；
  ///   - 图标：描边 `hd_outlined` ↔ 实心 `hd`，交替走 [GlassAnimatedIcon]；
  ///   - 文字：直接把档位名写在钮上，不用猜"点亮"是什么意思。
  Widget _buildQualityIndicator(BuildContext context, slang.Translations t) {
    final isOriginal = _activeQuality == galleryImageQualityOriginal;
    final label = isOriginal
        ? t.common.imageQualityOriginal
        : t.common.imageQualityStandard;
    // 胶囊本身只有 34 高，外面仍留满 48 的可点高度：一来手指目标不缩水，二来
    // _isPointInsideWidget 靠这只 key 的 RenderBox 把「点在按钮上」从左右边缘
    // 翻页里摘出去，矮下去会让钮上下各露一条会翻页的缝。
    return SizedBox(
      height: 48,
      child: Center(
        widthFactor: 1,
        child: GlassAnimatedColors(
          colors: [
            // 0 底色 / 1 前景（图标+文字） / 2 描边
            isOriginal ? Colors.white : Colors.white.withValues(alpha: 0.14),
            isOriginal ? Colors.black87 : Colors.white,
            isOriginal ? Colors.white : Colors.white.withValues(alpha: 0.32),
          ],
          builder: (context, c) => Container(
            height: 34,
            padding: const EdgeInsetsDirectional.only(start: 9, end: 11),
            decoration: BoxDecoration(
              color: c[0],
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: c[2]),
            ),
            child: AnimatedSize(
              duration: GlassTokens.motionDuration,
              curve: GlassTokens.motionCurve,
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassAnimatedIcon(
                    icon: Icon(
                      isOriginal ? Icons.hd : Icons.hd_outlined,
                      size: 18,
                      color: c[1],
                    ),
                  ),
                  const SizedBox(width: 5),
                  // 顶栏右侧还挤着快捷键 / ⋮ / 页码，日语的「オリジナル」在窄屏上
                  // 会顶到边——让它省略而不是把整行撑爆。
                  Flexible(
                    child: AnimatedSwitcher(
                      duration: GlassTokens.motionDuration,
                      switchInCurve: GlassTokens.motionCurve,
                      switchOutCurve: GlassTokens.motionCurve.flipped,
                      child: Text(
                        label,
                        key: ValueKey<String>(label),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c[1],
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
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
    );
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
    final shouldDismiss = dy.abs() > _dismissTriggerDistance || vy.abs() > 900;

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

  /// 「色觉辅助」那一条的哨兵下标：菜单项本身按下标取值，负数不会撞上。
  static const int _colorVisionMenuValue = -1;

  /// 图片操作菜单：全站统一的玻璃面板（复制 / 另存 / 保存到相册……，末尾始终
  /// 附带「图库色觉辅助」入口）。
  ///
  /// 原来是 `showAppDialog` 里塞一列 `ListTile` + `Divider`——一张居中的不透明
  /// 卡片，既离手指远、又和全站其它菜单不是一套东西（横向图片列表那边早就换过
  /// 了，见 `horizontial_image_list.dart` 的同名方法）。
  ///
  /// 三个入口共用它：长按图片、右键、右上角 ⋮。前两者传 [globalPosition]，面板
  /// 贴着落点弹出；⋮ 不传，贴着按钮弹（落点从 [anchorContext] 量）。
  ///
  /// ⛔ 必须在长按回调的**同步前缀**里被调到：`showGlassMenu` 就在第一个 await
  /// 之前，手指接力票才领得到（见 [GlassLongPressMenuArea.onMenu]）。
  Future<void> _showImageMenu(
    BuildContext anchorContext,
    ImageItem item, {
    Offset? globalPosition,
  }) async {
    // 如果禁用了菜单，直接返回
    if (!widget.enableMenu) return;

    final t = slang.Translations.of(anchorContext);

    // 动态生成菜单项
    final menuItems = widget.menuItemsBuilder != null
        ? widget.menuItemsBuilder!(anchorContext, item)
        : <MenuItem>[];

    final picked = await showGlassMenu<int>(
      anchorContext: anchorContext,
      globalAnchor: globalPosition == null ? null : globalPosition & Size.zero,
      entries: [
        for (final (index, menuItem) in menuItems.indexed)
          GlassMenuOption<int>(
            value: index,
            icon: menuItem.icon,
            label: menuItem.title,
          ),
        if (menuItems.isNotEmpty) const GlassMenuSeparator(),
        // 图库色觉辅助（独立于播放器色觉辅助开关）
        GlassMenuOption<int>(
          value: _colorVisionMenuValue,
          icon: Icons.invert_colors,
          label: t.colorVisionAssist.title,
          description: t.colorVisionAssist.galleryDescription,
        ),
      ],
    );
    if (picked == null || !mounted) return;
    if (picked == _colorVisionMenuValue) {
      ColorVisionSettingsWidget.showSelectionDialog(
        context,
        configKey: ConfigKey.GALLERY_COLOR_VISION_FILTER_ID,
        description: t.colorVisionAssist.galleryDescription,
      );
      return;
    }
    menuItems[picked].onTap();
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
                  // 不再在这里 onKeyEvent：按键统一由应用根部经
                  // ShortcutTargetRegistry 派发进来，两处都收会双触发。
                  child: Listener(
                    onPointerSignal: _galleryControls.handlePointerSignal,
                    onPointerDown: _onPointerDown,
                    onPointerUp: _onPointerUp,
                    onPointerCancel: _onPointerCancel,
                    child: GestureDetector(
                      onSecondaryTapDown: (details) {
                        if (!widget.enableMenu) return;
                        _showImageMenu(
                          context,
                          activeGalleryItems[currentIndex],
                          globalPosition: details.globalPosition,
                        );
                      },
                      // 长按走 GlassLongPressMenuArea：面板贴着手指弹出，且手指
                      // 不抬就能直接划到某一条上松手选中（点按与它同层分家，
                      // 见该组件类文档）。
                      child: GlassLongPressMenuArea(
                        onTap: _toggleUiVisibility,
                        // 关掉菜单时连长按都不注册：onMenu 一旦挂上，长按到点就
                        // 会先震一下、再去发现「没有菜单可开」。
                        onMenu: !widget.enableMenu
                            ? null
                            : (globalPosition) => _showImageMenu(
                                context,
                                activeGalleryItems[currentIndex],
                                globalPosition: globalPosition,
                              ),
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
                                      onDoubleTap: () => _galleryControls
                                          .handleDoubleTap(index),
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Center(child: mediaChild),
                                      ),
                                    ),
                                    minScale:
                                        PhotoViewComputedScale.contained * 0.5,
                                    maxScale:
                                        PhotoViewComputedScale.covered * 3,
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
                                        // 右侧这组会随画质钮的文案变宽（日语最
                                        // 长），Flexible 让它在窄屏上有处可让，
                                        // 而不是把整行顶出 OVERFLOWED 条。
                                        Flexible(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (_canSwitchQuality)
                                                // 画质面板走全站统一的玻璃菜单
                                                // （原来是 PopupMenuButton）。
                                                Builder(
                                                  key: _qualityButtonKey,
                                                  builder: (anchorContext) =>
                                                      GlassPressable(
                                                        // 长按也能打开，且长按不
                                                        // 抬手可以直接划到某一条上
                                                        // 松手选中（见
                                                        // GlassTapArea.opensOverlay）。
                                                        opensOverlay: true,
                                                        onTap: () =>
                                                            _openQualityMenu(
                                                              anchorContext,
                                                            ),
                                                        builder:
                                                            (
                                                              context,
                                                              pressed,
                                                            ) =>
                                                                _buildQualityIndicator(
                                                                  context,
                                                                  t,
                                                                ),
                                                      ),
                                                ),
                                              if (_canSwitchQuality)
                                                const SizedBox(width: 4),
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
                                              // 三个点菜单按钮：与旁边的画质键同
                                              // 一套触发件（长按也能打开、且长按
                                              // 不抬手可以直接划到某一条上松手
                                              // 选中，见 GlassTapArea.opensOverlay）。
                                              if (widget.enableMenu)
                                                Builder(
                                                  key: _menuButtonKey,
                                                  builder: (anchorContext) =>
                                                      GlassPressable(
                                                        opensOverlay: true,
                                                        onTap: () {
                                                          _showImageMenu(
                                                            anchorContext,
                                                            activeGalleryItems[currentIndex],
                                                          );
                                                          _showUiAndAutoHide();
                                                        },
                                                        builder:
                                                            (
                                                              context,
                                                              pressed,
                                                            ) => const SizedBox.square(
                                                              dimension: 48,
                                                              child: Icon(
                                                                Icons.more_vert,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                      ),
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
