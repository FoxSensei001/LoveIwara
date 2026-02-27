import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'video_player_widget.dart';
import 'image_widget.dart';
import 'navigation_controls.dart';
import 'gallery_controls.dart';
import 'gallery_info_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

class MyGalleryPhotoViewWrapper extends StatefulWidget {
  const MyGalleryPhotoViewWrapper({
    super.key,
    required this.galleryItems,
    this.initialIndex = 0,
    this.menuBuilder,
    this.menuItemsBuilder,
    this.enableMenu = true,
    this.heroTagBuilder,
  });

  final List<ImageItem> galleryItems;
  final int initialIndex;
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
  late int currentIndex = widget.initialIndex;
  late PageController pageController;
  late List<PhotoViewController> controllers;

  bool _isUiVisible = true;
  Timer? _uiHideTimer;
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

  // 是否显示左右导航 UI，仅在长按时显示
  bool _showNavigationOverlay = false;

  final AppService appService = Get.find();
  late GalleryControls _galleryControls;
  final GlobalKey _menuButtonKey = GlobalKey();

  // 使用Map存储每个图片的重新加载时间戳
  final Map<int, int> _reloadTimestamps = {};

  // 存储视频播放器的GlobalKey，用于控制播放状态
  final Map<int, GlobalKey<VideoPlayerWidgetState>> _videoPlayerKeys = {};

  // 预加载范围：当前图片前后各预加载多少张
  static const int _preloadRange = 3;

  // 记录已预加载的图片索引，避免重复预加载
  final Set<int> _preloadedImages = {};

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
    appService.hideSystemUI(hideTitleBar: false);
    pageController = PageController(initialPage: widget.initialIndex);
    controllers = List.generate(
      widget.galleryItems.length,
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
  void dispose() {
    // 释放所有视频播放器资源
    _releaseAllVideoPlayers();

    // 移除音量键监听
    _galleryControls.disableVolumeKeyListener();
    appService.showSystemUI();
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
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return true;
    }
    final didAct = _galleryControls.handleKeyPress(event);
    if (didAct) {
      _showUiAndAutoHide();
      setState(() {});
      return true;
    }
    return false;
  }

