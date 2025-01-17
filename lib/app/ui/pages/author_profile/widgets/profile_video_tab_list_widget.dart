import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import '../../../../models/video.model.dart';
import '../../popular_media_list/widgets/video_tile_list_item_widget.dart';
import '../controllers/userz_video_list_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ProfileVideoTabListWidget extends StatefulWidget {
  final String tabKey;
  final TabController tc;
  final String userId;
  final Function({int? count})? onFetchFinished;

  const ProfileVideoTabListWidget({
    super.key,
    required this.tabKey,
    required this.tc,
    required this.userId,
    this.onFetchFinished,
  });

  @override
  _ProfileVideoTabListWidgetState createState() =>
      _ProfileVideoTabListWidgetState();
}

class _ProfileVideoTabListWidgetState extends State<ProfileVideoTabListWidget>
    with AutomaticKeepAliveClientMixin {
  final String uniqueKey = UniqueKey().toString();
  late UserzVideoListController videoListController;
  late ScrollController _tabBarScrollController;

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
    videoListController = Get.put(
      UserzVideoListController(onFetchFinished: widget.onFetchFinished),
      tag: uniqueKey,
    );
    _tabBarScrollController = ScrollController();
    LogUtils.d('[详情视频列表] 初始化，当前的用户ID是：${widget.userId}, 排序是：${getSort()}');
    videoListController.userId.value = widget.userId;
    videoListController.sort.value = getSort();
  }

  @override
  void dispose() {
    widget.tc.removeListener(_handleTabSelection);
    Get.delete<UserzVideoListController>(tag: uniqueKey);
    _tabBarScrollController.dispose();
    super.dispose();
  }

  // 获取当前选择的
  void _handleTabSelection() {
    if (widget.tc.indexIsChanging) {
      videoListController.sort.value = getSort();

      LogUtils.d('[详情视频列表] 切换排序，当前选择的是：${widget.tc.index}, 排序是：${getSort()}');
    }
  }

  void _handleScroll(double delta) {
    if (_tabBarScrollController.hasClients) {
      final double newOffset = _tabBarScrollController.offset + delta;
      if (newOffset < 0) {
        _tabBarScrollController.jumpTo(0);
      } else if (newOffset > _tabBarScrollController.position.maxScrollExtent) {
        _tabBarScrollController.jumpTo(_tabBarScrollController.position.maxScrollExtent);
      } else {
        _tabBarScrollController.jumpTo(newOffset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = slang.Translations.of(context);
    final TabBar secondaryTabBar = TabBar(
      isScrollable: true,
      physics: const NeverScrollableScrollPhysics(),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      tabAlignment: TabAlignment.start,
      dividerColor: Colors.transparent,
      padding: EdgeInsets.zero,
      controller: widget.tc,
      tabs: <Tab>[
        // date
        Tab(
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Text(t.common.latest),
            ],
          ),
        ),
        // likes 
        Tab(
          child: Row(
            children: [
              const Icon(Icons.favorite),
              const SizedBox(width: 8),
              Text(t.common.likesCount),
            ],
          ),
        ),
        // views
        Tab(
          child: Row(
            children: [
              const Icon(Icons.remove_red_eye),
              const SizedBox(width: 8),
              Text(t.common.viewsCount),
            ],
          ),
        ),
        // popularity
        Tab(
          child: Row(
            children: [
              const Icon(Icons.star),
              const SizedBox(width: 8),
              Text(t.common.popular),
            ],
          ),
        ),
        // trending
        Tab(
          child: Row(
            children: [
              const Icon(Icons.trending_up),
              const SizedBox(width: 8),
              Text(t.common.trending),
            ],
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: MouseRegion(
                child: Listener(
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent) {
                      _handleScroll(pointerSignal.scrollDelta.dy);
                    }
                  },
                  child: SingleChildScrollView(
                    controller: _tabBarScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: secondaryTabBar,
                  ),
                ),
              ),
            ),
            // 一个刷新按钮
            Obx(() => videoListController.isLoading.value
                ? const IconButton(icon: Icon(Icons.refresh), onPressed: null)
                    .animate(
                      onPlay: (controller) => controller.repeat(), // loop
                    )
                    .addEffect(
                      const RotateEffect(
                        duration: Duration(seconds: 1),
                        curve: Curves.linear,
                      ),
                    )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      videoListController.fetchVideos(refresh: true);
                    },
                  )),
          ],
        ),
        Expanded(
          child: Obx(() => _buildVideoList()),
        )
      ],
    );
  }

  // 构建视频列表视图
  Widget _buildVideoList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!videoListController.isLoading.value &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 100 &&
            videoListController.hasMore.value) {
          // 接近底部时加载更多评论
          videoListController.fetchVideos();
        }
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: videoListController.videos.length + 1,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index < videoListController.videos.length) {
            Video video = videoListController.videos[index];
            return VideoTileListItem(video: video);
          } else {
            // 最后一项显示加载指示器或结束提示
            return _buildLoadMoreIndicator(context);
          }
        },
      ),
    );
  }

  // 构建加载更多指示器
  Widget _buildLoadMoreIndicator(BuildContext context) {
    final t = slang.Translations.of(context);
    if (videoListController.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            t.authorProfile.noMoreDatas,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
