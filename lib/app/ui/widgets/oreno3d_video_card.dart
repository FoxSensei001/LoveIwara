import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:i_iwara/app/models/oreno3d_video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/media_card_meta.dart';
import 'package:i_iwara/app/services/oreno3d_localization_service.dart';
import 'package:i_iwara/app/services/search_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

/// Oreno3D 搜索结果里的视频卡片。
///
/// 版式与站内视频卡片（`VideoCardListItemWidget`）对齐：同一套圆角 / 描边 /
/// 悬停抬升、16:9 缩略图、播放量压在缩略图右上角（共用
/// [MediaCardStatsOverlay]）、标题固定占两行。O3D 比站内视频多一排标签，
/// 那排也是**定高**的，见 [_Oreno3dTagStrip]——只要有一张卡片长高一点，
/// 瀑布流就会错开，整页看起来是乱的。
///
/// 与站内卡片刻意不同的两处：O3D 的作者只是个名字（没有 user 实体、点不开
/// 主页），所以它退到统计行右侧当署名，不占单独一行；也没有三点操作钮与多选
/// 态，因此文字区右侧不需要给 [kMediaCardActionReserve] 让位。
class Oreno3dVideoCard extends StatefulWidget {
  final Oreno3dVideo video;
  final double width;

  const Oreno3dVideoCard({super.key, required this.video, required this.width});

  @override
  State<Oreno3dVideoCard> createState() => _Oreno3dVideoCardState();
}

class _Oreno3dVideoCardState extends State<Oreno3dVideoCard> {
  // 点开才需要它。卡片一屏能有十几张，没必要每张构造时都去容器里查一次。
  SearchService get _searchService => Get.find<SearchService>();
  bool _isLoading = false;
  bool _isLoadingDialogVisible = false;
  BuildContext? _loadingDialogContext;
  CancelToken? _cancelToken;

  // 标题这三个数跟站内视频卡片逐字对齐，两种卡片混排时行距才是同一条。
  static const double _titleFontSize = 14;
  static const double _titleLineHeight = 1.22;
  static const double _titleHeight = _titleFontSize * _titleLineHeight * 2;

  static const Duration _hoverAnimationDuration = Duration(milliseconds: 220);

  bool _isHovering = false;

  @override
  void dispose() {
    // 如果组件销毁时还在loading，取消请求并关闭dialog
    if (_isLoading) {
      _cancelToken?.cancel('组件销毁');
      _closeLoadingDialogIfNeeded();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(14);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: _titleFontSize,
      fontWeight: FontWeight.w700,
      height: _titleLineHeight,
    );
    final bool enableHover = _isDesktopPlatform();
    final bool showHoverState = enableHover && _isHovering;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        child: MouseRegion(
          onEnter: enableHover
              ? (_) => setState(() => _isHovering = true)
              : null,
          onExit: enableHover
              ? (_) => setState(() => _isHovering = false)
              : null,
          child: AnimatedContainer(
            duration: _hoverAnimationDuration,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(
                    alpha: showHoverState ? 0.2 : 0.08,
                  ),
                  blurRadius: showHoverState ? 18 : 8,
                  offset: Offset(0, showHoverState ? 8 : 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: radius,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: radius,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: showHoverState ? 0.6 : 0.3,
                            ),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: radius,
                    onTap: _isLoading ? null : _handleVideoTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Thumbnail(video: widget.video, width: widget.width),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: _titleHeight,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    widget.video.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    strutStyle: const StrutStyle(
                                      fontSize: _titleFontSize,
                                      height: _titleLineHeight,
                                      forceStrutHeight: true,
                                    ),
                                    style: titleStyle,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _MetaLine(
                                favoriteCount: widget.video.favoriteCount,
                                author: widget.video.author,
                              ),
                              const SizedBox(height: 8),
                              _Oreno3dTagStrip(tags: widget.video.tags),
                            ],
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
    );
  }

  bool _isDesktopPlatform() {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }

