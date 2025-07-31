import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Import TickerProvider
import 'package:flutter/services.dart'; // Import for keyboard events
import 'package:get/get.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'menu_item_widget.dart';

enum MediaItemType {
  image,
  video,
}

class ImageItem {
  final String url;
  final ImageItemData data;
  double? width;
  double? height;
  // headers
  Map<String, String>? headers;
  final MediaItemType mediaType;

  ImageItem({
    required this.url,
    this.width,
    this.height,
    required this.data,
    this.headers,
    MediaItemType? mediaType,
  }) : mediaType = mediaType ?? _detectMediaType(url);

  // 自动检测媒体类型
  static MediaItemType _detectMediaType(String url) {
    final extension = CommonUtils.getFileExtension(url).toLowerCase();

    // 视频格式
    if (['mp4', 'webm', 'mov', 'avi', 'mkv', 'flv', 'wmv', 'm4v'].contains(extension)) {
      return MediaItemType.video;
    }

    // 默认为图片
    return MediaItemType.image;
  }

  bool get isVideo => mediaType == MediaItemType.video;
  bool get isImage => mediaType == MediaItemType.image;
}

class ImageItemData {
  final String id;
  final String? title;
  final String url;
  final String originalUrl;

  ImageItemData({
    required this.id,
    this.title,
    required this.url,
    required this.originalUrl,
  });
}

class MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class HorizontalImageList extends StatefulWidget {
  final List<ImageItem> images;
  final double defaultAspectRatio; // 默认宽高比
  final double? itemSpacing;
  final BoxDecoration? itemDecoration;
  final Function(ImageItem item)? onItemTap;
  final Widget Function(BuildContext, String)? placeholderBuilder;
  final Widget Function(BuildContext, String, dynamic)? errorBuilder;
  final BoxFit imageFit;
  final Color? scrollButtonColor;
  final double scrollOffset;
  final Color? backgroundColor; // 背景色
  final double wheelScrollFactor; // 滚轮滚动系数
  final Widget Function(BuildContext, ImageItem, Offset)?
      menuBuilder; // 自定义菜单构建器
  final List<MenuItem> Function(BuildContext, ImageItem)?
      menuItemsBuilder; // 动态菜单项生成器

  const HorizontalImageList({
    super.key,
    required this.images,
    this.defaultAspectRatio = 1.0, // 默认正方形
    this.itemSpacing = 8.0, // 减小默认间距
    this.itemDecoration,
    this.onItemTap,
    this.placeholderBuilder,
    this.errorBuilder,
    this.imageFit = BoxFit.contain,
    this.scrollButtonColor,
    this.scrollOffset = 300,
    this.backgroundColor,
    this.wheelScrollFactor = 5.0, // 修改默认滚动系数为更小的值
    this.menuBuilder,
    this.menuItemsBuilder, // 使用动态菜单项生成器
  });

  @override
  State<HorizontalImageList> createState() => _HorizontalImageListState();
}

