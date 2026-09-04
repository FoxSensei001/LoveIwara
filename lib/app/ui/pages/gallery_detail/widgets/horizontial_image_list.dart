import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Import TickerProvider
import 'package:flutter/services.dart'; // Import for keyboard events
import 'package:get/get.dart';
import 'package:i_iwara/app/models/media_file.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/color_vision_filter_wrapper.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontal_image_list_controller.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

enum MediaItemType { image, video }

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

  /// 兜底的媒体类型判定：**只在调用方没传 [mediaType] 时**才按后缀猜。
  ///
  /// 来自 Iwara 的图库条目一律由 `buildGalleryImageItems` 拿服务端的
  /// `type` / `mime` 明确传进来（见 [MediaFile.isVideo]）；这条路留给本地文件
  /// （下载回来的 `file://…`）与 markdown 里的裸链接，那里确实只有一个后缀可看。
  static MediaItemType _detectMediaType(String url) {
    final extension = CommonUtils.getFileExtension(url).toLowerCase();
    return kGalleryVideoFileExtensions.contains(extension)
        ? MediaItemType.video
        : MediaItemType.image;
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

  MenuItem({required this.icon, required this.title, required this.onTap});
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
  final BorderRadius clipBorderRadius; // 列表整体裁剪圆角
  final BorderRadius Function(ImageItem item)?
  itemBorderRadiusBuilder; // 单个item圆角
  final double Function(
    ImageItem item,
    double defaultAspectRatio,
    double? loadedAspectRatio,
  )?
  aspectRatioBuilder; // 单个item宽高比覆盖
  final BoxFit Function(ImageItem item)? imageFitBuilder; // 单个item fit 覆盖
  final Widget Function(BuildContext, ImageItem, Widget)?
  mediaContentBuilder; // 单个item内容包装器
  final double scrollOffset;
  final Color? backgroundColor; // 背景色
  final double wheelScrollFactor; // 滚轮滚动系数
  final List<MenuItem> Function(BuildContext, ImageItem)?
  menuItemsBuilder; // 动态菜单项生成器

  /// 「滚到第几张」的外部把手：大图页翻页时靠它把这条清单同步过去
  /// （见 [HorizontalImageListController]）。
  final HorizontalImageListController? listController;

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
    this.clipBorderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.itemBorderRadiusBuilder,
    this.aspectRatioBuilder,
    this.imageFitBuilder,
    this.mediaContentBuilder,
    this.scrollOffset = 300,
    this.backgroundColor,
    this.wheelScrollFactor = 5.0, // 修改默认滚动系数为更小的值
    this.menuItemsBuilder, // 使用动态菜单项生成器
    this.listController,
  });

  @override
  State<HorizontalImageList> createState() => _HorizontalImageListState();
}