  void _showLoadingDialog() {
    _isLoadingDialogVisible = true;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        _loadingDialogContext = dialogContext;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            // 弹窗被系统返回链或用户手势关闭后，也必须取消请求，避免继续跳转。
            if (_isLoading) {
              _cancelToken?.cancel('用户取消');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              } else {
                _isLoading = false;
              }
            }
            if (!didPop) {
              Navigator.of(dialogContext).pop();
            }
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(dialogContext).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 加载动画容器
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        dialogContext,
                      ).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(dialogContext).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 标题文本
                  Text(
                    slang.t.oreno3d.loading.gettingVideoInfo,
                    style: TextStyle(
                      color: Theme.of(dialogContext).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // 取消按钮
                  OutlinedButton(
                    onPressed: () {
                      // 取消网络请求
                      _cancelToken?.cancel('用户取消');
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                      Navigator.of(dialogContext).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: Theme.of(dialogContext).colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      slang.t.oreno3d.loading.cancel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(dialogContext).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (_isLoading) {
        _cancelToken?.cancel('用户取消');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        } else {
          _isLoading = false;
        }
      }
      _isLoadingDialogVisible = false;
      _loadingDialogContext = null;
    });
  }

  void _closeLoadingDialogIfNeeded() {
    if (!_isLoadingDialogVisible) {
      return;
    }

    final dialogContext = _loadingDialogContext;
    if (dialogContext != null && dialogContext.mounted) {
      AppService.tryPop(context: dialogContext);
      return;
    }

    AppService.tryPop(context: context);
  }

  Future<void> _handleVideoTap() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // 创建新的 CancelToken
    _cancelToken = CancelToken();

    // 显示loading dialog
    _showLoadingDialog();

    try {
      // 获取oreno3d详情，传入 CancelToken
      final detail = await _searchService.getOreno3dVideoDetail(
        widget.video.id,
        cancelToken: _cancelToken,
      );

      // 用户已取消（例如返回键关闭弹窗）时，即使请求晚到也不再继续后续跳转。
      if (!_isLoading) {
        return;
      }

      // 关闭loading dialog
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
        _closeLoadingDialogIfNeeded();
      }

      if (detail == null) {
        // 视频不存在或获取失败
        if (mounted) {
          showAppToast(
            slang.t.oreno3d.messages.videoNotFoundOrDeleted,
            type: AppToastType.error,
          );
        }
        return;
      }

      // 提取iwara视频ID
      final iwaraId = detail.extractIwaraId();

      if (iwaraId == null || iwaraId.isEmpty) {
        // 无法提取iwara ID，显示错误
        if (mounted) {
          showAppToast(
            slang.t.oreno3d.messages.unableToGetVideoPlayLink,
            type: AppToastType.error,
          );
        }
        return;
      }

      // 跳转到视频详情页
      NaviService.navigateToVideoDetailPage(
        iwaraId,
        extData: {'oreno3dVideoDetailInfo': detail.toJson()},
      );
    } catch (e) {
      // 如果是取消请求，不显示错误信息
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // 请求被取消，不需要显示错误
        return;
      }

      // 关闭loading dialog
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
        _closeLoadingDialogIfNeeded();
      }

      // 处理错误
      if (mounted) {
        showAppToast(
          '${slang.t.oreno3d.messages.getVideoDetailFailed}: $e',
          type: AppToastType.error,
        );
      }
    }
  }
}

/// 缩略图：16:9、上沿两角跟着卡片的圆角走，播放量压在右上角。
///
/// 播放量走的是站内卡片同一只 [MediaCardStatsOverlay]（O3D 没有评论数，传 0
/// 那一段自己会省掉），所以两种卡片上这块标签的圆角、字号、贴边规矩都是同一份。
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.video, required this.width});

  final Oreno3dVideo video;
  final double width;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.vertical(
      top: Radius.circular(kMediaCardThumbnailRadius),
    );

    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: video.thumbnailUrl,
              fit: BoxFit.cover,
              memCacheWidth: (width * 1.5).toInt(),
              fadeInDuration: const Duration(milliseconds: 50),
              placeholderFadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              maxWidthDiskCache: 400,
              maxHeightDiskCache: 400,
              placeholder: (context, url) => const _ThumbnailPlaceholder(),
              errorWidget: (context, url, error) =>
                  const _ThumbnailPlaceholder(failed: true),
            ),
            MediaCardStatsOverlay(views: video.viewCount, comments: 0),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder({this.failed = false});

  final bool failed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFE0E0E0)),
        child: failed
            ? const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 32,
                  color: Color(0xFF9E9E9E),
                ),
              )
            : null,
      ),
    );
  }
}

