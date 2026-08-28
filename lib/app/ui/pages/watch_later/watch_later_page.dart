import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

/// 「稍后再看」列表页。
///
/// # 版式
///
/// header 两行，与历史记录页同一配方：
/// - 第一行：返回钮 / 标题 / 一枚动作钮（排序 + 一键清除已看完都收在它的菜单里）；
/// - 第二行：左边 `视频 | 图库` 类型段，右边 `全部 | 未看完` 筛选段。两段都用
///   [GlassAdaptiveSegmentedControl]，窄屏摆不下会各自退化成下拉钮，所以不需要
///   为小屏再多加一行 header。
///
/// ⛔ **没有"全部（视频图库混排）"这个视图**：类型是硬分家的两个 tab。混排唯一
/// 的用处是"播放全部"，而那个按钮已经砍掉了。
///
/// ⛔ **没有「播放全部」按钮**：进播放器靠点某一条 + 池内续播。
class WatchLaterPage extends StatefulWidget {
  const WatchLaterPage({super.key});

  @override
  State<WatchLaterPage> createState() => _WatchLaterPageState();
}

class _WatchLaterPageState extends State<WatchLaterPage>
    with SingleTickerProviderStateMixin {
  /// 标题行与分段行之间的间距（与历史记录页保持一致）。
  static const double _headerRowGap = 6;
  static const double _headerBottomGap = 10;

  late final TabController _tabController;
  final _configService = Get.find<ConfigService>();

  /// 「全部 / 未看完」。刻意**不持久化**：它是"我现在想看哪一批"的临时意图，
  /// 排序才是长期偏好。
  bool _unwatchedOnly = false;

  List<WatchLaterItem> _items = const [];

  @override
  void initState() {
    super.initState();
    // 默认落「视频」tab、不记忆上次：两个 tab 内容差异大，记忆会让人以为东西丢了。
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) _reload();
      });
    WatchLaterService.to.watchLaterChangedNotifier.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    WatchLaterService.to.watchLaterChangedNotifier.removeListener(_reload);
    _tabController.dispose();
    super.dispose();
  }

  WatchLaterItemType get _currentType => _tabController.index == 0
      ? WatchLaterItemType.video
      : WatchLaterItemType.image;

  WatchLaterSort get _sort => WatchLaterSort.fromConfigValue(
    _configService[ConfigKey.WATCH_LATER_SORT_KEY] as String?,
  );

  void _reload() {
    if (!mounted) return;
    setState(() {
      _items = WatchLaterService.to.query(
        itemType: _currentType,
        unwatchedOnly: _unwatchedOnly,
        sort: _sort,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    const headerHeight =
        GlassTokens.headerRowHeight +
        _headerRowGap +
        GlassTokens.pillHeight +
        _headerBottomGap;

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: statusBarHeight + headerHeight,
        headerTop: statusBarHeight,
        headerHeight: headerHeight,
        solidExtent: statusBarHeight,
        liquid: true,
        header: _buildHeader(context, t),
        body: TabBarView(
          controller: _tabController,
          physics: const ClampingScrollPhysics(),
          children: [
            _buildList(context, t, statusBarHeight + headerHeight),
            _buildList(context, t, statusBarHeight + headerHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, slang.Translations t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: GlassTokens.headerRowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: t.common.back,
                  onPressed: () => AppService.tryPop(),
                ),
                const SizedBox(width: 8),
                Expanded(child: GlassTitlePill(title: t.watchLater.title)),
                const SizedBox(width: 8),
                Builder(
                  builder: (buttonContext) => GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.more_horiz),
                    tooltip: t.common.operation,
                    opensOverlay: true,
                    onPressed: () => _openActionMenu(buttonContext, t),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: _headerRowGap),
        SizedBox(
          height: GlassTokens.pillHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // 两段都必须待在能读到实际可用宽度的位置（Row 的非 flex 子项
                // 拿到的是无限宽，退化判断会永远认为摆得下）。
                Expanded(
                  child: GlassAdaptiveSegmentedControl(
                    selectedIndex: _tabController.index,
                    progress: _tabController.animation,
                    onChanged: _tabController.animateTo,
                    items: [
                      GlassSegmentItem(label: t.common.video),
                      GlassSegmentItem(label: t.common.gallery),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GlassAdaptiveSegmentedControl(
                    selectedIndex: _unwatchedOnly ? 1 : 0,
                    onChanged: (index) {
                      setState(() => _unwatchedOnly = index == 1);
                      _reload();
                    },
                    items: [
                      GlassSegmentItem(label: t.watchLater.filterAll),
                      GlassSegmentItem(label: t.watchLater.filterUnwatched),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: _headerBottomGap),
      ],
    );
  }

  Future<void> _openActionMenu(
    BuildContext anchorContext,
    slang.Translations t,
  ) async {
    final sort = _sort;
    final selected = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        GlassMenuSectionHeader(t.common.sort),
        GlassMenuOption<String>(
          value: WatchLaterSort.recentlyAdded.name,
          label: t.watchLater.sortRecentlyAdded,
          icon: Icons.arrow_downward,
          selected: sort == WatchLaterSort.recentlyAdded,
        ),
        GlassMenuOption<String>(
          value: WatchLaterSort.earliestAdded.name,
          label: t.watchLater.sortEarliestAdded,
          icon: Icons.arrow_upward,
          selected: sort == WatchLaterSort.earliestAdded,
        ),
        const GlassMenuSeparator(),
        GlassMenuOption<String>(
          value: '__clear_watched__',
          label: t.watchLater.clearWatched,
          icon: Icons.cleaning_services_outlined,
          destructive: true,
        ),
      ],
    );
    if (selected == null || !mounted) return;

    if (selected == '__clear_watched__') {
      // 批量物理删除、且没有 undo，必须先问一句——本项目的原则是"点一下东西
      // 就消失很惊悚"，批量版本只会更惊悚。
      final confirmed = await showAppDialog<bool>(
        Builder(
          builder: (dialogContext) => GlassAlertDialog(
            title: t.watchLater.clearWatched,
            content: Text(t.watchLater.clearWatchedConfirm),
            actions: [
              GlassDialogAction(
                label: t.common.cancel,
                emphasized: false,
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
              GlassDialogAction(
                label: t.common.confirm,
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
            ],
          ),
        ),
      );
      if (confirmed != true || !mounted) return;

      final removed = WatchLaterService.to.clearWatched(
        itemType: _currentType,
      );
      showGlassToast(
        removed > 0
            ? t.watchLater.watchedCleared(count: removed)
            : t.watchLater.noWatchedToClear,
        type: removed > 0 ? GlassToastType.success : GlassToastType.info,
      );
      return;
    }

    _configService.setSetting(ConfigKey.WATCH_LATER_SORT_KEY, selected);
    _reload();
  }

  Widget _buildList(
    BuildContext context,
    slang.Translations t,
    double topInset,
  ) {
    if (_items.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: topInset),
        child: MyEmptyWidget(
          // 「未看完」筛掉之后的空，和"一条都没加过"不是一回事——
          // 后者说"还没有加入"是误导。
          message: _unwatchedOnly
              ? (_currentType == WatchLaterItemType.video
                    ? t.watchLater.emptyUnwatchedVideo
                    : t.watchLater.emptyUnwatchedGallery)
              : (_currentType == WatchLaterItemType.video
                    ? t.watchLater.emptyVideo
                    : t.watchLater.emptyGallery),
        ),
      );
    }

    return ListView.builder(
      // ⛔ 不写 padding 会白继承 MediaQuery 的竖直 padding，首屏被 header 盖住。
      padding: EdgeInsets.only(
        top: topInset,
        bottom: MediaQuery.paddingOf(context).bottom + 24,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Dismissible(
          key: ValueKey('${item.itemType.name}:${item.itemId}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: Theme.of(context).colorScheme.errorContainer,
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          onDismissed: (_) {
            WatchLaterService.to.remove(item.itemId, item.itemType);
            // 误滑一条就没了太糙——toast 本来就支持挂动作钮（F12），给个撤销。
            showGlassToast(
              t.watchLater.removedFromWatchLater,
              type: GlassToastType.info,
              actionLabel: t.watchLater.undo,
              onAction: () {
                WatchLaterService.to.restore(item);
                dismissGlassToasts();
              },
            );
          },
          child: _WatchLaterTile(item: item),
        );
      },
    );
  }
}

/// 一条稍后再看。
///
/// 失效的条目**不会静默消失**：继续用本地快照把卡片画出来，整只压暗并挂一枚
/// 「已失效」角标，点它只弹提示而不进播放器。既然定了"只标记不自动删"，就得
/// 让人一眼看出这条是死的，否则列表里会躺着一堆点了没反应的卡片。
class _WatchLaterTile extends StatelessWidget {
  const _WatchLaterTile({required this.item});

  final WatchLaterItem item;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        if (item.isInvalid) {
          showGlassToast(t.watchLater.invalidItem, type: GlassToastType.warning);
          return;
        }
        if (item.itemType == WatchLaterItemType.video) {
          NaviService.navigateToVideoDetailPage(item.itemId);
        } else {
          NaviService.navigateToGalleryDetailPage(item.itemId);
        }
      },
      child: Opacity(
        // 失效项整只压暗。这里用 Opacity 是安全的：本行不是玻璃体，
        // 不存在"打断折射"的问题。
        opacity: item.isInvalid ? 0.45 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(context, cs),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty ? t.common.noTitle : item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if ((item.author ?? '').isNotEmpty)
                      Text(
                        item.author!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (item.isInvalid)
                          _Badge(
                            label: t.watchLater.invalidItem,
                            color: cs.error,
                          )
                        else if (item.isWatched)
                          // ⛔ 别拿「未看完」的文案划一道删除线来表示"已看完"：
                          // 读屏会直接念出"未看完"，语义正好相反。
                          _Badge(
                            label: t.watchLater.watched,
                            color: cs.onSurfaceVariant,
                          ),
                        if (item.numImages != null)
                          Text(
                            '${item.numImages}',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, ColorScheme cs) {
    final radius = BorderRadius.circular(8);
    return SizedBox(
      width: 132,
      height: 74,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: cs.surfaceContainerHighest),
            if ((item.thumbnailUrl ?? '').isNotEmpty)
              CachedNetworkImage(
                imageUrl: item.thumbnailUrl!,
                fit: BoxFit.cover,
                // 视频被删掉之后 CDN 上的封面也可能 404，得有占位兜底，
                // 否则失效项会变成一块破图。
                errorWidget: (context, url, error) => Icon(
                  Icons.broken_image_outlined,
                  color: cs.onSurfaceVariant,
                ),
              ),
            if (item.durationMs != null)
              Positioned(
                right: 4,
                bottom: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    child: Text(
                      CommonUtils.formatDuration(
                        Duration(milliseconds: item.durationMs!),
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            // 观看进度条：贴着封面下沿，和播放器里的进度条读起来是同一件事。
            if (item.progressRatio > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: item.progressRatio,
                  minHeight: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ),
      ),
    );
  }
}