  void goToNextPage() {
    if (currentIndex < widget.galleryItems.length - 1) {
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
    for (int i = 0; i < widget.galleryItems.length; i++) {
      if (i != currentIndex &&
          _isVideo(widget.galleryItems[i].data.originalUrl)) {
        final key = _videoPlayerKeys[i];
        if (key?.currentState != null) {
          key!.currentState!.pauseVideo();
        }
      }
    }
  }

  /// 根据当前是否是视频来更新音量键监听状态
  void _updateVolumeKeyListener() {
    final isCurrentVideo = _isVideo(
      widget.galleryItems[currentIndex].data.originalUrl,
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

    // 计算预加载范围
    final startIndex = (centerIndex - _preloadRange).clamp(
      0,
      widget.galleryItems.length - 1,
    );
    final endIndex = (centerIndex + _preloadRange).clamp(
      0,
      widget.galleryItems.length - 1,
    );

    for (int i = startIndex; i <= endIndex; i++) {
      // 跳过已经预加载的
      if (_preloadedImages.contains(i)) continue;

      final item = widget.galleryItems[i];
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

  void _showInfoModal(BuildContext context) {
    GalleryInfoDialog.show(context);
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
    final shouldDismiss = dy.abs() > 160 || vy.abs() > 900;

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
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_pointerDownPosition == null || _pointerDownTime == null) return;

    final duration = DateTime.now().difference(_pointerDownTime!);
    final delta = event.position - _pointerDownPosition!;

    // 判定为「轻点」：时间短、移动距离小，避免与滑动/缩放手势冲突
    if (duration.inMilliseconds > 250) return;
    if (delta.distance > 20) return;

    final dx = event.position.dx;

    // 左侧点击区域：上一张
    if (dx <= _tapAreaWidth && currentIndex > 0) {
      _suppressNextTapToggle = true;
      goToPreviousPage();
      return;
    }

    // 右侧点击区域：下一张
    if (dx >= _screenWidth - _tapAreaWidth &&
        currentIndex < widget.galleryItems.length - 1) {
      _suppressNextTapToggle = true;
      goToNextPage();
    }
  }

  void _showImageMenu(BuildContext context, ImageItem item) {
    // 如果禁用了菜单，直接返回
    if (!widget.enableMenu) return;

    // 动态生成菜单项
    final menuItems = widget.menuItemsBuilder != null
        ? widget.menuItemsBuilder!(context, item)
        : <MenuItem>[];

    // 如果没有菜单项，不显示对话框
    if (menuItems.isEmpty) return;

    // 使用 showAppDialog 显示菜单
    showAppDialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 菜单项列表
              ...menuItems.asMap().entries.map((entry) {
                final index = entry.key;
                final menuItem = entry.value;
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
                    // 添加分隔线，最后一项不添加
                    if (index < menuItems.length - 1) const Divider(height: 1),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      barrierDismissible: true, // 点击外部关闭
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度
    _screenWidth = MediaQuery.of(context).size.width;
    // 计算点击区域宽度，宽屏和窄屏使用不同的比例
    _tapAreaWidth = _screenWidth > 600
        ? _screenWidth * 0.2
        : _screenWidth * 0.25;

    final dismissProgress = (_dismissOffset.dy.abs() / 320).clamp(0.0, 1.0);
    final backgroundAlpha = (1.0 - dismissProgress).clamp(0.0, 1.0);
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
                    child: GestureDetector(
                      onTap: _toggleUiVisibility,
                      onLongPressStart: (details) {
                        if (!widget.enableMenu) return;
                        setState(() {
                          _showNavigationOverlay = true;
                        });
                        _showImageMenu(
                          context,
                          widget.galleryItems[currentIndex],
                        );
                      },
                      onLongPressEnd: (details) {
                        if (!widget.enableMenu) return;
                        setState(() {
                          _showNavigationOverlay = false;
                        });
                      },
                      onSecondaryTapDown: (details) {
                        if (!widget.enableMenu) return;
                        _showImageMenu(
                          context,
                          widget.galleryItems[currentIndex],
                        );
                      },
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          PhotoViewGallery.builder(
                            scrollPhysics: const BouncingScrollPhysics(),
                            allowImplicitScrolling: true,
                            wantKeepAlive: true,
                            builder: (BuildContext context, int index) {
                              String imageUrl =
                                  _reloadTimestamps.containsKey(index)
                                  ? '${widget.galleryItems[index].data.originalUrl}?reload=${_reloadTimestamps[index]}'
                                  : widget.galleryItems[index].data.originalUrl;

                              // 检查是否为视频文件
                              bool isVideo = _isVideo(imageUrl);

                              final heroTag = widget.heroTagBuilder?.call(
                                widget.galleryItems[index],
                              );

                              Widget mediaChild = KeyedSubtree(
                                key: ValueKey(
                                  '${widget.galleryItems[index]}_${_reloadTimestamps[index] ?? 0}',
                                ),
                                child: isVideo
                                    ? VideoPlayerWidget(
                                        key: _getVideoPlayerKey(index),
                                        videoUrl: imageUrl,
                                        headers:
                                            widget.galleryItems[index].headers,
                                      )
                                    : imageUrl.startsWith('file://')
                                    ? Image.file(
                                        File(
                                          imageUrl.replaceFirst('file://', ''),
                                        ),
                                        fit: BoxFit.contain,
                                      )
                                    : ImageWidget(
                                        imageUrl: imageUrl,
                                        headers:
                                            widget.galleryItems[index].headers,
                                      ),
                              );

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
                                initialScale: PhotoViewComputedScale.contained,
                                controller: controllers[index],
                              );
                            },
                            itemCount: widget.galleryItems.length,
                            pageController: pageController,
                            onPageChanged: _onPageChanged,
                          ),
                          // 导航控制组件
                          AnimatedOpacity(
                            opacity: chromeOpacity,
                            duration: const Duration(milliseconds: 180),
                            child: NavigationControls(
                              tapAreaWidth: _tapAreaWidth,
                              showOverlay: _showNavigationOverlay,
                              // 这里只负责「显示」左右渐变与箭头，真正的点击逻辑在 _onPointerDown/_onPointerUp 中处理
                              canGoPrevious: currentIndex > 0,
                              canGoNext:
                                  currentIndex < widget.galleryItems.length - 1,
                            ),
                          ),
                          SafeArea(
                            child: AnimatedOpacity(
                              opacity: chromeOpacity,
                              duration: const Duration(milliseconds: 180),
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    Row(
                                      children: [
                                        // 问号信息按钮
                                        IconButton(
                                          tooltip: slang.t.common.tips,
                                          icon: const Icon(
                                            Icons.help_outline,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            _showInfoModal(context);
                                            _showUiAndAutoHide();
                                          },
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
                                                widget
                                                    .galleryItems[currentIndex],
                                              );
                                              _showUiAndAutoHide();
                                            },
                                          ),
                                        // 页码显示
                                        const SizedBox(width: 8),
                                        Text(
                                          '${currentIndex + 1}/${widget.galleryItems.length}',
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
