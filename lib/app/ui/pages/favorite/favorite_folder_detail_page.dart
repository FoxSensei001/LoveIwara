import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/favorite/favorite_item.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/pages/favorite/widgets/folder_tag_filter.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 本地收藏夹详情：夹内作品列表（玻璃化 + 瀑布/分页双模式）。
class FavoriteFolderDetailPage extends StatefulWidget {
  final String folderId;
  final String? folderTitle;

  const FavoriteFolderDetailPage({
    super.key,
    required this.folderId,
    this.folderTitle,
  });

  @override
  State<FavoriteFolderDetailPage> createState() =>
      _FavoriteFolderDetailPageState();
}

class _FavoriteFolderDetailPageState extends State<FavoriteFolderDetailPage> {
  late final FavoriteItemRepository _repository;
  final ScrollController _scrollController = ScrollController();

  /// 外部刷新信号：分页模式必须由 MediaListView 自己刷新，
  /// 直接 `repository.refresh()` 只会动数据源、不会换掉当前显示的那一页。
  final ValueNotifier<int> _refreshSignal = ValueNotifier<int>(0);

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  late bool _isPaginated = CommonConstants.isPaginated;

  _FavoriteFilter _filter = const _FavoriteFilter();

  @override
  void initState() {
    super.initState();
    _repository = FavoriteItemRepository(widget.folderId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshSignal.dispose();
    _showBackToTop.dispose();
    _repository.dispose();
    super.dispose();
  }

  void _refreshList() => _refreshSignal.value++;

  void _togglePaginationMode() {
    setState(() => _isPaginated = !_isPaginated);
    persistPaginationMode(_isPaginated);
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_FavoriteFilter>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) =>
          _FavoriteFilterSheet(initial: _filter, folderId: widget.folderId),
    );
    if (result == null || !mounted) return;

