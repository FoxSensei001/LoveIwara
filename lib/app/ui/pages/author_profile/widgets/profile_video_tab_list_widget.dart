import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
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
  State<ProfileVideoTabListWidget> createState() => _ProfileVideoTabListWidgetState();
}

class _ProfileVideoTabListWidgetState extends State<ProfileVideoTabListWidget>
    with AutomaticKeepAliveClientMixin {
  late UserzVideoListRepository videoListRepository;
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
    _tabBarScrollController = ScrollController();
    _initRepository();
  }

  void _initRepository() {
    videoListRepository = UserzVideoListRepository(
      userId: widget.userId,
      sortType: getSort(),
      onFetchFinished: widget.onFetchFinished,
    );
    LogUtils.d('[详情视频列表] 初始化，当前的用户ID是：${widget.userId}, 排序是：${getSort()}');
  }

  @override
  void dispose() {
    widget.tc.removeListener(_handleTabSelection);
    videoListRepository.dispose();
    _tabBarScrollController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (widget.tc.indexIsChanging) {
      setState(() {
        videoListRepository.dispose();
        _initRepository();
      });
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
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => videoListRepository.refresh(true),
            ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await videoListRepository.refresh(true);
            },
            child: MediaListView<Video>(
              sourceList: videoListRepository,
              emptyIcon: Icons.video_library_outlined,
              itemBuilder: (context, video, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
                    vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
                  ),
                  child: VideoCardListItemWidget(
                    video: video,
                    width: MediaQuery.of(context).size.width <= 600 
                        ? MediaQuery.of(context).size.width / 2 - 8 
                        : 200,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
