import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:shimmer/shimmer.dart';

import 'menu_item_widget.dart';

class ImageItem {
  final String url;
  final ImageItemData data;
  double? width;
  double? height;

  ImageItem({
    required this.url,
    this.width,
    this.height,
    required this.data,
  });
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

class _HorizontalImageListState extends State<HorizontalImageList> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftButton = false;
  late bool _showRightButton;
  final Map<String, double> _loadedAspectRatios = {};
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _showRightButton = widget.images.length > 1;
    _scrollController.addListener(_updateButtonVisibility);
  }

  @override
  void dispose() {
    _hideMenu();
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
        return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
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
            ));
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
                child: CachedNetworkImage(
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
                                  .withOpacity(0.1),
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
                                      ? '不支持的文件格式: ${fileExtension.toUpperCase()}'
                                      : '图片加载失败',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 14,
                                  ),
                                ),
                                if (isUnsupportedFormat) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '请尝试使用其他查看器打开',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error
                                          .withOpacity(0.7),
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
                ),
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
}
