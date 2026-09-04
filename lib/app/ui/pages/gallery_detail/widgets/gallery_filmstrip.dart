import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 大图页最底下那条胶片：把整本图库摆成一排缩略图，当前这张钉在正中。
///
/// # 为什么另写一只，而不复用 `HorizontalImageList`
///
/// 那一只是**图库详情页**用的，摆在页面正文里、跟着页面一起滚。这一条是 chrome，
/// 还要反过来当**标尺**用：手指拖到哪儿，正中是第几张必须算得出来，才谈得上
/// 「拖着走的时候大图跟着换」。
///
/// # ⛔ 格子宽度不等宽，所以不能用 `itemExtent`
///
/// 第一版偷懒钉死了 44×58 的格子，结果一排横图全被裁成竖长条，一眼看不出哪张是
/// 哪张（用户 2026-09-04 报的）。现在每格**按图片自己的宽高比**定宽：
///
///   - 服务端在文件信息里就带了 `width` / `height`，[ImageItem] 一构造就知道
///     （见 `buildGalleryImageItems`），所以多数格子第一帧就是对的；
///   - 拿不到的（本地文件、markdown 里的裸链接）先按 [_defaultAspect] 摆，等图
///     真的解出来再[_onAspectResolved]换成实际比例——**换的时候要把滚动位置一起
///     补偿**，否则正中那张会被前面变宽的格子顶走。
///
/// 代价是"第几张"不再是一个除法：改成前缀和（[_leadingExtent]）。这条列表最多
/// 几十上百格，每次滚动线性扫一遍完全无所谓。
///
/// # 双向同步怎么不打架
///
/// 两个方向都会改 index：拖胶片 → 换大图；翻大图 → 胶片跟过去。靠
/// [_userScrolling] 分家：只要这一次滚动是用户自己发起的，就不再把他拽回去
/// （与 `HorizontalImageListController` 那条"用户自己动了就别再粘住"同理）。
///
/// # ⛔ 横向列表收不到鼠标滚轮
///
/// Flutter 的 `Scrollable` 给横向轴取的是 `scrollDelta.dx`，而滚轮给的是 `dy`
/// ——**一格都不会动**。所以这里自己挂 `Listener` 把 `dy` 折算成偏移，和
/// `HorizontalImageList._handleMouseScroll` 同一套做法。
///
/// 与此配套，大图页那条"滚轮翻页"必须在指针落在 chrome 上时让开，否则滚一格
/// 会同时滚动胶片**并且**翻一页（`RenderPointerListener` 是直接调
/// `onPointerSignal` 的，不走 `PointerSignalResolver`，内层处理了外层照收）。
class GalleryFilmstrip extends StatefulWidget {
  const GalleryFilmstrip({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onIndexSelected,
  });

  final List<ImageItem> items;
  final int currentIndex;

  /// 用户把胶片拖/滚到了第几张。
  final ValueChanged<int> onIndexSelected;

  /// 缩略图高度。宽度按各自的宽高比算。
  static const double tileHeight = 58;

  /// 格子之间的间隙（一格的占位 = 缩略图宽 + 这个）。
  static const double gap = 6;

  /// 整条的高度：够放下被放大的当前格，外加一点上下呼吸。
  static const double height = tileHeight + 16;

  /// 还不知道比例时先按这个摆——竖构图在图库里占多数。
  static const double _defaultAspect = 3 / 4;

  /// 宽度上下限。极端长图/宽图不能让一格吃掉半个屏。
  static const double _minTileWidth = 30;
  static const double _maxTileWidth = 104;

  @override
  State<GalleryFilmstrip> createState() => _GalleryFilmstripState();
}

class _GalleryFilmstripState extends State<GalleryFilmstrip> {
  final ScrollController _scrollController = ScrollController();

  /// 加载后才知道的宽高比，按 url 存。
  final Map<String, double> _resolvedAspects = {};

  /// 这一次滚动是用户自己发起的吗。是的话别把他拽回去。
  bool _userScrolling = false;

