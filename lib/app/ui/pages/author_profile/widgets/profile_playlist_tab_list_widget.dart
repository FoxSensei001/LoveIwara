import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/play_list/widgets/playlist_item_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_repository.dart';

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

class _ProfilePlaylistTabListWidgetState extends State<ProfilePlaylistTabListWidget> {
  late PlayListRepository listSourceRepository;

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
              padding: const EdgeInsets.all(5.0),
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