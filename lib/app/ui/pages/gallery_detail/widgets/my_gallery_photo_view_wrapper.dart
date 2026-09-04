import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/player_keybinding/keybinding_service.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/services/page_departure_guard.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_scope.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_target_registry.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_corner_chips.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_chrome_theme.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_filmstrip.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_video_center_button.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_video_control_bar.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_video_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/player_box_scope.dart';
import 'package:i_iwara/utils/easy_throttle.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:i_iwara/common/gallery_image_quality.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/device_form_factor_utils.dart';
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
    this.onIndexChanged,
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

  /// 翻到第几张就回报一次。
  ///
  /// 图库详情页拿它把底下那条横向清单同步滚过去：这一页是**盖在**详情页上的一层，
  /// 不同步的话退出来清单还停在当初点进去的那张，位置对不上
  /// （见 `HorizontalImageListController`）。
  ///
  /// ⛔ **进来那一下不报**：那一刻底下的清单正停在用户刚点的那张上，再挪一次
  /// 就是在入场淡入的当口把画面里的东西搬走。开局就不在同一张的
  /// 那条路（预览弹窗直开大图）由调用方自己先播一次种，见
  /// `openGalleryImageViewerByFileId`。
  final ValueChanged<int>? onIndexChanged;

  @override
  State<MyGalleryPhotoViewWrapper> createState() =>
      _MyGalleryPhotoViewWrapperState();
}