  /// 我们自己在挪位置（[_centerOn]）——这段时间里的滚动通知不算用户操作。
  bool _programmatic = false;

  /// 滚轮停下来之后再吸附，见 [_handlePointerSignal]。
  Timer? _wheelSettleTimer;

  /// 此刻这条胶片正被用户自己驱动着（手指拖 / 滚轮）。
  ///
  /// 拖动靠 [_userScrolling]，滚轮靠那只静默计时器还没到点——**两者都要算**：
  /// 滚一格会经由 `onIndexSelected` 让大图翻页，翻页又会把新的 `currentIndex`
  /// 传回来触发 [didUpdateWidget]，那时手指还在滚，不该被拽回去。
  bool get _selfDriven =>
      _userScrolling || (_wheelSettleTimer?.isActive ?? false);

  double _viewportWidth = 0;

  @override
  void dispose() {
    _wheelSettleTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GalleryFilmstrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex && !_selfDriven) {
      _centerOn(widget.currentIndex, animate: true);
    }
  }

  // ---- 几何 -----------------------------------------------------------------

  double _aspectOf(ImageItem item) {
    if (item.isVideo) return 16 / 9;
    final resolved = _resolvedAspects[item.url];
    if (resolved != null) return resolved;
    final w = item.width;
    final h = item.height;
    if (w != null && h != null && w > 0 && h > 0) return w / h;
    return GalleryFilmstrip._defaultAspect;
  }

  double _tileWidth(ImageItem item) =>
      (GalleryFilmstrip.tileHeight * _aspectOf(item)).clamp(
        GalleryFilmstrip._minTileWidth,
        GalleryFilmstrip._maxTileWidth,
      );

  double _slotWidth(ImageItem item) => _tileWidth(item) + GalleryFilmstrip.gap;

  /// 第 [index] 格之前所有格子的总宽。
  double _leadingExtent(int index) {
    double sum = 0;
    for (var i = 0; i < index && i < widget.items.length; i++) {
      sum += _slotWidth(widget.items[i]);
    }
    return sum;
  }

  /// 把第 [index] 格摆到视口正中要用的偏移。
  double _offsetFor(int index) {
    if (index < 0 || index >= widget.items.length) return 0;
    // 首格左侧的留白是「半个视口减半个首格」，把它与「半个视口」抵消之后，
    // 偏移就是「前面那些格子的总宽 + 自己半格 - 首格半格」。
    final slot = _slotWidth(widget.items[index]);
    final raw =
        _leadingExtent(index) + slot / 2 - _slotWidth(widget.items.first) / 2;
    if (!_scrollController.hasClients) return raw;
    final position = _scrollController.position;
    return raw.clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  /// 正中此刻是第几格。
  int _indexAtCenter() {
    if (!_scrollController.hasClients || widget.items.isEmpty) {
      return widget.currentIndex;
    }
    final target = _scrollController.offset + _slotWidth(widget.items[0]) / 2;
    double sum = 0;
    for (var i = 0; i < widget.items.length; i++) {
      final slot = _slotWidth(widget.items[i]);
      // 落在这一格的范围里就是它。⛔ 别写成 `sum + slot / 2`——那是"过了半格就
      // 算下一格"，正中还没走到下一张就先跳了。
      if (target < sum + slot) return i;
      sum += slot;
    }
    return widget.items.length - 1;
  }

  Future<void> _centerOn(int index, {required bool animate}) async {
    if (!_scrollController.hasClients) {
      // 还没排完版：等这一帧画完再落位，否则 min/maxScrollExtent 都还没有。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _centerOn(index, animate: false);
      });
      return;
    }
    final target = _offsetFor(index);
    if ((_scrollController.offset - target).abs() < 0.5) return;
    _programmatic = true;
    if (animate) {
      await _scrollController.animateTo(
        target,
        duration: GlassTokens.motionDuration,
        curve: GlassTokens.motionCurve,
      );
    } else {
      _scrollController.jumpTo(target);
    }
    if (mounted) _programmatic = false;
  }

  /// 某一格量出真实比例了。
  ///
  /// ⛔ 换宽度要**同时补偿滚动位置**：前面几格一变宽，正中那张就被顶到一边去了。
  /// 记下换之前正中那格该在的偏移，排完版再落回去。
  ///
  /// ⛔ **这条回调可能在 build 中间同步跑**：`imageBuilder` 只在图**已经解码完**
  /// 之后才被调用，于是 `provider.resolve(...)` 拿到的 completer 里已经躺着一帧，
  /// `addListener` 会当场回调——而那一刻子 tile 正在 build，直接 `setState` 就是
  /// 「setState() or markNeedsBuild() called during build」。表可以同步落（下一帧
  /// 就别再为这一格挂监听了），**重建必须排到帧末**。
  void _onAspectResolved(String url, double aspect) {
    if (!mounted) return;
    final old = _resolvedAspects[url];
    if (old != null && (old - aspect).abs() < 0.01) return;
    _resolvedAspects[url] = aspect;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // 表在上面已经改过了，这一次只是把「宽度变了」告诉框架。
      setState(() {});
      if (_selfDriven) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_selfDriven) {
          _centerOn(widget.currentIndex, animate: false);
        }
      });
    });
  }

  // ---- 输入 -----------------------------------------------------------------

  bool _onScrollNotification(ScrollNotification notification) {
    if (_programmatic) return false;
    if (notification is ScrollStartNotification) {
      _userScrolling = true;
    } else if (notification is ScrollUpdateNotification) {
      _userScrolling = true;
      // 拖着走的过程中大图就跟着换——这正是 iPhone 那条胶片的手感。
      // 只在「正中那一张变了」时才报，天然节流。
      final index = _indexAtCenter();
      if (index != widget.currentIndex) widget.onIndexSelected(index);
    } else if (notification is ScrollEndNotification) {
      _userScrolling = false;
      // 松手后吸到最近一格，免得停在两张中间。
      _centerOn(_indexAtCenter(), animate: true);
    }
    return false;
  }

  /// 鼠标滚轮 / 触控板。
  ///
  /// ⛔ `jumpTo` 会**同步**派发 ScrollStart / Update / **End** 三条通知，而 End
  /// 那一支会当场排一次 300ms 的吸附动画——滚轮每拨一格就打断上一次吸附再排一次，
  /// 读起来是「越滚越往回弹、根本连不成一段连续滚动」。所以这一段整个从通知里
  /// 摘出去（[_programmatic]），吸附改由静默计时器在**停手之后**排一次。
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!_scrollController.hasClients) return;
    // 竖滚轮给的是 dy，横向列表自己只认 dx（一格都不会动），这里手动折算。
    // 触控板的横向分量也一并算上。
    final double delta = event.scrollDelta.dy.abs() > event.scrollDelta.dx.abs()
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    if (delta == 0) return;
    final position = _scrollController.position;
    _programmatic = true;
    _scrollController.jumpTo(
      (_scrollController.offset + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
    _programmatic = false;
    final index = _indexAtCenter();
    if (index != widget.currentIndex) widget.onIndexSelected(index);
    // 停手之后吸到最近一格，与拖动松手那一下同一个行为。
    // 计时器还没到点期间 [_selfDriven] 为真，翻页回传的 currentIndex 不会把
    // 滚动位置拽走。
    _wheelSettleTimer?.cancel();
    _wheelSettleTimer = Timer(const Duration(milliseconds: 180), () {
      if (mounted) _centerOn(_indexAtCenter(), animate: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: GalleryFilmstrip.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double viewportWidth = constraints.maxWidth;
          if (viewportWidth != _viewportWidth) {
            _viewportWidth = viewportWidth;
            // 视口宽度变了（转屏 / 分屏），首尾两端的留白跟着变，得重新落位。
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_selfDriven) {
                _centerOn(widget.currentIndex, animate: false);
              }
            });
          }
          // 首尾各留半个视口（减去半个首/尾格）：第一张与最后一张也能停在正中。
          final double leading =
              (viewportWidth - _slotWidth(widget.items.first)) / 2;
          final double trailing =
              (viewportWidth - _slotWidth(widget.items.last)) / 2;

          return Listener(
            onPointerSignal: _handlePointerSignal,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(
                  left: leading.clamp(0.0, double.infinity),
                  right: trailing.clamp(0.0, double.infinity),
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return SizedBox(
                    width: _slotWidth(item),
                    child: _FilmstripTile(
                      item: item,
                      width: _tileWidth(item),
                      selected: index == widget.currentIndex,
                      onTap: () => widget.onIndexSelected(index),
                      // 服务端已经给了宽高、或者已经量过一次的，就别再挂监听了
                      // ——`ImageStream` 的监听不摘，每次重建挂一个就是泄漏。
                      onAspectResolved:
                          _resolvedAspects.containsKey(item.url) ||
                              (item.width != null && item.height != null)
                          ? null
                          : (aspect) => _onAspectResolved(item.url, aspect),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilmstripTile extends StatelessWidget {
  const _FilmstripTile({
    required this.item,
    required this.width,
    required this.selected,
    required this.onTap,
    required this.onAspectResolved,
  });

  final ImageItem item;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  /// 量出真实比例后回报。已经知道比例的条目传 null，避免重复挂 `ImageStream`
  /// 监听（挂了不摘就是泄漏）。
  final ValueChanged<double>? onAspectResolved;

  @override
  Widget build(BuildContext context) {
    // 未选中的缩一档：不用换颜色也能一眼看出正中是谁，而且尺寸变化本身就是过渡。
    return Center(
      child: AnimatedScale(
        duration: GlassTokens.motionDuration,
        curve: GlassTokens.motionCurve,
        scale: selected ? 1.0 : 0.84,
        child: AnimatedContainer(
          duration: GlassTokens.motionDuration,
          curve: GlassTokens.motionCurve,
          width: width,
          height: GalleryFilmstrip.tileHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? 0.95 : 0.0),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: GestureDetector(onTap: onTap, child: _thumbnail(context)),
          ),
        ),
      ),
    );
  }

  Widget _thumbnail(BuildContext context) {
    if (item.isVideo) {
      // 视频没有现成的缩略图地址，也不值得为一格几十像素再起一份 libmpv 实例
      // 去解首帧——摆一格能认出来的深色片头就够了。
      return const ColoredBox(
        color: Color(0xFF2A2A2A),
        child: Center(
          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
        ),
      );
    }

    if (item.url.startsWith('file://')) {
      return Image.file(
        File(item.url.replaceFirst('file://', '')),
        fit: BoxFit.cover,
        cacheWidth: 256,
        errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF2A2A2A)),
      );
    }

    return CachedNetworkImage(
      imageUrl: item.url,
      httpHeaders: item.headers,
      fit: BoxFit.cover,
      // 一格最宽也就一百来像素，按原图解码是纯浪费（大图页那边另有一份全分辨率
      // 的缓存，两者互不干扰）。
      memCacheWidth: 256,
      imageBuilder: (context, provider) {
        final report = onAspectResolved;
        if (report != null) {
          // 服务端没给宽高的条目，等图真的解出来再把比例回报上去。
          late final ImageStreamListener listener;
          final stream = provider.resolve(const ImageConfiguration());
          listener = ImageStreamListener((info, _) {
            stream.removeListener(listener);
            final w = info.image.width.toDouble();
            final h = info.image.height.toDouble();
            // ⛔ 派给监听器的是一份**克隆**，不还回去就是每格漏一张解码位图。
            // 尺寸要在 dispose 之前读完。
            info.dispose();
            if (w > 0 && h > 0) report(w / h);
          });
          stream.addListener(listener);
        }
        return Image(image: provider, fit: BoxFit.cover);
      },
      placeholder: (_, _) => const ColoredBox(color: Color(0xFF2A2A2A)),
      errorWidget: (_, _, _) => const ColoredBox(
        color: Color(0xFF2A2A2A),
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.white38,
            size: 18,
          ),
        ),
      ),
    );
  }
}