    setState(() {
      _filter = result;
      _repository.searchText = result.searchText;
      _repository.tagIds = result.tags.map((tag) => tag.id).toList();
      _repository.startDate = result.dateRange?.start;
      _repository.endDate = result.dateRange?.end;
    });
    _refreshList();
  }

  /// 右侧动作胶囊：筛选（生效时带红点）· 瀑布/分页。
  ///
  /// 没有刷新键：本地收藏是本地库，只会被 App 自己的操作改动（增删、筛选都会
  /// 就地刷新列表），留一个手动刷新纯属占位；真要重拉还有下拉刷新。
  Widget _buildActionGroup(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassButtonGroup(
      children: [
        GlassIconButton(
          icon: const Icon(Icons.filter_list),
          showBadge: _filter.isActive,
          tooltip: t.searchFilter.filterSettings,
          onPressed: _openFilterSheet,
        ),
        GlassIconButton(
          icon: Icon(_isPaginated ? Icons.grid_view : Icons.view_stream),
          tooltip: _isPaginated
              ? t.common.pagination.waterfall
              : t.common.pagination.pagination,
          onPressed: _togglePaginationMode,
        ),
      ],
    );
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮；分页模式下抬到分页栏之上。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 16,
      bottom:
          computeBottomSafeInset(MediaQuery.of(context)) +
          16 +
          (_isPaginated ? PaginationBar.barHeight : 0),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (context, visible, _) => IgnorePointer(
          ignoring: !visible,
          child: AnimatedSlide(
            duration: GlassTokens.motionDuration,
            curve: GlassTokens.motionCurve,
            offset: visible ? Offset.zero : const Offset(0, 0.4),
            child: AnimatedOpacity(
              duration: GlassTokens.motionDuration,
              opacity: visible ? 1 : 0,
              child: GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.vertical_align_top),
                tooltip: t.common.scrollToTop,
                onPressed: _scrollToTop,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    final bool isNarrow = MediaQuery.sizeOf(context).width <= 600;
    final double maxCrossAxisExtent = isNarrow
        ? MediaQuery.sizeOf(context).width / 2
        : 200;

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        liquid: true,
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.depth == 0 &&
                notification.metrics.axis == Axis.vertical) {
              _showBackToTop.value = notification.metrics.pixels >= 300;
            }
            return false;
          },
          child: MediaListView<FavoriteItem>(
            sourceList: _repository,
            isPaginated: _isPaginated,
            refreshSignal: _refreshSignal,
            scrollController: _scrollController,
            paddingTop: headerExtent,
            emptyIcon: Icons.folder_open,
            extendedListDelegate:
                SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                  crossAxisSpacing: isNarrow ? 4 : 5,
                  mainAxisSpacing: isNarrow ? 4 : 5,
                ),
            itemBuilder: (context, item, index) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 2 : 0,
                vertical: isNarrow ? 2 : 3,
              ),
              child: _buildFavoriteItem(item),
            ),
          ),
        ),
        // header 行：左 返回圆钮 / 中 收藏夹标题胶囊 / 右 动作胶囊
        header: Padding(
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
              Expanded(
                child: GlassTitlePill(
                  title: (widget.folderTitle?.isEmpty ?? true)
                      ? t.favorite.localizeFavorite
                      : widget.folderTitle,
                ),
              ),
              const SizedBox(width: 8),
              _buildActionGroup(context),
            ],
          ),
        ),
        extra: [_buildScrollToTopFab(context)],
      ),
    );
  }

  Widget _buildFavoriteItem(FavoriteItem item) {
    final width = MediaQuery.sizeOf(context).width <= 600
        ? MediaQuery.sizeOf(context).width / 2 - 8
        : 200.0;

    switch (item.itemType) {
      case FavoriteItemType.video:
        if (item.extData != null) {
          final video = Video.fromJson(item.extData!);
          return SizedBox(
            width: width,
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  MediaQuery.sizeOf(context).width < 600 ? 6 : 8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VideoCardListItemWidget(video: video, width: width),
                  _buildItemFooter(item),
                ],
              ),
            ),
          );
        }
        return _buildErrorItem(width);
      case FavoriteItemType.image:
        if (item.extData != null) {
          final image = ImageModel.fromJson(item.extData!);
          return SizedBox(
            width: width,
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  MediaQuery.sizeOf(context).width < 600 ? 6 : 8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageModelCardListItemWidget(imageModel: image, width: width),
                  _buildItemFooter(item),
                ],
              ),
            ),
          );
        }
        return _buildErrorItem(width);
      case FavoriteItemType.user:
        return _buildUserItem(item, width);
    }
  }

  Widget _buildItemFooter(FavoriteItem item) {
    // 获取类型对应的颜色和图标
    final (color, icon) = _getItemTypeStyle(item.itemType);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 显示时间
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Text(
                CommonUtils.formatFriendlyTimestamp(item.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // 显示类型
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      _getItemTypeText(item.itemType),
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 删除按钮
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => _removeItem(item),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getItemTypeStyle(FavoriteItemType type) {
    switch (type) {
      case FavoriteItemType.video:
        return (Colors.blue, Icons.play_circle_outline);
      case FavoriteItemType.image:
        return (Colors.green, Icons.image_outlined);
      case FavoriteItemType.user:
        return (Colors.orange, Icons.person_outline);
    }
  }

  String _getItemTypeText(FavoriteItemType type) {
    switch (type) {
      case FavoriteItemType.video:
        return slang.t.common.video;
      case FavoriteItemType.image:
        return slang.t.common.gallery;
      case FavoriteItemType.user:
        return slang.t.common.user;
    }
  }

  Widget _buildErrorItem(double width) {
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            MediaQuery.sizeOf(context).width < 600 ? 6 : 8,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                slang.t.errors.failedToFetchData,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(FavoriteItem item, double width) {
    final user = item.extData != null ? User.fromJson(item.extData!) : null;

    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            MediaQuery.sizeOf(context).width < 600 ? 6 : 8,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (user != null) {
              NaviService.navigateToAuthorProfilePage(user.username);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                AvatarWidget(user: user, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user?.premium == true)
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.purple.shade300,
                              Colors.blue.shade300,
                              Colors.pink.shade300,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            user?.name ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        Text(
                          user?.name ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user?.username ?? ''}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeItem(item),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _removeItem(FavoriteItem item) async {
    final t = slang.Translations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => GlassAlertDialog(
        title: t.favorite.removeItemTitle,
        content: Text(t.favorite.removeItemConfirmWithTitle(title: item.title)),
        actions: [
          GlassDialogAction(
            label: t.common.cancel,
            emphasized: false,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          GlassDialogAction(
            label: t.common.confirm,
            emphasized: false,
            destructive: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      final success = await FavoriteService.to.removeFromFolder(item.id);
      if (!success) throw Exception('删除失败');
      _refreshList();
      if (!mounted) return;
      showGlassToast(
        t.favorite.removeItemSuccess,
        type: GlassToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showGlassToast(t.favorite.removeItemFailed, type: GlassToastType.error);
    }
  }
}

/// 收藏夹内容筛选条件（标题关键字 / 标签 / 时间范围）。
class _FavoriteFilter {
  const _FavoriteFilter({
    this.searchText,
    this.tags = const [],
    this.dateRange,
  });

  final String? searchText;

  /// 已选标签，多选为 AND 语义（作品需同时带上全部标签）。
  final List<Tag> tags;

  final DateTimeRange? dateRange;

  bool get isActive =>
      (searchText?.isNotEmpty ?? false) || tags.isNotEmpty || dateRange != null;
}

/// 筛选弹窗：一次改完关键字 / 标签 / 时间范围再应用，避免逐字符触发重查。
class _FavoriteFilterSheet extends StatefulWidget {
  const _FavoriteFilterSheet({required this.initial, required this.folderId});

  final _FavoriteFilter initial;
  final String folderId;

  @override
  State<_FavoriteFilterSheet> createState() => _FavoriteFilterSheetState();
}

class _FavoriteFilterSheetState extends State<_FavoriteFilterSheet> {
  late final TextEditingController _searchController = TextEditingController(
    text: widget.initial.searchText,
  );
  late List<Tag> _tags = List<Tag>.from(widget.initial.tags);
  late DateTimeRange? _dateRange = widget.initial.dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked == null || !mounted) return;
    setState(() => _dateRange = picked);
  }

  void _apply() {
    Navigator.of(context).pop(
      _FavoriteFilter(
        searchText: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        tags: _tags,
        dateRange: _dateRange,
      ),
    );
  }

  Widget _glassField(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: GlassTokens.fill(colorScheme),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: GlassTokens.stroke(colorScheme),
          width: GlassTokens.strokeWidth,
        ),
      ),
      child: child,
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: computeSheetBottomInset(context)),
      // 标签区把弹窗撑高了：限高 + 只让中间内容滚动，标题行与确认行常驻可见
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题行：标题 + 玻璃关闭圆钮
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.searchFilter.filterSettings,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.close),
                    tooltip: t.common.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _glassField(
                        context,
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.done,
                          decoration: _fieldDecoration(
                            context,
                            hint: t.favorite.searchItems,
                            icon: Icons.search,
                          ),
                          onSubmitted: (_) => _apply(),
                        ),
                      ),
                    ),
                    // 时间范围：点按选择，已选中时右侧给一个清除钮
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: _glassField(
                        context,
                        child: InkWell(
                          onTap: _pickDateRange,
                          borderRadius: BorderRadius.circular(22),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.date_range,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _dateRange == null
                                        ? t.common.selectDateRange
                                        : '${CommonUtils.formatDate(_dateRange!.start)} - '
                                              '${CommonUtils.formatDate(_dateRange!.end)}',
                                    style: TextStyle(
                                      color: _dateRange == null
                                          ? colorScheme.onSurfaceVariant
                                          : colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_dateRange != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    tooltip: t.common.clearDateRange,
                                    onPressed: () =>
                                        setState(() => _dateRange = null),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: FolderTagFilter(
                        folderId: widget.folderId,
                        selectedTags: _tags,
                        onChanged: (tags) => setState(() => _tags = tags),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _tags = [];
                        _dateRange = null;
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    label: Text(t.searchFilter.clearAll),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _apply,
                    child: Text(t.common.confirm),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 收藏夹内容数据源。
///
/// 走 [ExtendedLoadingMoreBase] 是为了拿到 `loadPageData` / `requestTotalCount`
/// 这套分页契约——[MediaListView] 的分页模式依赖它，普通 `LoadingMoreBase`
/// 只能跑瀑布流。
class FavoriteItemRepository extends ExtendedLoadingMoreBase<FavoriteItem> {
  final String folderId;

  String? searchText;

  /// 已选标签 id，多个为 AND 语义。
  List<String> tagIds = const [];

  DateTime? startDate;
  DateTime? endDate;

  FavoriteItemRepository(this.folderId);

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final items = await FavoriteService.to.getFolderItems(
      folderId,
      offset: page * limit,
      limit: limit,
      searchText: searchText,
      tagIds: tagIds,
      startDate: startDate,
      endDate: endDate,
    );
    final count = await FavoriteService.to.countFolderItems(
      folderId,
      searchText: searchText,
      tagIds: tagIds,
      startDate: startDate,
      endDate: endDate,
    );
    return {'items': items, 'count': count};
  }

  @override
  List<FavoriteItem> extractDataList(Map<String, dynamic> response) =>
      response['items'] as List<FavoriteItem>;

  @override
  int extractTotalCount(Map<String, dynamic> response) =>
      response['count'] as int;

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e(
      '加载收藏夹内容失败: $message',
      error: error,
      stack: stackTrace,
      tag: 'FavoriteItemRepository',
    );
  }
}