class _HorizontalImageListState extends State<HorizontalImageList>
    with TickerProviderStateMixin { // Mixin TickerProvider
  final FocusNode _focusNode = FocusNode(); // Add FocusNode
  final ScrollController _scrollController = ScrollController();
  bool _showLeftButton = false;
  late bool _showRightButton;
  final Map<String, double> _loadedAspectRatios = {};
  OverlayEntry? _overlayEntry;

  // --- Continuous Scroll State ---
  Ticker? _ticker;
  bool _isScrollingLeft = false;
  bool _isScrollingRight = false;
  final double _scrollVelocity = 200.0; // Pixels per second
  // ------------------------------

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick); // Create ticker
    // Request focus when the widget is initialized, if needed
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     FocusScope.of(context).requestFocus(_focusNode);
    //   }
    // });
    _showRightButton = widget.images.length > 1;
    _scrollController.addListener(_updateButtonVisibility);
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose FocusNode
    _ticker?.dispose(); // Dispose ticker
    _hideMenu();
    _scrollController.removeListener(_updateButtonVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateButtonVisibility() {
    setState(() {
      _showLeftButton = _scrollController.offset > 0;
      _showRightButton =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  void _handleMouseScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // 优化滚动计算逻辑
      final scrollAmount = event.scrollDelta.dy * widget.wheelScrollFactor;
      final targetOffset = _scrollController.offset + scrollAmount;

      // 添加最小滚动距离
      if (scrollAmount.abs() < 1.0) return;

      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 100), // 缩短动画时间提高响应度
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showImageMenu(BuildContext context, ImageItem item, Offset position,
      Size containerSize) {
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
      constraints: BoxConstraints(
        maxWidth: containerSize.width * 0.3, // 限制菜单最大宽度为容器的30%
        maxHeight: containerSize.height * 0.8, // 限制菜单最大高度为容器的80%
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Wrap with Focus to handle keyboard events
        return Focus(
          focusNode: _focusNode,
          autofocus: true, // Automatically request focus
          canRequestFocus: true,
          onKeyEvent: (node, event) {
            final bool isArrowLeft = event.logicalKey == LogicalKeyboardKey.arrowLeft;
            final bool isArrowRight = event.logicalKey == LogicalKeyboardKey.arrowRight;

            if (event is KeyDownEvent) {
              if (isArrowLeft) {
                _isScrollingLeft = true;
                _isScrollingRight = false; // Ensure only one direction
                _startScrolling();
                return KeyEventResult.handled;
              } else if (isArrowRight) {
                _isScrollingRight = true;
                _isScrollingLeft = false; // Ensure only one direction
                _startScrolling();
                return KeyEventResult.handled;
              }
            } else if (event is KeyUpEvent) {
              if (isArrowLeft) {
                _isScrollingLeft = false;
                _stopScrollingIfIdle();
                return KeyEventResult.handled;
              } else if (isArrowRight) {
                _isScrollingRight = false;
                _stopScrollingIfIdle();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored; // Ignore other keys
          },
          child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Use Listener for mouse wheel scroll
                  Listener(
                    onPointerSignal: _handleMouseScroll,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.images.length,
                      itemBuilder: (context, index) {
                        final imageItem = widget.images[index];
                        return _buildImageItem(context, imageItem, index,
                            Size(constraints.maxWidth, constraints.maxHeight));
                      },
                    ),
                  ),
                  // Scroll buttons (visibility handled by listener)
                  if (_showLeftButton)
                    Positioned(
                      left: 8,
                      child: _buildScrollButton(
                        Icons.arrow_back_ios_rounded,
                        () => _scrollController.animateTo(
                          _scrollController.offset - widget.scrollOffset,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                  if (_showRightButton)
                    Positioned(
                      right: 8,
                      child: _buildScrollButton(
                        Icons.arrow_forward_ios_rounded,
                        () => _scrollController.animateTo(
                          _scrollController.offset + widget.scrollOffset,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                ],
              )
          ),
        );
      },
    );
  }

  Widget _buildScrollButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: widget.scrollButtonColor ?? Colors.black54,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem(BuildContext context, ImageItem imageItem, int index,
      Size containerSize) {
    final aspectRatio =
        _loadedAspectRatios[imageItem.url] ?? widget.defaultAspectRatio;

    return GestureDetector(
      onLongPressStart: (details) {
        _showImageMenu(
            context, imageItem, details.globalPosition, containerSize);
      },
      onSecondaryTapDown: (details) {
        _showImageMenu(
            context, imageItem, details.globalPosition, containerSize);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.itemSpacing ?? 8.0, // 减小水平padding
        ),
        child: SizedBox(
          height: containerSize.height,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Material(
              color: widget.backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(8), // 添加圆角
              clipBehavior: Clip.antiAlias, // 确保圆角裁剪生效
              child: InkWell(
                onTap: () => widget.onItemTap?.call(imageItem),
                child: _buildMediaContent(context, imageItem),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String url) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8), // 占位图也添加圆角
        ),
      ),
    );
  }

  void _updateImageSize(ImageProvider provider, String url) {
    // 获取图片实际尺寸并更新状态
    provider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final double width = info.image.width.toDouble();
        final double height = info.image.height.toDouble();
        if (_loadedAspectRatios[url] != width / height) {
          setState(() {
            _loadedAspectRatios[url] = width / height;
          });
        }
      }),
    );
  }

  // --- Ticker Callback for Continuous Scroll ---
  void _tick(Duration elapsed) {
    if (!mounted) return;

    double delta = 0.0;
    // Calculate scroll delta based on elapsed time and velocity
    // Assume ~60 FPS for frame time calculation if needed, or use actual elapsed
    final double frameTime = elapsed.inMilliseconds / 1000.0; // Time since last tick in seconds

    if (_isScrollingLeft) {
      delta = -_scrollVelocity * frameTime;
    } else if (_isScrollingRight) {
      delta = _scrollVelocity * frameTime;
    }

    if (delta != 0) {
      final targetOffset = (_scrollController.offset + delta)
          .clamp(0.0, _scrollController.position.maxScrollExtent);
      // Use jumpTo for immediate response within the ticker loop
      _scrollController.jumpTo(targetOffset);
      // If jumpTo reaches the boundary, stop scrolling in that direction
      if (targetOffset == 0.0 && _isScrollingLeft) {
        _isScrollingLeft = false;
        _stopScrollingIfIdle();
      } else if (targetOffset == _scrollController.position.maxScrollExtent && _isScrollingRight) {
        _isScrollingRight = false;
        _stopScrollingIfIdle();
      }
    }
  }

  void _startScrolling() {
    if (!_ticker!.isTicking) {
      _ticker?.start();
    }
  }

  void _stopScrollingIfIdle() {
    if (!_isScrollingLeft && !_isScrollingRight && _ticker!.isTicking) {
      _ticker?.stop();
    }
  }
  // ------------------------------------------

  // 构建媒体内容（图片或视频）
  Widget _buildMediaContent(BuildContext context, ImageItem imageItem) {
    if (imageItem.isVideo) {
      return _buildVideoContent(context, imageItem);
    } else {
      return _buildImageContent(context, imageItem);
    }
  }

  // 构建图片内容
  Widget _buildImageContent(BuildContext context, ImageItem imageItem) {
    return CachedNetworkImage(
      imageUrl: imageItem.url,
      placeholder: (context, url) =>
          widget.placeholderBuilder?.call(context, url) ??
          _buildPlaceholder(context, url),
      fit: widget.imageFit,
      errorWidget: (context, url, error) {
        LogUtils.e('加载图片失败: $url', tag: 'ImageList', error: error);

        final fileExtension = CommonUtils.getFileExtension(url);
        final isUnsupportedFormat = error is Exception &&
            error.toString().contains('Invalid image data');

        return widget.errorBuilder?.call(context, url, error) ??
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      color: Theme.of(context).colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isUnsupportedFormat
                          ? t.download.errors.unsupportedImageFormatWithMessage(extension: fileExtension.toUpperCase())
                          : t.download.errors.imageLoadFailed,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                    if (isUnsupportedFormat) ...[
                      const SizedBox(height: 4),
                      Text(
                        t.download.errors.pleaseTryOtherViewer,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
      },
      imageBuilder: (context, imageProvider) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateImageSize(imageProvider, imageItem.url);
        });
        return Hero(
            tag: imageItem.data.id,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: widget.imageFit,
                ),
              ),
            ));
      },
    );
  }

  // 构建视频内容
  Widget _buildVideoContent(BuildContext context, ImageItem imageItem) {
    return _VideoThumbnailWidget(
      videoUrl: imageItem.url,
      imageItem: imageItem,
      fit: widget.imageFit,
      onError: (error) {
        LogUtils.e('加载视频失败: ${imageItem.url}', tag: 'ImageList', error: error);
      },
    );
  }
}

