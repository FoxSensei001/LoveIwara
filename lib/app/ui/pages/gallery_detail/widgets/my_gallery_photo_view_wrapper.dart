import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'menu_item_widget.dart';
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
  });

  final List<ImageItem> galleryItems;
  final int initialIndex;
  final Widget Function(BuildContext, ImageItem, Offset)?
  menuBuilder; // 自定义菜单构建器
  final List<MenuItem> Function(BuildContext, ImageItem)?
  menuItemsBuilder; // 动态菜单项生成器

  @override
  State<MyGalleryPhotoViewWrapper> createState() =>
      _MyGalleryPhotoViewWrapperState();
}

class _MyGalleryPhotoViewWrapperState extends State<MyGalleryPhotoViewWrapper>
    with TickerProviderStateMixin {
  late int currentIndex = widget.initialIndex;
  late PageController pageController;
  late List<PhotoViewController> controllers;
  final AppService appService = Get.find();
  OverlayEntry? _overlayEntry;
  late GalleryControls _galleryControls;

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
      if (i != currentIndex && _isVideo(widget.galleryItems[i].data.originalUrl)) {
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

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showImageMenu(BuildContext context, ImageItem item, Offset position) {
    _hideMenu();
    // 计算菜单显示位置
    final dx = position.dx;
    final dy = position.dy;

    // 动态生成菜单项
    final menuItems = widget.menuItemsBuilder != null
        ? widget.menuItemsBuilder!(context, item)
        : widget.menuItemsBuilder!(context, item);

    // 创建菜单
    final menuWidget = DefaultImageMenu(
      item: item,
      onDismiss: _hideMenu,
      customBuilder: widget.menuBuilder,
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
      position: Offset(dx, dy),
      // 使用计算后的相对位置
      menuItems: menuItems, // 传递菜单项列表
    );

    // 插入菜单到Overlay
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 添加透明层，点击时关闭菜单
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideMenu,
              onSecondaryTap: _hideMenu,
              child: Container(color: Colors.transparent),
            ),
          ),
          // 显示菜单
          Positioned(
            left: dx,
            top: dy,
            child: Material(color: Colors.transparent, child: menuWidget),
          ),
        ],
      ),
    );
    BuildContext? overlay = Get.overlayContext;
    if (overlay != null) {
      Overlay.of(overlay).insert(_overlayEntry!);
    } else {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    // 计算点击区域宽度，宽屏和窄屏使用不同的比例
    final tapAreaWidth = screenWidth > 600
        ? screenWidth * 0.2
        : screenWidth * 0.25;

    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: _handleKeyPress,
        child: Listener(
          onPointerSignal: _galleryControls.handlePointerSignal,
          child: GestureDetector(
            onLongPressStart: (details) {
              _showImageMenu(
                context,
                widget.galleryItems[currentIndex],
                details.globalPosition,
              );
            },
            onSecondaryTapDown: (details) {
              _showImageMenu(
                context,
                widget.galleryItems[currentIndex],
                details.globalPosition,
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
                        onDoubleTap: () => _galleryControls.handleDoubleTap(index),
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
                                      headers: widget.galleryItems[index].headers,
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
                                      headers: widget.galleryItems[index].headers,
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
                  tapAreaWidth: tapAreaWidth,
                  onPrevious: goToPreviousPage,
                  onNext: goToNextPage,
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
                            // 更多设置按钮
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