class _MyGalleryPhotoViewWrapperState extends State<MyGalleryPhotoViewWrapper>
    with TickerProviderStateMixin
    implements PageDepartureAware {
  late int currentIndex;
  late String _activeQuality;
  late PageController pageController;
  late List<PhotoViewController> controllers;

  bool _isUiVisible = true;
  Timer? _uiHideTimer;

  // 跟随路由过渡切换系统 UI（侧边栏）用，见 _attachRouteAnimation
  ModalRoute<dynamic>? _observedRoute;
  Animation<double>? _routeAnimation;
  bool _isExiting = false;
  final FocusNode _keyboardFocusNode = FocusNode(debugLabel: 'GalleryViewer');

  // Telegram-like drag-to-dismiss state
  Offset _dismissOffset = Offset.zero;
  bool _isDraggingToDismiss = false;
  late final AnimationController _dismissResetController;
  Animation<Offset>? _dismissResetAnimation;

  /// 这台设备需不需要那枚「转成横屏」的键。
  ///
  /// 只有手机需要：App 启动时把手机**强制锁在竖屏**（见
  /// [DeviceFormFactorUtils.applyMobileOrientationPolicy]），于是图库里那条横视频
  /// 只能缩在屏幕中间一条，用户没有任何办法把设备横过来。平板 / 桌面 / XR 本来
  /// 就没被锁，多一枚键只是噪声。
  bool _canRotateToLandscape = false;

  /// 此刻是不是靠那枚键把系统屏幕转成了横屏。
  bool _isLandscapeFullscreen = false;

  /// 已经在拆了。
  ///
  /// ⛔ [State.mounted] 在 `dispose()` **执行期间仍然是 true**（element 是在
  /// dispose 返回之后才置空的），而那一刻整棵树是锁住的——照着 `mounted` 去
  /// `setState` 会当场抛「widget tree was locked」。收尾那条路要靠这面旗子分辨。
  bool _disposed = false;

  // 记录当前屏幕宽度和左右点击区域宽度，用于轻量级指针监听
  double _screenWidth = 0;
  double _tapAreaWidth = 0;

  final AppService? _appService = Get.isRegistered<AppService>()
      ? Get.find<AppService>()
      : null;
  final ConfigService? _configService = Get.isRegistered<ConfigService>()
      ? Get.find<ConfigService>()
      : null;
  late GalleryControls _galleryControls;
  final GlobalKey _qualityButtonKey = GlobalKey();
  final GlobalKey _menuButtonKey = GlobalKey();
  final GlobalKey _topChromeKey = GlobalKey();
  final GlobalKey _bottomChromeKey = GlobalKey();
  final GlobalKey _centerControlsKey = GlobalKey();

  /// 「点/滚在这上面不算翻页」的名单。
  ///
  /// ⛔ 原本是三个 if 手写在 `_isPointerOnTopActionButton` 里，于是每加一件浮在
  /// 画面上的 chrome 就要记得回去补一条——底部控件条与胶片条正好落在左右各
  /// 20~25% 的翻页热区里，漏一条就是「拖进度条拖着拖着翻页了」。改成三片
  /// 整区（顶 / 中 / 底），新 chrome 只要摆进对应那片就自动被算进来。
  ///
  /// 滚轮同样问这张名单，见 [_handlePointerSignal]。
  Iterable<GlobalKey> get _chromeHitKeys => [
    _topChromeKey,
    _centerControlsKey,
    _bottomChromeKey,
  ];

  // 使用Map存储每个图片的重新加载时间戳
  final Map<int, int> _reloadTimestamps = {};

  /// 每条视频一只轻量播放器，**按文件 id 存**。
  ///
  /// ⛔ 不能按下标：切画质会把整份清单换成另一份对象（`standardGalleryItems` ↔
  /// `originalGalleryItems`），按下标存的话第 3 页的播放器会被第 3 页的**另一个
  /// 文件**接手；预览弹窗那条路进来时首图还会被提到最前，下标与文件更是对不上。
  final Map<String, GalleryVideoController> _videoControllers = {};

  /// 当前这一页那条视频的播放器；这一页是静态图就是 null。
  GalleryVideoController? get _currentVideoController {
    final items = _activeGalleryItems;
    if (currentIndex < 0 || currentIndex >= items.length) return null;
    final item = items[currentIndex];
    if (!item.isVideo) return null;
    return _videoControllers[item.data.id];
  }

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
    // 首帧就要有：控件条在 build 的开头问「这一页有播放器吗」，晚建一步就是
    // 第一帧问到 null（见 [_ensureVideoControllers]）。
    _ensureVideoControllers(currentIndex);
    _observeCurrentVideo();
    _syncChromeVideo();
    _appService?.hideSystemUI(hideTitleBar: false);
    _resolveRotationCapability();
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
      // 这三条只在当前页是视频时有事可做，所以取的是**当下**那一页的播放器，
      // 而不是在这里捕获某一只。
      onTogglePlayPause: () {
        final controller = _currentVideoController;
        if (controller == null) return false;
        controller.togglePlayPause();
        return true;
      },
      onSeek: (forward) {
        final controller = _currentVideoController;
        if (controller == null || !controller.ready) return false;
        // 步长跟播放器设置走，图库不另开一套：用户在设置里把快进改成 5 秒，
        // 这里也该是 5 秒。
        final seconds = _seekSeconds(forward);
        controller.seekBy(Duration(seconds: forward ? seconds : -seconds));
        return true;
      },
      onToggleMute: () {
        final controller = _currentVideoController;
        if (controller == null || !controller.ready) return false;
        controller.toggleMute();
        return true;
      },
    );
    _galleryControls.currentIndex = currentIndex;
    // 跳去别的页面时收尾（暂停）。图库查看器此前完全没接这条：从提示条的动作钮
    // 跳走之后，视频会在新页面背面继续响。
    PageDepartureGuard.attach(this);

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
      // 缩放流要等 PhotoView 排完第一帧才有值。
      _observePageScale();
      // 进来先亮着，过一会儿自己收（看图与看视频一视同仁）。
      _scheduleAutoHideUi();
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
        // 屏幕方向跟系统 UI 走同一拍：一开始 pop 就转回竖屏，转屏与本页淡出
        // 同时发生。只写在 dispose 里的话，用户会先看着横屏的下层页面，等本页
        // 被移除之后屏幕才自己转回来。
        _exitLandscapeFullscreen();
        _setExiting(true);
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        _appService?.hideSystemUI(hideTitleBar: false);
        // iOS 侧滑取消（reverse -> forward）会走到这里，退场那套要收回去。
        _setExiting(false);
    }
  }

  /// 退场（下拉甩出 / 系统返回 / 关闭钮）时这一页只做一件事：**淡出**。
  ///
  /// 黑底跟着路由动画一起退（见 [_ExitFadeBackdrop]），不再是「整屏黑着淡」
  /// ——后者看上去是「先黑屏一下再露出下面那页」。
  ///
  /// 这里曾经还负责在退场前把 Hero 关掉（`HeroMode(enabled: !_isExiting)`）：
  /// 那时进来那一下要飞一段「缩略图长成大图」。整套 Hero 已于 2026-09-05 按用户
  /// 要求整只移除（不管从哪个入口进来都没有），所以只剩淡出这一件事。
  void _setExiting(bool value) {
    if (_isExiting == value) return;
    setState(() {
      _isExiting = value;
    });
  }

  @override
  void dispose() {
    _disposed = true;
    ShortcutTargetRegistry.instance.unregister(this);
    PageDepartureGuard.detach(this);
    _observedVideo?.removeListener(_handleVideoPlaybackChanged);
    _observedVideo = null;
    _pageScaleSubscription?.cancel();
    _chromeVideoDropTimer?.cancel();
    // 释放所有视频播放器资源
    _releaseAllVideoPlayers();

    // 移除音量键监听
    _galleryControls.disableVolumeKeyListener();
    _detachRouteAnimation();
    // 兜底：无过渡动画的 pop（或路由没有 animation）时仍要恢复系统 UI 与屏幕方向。
    // 与上面的 reverse 分支重复调用是幂等的（Rx 同值不通知 / 方向策略幂等）。
    _appService?.showSystemUI();
    _exitLandscapeFullscreen();
    _uiHideTimer?.cancel();
    _dismissResetController.dispose();
    _keyboardFocusNode.dispose();
    pageController.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 真正把播放器还回去。
  ///
  /// ⛔ 改造前这里叫 `releasePlayer()`，方法体却只有一句 `pause()`——名字说的是
  /// 释放，做的是暂停，于是退出大图页之后 libmpv 实例还挂着。
  void _releaseAllVideoPlayers() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
  }

  /// 拿这一条的播放器，没有就现建。
  ///
  /// 每只都是一份 libmpv 实例，所以只给当前页前后各一页留（[_reapVideoControllers]
  /// 负责回收更远的）：图库里连着好几条视频时，全建出来既吃内存，也正撞上项目
  /// 里那份「播放器 dispose 后几秒原生闪退」的悬案。
  GalleryVideoController _videoControllerFor(ImageItem item) {
    return _videoControllers.putIfAbsent(
      item.data.id,
      () => GalleryVideoController(
        videoUrl: item.data.originalUrl,
        headers: item.headers,
      ),
    );
  }

  /// 把**当前这一页**的播放器提前建好。
  ///
  /// ⛔ 不能只靠 `PhotoViewGallery.builder` 里那次懒建：控件条挂在大图页的
  /// `Stack` 上、在 build 的**开头**就要问「这一页有播放器吗」，而懒建发生在同
  /// 一次 build 的**后面**。第一帧永远问到 null，之后又没有任何东西触发重建
  /// ——读起来就是「视频在放，但控件条从来不出现」。
  ///
  /// ⛔ **只建当前这一页，不预建邻居**。前后各建一个的写法看着是"预加载"，实际
  /// 是让 2~3 条网络流同时开着抢带宽——视频挨着视频的图库里，中间那条就可能一直
  /// 停在黑屏转圈（用户 2026-09-04 报的 fNydvxHY6CDxjm 第 2 个 item 正是这个形状）。
  /// 邻居**已经建过**的会被 [_reapVideoControllers] 的 ±1 窗口留下来，所以来回
  /// 翻页并不会反复重开。
  ///
  /// 返回是否动过表，调用方据此决定要不要 setState。
  bool _ensureVideoControllers(int centerIndex) {
    final items = _activeGalleryItems;
    if (centerIndex < 0 || centerIndex >= items.length) return false;
    final item = items[centerIndex];
    if (!item.isVideo) return false;
    if (_videoControllers.containsKey(item.data.id)) return false;
    _videoControllerFor(item);
    return true;
  }

  /// 回收离当前页太远的播放器。
  ///
  /// ⛔ **必须排到帧末**：`dispose()` 之后这只 `ChangeNotifier` 就不能再被
  /// `addListener`，而翻页那一刻旧页的 `GalleryVideoPlayer` 还挂在树上、还会
  /// 在本帧重建一次。当场回收会让那次重建撞上一只已经 dispose 的 notifier。
  void _reapVideoControllers(int centerIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final items = _activeGalleryItems;
      final keep = <String>{};
      for (var i = centerIndex - 1; i <= centerIndex + 1; i++) {
        if (i < 0 || i >= items.length) continue;
        if (items[i].isVideo) keep.add(items[i].data.id);
      }
      final stale = _videoControllers.keys
          .where((id) => !keep.contains(id))
          // 正在演退场的那只先留着：控件还挂在树上引用着它，当场 dispose 会让
          // 下一次重建撞上一只已经 dispose 的 ChangeNotifier。下次翻页再收。
          .where((id) => !identical(_videoControllers[id], _chromeVideo))
          .toList(growable: false);
      if (stale.isEmpty) return;
      for (final id in stale) {
        _videoControllers.remove(id)?.dispose();
      }
    });
  }

  // ---- 「当前这条视频」的旁听 ------------------------------------------------
  //
  // chrome 的自动收起要在**开始播放**那一刻才排得上，而控件条上的播放钮是先
  // 报 onInteraction、再 togglePlayPause——排定时器的时候 `playing` 还是 false，
  // 只看那一下永远排不上。所以改成旁听当前这只播放器的播放态翻面。

  GalleryVideoController? _observedVideo;
  bool _observedPlaying = false;

  // ---- 视频控件的进退 --------------------------------------------------------
  //
  // ⛔ 从视频翻到图片时不能当场把中间那组钮和控件条从树上摘掉——那是硬切，
  // 而本项目对"出现与消失都必须有动画"是明令要求的。所以留一份**正在退场的**
  // 播放器引用，让 GlassReveal / GlassGroupSlot 把退场演完，演完再摘。

  GalleryVideoController? _chromeVideo;
  Timer? _chromeVideoDropTimer;

  /// 退场留够的时间：位移与材质都走 [GlassTokens.motionDuration]，留一倍余量。
  static const Duration _chromeExitGrace = Duration(milliseconds: 480);

  void _syncChromeVideo() {
    final current = _currentVideoController;
    if (current != null) {
      _chromeVideoDropTimer?.cancel();
      _chromeVideoDropTimer = null;
      if (!identical(_chromeVideo, current)) {
        _chromeVideo = current;
        if (mounted) setState(() {});
      }
      return;
    }
    if (_chromeVideo == null) return;
    _chromeVideoDropTimer?.cancel();
    _chromeVideoDropTimer = Timer(_chromeExitGrace, () {
      if (!mounted || _currentVideoController != null) return;
      setState(() => _chromeVideo = null);
    });
  }

  // ---- 「这一页被放大到多少」--------------------------------------------------
  //
  // 控件条左上角那枚钮要显示当前倍数、点一下复位，所以得有人盯着 PhotoView 的
  // 缩放值。`PhotoViewController` 自己吐 `outputStateStream`，订阅当前这一页即可。

  /// 当前页的缩放倍数。1.0 = 原始（`customChild` 的 contained 就是 1.0）。
  double _pageScale = 1.0;
  StreamSubscription<PhotoViewControllerValue>? _pageScaleSubscription;

  void _observePageScale() {
    // ⛔ 这里**不碰** `_chromeVideoDropTimer`。它是「视频控件演完退场再摘」的
    // 那只闹钟（见 [_syncChromeVideo]），与页面缩放毫无关系——曾经从
    // `_pageScaleSubscription` 那行一起抄了下来，只因为每个调用点恰好紧接着都会
    // 再调一次 `_syncChromeVideo()` 重新上闹钟才没出事。一旦顺序变了或多一个
    // 调用点，`_chromeVideo` 就会永远钉住：控件条与中央控件在图片页上退不掉，
    // 而 [_reapVideoControllers] 又刻意跳过那一只，等于漏一份 libmpv 实例。
    _pageScaleSubscription?.cancel();
    _pageScaleSubscription = null;
    if (currentIndex < 0 || currentIndex >= controllers.length) return;
    final controller = controllers[currentIndex];
    _applyPageScale(controller.scale ?? 1.0);
    _pageScaleSubscription = controller.outputStateStream.listen(
      (value) => _applyPageScale(value.scale ?? 1.0),
    );
  }

  void _applyPageScale(double scale) {
    if (!mounted) return;
    // 缩放流每帧都吐，差不到半个百分点就别重建整页了。
    if ((scale - _pageScale).abs() < 0.005) return;
    setState(() => _pageScale = scale);
  }

  void _resetPageScale() {
    _showUiAndAutoHide();
    _galleryControls.resetZoom();
  }

  void _observeCurrentVideo() {
    final next = _currentVideoController;
    if (identical(next, _observedVideo)) return;
    _observedVideo?.removeListener(_handleVideoPlaybackChanged);
    _observedVideo = next;
    _observedPlaying = next?.playing ?? false;
    next?.addListener(_handleVideoPlaybackChanged);
  }

  void _handleVideoPlaybackChanged() {
    if (!mounted) return;
    final playing = _observedVideo?.playing ?? false;
    if (playing == _observedPlaying) return;
    _observedPlaying = playing;
    if (playing) {
      // 放起来了：过一会儿把 chrome 收走，别一直挡着画面下缘。
      _scheduleAutoHideUi();
    } else {
      // 停下来了：把 chrome 放回来——此刻用户多半正想操作它。之后照样会自己收。
      _showUiAndAutoHide();
    }
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
      _ensureVideoControllers(index);
    });
    _observeCurrentVideo();
    _observePageScale();
    _syncChromeVideo();
    // 离得远的整只还回去（每只都是一份 libmpv 实例）。排到帧末，理由见方法注释。
    _reapVideoControllers(index);
    _galleryControls.updateCurrentIndex(index);
    widget.onIndexChanged?.call(index);

    // 根据当前页面是否是视频来决定是否启用音量键监听
    _updateVolumeKeyListener();

    // 预加载周围的图片
    _preloadNearbyImages(index);

    // ⛔ 翻页**不再无条件把界面弹回来**。
    //
    // 用户把界面收起来就是为了干净看图，每翻一页又弹一次是在跟他较劲
    // （2026-09-04 用户明确要求）。只有一种情况要主动亮出来：**翻到了视频**
    // ——那一页凭空多出播放钮、进度条、胶片条，不亮一下用户不知道它们存在。
    if (_currentVideoController != null) {
      _showUiAndAutoHide();
    } else {
      // 还开着就顺手把计时器往后推一档；已经收起来的保持收起。
      //
      // ⛔ 这里**不**顺手转回竖屏：图片页右下角自己有一枚横竖屏牌
      // （见 [_buildImageCornerChips]），横过来看长图是正当需求。曾经有一版在
      // 这儿强制转回，理由是「图片页没有出口」——出口后来补上了，那条就该撤掉。
      _scheduleAutoHideUi();
    }
  }

  /// 暂停除指定索引外的所有视频
  void _pauseAllVideosExcept(int currentIndex) {
    final activeGalleryItems = _activeGalleryItems;
    final String? keepId =
        currentIndex >= 0 && currentIndex < activeGalleryItems.length
        ? activeGalleryItems[currentIndex].data.id
        : null;
    for (final entry in _videoControllers.entries) {
      if (entry.key == keepId) continue;
      entry.value.pause();
    }
  }

  /// 一次快进 / 快退多少秒。跟播放器设置走，图库不另开一套开关。
  int _seekSeconds(bool forward) {
    final value =
        _configService?[forward
            ? ConfigKey.FAST_FORWARD_SECONDS_KEY
            : ConfigKey.REWIND_SECONDS_KEY];
    return value is int && value > 0 ? value : 10;
  }

  /// 某项播放器手势开关是否打开（默认开）。
  bool _gestureEnabled(ConfigKey key) => _configService?[key] as bool? ?? true;

  /// 暂停这一页在内的**所有**视频（被别的页面盖住、应用退到后台时用）。
  void _pauseAllVideos() {
    for (final controller in _videoControllers.values) {
      controller.pause();
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

    final isCurrentVideo = activeGalleryItems[currentIndex].isVideo;

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
      if (item.isVideo) continue;

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
      // 胶囊高 34，外面留满顶栏那条玻璃的高度（44）：手指目标不缩水，
      // 且 _isPointInsideWidget 靠这只 key 把「点在按钮上」从边缘翻页里摘出去。
      height: GlassTokens.pillHeight,
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
      // 换的是另一份清单对象，播放器表按文件 id 存所以能留下来；但这一档下多
      // 出来的视频条目要补建。
      _ensureVideoControllers(nextIndex);
    });
    _observeCurrentVideo();
    _observePageScale();
    _syncChromeVideo();

    _galleryControls.updateCurrentIndex(currentIndex);
    widget.onIndexChanged?.call(currentIndex);
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

  /// chrome 自动收起的时值。与主播放器的 `_autoHideDelay` 同一档。
  static const Duration _uiAutoHideDelay = Duration(seconds: 4);

  void _showUiAndAutoHide() {
    if (!mounted) return;
    setState(() {
      _isUiVisible = true;
    });
    _scheduleAutoHideUi();
  }

  /// 排一次「过一会儿自己收起来」。
  ///
  /// 这套骨架（`_isUiVisible` / `_uiHideTimer` / 本方法）从 2026-02 引入那天起
  /// 就只有 `cancel()` 一行、从未真正调度过——图库的 chrome 从来没有自动收起过。
  ///
  /// 2026-09-04 用户拍板：**看图与看视频一视同仁**，都过一段时间自己收。看图时
  /// 那几枚钮同样是压在画面上的东西，没道理只让视频让开。
  ///
  /// 唯一不排的情况是**正被按住加速**：那会儿手指还在屏幕上，收起来毫无意义，
  /// 而且松手时 [_endVideoBoost] 会重排一次。
  void _scheduleAutoHideUi() {
    _uiHideTimer?.cancel();
    if (!_isUiVisible) return;
    if (_currentVideoController?.boosting == true) return;
    _uiHideTimer = Timer(_uiAutoHideDelay, () {
      if (!mounted || !_isUiVisible) return;
      setState(() {
        _isUiVisible = false;
      });
    });
  }

  /// 单击画面：**切**顶栏与控件条的显隐。
  ///
  /// 改造前这里只有「不可见就置为可见」一个分支，没有任何地方会把它置回 false
  /// ——名字叫 toggle，实际只会开。控件条进来之后必须能收起，否则看视频时画面
  /// 下缘恒被挡住。
  void _toggleUiVisibility() {
    if (!mounted) return;
    _uiHideTimer?.cancel();
    setState(() {
      _isUiVisible = !_isUiVisible;
    });
    if (_isUiVisible) _scheduleAutoHideUi();
  }

  // ---- 视频页的长按加速 ------------------------------------------------------
  //
  // 与主播放器 `GestureArea` 同一套手感：按住画面进入倍速，手指**横向**拖动调档，
  // 松手回 1×。系数、阈值、上下限都照抄那边（每 30px 一档、按拖动距离放大档距、
  // 夹在 0.1–4.0、保留一位小数），不另起一套——同一个应用里"按住画面"的手感只
  // 应该有一种。
  //
  // ⛔ 与「长按开菜单」互斥，见 build 里 GlassLongPressMenuArea.onMenu 那段。

  double? _boostStartX;
  double _boostBaseRate = 2.0;

  double get _configuredBoostRate {
    final value = _configService?[ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY];
    return value is double && value > 0 ? value : 2.0;
  }

  void _beginVideoBoost(GalleryVideoController controller, double localDx) {
    if (!_gestureEnabled(ConfigKey.ENABLE_LONG_PRESS_FAST_FORWARD)) return;
    // 没在播 / 还没就绪时按住只会空转，和主播放器一样直接不进这个态。
    if (!controller.ready || !controller.playing) return;
    VibrateUtils.vibrate();
    _boostStartX = localDx;
    _boostBaseRate = _configuredBoostRate;
    controller.beginBoost(_boostBaseRate);
    // 按住期间 chrome 让开，但计时器要停——松手那一刻不该正好赶上自动收起。
    _uiHideTimer?.cancel();
  }

  void _updateVideoBoost(GalleryVideoController controller, double localDx) {
    final startX = _boostStartX;
    if (startX == null || !controller.boosting) return;

    final double drag = localDx - startX;
    final double distance = drag.abs();
    // 拖得越远，每一档跨得越大（照抄主播放器的分段）。
    final double increment = distance < 60
        ? 0.1
        : distance < 90
        ? 0.2
        : distance < 120
        ? 0.3
        : 0.4;
    const double pixelsPerStep = 30.0;
    double delta = (distance / pixelsPerStep).floor() * increment;
    if (drag < 0) delta = -delta;

    final double next =
        ((_boostBaseRate + delta).clamp(0.1, 4.0) * 10).roundToDouble() / 10;
    // 50ms 节流：拖动每帧都算一次，真发给 mpv 会把它按在换速上。
    EasyThrottle.throttle(
      'gallery_video_boost_${identityHashCode(controller)}',
      const Duration(milliseconds: 50),
      () {
        if (mounted) controller.setRate(next);
      },
    );
  }

  void _endVideoBoost(GalleryVideoController controller) {
    _boostStartX = null;
    if (!controller.boosting) return;
    VibrateUtils.vibrate();
    controller.endBoost();
    _showUiAndAutoHide();
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
      // ⛔ `maybePop` 是**可能**被拒的：祖先挂了 `PopScope`、或本页正好是所在
      // navigator 的第一条路由时它会返回 false 而什么都不做。不理会返回值的话，
      // 这一页就永远停在拖到一半的位移 + 缩放上、chrome 还压着，用户只能再拖
      // 一次才恢复。拒了就把弹回去的那段动画照常演完。
      Navigator.of(context).maybePop().then((popped) {
        if (!popped && mounted) _animateDismissBack();
      });
      return;
    }

    _animateDismissBack();
  }

  /// 没走成的那一次下拉：把画面弹回原位。
  void _animateDismissBack() {
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

  /// 页面上的一次轻点。
  ///
  /// # ⛔ 为什么这两件事必须在同一个回调里、而且必须走 photo_view 的 `onTapUp`
  ///
  /// 改造前是分开的两条路，两条都是错的：
  ///
  ///   - **翻页**挂在裸 `Listener` 的 `onPointerDown/Up` 上。`Listener` **不参与
  ///     手势竞技场**——不管这一下最后被谁赢走，它都照样触发。于是点页内任何一个
  ///     按钮（比如图片加载失败那张卡上的「重试」）只要落在左右各 20~25% 的热区
  ///     里，按钮响应的同时还会翻一页。用户 2026-09-04 报的就是这一幕。
  ///   - **切 chrome** 挂在最外层 `GlassLongPressMenuArea.onTap` 上。它要等
  ///     photo_view 自己那只双击识别器（`photo_view_core.dart` 恒定注册
  ///     `onDoubleTap: nextScaleState`）超时释放竞技场之后才轮得到，中间还夹着
  ///     本页曾经自带的另一只双击——谁先 accept 不确定，读起来就是「点中间有时
  ///     候有反应、多数时候没有」。
  ///
  /// 现在两件事都交给 photo_view 的 `onTapUp`：那是一只正经的
  /// `TapGestureRecognizer`，与它的双击识别器同在一个 `RawGestureDetector` 里，
  /// 由包自己协调先后。更深的按钮赢了竞技场，这里就收不到——正是我们要的。
  void _handlePageTap(Offset globalPosition) {
    // ⛔ 视频页：点哪儿都只切 chrome，不翻页。播放中误翻页比翻不了页糟得多，
    // 而且视频页底下还摆着胶片条，翻页有的是别的入口。
    if (_currentVideoController == null) {
      final direction = _resolveEdgeTapDirection(globalPosition.dx);
      if (direction < 0) {
        goToPreviousPage();
        return;
      }
      if (direction > 0) {
        goToNextPage();
        return;
      }
    }
    _toggleUiVisibility();
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

  /// 这一下按在 chrome 上了吗？按在上面就不算「边缘轻点翻页」。
  bool _isPointerOnChrome(Offset globalPosition) {
    for (final key in _chromeHitKeys) {
      if (_isPointInsideWidget(key, globalPosition)) return true;
    }
    return false;
  }

  /// 滚轮。
  ///
  /// ⛔ 落在 chrome 上时必须整只让开：底下那条胶片要靠自己的 `Listener` 把竖向
  /// 滚轮折算成横向偏移（横向 `Scrollable` 只认 `scrollDelta.dx`，滚轮给的是
  /// `dy`，一格都不会动）。而 `RenderPointerListener` 是**直接**调
  /// `onPointerSignal` 的、不走 `PointerSignalResolver`——内层处理了外层照样收得
  /// 到，不让开的话滚一格会同时滚动胶片**并且**翻一页。
  void _handlePointerSignal(PointerSignalEvent event) {
    if (_isPointerOnChrome(event.position)) return;
    _galleryControls.handlePointerSignal(event);
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

  // ---- 横屏全屏 --------------------------------------------------------------

  /// 问一次这台设备是不是被锁竖屏的手机。
  ///
  /// 设备类型在启动时（`main.dart` 的 [DeviceFormFactorUtils.applyMobileOrientationPolicy]）
  /// 就已经解析并缓存，这里这次 await 只是取缓存，最多让那枚键晚一帧出现——
  /// 而它是从 [GlassGroupSlot] 里长出来的，晚的那一下正好是一次正常的出场。
  Future<void> _resolveRotationCapability() async {
    if (!DeviceFormFactorUtils.isMobilePlatform) return;
    // XR 头显在 [DeviceFormFactorUtils] 里被归成 tablet，天然不会走到这一支：
    // 那上面任何固定方向请求都会把面板宽度锁死。
    final bool canRotate = await DeviceFormFactorUtils.isPhone();
    if (!mounted || canRotate == _canRotateToLandscape) return;
    setState(() => _canRotateToLandscape = canRotate);
  }

  /// 底下那条胶片此刻该不该让位。
  ///
  /// 只有一种情形要收：**手机横过来看视频**。横屏本来就是为了把画面放大，而这
  /// 一条会从下缘吃掉六七十像素；图片页不收——那儿翻页很依赖它，而且静态图不像
  /// 视频那样被上下两条 chrome 夹成一条窄带。
  ///
  /// 判据用 [_isLandscapeFullscreen] 而不是「当前朝向是横的」：能走到这个状态的
  /// 只有手机（平板/桌面/XR 从来没被锁竖屏，也就没有那枚键），大屏横过来看时
  /// 地方够，不该跟着收。
  bool get _filmstripSuppressed =>
      _isLandscapeFullscreen && _currentVideoController != null;

  void _toggleLandscapeFullscreen() {
    if (_isLandscapeFullscreen) {
      _exitLandscapeFullscreen();
    } else {
      _enterLandscapeFullscreen();
    }
  }

  /// 把系统屏幕真的转成横屏。
  ///
  /// 走的是播放器全屏那条路（[CommonUtils.defaultEnterNativeFullscreen]），
  /// 于是「设置里选的左/右横屏」「关掉自动旋转也要转」「XR 一律不请求方向」
  /// 这几件都跟播放器保持一致，不在这儿再写一份。
  Future<void> _enterLandscapeFullscreen() async {
    if (_isLandscapeFullscreen || !_canRotateToLandscape) return;
    setState(() => _isLandscapeFullscreen = true);
    // 转屏那一下 chrome 得亮着：不然用户横过来面对的是一屏没有出口的画面。
    _showUiAndAutoHide();
    await CommonUtils.defaultEnterNativeFullscreen();
  }

  /// 转回竖屏。**幂等**：不在横屏里时什么都不做。
  ///
  /// ⛔ 这里只还方向、不碰系统 UI 模式：大图页从进来那一刻起就是沉浸的
  /// （见 [initState] 里的 `hideSystemUI`），退出横屏并不意味着要把状态栏放回来。
  /// 系统 UI 的归还仍旧由路由退场那条路负责。
  Future<void> _exitLandscapeFullscreen() async {
    if (!_isLandscapeFullscreen) return;
    _isLandscapeFullscreen = false;
    // dispose 也会走到这儿，那时不能再 setState（见 [_disposed]）。
    if (mounted && !_disposed) setState(() {});
    await DeviceFormFactorUtils.applyMobileOrientationPolicy();
  }

  // ---- PageDepartureAware ---------------------------------------------------

  /// 大图页的「全屏」就是上面那一份横屏：跳去别的页面时要把方向交还，
  /// 否则新页面会顶着一块横屏出现。
  @override
  bool get isPresentingFullscreen => _isLandscapeFullscreen;

  @override
  Future<void> releaseFullscreen() => _exitLandscapeFullscreen();

  @override
  void onCoveredByAnotherPage() {
    if (!mounted) return;
    _pauseAllVideos();
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

  /// 图片页右下角那一撮小胶囊：缩放倍数 · 横竖屏。
  ///
  /// 视频页的这两件分别长在控件条上方与条里（那条本来就在，不必再多一撮）；
  /// 图片页没有控件条，所以单独摆一撮，位置与视频页的缩放牌对齐——翻页在两种
  /// 页面之间来回时，缩放牌是**同一个东西挪了挪**，不是一会儿有一会儿没有。
  Widget _buildImageCornerChips({required bool visible}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GalleryScaleChip(
              scale: _pageScale,
              visible: visible,
              onReset: _resetPageScale,
            ),
            // 8 是 chrome 之间的标定间距（[GlassTokens.chromeBlend]）：
            // 静止时刚好不粘连，拖近了才融合。
            if (_canRotateToLandscape) ...[
              const SizedBox(width: 8),
              GalleryRotateChip(
                visible: visible,
                landscape: _isLandscapeFullscreen,
                onToggle: () {
                  _showUiAndAutoHide();
                  _toggleLandscapeFullscreen();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 胶片条把用户拖到的那一张报上来。
  void _jumpToIndexFromFilmstrip(int index) {
    if (index == currentIndex) return;
    if (index < 0 || index >= _activeGalleryItems.length) return;
    if (!pageController.hasClients) return;
    // 拖胶片是**连续**的：每跨过一张就跳一次，用 jumpToPage 而不是 animateToPage
    // ——后者的 300ms 会和下一次跳打架，读起来是大图追不上手指。
    pageController.jumpToPage(index);
    _showUiAndAutoHide();
  }

  /// 顶栏。
  ///
  /// 改造前这里是「白图标直接浮在黑底上」的老写法（裸 `IconButton` + 一枚手搓
  /// 的画质胶囊），而页面底下现在摆着玻璃控件条与胶片条——同一屏两种语言。
  /// 现在收成两块玻璃：左边一枚关闭圆钮，右边一条装着画质 / 快捷键 / ⋮ / 页码
  /// 的胶囊。
  ///
  /// **两块各自 `group: false`**：它们要跟着 chrome 一起做材质淡入，而融合组里
  /// 同一层只有一份材质、`materialize` 会被静默吃掉（debug 下有 assert）。
  /// 左右分居两端本来也不成簇。
  Widget _buildTopChrome(
    BuildContext context,
    slang.Translations t,
    List<ImageItem> activeGalleryItems, {
    required bool visible,
    required bool isVideoPage,
  }) {
    // 深色底由 [GalleryDarkChrome] 统一供给（理由见那只类）。
    return GalleryDarkChrome(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassReveal(
              visible: visible,
              slideFrom: const Offset(0, -0.6),
              builder: (context, materialize) => GlassChromeLayer(
                group: false,
                child: GlassIconButton(
                  standalone: true,
                  materialize: materialize,
                  icon: const Icon(Icons.close),
                  tooltip: t.common.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            // 右侧这条会随画质钮的文案变宽（日语最长），Flexible 让它在窄屏上
            // 有处可让，而不是把整行顶出 OVERFLOWED 条。
            Flexible(
              child: GlassReveal(
                visible: visible,
                slideFrom: const Offset(0, -0.6),
                builder: (context, materialize) => GlassChromeLayer(
                  group: false,
                  child: GlassSurface(
                    height: GlassTokens.pillHeight,
                    borderRadius: BorderRadius.circular(
                      GlassTokens.pillHeight / 2,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    materialize: materialize,
                    // 条内有可拖/可点的子件，整只跟手形变会跟它们抢手指。
                    liquidTouch: false,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ⛔ 视频页不摆画质钮：视频没有"标清 / 原画"之分
                        // （[MediaFile.getLargeImageUrl] 对没有缩放版的文件本来
                        // 就回落到 original），摆在那儿是一枚点了什么也不会变的
                        // 钮。走 [GlassGroupSlot] 让它**宽度渐变**地进退，而不是
                        // 翻到视频那一下整行东西横着跳一格。
                        GlassGroupSlot(
                          visible: _canSwitchQuality && !isVideoPage,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 画质面板走全站统一的玻璃菜单。
                              Builder(
                                key: _qualityButtonKey,
                                builder: (anchorContext) => GlassPressable(
                                  // 长按也能打开，且长按不抬手可以直接划到某一条
                                  // 上松手选中（见 GlassTapArea.opensOverlay）。
                                  opensOverlay: true,
                                  onTap: () {
                                    _showUiAndAutoHide();
                                    _openQualityMenu(anchorContext);
                                  },
                                  builder: (context, pressed) =>
                                      _buildQualityIndicator(context, t),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                        _TopBarIconButton(
                          icon: Icons.keyboard,
                          tooltip: t.settings.keybinding.title,
                          materialize: materialize,
                          onPressed: () {
                            _showUiAndAutoHide();
                            KeybindingSettingsPage.openSheet(
                              context,
                              scopeFilter: ShortcutScope.gallery,
                            );
                          },
                        ),
                        if (widget.enableMenu)
                          Builder(
                            key: _menuButtonKey,
                            builder: (anchorContext) => GlassPressable(
                              opensOverlay: true,
                              onTap: () {
                                _showImageMenu(
                                  anchorContext,
                                  activeGalleryItems[currentIndex],
                                );
                                _showUiAndAutoHide();
                              },
                              builder: (context, pressed) => SizedBox.square(
                                dimension: 40,
                                child: Icon(
                                  Icons.more_vert,
                                  size: 22,
                                  color: Colors.white.withValues(
                                    alpha: materialize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          '${currentIndex + 1}/${activeGalleryItems.length}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: materialize),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
    // 整套 chrome（顶栏 / 正中控件 / 底部控件条 / 胶片条）共用同一个开关，
    // 单击一下全体进退，各自的位移方向不同但时值曲线一致（[GlassTokens]）。
    final bool chromeVisible = _isUiVisible && !_isDraggingToDismiss;
    // 这一页是视频吗——顶栏之外还要决定底部控件条在不在场、边缘轻点要不要
    // 让开它（见 [_chromeHitKeys]）。
    final currentVideoController = _currentVideoController;
    // 挂在树上的那一只**可能是正在退场的上一条**：视频翻到图片时控件要演完
    // 退场再摘（见 [_syncChromeVideo]）。谁在场由 `present` 说了算。
    final chromeVideoController = _chromeVideo;
    final bool videoChromePresent = currentVideoController != null;

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
          child: _ExitFadeBackdrop(
            alpha: backgroundAlpha,
            exitFade: _isExiting ? _routeAnimation : null,
            // ⛔ 下拉关闭的位移与缩放**只作用在画面上，不带 chrome**。
            //
            // 原先这两只 Transform 裹着整个 Stack，于是收起来的 chrome（它是
            // 靠"滑出屏幕外"藏的）会跟着手指一起被拖回屏幕里——用户上滑退出
            // 时，本该看不见的控件条与胶片条从下缘冒出来（2026-09-05 报的）。
            // 根因有两条，这是其中一条；另一条是 chrome 藏得不彻底，见
            // [_ChromeSlot]。两条都得堵，因为退场动画那 300ms 里 chrome 还在
            // 往外滑，光靠"演完就摘"仍会被拖进视野。
            child: Focus(
              focusNode: _keyboardFocusNode,
              autofocus: true,
              // 不再在这里 onKeyEvent：按键统一由应用根部经
              // ShortcutTargetRegistry 派发进来，两处都收会双触发。
              // 只剩滚轮：轻点与翻页都收进 photo_view 的 onTapUp 了
              // （见 [_handlePageTap]），`Listener` 不参与竞技场，拿它做
              // 点击判定必然会和更深的按钮双触发。
              child: Listener(
                onPointerSignal: _handlePointerSignal,
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
                    // ⛔ 这里不再收点击：它在竞技场里排得太靠外，见
                    // [_handlePageTap]。只留长按开菜单。
                    onTap: null,
                    // 关掉菜单时连长按都不注册：onMenu 一旦挂上，长按到点就
                    // 会先震一下、再去发现「没有菜单可开」。
                    // ⛔ 视频页不注册长按菜单：那一页的长按归**按住加速**
                    // （见 [_beginVideoBoost]）。两只长按识别器同时在场时
                    // 谁先 accept 是不确定的——不能靠运气，只能让其中一只
                    // 压根不上场。视频页要开菜单还有右键与右上角 ⋮ 两条路。
                    onMenu:
                        (!widget.enableMenu || currentVideoController != null)
                        ? null
                        : (globalPosition) => _showImageMenu(
                            context,
                            activeGalleryItems[currentIndex],
                            globalPosition: globalPosition,
                          ),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // 下拉关闭的位移与缩放挂在**这里**（画面这一层），
                        // 不在整只 Stack 外面：理由见上面 _ExitFadeBackdrop
                        // 那段注释。
                        Transform.translate(
                          offset: Offset(0, _dismissOffset.dy),
                          child: Transform.scale(
                            scale: contentScale,
                            alignment: Alignment.center,
                            child: KeyedSubtree(
                              key: ValueKey(_activeQuality),
                              child: PhotoViewGallery.builder(
                                // PhotoView 默认会给每页铺一层不透明黑底，压在外层那层
                                // 会随拖拽淡出的黑背景之上 —— 不置空的话拖拽消隐完全看不见。
                                // 黑底统一由外层 [_ExitFadeBackdrop] 提供。
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

                                  // 媒体类型由服务端的 type/mime 决定，不再
                                  // 按 URL 后缀猜（见 [MediaFile.isVideo]）。
                                  // 顺带治好了一个隐患：重试时 URL 会被拼上
                                  // `?reload=…`，按后缀判就得看运气。
                                  final bool isVideo = activeItem.isVideo;

                                  final pageVideoController = isVideo
                                      ? _videoControllers[activeItem.data.id]
                                      : null;

                                  Widget mediaChild = KeyedSubtree(
                                    key: ValueKey(
                                      '${activeItem.data.id}_${_activeQuality}_${_reloadTimestamps[index] ?? 0}',
                                    ),
                                    child: isVideo
                                        // ⛔ 只画**已经有播放器**的那一页。
                                        // `PageView` 会把前后各一页也建出来，
                                        // 在这儿 putIfAbsent 就等于替邻居把
                                        // 网络流也开了——视频挨着视频时几条流
                                        // 一起抢带宽，中间那条会一直停在黑屏
                                        // 转圈。邻居先摆一块黑，翻到它时
                                        // [_ensureVideoControllers] 再开。
                                        ? (pageVideoController != null
                                              ? GalleryVideoPlayer(
                                                  controller:
                                                      pageVideoController,
                                                )
                                              : const SizedBox.expand())
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

                                  return PhotoViewGalleryPageOptions.customChild(
                                    child: GestureDetector(
                                      // ⛔ 这里**一只双击都不挂**。photo_view
                                      // 自己恒定注册着 `onDoubleTap:
                                      // nextScaleState`（双击缩放），再挂一只
                                      // 就是两只同类识别器抢同一次手势——谁先
                                      // accept 不确定，顺带把单击也拖下水。
                                      // 双击缩放交给包自己那只。
                                      // 按住加速。挂在这一层（比外层那只长按
                                      // 更深）是为了拿到页内局部坐标，横向拖动
                                      // 调档就按它算。
                                      onLongPressStart:
                                          pageVideoController == null
                                          ? null
                                          : (details) => _beginVideoBoost(
                                              pageVideoController,
                                              details.localPosition.dx,
                                            ),
                                      onLongPressMoveUpdate:
                                          pageVideoController == null
                                          ? null
                                          : (details) => _updateVideoBoost(
                                              pageVideoController,
                                              details.localPosition.dx,
                                            ),
                                      onLongPressEnd:
                                          pageVideoController == null
                                          ? null
                                          : (_) => _endVideoBoost(
                                              pageVideoController,
                                            ),
                                      onLongPressCancel:
                                          pageVideoController == null
                                          ? null
                                          : () => _endVideoBoost(
                                              pageVideoController,
                                            ),
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Center(child: mediaChild),
                                      ),
                                    ),
                                    // 轻点：翻页与切 chrome 都在这里，理由见
                                    // [_handlePageTap]。
                                    onTapUp: (context, details, value) =>
                                        _handlePageTap(details.globalPosition),
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
                          ),
                        ),
                        // 顶栏
                        SafeArea(
                          child: KeyedSubtree(
                            key: _topChromeKey,
                            child: _buildTopChrome(
                              context,
                              t,
                              activeGalleryItems,
                              visible: chromeVisible,
                              isVideoPage: currentVideoController != null,
                            ),
                          ),
                        ),
                        // 正中那一组：倒退 N 秒 · 播放/暂停 · 快进 N 秒。
                        //
                        // ⛔ 它**不能**待在页内——那儿是 PhotoViewGallery 的
                        // 缩放变换里头，双指一放大控件会跟着一起变大。
                        if (chromeVideoController != null)
                          Positioned.fill(
                            // 这一片只有那一组钮自己吃得到点击：`Center` 的
                            // 命中测试只认子件那块矩形，其余整片照样落到底下
                            // 的画面上（单击切显隐、长按加速都在那一层）。
                            child: Stack(
                              children: [
                                // 倍速牌**不进那一列**：跟着排在钮上方的话，
                                // 它收起来之后留下的那段间距会把整组钮从正中
                                // 顶下去一截。它自己浮在偏上一点的位置。
                                Align(
                                  alignment: const Alignment(0, -0.26),
                                  child: GalleryVideoBoostBadge(
                                    controller: chromeVideoController,
                                  ),
                                ),
                                Center(
                                  child: KeyedSubtree(
                                    key: _centerControlsKey,
                                    child: GalleryVideoCenterControls(
                                      controller: chromeVideoController,
                                      present: videoChromePresent,
                                      chromeVisible: chromeVisible,
                                      seekSeconds: (
                                        rewind: _seekSeconds(false),
                                        forward: _seekSeconds(true),
                                      ),
                                      onInteraction: _showUiAndAutoHide,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // 底部：视频控件条 + 胶片条。整片挂一个 key，边缘
                        // 轻点翻页与滚轮都靠它让开（见 [_chromeHitKeys]）。
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          // ⛔ 整块一起滑，位移按**含安全区的整块高度**算。
                          // 此前是让胶片条自己滑 1.4 个身位（≈104px），而它
                          // 到屏幕下缘的距离是「自身高 + 间距 + 安全区」
                          // （≈118px）——差那一截，收起来还露着半条，正是
                          // 用户报的「只是向下移动且不彻底」。
                          child: _ChromeSlot(
                            visible: chromeVisible,
                            // 1.02 而不是 1.0：留一丝余量，别在某些机型的
                            // 亚像素取整上露出一条发丝。
                            slideFrom: const Offset(0, 1.02),
                            child: KeyedSubtree(
                              key: _bottomChromeKey,
                              child: SafeArea(
                                top: false,
                                // Seek Preview 要按「播放器有多大」摆窗口，
                                // 这一页铺满屏幕，供的就是屏幕尺寸。
                                child: PlayerBoxScope(
                                  size: MediaQuery.sizeOf(context),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 视频控件条按**高度**渐变地进退，
                                      // 图片页翻到视频页时不再是整条凭空
                                      // 蹦出来（[GlassGroupSlot] 自己缓存
                                      // child 演完退场）。
                                      GlassGroupSlot(
                                        axis: Axis.vertical,
                                        visible:
                                            videoChromePresent &&
                                            chromeVideoController != null,
                                        child: chromeVideoController == null
                                            ? const SizedBox.shrink()
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                      16,
                                                      0,
                                                      16,
                                                      12,
                                                    ),
                                                child: GalleryVideoControlBar(
                                                  controller:
                                                      chromeVideoController,
                                                  scale: _pageScale,
                                                  onResetScale: _resetPageScale,
                                                  chromeVisible:
                                                      chromeVisible &&
                                                      videoChromePresent,
                                                  onInteraction:
                                                      _showUiAndAutoHide,
                                                  canRotate:
                                                      _canRotateToLandscape,
                                                  landscape:
                                                      _isLandscapeFullscreen,
                                                  onToggleRotation:
                                                      _toggleLandscapeFullscreen,
                                                ),
                                              ),
                                      ),
                                      // 图片页的右下角那一撮（缩放 · 横竖屏）。
                                      // 视频页不建：那两件在控件条上/条里。
                                      GlassGroupSlot(
                                        axis: Axis.vertical,
                                        visible: !videoChromePresent,
                                        child: _buildImageCornerChips(
                                          visible:
                                              chromeVisible &&
                                              !videoChromePresent,
                                        ),
                                      ),
                                      if (activeGalleryItems.length > 1)
                                        // ⛔ 手机横过来看视频时整条收起来。
                                        // 横屏下这一条要吃掉画面下缘一大截，
                                        // 而横屏正是为了把画面放大——图片页
                                        // 不受影响（那儿翻页靠它，画面也没被
                                        // 挤到）。按高度渐变地收，不是硬切。
                                        GlassGroupSlot(
                                          axis: Axis.vertical,
                                          visible: !_filmstripSuppressed,
                                          child: GalleryFilmstrip(
                                            items: activeGalleryItems,
                                            currentIndex: currentIndex,
                                            onIndexSelected:
                                                _jumpToIndexFromFilmstrip,
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
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
    );
  }
}

/// 顶栏那条胶囊里的一枚键。
///
/// 与控件条里的同族：整条已经是一块玻璃了，条里每枚键再各自长一层玻璃就是
/// 「玻璃套玻璃」——多几次背景采样，视觉上还变成一排小胶囊挤在大胶囊里。
class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.materialize,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final double materialize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 22,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      padding: EdgeInsets.zero,
      // 走颜色通道跟着材质一起淡入，不套 Opacity。
      color: Colors.white.withValues(alpha: materialize),
      onPressed: onPressed,
    );
  }
}

/// 非玻璃 chrome 的出入场（胶片条 + 视频控件条那一整块）。
///
/// 玻璃件走 [GlassReveal]（材质淡入）；胶片条整只是缩略图 + 滚动容器，本来就
/// 不是玻璃——玻璃装不下滚动容器，见 `horizontial_image_list.dart` 里那段说明。
///
/// ⛔ **不用 `Opacity` 淡出，整条滑出屏幕下缘**。理由不是那条"玻璃外面不许包
/// Opacity"的规矩（这里确实没有玻璃），而是它在这儿本来也不划算：α∈(0,1) 的
/// 那几帧要给一整排缩略图开一次 `saveLayer`，而位移一分钱不花。时值曲线取
/// [GlassTokens] 同一档，整套 chrome 才像是一起进退的。
///
/// # ⛔ 但「滑出屏幕」不等于「不在了」
///
/// 只滑不摘的话，这一整块只是**停在屏幕外面**——而大图页有下拉/上滑关闭：
/// 用户把画面往上一推，屏幕下缘外面那块就跟着被推进视野，读起来是"收起来的
/// 控件条自己冒出来了"（用户 2026-09-05 报的）。位移这条路上还有一条同源的
/// 账：那一排缩略图、那条进度条即使看不见也照样在建、在动画、在解码。
///
/// 所以退场动画**跑完就把 child 整只不建**——与 [GlassReveal] 同一套语义，
/// 也是本项目对显隐的统一要求。外层的 [AnimatedSlide] 留在树上不动，它自己
/// 记着当前偏移，下次亮出来才是从屏幕外滑回来而不是凭空出现。
class _ChromeSlot extends StatefulWidget {
  const _ChromeSlot({
    required this.visible,
    required this.child,
    this.slideFrom = const Offset(0, 1.4),
  });

  final bool visible;
  final Widget child;

  /// 退场落点，按自身尺寸的倍数算。默认 1.4 个身位——比 1 多一截，
  /// 把安全区那段也让出去，否则收起来还会露出一条边。
  final Offset slideFrom;

  @override
  State<_ChromeSlot> createState() => _ChromeSlotState();
}

class _ChromeSlotState extends State<_ChromeSlot> {
  /// 退场留够的余量：位移本身走 [GlassTokens.motionDuration]，多给一点，
  /// 免得在最后一两帧上把还没滑完的东西当场摘掉（那就成硬切了）。
  static const Duration _grace = Duration(milliseconds: 60);

  late bool _present = widget.visible;
  Timer? _dropTimer;

  @override
  void didUpdateWidget(covariant _ChromeSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;
    _dropTimer?.cancel();
    _dropTimer = null;
    if (widget.visible) {
      // 亮出来是当场建：这一帧 AnimatedSlide 还停在屏幕外的偏移上，
      // 建好正好从那儿滑回来。
      setState(() => _present = true);
      return;
    }
    _dropTimer = Timer(GlassTokens.motionDuration + _grace, () {
      _dropTimer = null;
      if (mounted) setState(() => _present = false);
    });
  }

  @override
  void dispose() {
    _dropTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.visible,
      child: AnimatedSlide(
        duration: GlassTokens.motionDuration,
        curve: GlassTokens.motionCurve,
        offset: widget.visible ? Offset.zero : widget.slideFrom,
        child: _present ? widget.child : const SizedBox.shrink(),
      ),
    );
  }
}

/// 这一页的黑底。
///
/// 退场时黑底跟着路由动画一起收（[exitFade] 非空即为退场中），而不是整屏黑着
/// 让外层慢慢淡——后者看上去就是「先黑屏一下再露出下面那页」。只重画这一层，
/// 不惊动上面那整只 [PhotoViewGallery]。
class _ExitFadeBackdrop extends StatelessWidget {
  const _ExitFadeBackdrop({
    required this.alpha,
    required this.exitFade,
    required this.child,
  });

  final double alpha;
  final Animation<double>? exitFade;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fade = exitFade;
    if (fade == null) {
      return ColoredBox(
        color: Colors.black.withValues(alpha: alpha),
        child: child,
      );
    }
    return AnimatedBuilder(
      animation: fade,
      child: child,
      builder: (context, child) => ColoredBox(
        color: Colors.black.withValues(alpha: alpha * fade.value),
        child: child,
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
