import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'video_player_widget.dart';
import 'image_widget.dart';
import 'navigation_controls.dart';
import 'gallery_controls.dart';
import 'gallery_info_dialog.dart';

class MyGalleryPhotoViewWrapper extends StatefulWidget {
  const MyGalleryPhotoViewWrapper({
    super.key,
    required this.galleryItems,
    this.initialIndex = 0,
    this.menuBuilder,
    this.menuItemsBuilder,
    this.enableMenu = true,
  });

  final List<ImageItem> galleryItems;
  final int initialIndex;
  final Widget Function(BuildContext, ImageItem, Offset)?
  menuBuilder; // 自定义菜单构建器
  final List<MenuItem> Function(BuildContext, ImageItem)?
  menuItemsBuilder; // 动态菜单项生成器
  final bool enableMenu; // 是否启用菜单和相关触发

  @override
  State<MyGalleryPhotoViewWrapper> createState() =>
      _MyGalleryPhotoViewWrapperState();
}

class _MyGalleryPhotoViewWrapperState extends State<MyGalleryPhotoViewWrapper>
    with TickerProviderStateMixin {
  late int currentIndex = widget.initialIndex;
  late PageController pageController;
  late List<PhotoViewController> controllers;

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

    // 初始化音量键监听
    _galleryControls.initVolumeKeyListener();

    // 延迟执行，确保所有视频组件都已创建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pauseAllVideosExcept(currentIndex);
    });
  }

  @override
  void dispose() {
    // 释放所有视频播放器资源
    _releaseAllVideoPlayers();

    // 移除音量键监听
    _galleryControls.disableVolumeKeyListener();
    appService.showSystemUI();
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

  void _handleKeyPress(KeyEvent event) {
    _galleryControls.handleKeyPress(event);
    setState(() {}); // 更新UI状态
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

  void _showInfoModal(BuildContext context) {
    GalleryInfoDialog.show(context);
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
      goToPreviousPage();
      return;
    }

    // 右侧点击区域：下一张
    if (dx >= _screenWidth - _tapAreaWidth &&
        currentIndex < widget.galleryItems.length - 1) {
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

    // 使用 Get.dialog 显示菜单
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                    if (index < menuItems.length - 1)
                      const Divider(height: 1),
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: _handleKeyPress,
        child: Listener(
          onPointerSignal: _galleryControls.handlePointerSignal,
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          child: GestureDetector(
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
                    String imageUrl = _reloadTimestamps.containsKey(index)
                        ? '${widget.galleryItems[index].data.originalUrl}?reload=${_reloadTimestamps[index]}'
                        : widget.galleryItems[index].data.originalUrl;

                    // 检查是否为视频文件
                    bool isVideo = _isVideo(imageUrl);

                    return PhotoViewGalleryPageOptions.customChild(
                      child: GestureDetector(
                        onDoubleTap: () =>
                            _galleryControls.handleDoubleTap(index),
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: KeyedSubtree(
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
                            ),
                          ),
                        ),
                      ),
                      minScale: PhotoViewComputedScale.contained * 0.5,
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
                NavigationControls(
                  tapAreaWidth: _tapAreaWidth,
                  showOverlay: _showNavigationOverlay,
                  // 这里只负责「显示」左右渐变与箭头，真正的点击逻辑在 _onPointerDown/_onPointerUp 中处理
                  canGoPrevious: currentIndex > 0,
                  canGoNext: currentIndex < widget.galleryItems.length - 1,
                ),
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Row(
                          children: [
                            // 问号信息按钮
                            IconButton(
                              tooltip: slang
                                  .t
                                  .common
                                  .tips, // Assuming slang is available
                              icon: const Icon(
                                Icons.help_outline,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _showInfoModal(context);
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
                                widget.galleryItems[currentIndex],
                              );
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