// 视频缩略图组件
class _VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final ImageItem imageItem;
  final BoxFit fit;
  final Function(dynamic)? onError;

  const _VideoThumbnailWidget({
    required this.videoUrl,
    required this.imageItem,
    required this.fit,
    this.onError,
  });

  @override
  State<_VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<_VideoThumbnailWidget> {
  late Player _player;
  late VideoController _videoController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isHovered = false;
  bool _shouldAutoPlay = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _player = Player();
      _videoController = VideoController(_player);

      // 监听播放器状态
      _player.stream.error.listen((error) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = error;
          });
          widget.onError?.call(error);
        }
      });

      _player.stream.buffering.listen((buffering) {
        if (mounted && !buffering && !_isInitialized) {
          setState(() {
            _isInitialized = true;
          });
        }
      });

      // 打开视频但不自动播放
      await _player.open(Media(widget.videoUrl));
      await _player.pause(); // 确保暂停状态

    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
        widget.onError?.call(e);
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered && _isInitialized && !_hasError) {
      // 鼠标悬停时播放预览
      _player.play();
      _shouldAutoPlay = true;
    } else if (!isHovered && _shouldAutoPlay) {
      // 鼠标离开时暂停并回到开始
      _player.pause();
      _player.seek(Duration.zero);
      _shouldAutoPlay = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 视频播放器
          if (_isInitialized)
            Hero(
              tag: widget.imageItem.data.id,
              child: Video(
                controller: _videoController,
                controls: null,
                fit: widget.fit,
              ),
            )
          else
            _buildLoadingWidget(),

          // 播放图标覆盖层
          if (!_isHovered || !_isInitialized)
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

          // 视频标识
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'VIDEO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final fileExtension = CommonUtils.getFileExtension(widget.videoUrl);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              '视频加载失败',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '格式: ${fileExtension.toUpperCase()}',
              style: TextStyle(
                color: Colors.red.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
