import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import '../../../../models/image.model.dart';
import '../../../../models/tag.model.dart';
import '../../../../utils/show_app_dialog.dart';
import '../../popular_media_list/widgets/popular_media_search_config_widget.dart';
import '../controllers/userz_image_model_list_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';

class ProfileImageModelTabListWidget extends StatefulWidget {
  final String tabKey;
  final TabController tc;

  /// 上方被页面级 header（主 Tab 行）占掉的高度；本 widget 的排序行叠在它下面。
  final double overlayTopInset;

  /// 顶部蒙层平台段（状态栏）高度。
  final double scrimSolidExtent;
  final String userId;
  final Function({int? count})? onFetchFinished;
  final bool isMultiSelectMode;
  final Set<String> selectedItemIds;
  final Function(ImageModel image)? onItemSelect;
  final VoidCallback? onPageChanged;
  final bool isPaginated;
  final VoidCallback? onPaginationToggle;
  final VoidCallback? onMultiSelectToggle;

  const ProfileImageModelTabListWidget({
    super.key,
    required this.tabKey,
    required this.tc,
    required this.userId,
    this.overlayTopInset = 0,
    this.scrimSolidExtent = 0,
    this.onFetchFinished,
    this.isMultiSelectMode = false,
    this.selectedItemIds = const {},
    this.onItemSelect,
    this.onPageChanged,
    this.isPaginated = false,
    this.onPaginationToggle,
    this.onMultiSelectToggle,
  });

  @override
  State<ProfileImageModelTabListWidget> createState() =>
      _ProfileImageModelTabListWidgetState();
}

class _ProfileImageModelTabListWidgetState
    extends State<ProfileImageModelTabListWidget>
    with AutomaticKeepAliveClientMixin {
  late UserzImageModelListRepository imageListRepository;

  /// 带回执的刷新信号：header 上的刷新钮据此在刷完前显示沙漏。
  final ListRefreshSignal _refreshSignal = ListRefreshSignal();

  /// 标签 / 日期筛选。与视频 tab 一致，作者页不提供评级筛选——服务端在带
  /// `user=` 的查询里会忽略 `rating`。
  List<Tag> _filterTags = [];
  String _filterDate = '';

  bool get _hasFilter => _filterTags.isNotEmpty || _filterDate.isNotEmpty;

  String getSort() {
    switch (widget.tc.index) {
      case 0:
        return 'date';
      case 1:
        return 'likes';
      case 2:
        return 'views';
      case 3:
        return 'popularity';
      case 4:
        return 'trending';
      default:
        return 'date';
    }
  }

  @override
  void initState() {
    super.initState();
    widget.tc.addListener(_handleTabSelection);
    _initRepository();
  }

  void _initRepository() {
    imageListRepository = UserzImageModelListRepository(
      userId: widget.userId,
      sortType: getSort(),
      searchTagIds: _filterTags.map((tag) => tag.id).toList(),
      searchDate: _filterDate,
      onFetchFinished: widget.onFetchFinished,
    );
    LogUtils.d(
      '[详情图片列表] 初始化，当前的用户ID是：${widget.userId}, 排序是：${getSort()}, '
      '标签：${_filterTags.map((e) => e.id).join(',')}, 日期：$_filterDate',
    );
  }

  /// 打开筛选弹窗；确认后按「切换排序」同样的方式重建数据源。
  void _openFilterDialog() {
    showAppDialog(
      PopularMediaSearchConfig(
        searchTags: _filterTags,
        searchYear: _filterDate,
        searchRating: '',
        showRating: false,
        onConfirm: (tags, year, rating, _) {
          if (!mounted) return;
          setState(() {
            _filterTags = tags;
            _filterDate = year;
            imageListRepository.dispose();
            _initRepository();
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.tc.removeListener(_handleTabSelection);
    _refreshSignal.dispose();
    imageListRepository.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (widget.tc.indexIsChanging) {
      setState(() {
        imageListRepository.dispose();
        _initRepository();
      });
      LogUtils.d('[详情图片列表] 切换排序，当前选择的是：${widget.tc.index}, 排序是：${getSort()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = slang.Translations.of(context);
    final sortItems = <GlassSegmentItem>[
      GlassSegmentItem(
        label: t.common.latest,
        icon: const Icon(Icons.calendar_today),
      ),
      GlassSegmentItem(
        label: t.common.likesCount,
        icon: const Icon(Icons.favorite),
      ),
      GlassSegmentItem(
        label: t.common.viewsCount,
        icon: const Icon(Icons.remove_red_eye),
      ),
      GlassSegmentItem(label: t.common.popular, icon: const Icon(Icons.star)),
      GlassSegmentItem(
        label: t.common.trending,
        icon: const Icon(Icons.trending_up),
      ),
    ];
    // 排序行叠在页面级主 Tab 行下面，列表从它们背后经过
    const double sortRowHeight = GlassTokens.pillHeight + 12;
    final double headerExtent = widget.overlayTopInset + sortRowHeight;
    return GlassHeaderOverlay(
      headerExtent: headerExtent,
      headerTop: widget.overlayTopInset,
      headerHeight: sortRowHeight,
      solidExtent: widget.scrimSolidExtent,
      body: MediaListView<ImageModel>(
        paddingTop: headerExtent,
        sourceList: imageListRepository,
        isPaginated: widget.isPaginated,
        refreshSignal: _refreshSignal,
        emptyIcon: Icons.image_outlined,
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, image, index) {
          return Obx(() {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
                vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
              ),
              child: ImageModelCardListItemWidget(
                imageModel: image,
                width: MediaQuery.of(context).size.width <= 600
                    ? MediaQuery.of(context).size.width / 2 - 8
                    : 200,
                disableBlock: true,
                isMultiSelectMode: widget.isMultiSelectMode,
                isSelected: widget.selectedItemIds.contains(image.id),
                onSelect: () => widget.onItemSelect?.call(image),
              ),
            );
          });
        },
      ),
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: GlassSegmentedControl(
                  selectedIndex: widget.tc.index,
                  progress: widget.tc.animation,
                  onChanged: widget.tc.animateTo,
                  items: sortItems,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GlassButtonGroup(
              children: [
                GlassIconButton(
                  icon: const Icon(Icons.filter_list),
                  showBadge: _hasFilter,
                  tooltip: t.searchFilter.filterSettings,
                  onPressed: _openFilterDialog,
                ),
                GlassIconButton(
                  icon: Icon(
                    widget.isMultiSelectMode ? Icons.close : Icons.checklist,
                  ),
                  tooltip: widget.isMultiSelectMode
                      ? t.common.exitEditMode
                      : t.common.editMode,
                  onPressed: widget.onMultiSelectToggle,
                ),
                GlassIconButton(
                  icon: Icon(
                    widget.isPaginated ? Icons.grid_view : Icons.view_stream,
                  ),
                  tooltip: widget.isPaginated
                      ? t.common.pagination.waterfall
                      : t.common.pagination.pagination,
                  onPressed: widget.onPaginationToggle,
                ),
                GlassAsyncIconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: t.common.refresh,
                  onPressed: _refreshSignal.request,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