class _HorizontalImageListState extends State<HorizontalImageList>
    with TickerProviderStateMixin {
  // Mixin TickerProvider
  final FocusNode _focusNode = FocusNode(); // Add FocusNode
  final ScrollController _scrollController = ScrollController();
  bool _showLeftButton = false;
  late bool _showRightButton;
  final Map<String, double> _loadedAspectRatios = {};

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
    widget.listController?.attach(_revealIndex);
  }

  @override
  void didUpdateWidget(covariant HorizontalImageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.listController, widget.listController)) {
      oldWidget.listController?.detach(_revealIndex);
      widget.listController?.attach(_revealIndex);
    }
  }

  @override
  void dispose() {
    widget.listController?.detach(_revealIndex);
    _focusNode.dispose(); // Dispose FocusNode
    _ticker?.dispose(); // Dispose ticker
    _scrollController.removeListener(_updateButtonVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  // ---- 「滚到第几张」----------------------------------------------------
  //
  // 这条清单每条的宽度都不一样（高度固定、宽高比逐条算），没有现成的
  // `scrollToIndex` 可用；`Scrollable.ensureVisible` 也不行——目标多半远在视野
  // 之外、压根没被建出来，拿不到 context。所以按 build 里那套同样的算法把前面
  // 每条的宽度加起来，直接落到偏移上。
  //
  // 宽高比是图片加载完才知道的（[_loadedAspectRatios]），所以目标下标要**粘住**：
  // 每次有新的宽高比进来就照着重算一次，直到用户自己动了这条清单为止。
  int? _revealTarget;
  double? _viewportHeight;

  void _revealIndex(int index) {
    if (index < 0 || index >= widget.images.length) return;
    _revealTarget = index;
    _applyRevealTarget();
  }

  void _applyRevealTarget() {
    final target = _revealTarget;
    if (target == null) return;
    if (!mounted) return;
    // 还没量出高度（首帧之前）或滚动位置还没挂上：等这一帧画完再来。
    if (_viewportHeight == null || !_scrollController.hasClients) {
      _scheduleApplyRevealTarget(onlyWhenReady: true);
      return;
    }
    final offset = _offsetForIndex(target, _viewportHeight!);
    if (offset == null) return;
    if ((_scrollController.offset - offset).abs() < 0.5) return;
    _scrollController.jumpTo(offset);
  }

  bool _revealScheduled = false;

  void _scheduleApplyRevealTarget({bool onlyWhenReady = false}) {
    if (_revealTarget == null || _revealScheduled) return;
    _revealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealScheduled = false;
      if (!mounted) return;
      // 排完这一帧还是没就绪就作罢：再排下去就是每帧空转一次。
      if (onlyWhenReady &&
          (_viewportHeight == null || !_scrollController.hasClients)) {
        return;
      }
      _applyRevealTarget();
    });
  }

  /// 把第 [index] 条尽量摆到视野正中要用的偏移；算不出来返回 null。
  double? _offsetForIndex(int index, double height) {
    final position = _scrollController.position;
    if (!position.hasViewportDimension || !position.hasContentDimensions) {
      return null;
    }
    double leading = 0;
    for (var i = 0; i < index && i < widget.images.length; i++) {
      leading += _itemWidth(widget.images[i], height);
    }
    final itemWidth = _itemWidth(widget.images[index], height);
    final target = leading - (position.viewportDimension - itemWidth) / 2;
    return target.clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  /// 与 [_buildImageItem] 完全同一套算法：左右各一份 padding + 高度 × 宽高比。
  double _itemWidth(ImageItem item, double height) {
    final spacing = widget.itemSpacing ?? 8.0;
    final aspectRatio = _resolveAspectRatio(item);
    return spacing * 2 + height * aspectRatio;
  }

  double _resolveAspectRatio(ImageItem item) {
    final loadedAspectRatio = _loadedAspectRatios[item.url];
    return widget.aspectRatioBuilder?.call(
          item,
          widget.defaultAspectRatio,
          loadedAspectRatio,
        ) ??
        (loadedAspectRatio ?? widget.defaultAspectRatio);
  }

  /// 用户自己动了这条清单，就别再把他拽回去了。
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _revealTarget = null;
    }
    return false;
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
      // 用户自己滚了，粘住的目标作废（滚轮走 animateTo，不产生拖拽通知）。
      _revealTarget = null;
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

  /// 长按 / 右键图片弹出的操作菜单：走全站统一的玻璃面板。
  ///
  /// 原来是 `showAppDialog` 里塞一列 `ListTile` —— 一张居中的不透明卡片，
  /// 既离手指远，又和全站其它菜单不是一套东西。面板贴着落点弹出
  /// （[globalPosition]，见 [showGlassMenu] 的 globalAnchor）。
  Future<void> _showImageMenu(
    BuildContext context,
    ImageItem item,
    Offset globalPosition,
  ) async {
    // 动态生成菜单项
    final menuItems = widget.menuItemsBuilder != null
        ? widget.menuItemsBuilder!(context, item)
        : <MenuItem>[];

    // 如果没有菜单项，不显示菜单
    if (menuItems.isEmpty) return;

    final picked = await showGlassMenu<int>(
      anchorContext: context,
      globalAnchor: globalPosition & Size.zero,
      entries: [
        for (final (index, menuItem) in menuItems.indexed)
          GlassMenuOption<int>(
            value: index,
            icon: menuItem.icon,
            label: menuItem.title,
          ),
      ],
    );
    if (picked == null) return;
    menuItems[picked].onTap();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportHeight = constraints.maxHeight;
        // Wrap with Focus to handle keyboard events
        return Focus(
          focusNode: _focusNode,
          autofocus: true, // Automatically request focus
          canRequestFocus: true,
          onKeyEvent: (node, event) {
            final bool isArrowLeft =
                event.logicalKey == LogicalKeyboardKey.arrowLeft;
            final bool isArrowRight =
                event.logicalKey == LogicalKeyboardKey.arrowRight;

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
            borderRadius: widget.clipBorderRadius,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Use Listener for mouse wheel scroll
                Listener(
                  onPointerSignal: _handleMouseScroll,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _handleScrollNotification,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.images.length,
                      itemBuilder: (context, index) {
                        final imageItem = widget.images[index];
                        return _buildImageItem(
                          context,
                          imageItem,
                          index,
                          Size(constraints.maxWidth, constraints.maxHeight),
                        );
                      },
                    ),
                  ),
                ),
                // Scroll buttons (visibility handled by listener)
                if (_showLeftButton)
                  Positioned(
                    left: 8,
                    child: _buildScrollButton(
                      icon: Icons.arrow_back_ios_rounded,
                      tooltip: t.galleryDetail.scrollLeft,
                      onPressed: () => _scrollBy(-widget.scrollOffset),
                    ),
                  ),
                if (_showRightButton)
                  Positioned(
                    right: 8,
                    child: _buildScrollButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      tooltip: t.galleryDetail.scrollRight,
                      onPressed: () => _scrollBy(widget.scrollOffset),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollBy(double delta) {
    _revealTarget = null;
    _scrollController.animateTo(
      (_scrollController.offset + delta).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  /// 左右滚动钮：全站统一的玻璃圆钮。
  ///
  /// 原来是「black54 圆片 + InkWell + 20px 白图标」——全 App 只有这两枚是那个
  /// 长相，而它俩恰恰悬浮在图片之上，是最该看出折射的位置。
  ///
  /// ⚠️ 外面必须单独供一层 chrome 档（[GlassChromeLayer]）：这条横向列表人在
  /// 页面 `body` 子树里，而外层 `GlassHeaderOverlay(liquid: true)` 会把整个
  /// `body` 摁回 [GlassBackend.plain]（列表是滚动容器，装不得 lens，见该组件
  /// 类文档）。不重新供档的话这两枚钮永远是假玻璃——与相关图库分段胶囊当初
  /// 那个坑同源。它们浮在内容**之上**、自己不在滚动里，正是透镜的适用场景。
  ///
  /// `group: false`：左右各在一边，隔着整条列表，不成簇（见 GlassChromeLayer）。
  Widget _buildScrollButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return GlassChromeLayer(
      group: false,
      child: GlassIconButton(
        standalone: true,
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildImageItem(
    BuildContext context,
    ImageItem imageItem,
    int index,
    Size containerSize,
  ) {
    final backgroundColor = widget.backgroundColor;
    final bool hasBackground = backgroundColor != null;

    final aspectRatio = _resolveAspectRatio(imageItem);

    final BorderRadius itemBorderRadius =
        widget.itemBorderRadiusBuilder?.call(imageItem) ??
        BorderRadius.circular(8);

    final baseContent = _buildMediaContent(context, imageItem);
    // ⛔ 这里曾经按 `heroTagBuilder` 包一层 Hero（缩略图飞成大图）。整套 Hero
    // 已于 2026-09-05 移除，进大图页只走路由自己那段淡入淡出。
    final mediaContent =
        widget.mediaContentBuilder?.call(context, imageItem, baseContent) ??
        baseContent;

    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showImageMenu(context, imageItem, details.globalPosition);
      },
      // 长按走 GlassLongPressMenuArea：手指不抬就能直接划到某一条上松手选中。
      child: GlassLongPressMenuArea(
        onMenu: (globalPosition) =>
            _showImageMenu(context, imageItem, globalPosition),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.itemSpacing ?? 8.0, // 减小水平padding
          ),
          child: SizedBox(
            height: containerSize.height,
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Material(
                type: hasBackground
                    ? MaterialType.canvas
                    : MaterialType.transparency,
                color: hasBackground ? backgroundColor : null,
                borderRadius: itemBorderRadius, // 添加圆角
                clipBehavior: Clip.antiAlias, // 确保圆角裁剪生效
                child: InkWell(
                  onTap: () => widget.onItemTap?.call(imageItem),
                  child: mediaContent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, BorderRadius borderRadius) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: borderRadius, // 占位图也添加圆角
        ),
      ),
    );
  }

  void _updateImageSize(ImageProvider provider, String url) {
    // 获取图片实际尺寸并更新状态
    provider
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            final double width = info.image.width.toDouble();
            final double height = info.image.height.toDouble();
            if (_loadedAspectRatios[url] != width / height) {
              setState(() {
                _loadedAspectRatios[url] = width / height;
              });
              // 宽度刚刚变了，粘住的目标要照新宽度重新落一次位——要等这一帧
              // 排完版，不然 maxScrollExtent 还是旧的。
              _scheduleApplyRevealTarget();
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
    final double frameTime =
        elapsed.inMilliseconds / 1000.0; // Time since last tick in seconds

    if (_isScrollingLeft) {
      delta = -_scrollVelocity * frameTime;
    } else if (_isScrollingRight) {
      delta = _scrollVelocity * frameTime;
    }

    if (delta != 0) {
      final targetOffset = (_scrollController.offset + delta).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      // Use jumpTo for immediate response within the ticker loop
      _scrollController.jumpTo(targetOffset);
      // If jumpTo reaches the boundary, stop scrolling in that direction
      if (targetOffset == 0.0 && _isScrollingLeft) {
        _isScrollingLeft = false;
        _stopScrollingIfIdle();
      } else if (targetOffset == _scrollController.position.maxScrollExtent &&
          _isScrollingRight) {
        _isScrollingRight = false;
        _stopScrollingIfIdle();
      }
    }
  }

  void _startScrolling() {
    _revealTarget = null;
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
    final BorderRadius itemBorderRadius =
        widget.itemBorderRadiusBuilder?.call(imageItem) ??
        BorderRadius.circular(8);
    final BoxFit fit =
        widget.imageFitBuilder?.call(imageItem) ?? widget.imageFit;

    return CachedNetworkImage(
      imageUrl: imageItem.url,
      // 主查看器需保留原图清晰度，因此不做显示降采样；仅设置一个较高的磁盘缓存
      // 上限（4096px），让典型图片不受影响，只对超大图（>4K）限制以避免全分辨率
      // 解码导致的内存飙升 / 低端设备 OOM。
      maxWidthDiskCache: 4096,
      maxHeightDiskCache: 4096,
      placeholder: (context, url) =>
          widget.placeholderBuilder?.call(context, url) ??
          _buildPlaceholder(context, itemBorderRadius),
      fit: fit,
      errorWidget: (context, url, error) {
        LogUtils.e('加载图片失败: $url', tag: 'ImageList', error: error);

        final fileExtension = CommonUtils.getFileExtension(url);
        final isUnsupportedFormat =
            error is Exception &&
            error.toString().contains('Invalid image data');

        return widget.errorBuilder?.call(context, url, error) ??
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.errorContainer.withValues(alpha: 0.1),
                  borderRadius: itemBorderRadius,
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
                          ? t.download.errors.unsupportedImageFormatWithMessage(
                              extension: fileExtension.toUpperCase(),
                            )
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
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.7),
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
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        );
      },
    );
  }

  /// 视频条目的缩略图：和其它视频格式一样出真实首帧。
  ///
  /// 这里原来对 webm 单独画一个「play 图标 + WEBM 字样」的死板占位块，从不尝试
  /// 加载。那是在给一个**上游**的毛病打补丁：图库里的视频地址此前被拼成了图片
  /// 缩放端点 `/image/large/…/x.webm`，喂给 libmpv 当然打不开，于是干脆不试。
  /// 地址在 [MediaFile.getLargeImageUrl] 修好之后，webm 与 mp4 已经没有区别了。
  Widget _buildVideoContent(BuildContext context, ImageItem imageItem) {
    final BoxFit fit =
        widget.imageFitBuilder?.call(imageItem) ?? widget.imageFit;

    return _VideoThumbnailWidget(
      videoUrl: imageItem.url,
      imageItem: imageItem,
      headers: imageItem.headers,
      fit: fit,
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
  final Map<String, String>? headers;
  final BoxFit fit;
  final Function(dynamic)? onError;

  const _VideoThumbnailWidget({
    required this.videoUrl,
    required this.imageItem,
    required this.fit,
    this.headers,
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

      // 添加额外的配置来支持 webm 格式
      await _player.setAudioTrack(AudioTrack.no()); // 禁用音频避免权限问题

      // 打开视频但不自动播放
      final media = Media(widget.videoUrl, httpHeaders: widget.headers);
      await _player.open(media);
      await _player.pause(); // 确保暂停状态
    } catch (e) {
      LogUtils.e(
        '视频初始化失败: ${widget.videoUrl}',
        tag: 'VideoThumbnail',
        error: e,
      );
      if (mounted) {
        setState(() {
          _hasError = true;
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
          //
          // ⛔ 这里曾经包着 `Hero(tag: imageItem.data.id)`，可**从来没飞过**：
          // 大图页那侧的 heroTagBuilder 对视频恒返回 null（视频没有 Hero 对家），
          // 于是它只是一个裸文件 id 的孤儿标签——同一张图在两处同时出现就会撞
          // 「duplicate hero tag」。整套 Hero 已于 2026-09-05 移除，它跟着一起走。
          if (_isInitialized)
            ColorVisionFilterWrapper(
              configKey: ConfigKey.GALLERY_COLOR_VISION_FILTER_ID,
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
                  Icon(Icons.videocam, color: Colors.white, size: 12),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.error.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_library, color: colorScheme.error, size: 48),
            const SizedBox(height: 8),
            Text(
              // 这里原来写死 'WEBM'，mp4 播不出来时也一样报 WEBM。
              CommonUtils.getFileExtension(widget.videoUrl).toUpperCase(),
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
