import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/play_list/widgets/playlist_item_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_repository.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

class ProfilePlaylistTabListWidget extends StatefulWidget {
  final String userId;
  final String tabKey;
  final TabController tc;
  final Function({int? count})? onFetchFinished;

  const ProfilePlaylistTabListWidget({
    super.key,
    required this.userId,
    required this.tabKey,
    required this.tc,
    this.onFetchFinished,
  });

  @override
  State<ProfilePlaylistTabListWidget> createState() => _ProfilePlaylistTabListWidgetState();
}

class _ProfilePlaylistTabListWidgetState extends State<ProfilePlaylistTabListWidget>
    with AutomaticKeepAliveClientMixin {
  late PlayListRepository listSourceRepository;

  // 四个 tab 里原本只有播放列表这一个没有保活：TabBarView 未开
  // allowImplicitScrolling，非当前页在切换动画结束后即被 unmount，
  // 导致每次切回来都从第 0 页重新拉数据、滚动位置也回到顶部。
  // 其余三个 tab（video / image / post）都已 wantKeepAlive => true。
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    listSourceRepository = PlayListRepository(userId: widget.userId);
  }

  @override 
  void dispose() {
    listSourceRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 要求
    return RefreshIndicator(
      onRefresh: () async {
        await listSourceRepository.refresh(true);
      },
      child: LoadingMoreCustomScrollView(
        slivers: <Widget>[
          LoadingMoreSliverList<PlaylistModel>(
            SliverListConfig<PlaylistModel>(
              extendedListDelegate: const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (context, item, index) => PlaylistItemWidget(playlist: item),
              sourceList: listSourceRepository,
              // 四个 tab 里只有这里没有底部安全区：video / image 走 MediaListView
              // （showBottomPadding 默认 true），post 由外层 Stack 补，
              // 唯独播放列表是裸的 LoadingMoreCustomScrollView，最后一行会被
              // 手势条 / 底栏压住。
              padding: EdgeInsets.fromLTRB(
                5.0,
                5.0,
                5.0,
                5.0 + computeBottomSafeInset(MediaQuery.of(context)),
              ),
              lastChildLayoutType: LastChildLayoutType.foot,
              indicatorBuilder: (context, status) => myLoadingMoreIndicator(
                context, 
                status,
                isSliver: true, 
                loadingMoreBase: listSourceRepository
              ),
            ),
          )
        ],
      ),
    );
  }
} 