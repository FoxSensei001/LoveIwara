import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../widgets/loading_button_widget.dart';
import 'menu_item_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

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

class _MyGalleryPhotoViewWrapperState extends State<MyGalleryPhotoViewWrapper> {
  static const platform = MethodChannel('i_iwara/volume_key');
  late int currentIndex = widget.initialIndex;
  late PageController pageController;
  bool isDragging = false;
  bool isCtrlPressed = false;
  double dragStartX = 0;
  late List<PhotoViewController> controllers;
  final double _zoomInterval = 0.2;
  final double _fineZoomInterval = 0.1;
  final AppService appService = Get.find();
  OverlayEntry? _overlayEntry;

  // 使用Map存储每个图片的重新加载时间戳
  final Map<int, int> _reloadTimestamps = {};

  @override
  void initState() {
    super.initState();
    appService.hideSystemUI(hideTitleBar: false);
    pageController = PageController(initialPage: widget.initialIndex);
    controllers = List.generate(
      widget.galleryItems.length,
      (index) => PhotoViewController(),
    );
    
    // 仅在移动平台添加音量键监听
    if (Platform.isAndroid || Platform.isIOS) {
      _initVolumeKeyListener();
    }
  }

  Future<void> _initVolumeKeyListener() async {
    try {
      // 设置方法调用处理器
      platform.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onVolumeKeyUp':
            goToPreviousPage();
            break;
          case 'onVolumeKeyDown':
            goToNextPage();
            break;
        }
      });
      
      // 启用音量键监听
      await platform.invokeMethod('enableVolumeKeyListener');
    } catch (e) {
      LogUtils.e('音量键监听初始化失败: $e', tag: 'MyGalleryPhotoViewWrapper');
    }
  }

  @override
  void dispose() {
    // 移除音量键监听
    if (Platform.isAndroid || Platform.isIOS) {
      platform.invokeMethod('disableVolumeKeyListener');
    }
    appService.showSystemUI();
    pageController.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.controlLeft) {
      setState(() => isCtrlPressed = true);
    }
    if (event is KeyUpEvent &&
        event.logicalKey == LogicalKeyboardKey.controlLeft) {
      setState(() => isCtrlPressed = false);
    }

    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowRight:
          goToNextPage();
          break;
        case LogicalKeyboardKey.arrowLeft:
          goToPreviousPage();
          break;
        case LogicalKeyboardKey.arrowUp:
          _zoomIn();
          break;
        case LogicalKeyboardKey.arrowDown:
          _zoomOut();
          break;
      }
    }
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

  void _zoomIn({bool fine = false}) {
    final scale = controllers[currentIndex].scale;
    if (scale != null) {
      controllers[currentIndex].scale =
          scale + (fine ? _fineZoomInterval : _zoomInterval);
    }
  }

  void _zoomOut({bool fine = false}) {
    final scale = controllers[currentIndex].scale;
    if (scale != null && scale > 0.5) {
      controllers[currentIndex].scale =
          scale - (fine ? _fineZoomInterval : _zoomInterval);
    }
  }

  void _triggerReload(int index) {
    setState(() {
      _reloadTimestamps[index] = DateTime.now().millisecondsSinceEpoch;
    });
  }

  void _showInfoModal(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text(slang.t.galleryDetail.imageLibraryFunctionIntroduction),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              // 点击左右边缘以切换图片
              Row(
                children: [
                  const Icon(Icons.arrow_right_alt),
                  const SizedBox(width: 8),
                  Expanded(child: Text(slang.t.galleryDetail.clickLeftAndRightEdgeToSwitchImage)),
                ],
              ),
              const SizedBox(height: 8),
              // 右键保存单张图片
              Row(
                children: [
                  const Icon(Icons.save),
                  const SizedBox(width: 8),
                  Expanded(child: Text(slang.t.galleryDetail.rightClickToSaveSingleImage)),
                ],
              ),
              const SizedBox(height: 8),
              // 批量保存
              Row(
                children: [
                  const Icon(Icons.save_alt),
                  const SizedBox(width: 8),
                  // TODO 批量保存功能还未实现
                  Expanded(child: Text(slang.t.galleryDetail.batchSave)),
                ],
              ),
              const SizedBox(height: 8),
              // 键盘的左右控制切换
              Row(
                children: [
                  const Icon(Icons.keyboard_arrow_left),
                  const SizedBox(width: 8),
                  Expanded(child: Text(slang.t.galleryDetail.keyboardLeftAndRightToSwitch)),
                ],
              ),
              const SizedBox(height: 8),
              // 键盘的上下控制缩放
              Row(
                children: [
                  const Icon(Icons.keyboard_arrow_up),
                  const SizedBox(width: 8),
                  Expanded(child: Text(slang.t.galleryDetail.keyboardUpAndDownToZoom)),
                ],
              ),
              const SizedBox(height: 8),
              // 鼠标的滚轮滑动控制切换
              Row(
                children: [
                  const Icon(Icons.swap_vert),
                  const SizedBox(width: 8),
                  Expanded(child: Text(slang.t.galleryDetail.mouseWheelToSwitch)),
                ],
              ),
              const SizedBox(height: 8),
              // CTRL + 鼠标滚轮控制缩放
              Row(
                children: [
                  const Icon(Icons.zoom_in),
                  const SizedBox(width: 8),
                  Expanded(child: Text(slang.t.galleryDetail.ctrlAndMouseWheelToZoom)),
                ],
              ),
              const SizedBox(height: 8),
              // 更多功能待发现
              Row(
                children: [
                  const Icon(Icons.thumb_up),
                  const SizedBox(width: 8),
                  Expanded(child: Text(slang.t.galleryDetail.moreFeaturesToBeDiscovered)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(slang.t.common.close),
            onPressed: () {
              AppService.tryPop();
            },
          ),
        ],
      ),
    );
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
      constraints: const BoxConstraints(
        maxWidth: 300,
        maxHeight: 400,
      ),
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
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // 显示菜单
          Positioned(
            left: dx,
            top: dy,
            child: Material(
              color: Colors.transparent,
              child: menuWidget,
            ),
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

  // 添加新的方法来构建点击区域
  Widget _buildTapArea({
    required bool isLeft,
    required double width,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: double.infinity,
        color: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    // 计算点击区域宽度，宽屏和窄屏使用不同的比例
    final tapAreaWidth = screenWidth > 600 ? screenWidth * 0.2 : screenWidth * 0.25;

    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: _handleKeyPress,
        child: Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              if (isCtrlPressed) {
                if (pointerSignal.scrollDelta.dy > 0) {
                  _zoomOut(fine: true);
                } else {
                  _zoomIn(fine: true);
                }
              } else {
                if (pointerSignal.scrollDelta.dy > 0) {
                  goToNextPage();
                } else {
                  goToPreviousPage();
                }
              }
            }
          },
          child: GestureDetector(
            onLongPressStart: (details) {
              _showImageMenu(context, widget.galleryItems[currentIndex],
                  details.globalPosition);
            },
            onSecondaryTapDown: (details) {
              _showImageMenu(context, widget.galleryItems[currentIndex],
                  details.globalPosition);
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

                    return PhotoViewGalleryPageOptions.customChild(
                      child: KeyedSubtree(
                        key: ValueKey(
                            '${widget.galleryItems[index]}_${_reloadTimestamps[index] ?? 0}'),
                        child: Image(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.contain,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  if (loadingProgress.expectedTotalBytes !=
                                      null) ...[
                                    Text(
                                      '${((loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${(loadingProgress.cumulativeBytesLoaded / 1024 / 1024).toStringAsFixed(1)}MB / ${(loadingProgress.expectedTotalBytes! / 1024 / 1024).toStringAsFixed(1)}MB',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // 如果是Invalid image data错误，说明图片格式不支持
                            // 获取文件扩展名
                            final fileExtension = CommonUtils.getFileExtension(imageUrl);

                            if (error is Exception &&
                                error
                                    .toString()
                                    .contains('Invalid image data')) {
                              LogUtils.e(
                                '图片格式不支持, 当前的图片地址是: $imageUrl\n'
                                '文件扩展名: $fileExtension\n'
                                '错误详情: ${error.toString()}',
                                tag: 'MyGalleryPhotoViewWrapper',
                                error: error,
                              );

                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      slang.t.errors.unsupportedImageFormat(str: fileExtension),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    slang.t.errors.errorWhileLoadingGallery,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  LoadingButton(
                                    onPressed: () => Future(() {
                                      _triggerReload(index);
                                    }),
                                    text: slang.t.common.retry,
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      minScale: PhotoViewComputedScale.contained * 0.5,
                      maxScale: PhotoViewComputedScale.covered * 3,
                      initialScale: PhotoViewComputedScale.contained,
                      controller: controllers[index],
                      heroAttributes: PhotoViewHeroAttributes(
                          tag: widget.galleryItems[index].data.id),
                    );
                  },
                  itemCount: widget.galleryItems.length,
                  // 移除全局 loadingBuilder，因为现在每个图片都有自己的加载进度
                  pageController: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
                // 添加左右点击区域
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: _buildTapArea(
                    isLeft: true,
                    width: tapAreaWidth,
                    onTap: () {
                      if (currentIndex > 0) {
                        goToPreviousPage();
                      }
                    },
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: _buildTapArea(
                    isLeft: false,
                    width: tapAreaWidth,
                    onTap: () {
                      if (currentIndex < widget.galleryItems.length - 1) {
                        goToNextPage();
                      }
                    },
                  ),
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
                              tooltip: slang.t.common.tips,
                              icon: const Icon(Icons.help_outline,
                                  color: Colors.white),
                              onPressed: () {
                                _showInfoModal(context);
                              },
                            ),
                            // 更多设置按钮
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: slang.t.common.more,
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white),
                              onPressed: () {
                                // TODO 还未实现
                                showToastWidget(MDToastWidget(message: slang.t.common.moreFeaturesToBeDeveloped, type: MDToastType.info));
                              },
                            ),
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
                        )
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