/// 标题下面那一行：左边收藏数胶囊，右边作者署名。
///
/// 站内卡片这一行右边放的是发布时间——O3D 的列表接口不给时间，而作者又没有
/// 实体可点，正好落在这个「只读的次要信息」槽位里，两种卡片的行结构因此还是
/// 对齐的（胶囊 + 右对齐小字）。
///
/// 收藏数用实心心形但取 onSurfaceVariant 而不是站内那种粉色：粉色在站内表示
/// 「我点过赞」，这里只是站点统计，染成粉色会读成一个已经生效的操作。
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.favoriteCount, required this.author});

  final int favoriteCount;
  final String author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authorStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: 11,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            MediaCardStatChip(
              icon: Icons.favorite,
              value: CommonUtils.formatFriendlyNumber(
                favoriteCount < 0 ? 0 : favoriteCount,
              ),
              color: theme.colorScheme.onSurfaceVariant,
              maxTextWidth: (constraints.maxWidth - 90).clamp(24.0, 56.0),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                author,
                maxLines: 1,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: authorStyle,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 卡片最下面那排标签：最多三个，**永远只占一行**。
///
/// 这是 O3D 卡片相对站内卡片多出来的一块，也是唯一会把卡片撑高的一块：标签是
/// 变长文本，用 [Wrap] 就会按内容折行，几张卡片一高一矮，瀑布流立刻错开。所以
/// 这里自己量宽：先算出每个胶囊的实际宽度，贪心地放能放下的那几个，放不下的
/// 用一枚「…」胶囊代掉；连第一个都摆不下时，让它自己在剩余宽度里省略。
///
/// 行高与胶囊高度都由 [heightOf] 一处算出（跟着系统字体缩放走），标签为空时
/// 也照样留着这一行——不留就等于让「没有标签的视频」比别人矮一截。
class _Oreno3dTagStrip extends StatelessWidget {
  const _Oreno3dTagStrip({required this.tags});

  final List<String> tags;

  static const int _maxTags = 3;
  static const double _spacing = 4;
  static const double _chipHPadding = 6;
  static const double _chipVPadding = 2;
  static const double _fontSize = 10;
  static const double _lineHeight = 1.3;
  static const String _ellipsis = '…';

  /// 这一行的定高：字号乘行高再加上下内边距，跟着系统字体缩放走。
  static double heightOf(BuildContext context) {
    final scaled = MediaQuery.textScalerOf(context).scale(_fontSize);
    return scaled * _lineHeight + _chipVPadding * 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);
    final height = heightOf(context);
    final style = TextStyle(
      fontSize: _fontSize,
      height: _lineHeight,
      color: theme.colorScheme.onSurfaceVariant,
    );

    final labels = <String>[
      for (final tag in tags.take(_maxTags))
        Oreno3dLocalizationService.displayByName(tag),
    ];
    if (labels.isEmpty) return SizedBox(height: height);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final widths = [
            for (final label in labels)
              _chipWidth(label, style, scaler, textDirection),
          ];
          final ellipsisWidth = _chipWidth(
            _ellipsis,
            style,
            scaler,
            textDirection,
          );
          final shown = _fitCount(widths, ellipsisWidth, constraints.maxWidth);

          // 一个都摆不下：把第一个塞进剩余宽度里，让文字自己省略，
          // 总比整行空着强。
          if (shown == 0) {
            return Row(
              children: [
                Flexible(child: _chip(labels.first, style, theme, height)),
              ],
            );
          }

          return Row(
            children: [
              for (var i = 0; i < shown; i++) ...[
                if (i > 0) const SizedBox(width: _spacing),
                _chip(labels[i], style, theme, height),
              ],
              if (shown < labels.length) ...[
                const SizedBox(width: _spacing),
                _chip(_ellipsis, style, theme, height),
              ],
            ],
          );
        },
      ),
    );
  }

  /// 能完整摆下的标签数。摆不完时要给「…」那枚也留出位置，
  /// 所以只在 `k == labels.length` 时才按纯标签宽度判定。
  int _fitCount(List<double> widths, double ellipsisWidth, double maxWidth) {
    for (var k = widths.length; k >= 1; k--) {
      var total = 0.0;
      for (var i = 0; i < k; i++) {
        if (i > 0) total += _spacing;
        total += widths[i];
      }
      if (k < widths.length) total += _spacing + ellipsisWidth;
      if (total <= maxWidth) return k;
    }
    return 0;
  }

  double _chipWidth(
    String text,
    TextStyle style,
    TextScaler scaler,
    TextDirection textDirection,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width + _chipHPadding * 2;
  }

  Widget _chip(String text, TextStyle style, ThemeData theme, double height) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _chipHPadding),
          child: Center(
            widthFactor: 1,
            child: Text(
              text,
              style: style,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              strutStyle: const StrutStyle(
                fontSize: _fontSize,
                height: _lineHeight,
                forceStrutHeight: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
