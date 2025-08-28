import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/favorite/favorite_item.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class FavoriteFolderDetailPage extends StatefulWidget {
  final String folderId;
  final String? folderTitle;

  const FavoriteFolderDetailPage({
    super.key,
    required this.folderId,
    this.folderTitle,
  });

  @override
  State<FavoriteFolderDetailPage> createState() => _FavoriteFolderDetailPageState();
}

class _FavoriteFolderDetailPageState extends State<FavoriteFolderDetailPage> {
  late final FavoriteItemRepository _repository;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _tagSearchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _repository = FavoriteItemRepository(widget.folderId);
    _searchController.addListener(() {
      setState(() {
        _repository.searchText = _searchController.text;
        _repository.refresh();
      });
    });
    _tagSearchController.addListener(() {
      setState(() {
        _repository.tagSearch = _tagSearchController.text;
        _repository.refresh();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tagSearchController.dispose();
    _repository.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _repository.startDate = picked.start;
        _repository.endDate = picked.end;
        _repository.refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderTitle ?? ''),
      ),
      body: Column(
        children: [
          // 搜索和时间筛选区域
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // 搜索框
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: slang.t.favorite.searchItems,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 标签搜索按钮
                Material(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => _showTagSearchBottomSheet(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tag,
                            size: 24,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          if (_repository.tagSearch?.isNotEmpty == true) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.clear,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 日期选择按钮
                Material(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: _selectDateRange,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            size: 24,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          if (_selectedDateRange != null) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.clear,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 显示选中的时间范围、搜索文本和标签
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_selectedDateRange != null)
                  _buildFilterChip(
                    icon: Icons.date_range,
                    text: '${CommonUtils.formatDate(_selectedDateRange!.start)} - ${CommonUtils.formatDate(_selectedDateRange!.end)}',
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    onTap: () {
                      setState(() {
                        _selectedDateRange = null;
                        _repository.startDate = null;
                        _repository.endDate = null;
                        _repository.refresh();
                      });
                    },
                  ),
                if (_searchController.text.isNotEmpty)
                  _buildFilterChip(
                    icon: Icons.search,
                    text: _searchController.text,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  ),
                if (_tagSearchController.text.isNotEmpty)
                  _buildFilterChip(
                    icon: Icons.tag,
                    text: _tagSearchController.text,
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    onTap: () {
                      setState(() {
                        _tagSearchController.clear();
                      });
                    },
                  ),
              ],
            ),
          ),
          // 列表内容
          Expanded(
            child: LoadingMoreCustomScrollView(
              slivers: <Widget>[
                LoadingMoreSliverList(
                  SliverListConfig<FavoriteItem>(
                    extendedListDelegate:
                        SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: MediaQuery.of(context).size.width <= 600 ? MediaQuery.of(context).size.width / 2 : 200,
                      crossAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
                      mainAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
                    ),
                    itemBuilder: (BuildContext context, FavoriteItem item, int index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
                          vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
                        ),
                        child: _buildFavoriteItem(item),
                      );
                    },
                    sourceList: _repository,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
                      right: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
                      top: MediaQuery.of(context).size.width <= 600 ? 2.0 : 3.0,
                      bottom: Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0,
                    ),
                    lastChildLayoutType: LastChildLayoutType.foot,
                    indicatorBuilder: _buildIndicator,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(FavoriteItem item) {
    final width = MediaQuery.of(context).size.width <= 600 
        ? MediaQuery.of(context).size.width / 2 - 8 
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
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width < 600 ? 6 : 8)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VideoCardListItemWidget(
                    video: video,
                    width: width,
                  ),
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
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width < 600 ? 6 : 8)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageModelCardListItemWidget(
                    imageModel: image,
                    width: width,
                  ),
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                    Icon(
                      icon,
                      size: 12,
                      color: color,
                    ),
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
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width < 600 ? 6 : 8)
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
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
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
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width < 600 ? 6 : 8)
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
                AvatarWidget(
                  user: user,
                  size: 24
                ),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
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

  Widget? _buildIndicator(BuildContext context, IndicatorStatus status) {
    Widget? widget;
    
    switch (status) {
      case IndicatorStatus.none:
        return null;
      case IndicatorStatus.loadingMoreBusying:
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
            vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: _buildShimmerItem(MediaQuery.of(context).size.width <= 600 ? 180 : 200),
          ),
        );
      case IndicatorStatus.fullScreenBusying:
        widget = Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: MediaQuery.of(context).size.width <= 600 ? 180 : 200,
              crossAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
              mainAxisSpacing: MediaQuery.of(context).size.width <= 600 ? 4 : 5,
              childAspectRatio: 1,
            ),
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
              right: MediaQuery.of(context).size.width <= 600 ? 2.0 : 5.0,
              top: MediaQuery.of(context).size.width <= 600 ? 2.0 : 3.0,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => _buildShimmerItem(MediaQuery.of(context).size.width <= 600 ? 180 : 200),
          ),
        );
        return SliverFillRemaining(child: widget);
      case IndicatorStatus.error:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.errorContainer,
            child: InkWell(
              onTap: () => _repository.errorRefresh(),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      slang.t.conversation.errors.loadFailedClickToRetry,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      case IndicatorStatus.fullScreenError:
        widget = Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.errorContainer,
          child: InkWell(
            onTap: () => _repository.errorRefresh(),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    slang.t.conversation.errors.loadFailed,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slang.t.conversation.errors.clickToRetry,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget,
            ),
          ),
        );
      case IndicatorStatus.noMoreLoad:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              slang.t.common.noMoreDatas,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        );
      case IndicatorStatus.empty:
        widget = Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open,
                size: 48,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 16),
              Text(
                slang.t.common.noData,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: widget),
        );
    }
  }

  Widget _buildShimmerItem(double width) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        width: width,
        height: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 缩略图区域
            Container(
              width: width,
              height: width * 9 / 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            // 标题区域
            Container(
              width: width * 0.8,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            // 信息区域
            Container(
              width: width * 0.6,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeItem(FavoriteItem item) async {
    final t = slang.Translations.of(context);
    final result = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    t.favorite.removeItemTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(t.favorite.removeItemConfirmWithTitle(title: item.title)),
                ],
              ),
            ),
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(t.common.cancel),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      t.common.confirm,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final success = await FavoriteService.to.removeFromFolder(item.id);
        if (success) {
          _repository.refresh();
          if (mounted) {
            showToastWidget(
              MDToastWidget(
                message: t.favorite.removeItemSuccess,
                type: MDToastType.success,
              ),
            );
          }
        } else {
          throw Exception('删除失败');
        }
      } catch (e) {
        if (mounted) {
          showToastWidget(
            MDToastWidget(
              message: t.favorite.removeItemFailed,
              type: MDToastType.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTagSearchBottomSheet(BuildContext context) {
    final t = slang.Translations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.favorite.searchTags,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (_repository.tagSearch?.isNotEmpty == true)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _tagSearchController.clear();
                          _repository.tagSearch = null;
                          _repository.refresh();
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.clear),
                      label: Text(t.common.clear),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tagSearchController,
                decoration: InputDecoration(
                  hintText: t.favorite.searchTags,
                  prefixIcon: const Icon(Icons.tag),
                ),
                autofocus: true,
                onSubmitted: (value) {
                  setState(() {
                    _repository.tagSearch = value;
                    _repository.refresh();
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.common.cancel),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _repository.tagSearch = _tagSearchController.text;
                        _repository.refresh();
                      });
                      Navigator.pop(context);
                    },
                    child: Text(t.common.confirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteItemRepository extends LoadingMoreBase<FavoriteItem> {
  final String folderId;
  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;
  
  String? searchText;
  String? tagSearch;
  DateTime? startDate;
  DateTime? endDate;
  
  static const int pageSize = 20;
  
  FavoriteItemRepository(this.folderId);
  
  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _pageIndex = 0;
    forceRefresh = !notifyStateChanged;
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    try {
      final items = await FavoriteService.to.getFolderItems(
        folderId,
        offset: _pageIndex * pageSize,
        limit: pageSize,
        searchText: searchText,
        tagSearch: tagSearch,
        startDate: startDate,
        endDate: endDate,
      );

      if (_pageIndex == 0) {
        clear();
      }

      addAll(items);

      _hasMore = items.length >= pageSize;
      _pageIndex++;
      isSuccess = true;
    } catch (e) {
      isSuccess = false;
    }
    return isSuccess;
  }
} 