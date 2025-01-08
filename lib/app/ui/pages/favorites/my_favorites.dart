import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/favorites/controllers/favorites_controller.dart';
import 'package:i_iwara/app/ui/pages/favorites/widgets/favorite_video_list.dart';
import 'package:i_iwara/app/ui/pages/favorites/widgets/favorite_image_list.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
class MyFavorites extends StatefulWidget {
  const MyFavorites({super.key});

  @override
  State<MyFavorites> createState() => _MyFavoritesState();
}

class _MyFavoritesState extends State<MyFavorites>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FavoritesController controller;
  final ScrollController _videoScrollController = ScrollController();
  final ScrollController _imageScrollController = ScrollController();
  // 记录上一次点击的tab索引
  int _lastTappedIndex = 0;

  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(FavoritesController());
    _tabController = TabController(length: 2, vsync: this);
    // 监听tab变化
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _videoScrollController.dispose();
    _imageScrollController.dispose();
    Get.delete<FavoritesController>();
    super.dispose();
  }

  void _handleTabChange() {
    // 只在动画完成时处理
    if (!_tabController.indexIsChanging) {
      _lastTappedIndex = _tabController.index;
    }
  }

  void _handleTabTap(int index) {
    // 只有点击当前已选中的tab时才触发刷新
    if (index == _lastTappedIndex) {
      if (index == 0) {
        _scrollToTopAndRefresh(controller.videoRepository);
      } else {
        _scrollToTopAndRefresh(controller.imageRepository);
      }
    }
  }

  Future<void> _scrollToTopAndRefresh(LoadingMoreBase repository) async {
    // 获取当前活动的ScrollController
    final ScrollController activeController = _tabController.index == 0
        ? _videoScrollController
        : _imageScrollController;

    // 检查ScrollController是否已附加并且有滚动位置
    if (!activeController.hasClients) {
      // 如果还没有附加，直接刷新数据
      isLoading.value = true;
      await repository.refresh();
      isLoading.value = false;
      return;
    }

    // 如果已经在顶部，直接刷新
    if (activeController.position.pixels == 0.0) {
      isLoading.value = true;
      await repository.refresh();
      isLoading.value = false;
    } else {
      // 否则先滚动到顶部，然后刷新
      activeController
          .animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      )
          .then((_) async {
        isLoading.value = true;
        await repository.refresh();
        isLoading.value = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.favorites.myFavorites),
        actions: [
          // 使用 GetBuilder 替代 Obx
          Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading.value
                    ? Container(
                        margin: const EdgeInsets.only(right: 16),
                        width: 20,
                        height: 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const SizedBox.shrink(),
              )),
          IconButton(
            onPressed: () {
              if (_tabController.index == 0) {
                _scrollToTopAndRefresh(controller.videoRepository);
              } else {
                _scrollToTopAndRefresh(controller.imageRepository);
              }
            },
            icon: const Icon(Icons.refresh),
            tooltip: t.common.refresh,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildTabBar(context),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FavoriteVideoList(scrollController: _videoScrollController),
          FavoriteImageList(scrollController: _imageScrollController),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final t = slang.Translations.of(context);
    return Container(
      width: 400,
      margin: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: _handleTabTap,
        // 使用Material 3风格的指示器
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).colorScheme.primary,
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        // 标签样式
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        // 取消标签的内边距，让整个区域都可点击
        padding: EdgeInsets.zero,
        tabs: [
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.video_library),
                  const SizedBox(width: 8),
                  Text(t.common.video),
                ],
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library),
                  const SizedBox(width: 8),
                  Text(t.common.gallery),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
