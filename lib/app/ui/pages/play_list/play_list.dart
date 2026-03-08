import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_controller.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_repository.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';

enum _PlaylistMenuAction { delete }

class PlayListPage extends StatefulWidget {
  final String userId;
  final bool isMine;

  const PlayListPage({super.key, required this.userId, required this.isMine});

  @override
  State<PlayListPage> createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  late PlayListsController controller;
  late PlayListRepository listSourceRepository;
  final ScrollController _scrollController = ScrollController();
  final RxBool _showBackToTop = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PlayListsController());
    listSourceRepository = PlayListRepository(userId: widget.userId);

    // 添加滚动监听
    _scrollController.addListener(() {
      if (_scrollController.offset >= 300) {
        _showBackToTop.value = true;
      } else {
        _showBackToTop.value = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<PlayListsController>();
    listSourceRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(slang.t.playList.myPlayList),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => listSourceRepository.refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
          if (widget.isMine)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateDialog(context),
            ),
          // 分享
          // IconButton(
          //   icon: const Icon(Icons.share),
          //   onPressed: () => ShareService.sharePlayList(widget.userId),
          // ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => listSourceRepository.refresh(true),
        child: LoadingMoreCustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            LoadingMoreSliverList<PlaylistModel>(
              SliverListConfig<PlaylistModel>(
                extendedListDelegate:
                    const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                itemBuilder: buildItem,
                sourceList: listSourceRepository,
                padding: EdgeInsets.only(
                  left: 5.0,
                  right: 5.0,
                  top: 5.0,
                  bottom: computeBottomSafeInset(MediaQuery.of(context)),
                ),
                lastChildLayoutType: LastChildLayoutType.foot,
                indicatorBuilder: (context, status) => myLoadingMoreIndicator(
                  context,
                  status,
                  isSliver: true,
                  loadingMoreBase: listSourceRepository,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => _showBackToTop.value
            ? FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Icon(Icons.arrow_upward),
              ).paddingBottom(computeBottomSafeInset(MediaQuery.of(context)))
            : const SizedBox(),
      ),
    );
  }

  Widget buildItem(BuildContext c, PlaylistModel playlist, int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final result = await GoRouter.of(c).push(
            '/playlist_detail/${playlist.id}',
            extra: PlayListDetailExtra(isMine: widget.isMine),
          );
          if (!c.mounted) {
            return;
          }
          if (result == true && widget.isMine) {
            await listSourceRepository.refresh(true);
          }
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: playlist.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) =>
                        const Center(child: Icon(Icons.error)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slang.t.common.videoCount(num: playlist.numVideos),
                        style: TextStyle(
                          color: Theme.of(c).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.isMine)
              Positioned(
                top: 4,
                right: 4,
                child: Obx(
                  () => PopupMenuButton<_PlaylistMenuAction>(
                    tooltip: MaterialLocalizations.of(c).showMenuTooltip,
                    enabled: !controller.isDeletingPlaylist(playlist.id),
                    onSelected: (action) {
                      if (action == _PlaylistMenuAction.delete) {
                        _showDeletePlaylistDialog(playlist);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<_PlaylistMenuAction>(
                        value: _PlaylistMenuAction.delete,
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              slang.t.common.delete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          c,
                        ).colorScheme.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: controller.isDeletingPlaylist(playlist.id)
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.more_vert, size: 20),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeletePlaylistDialog(PlaylistModel playlist) {
    final RxBool isLoading = false.obs;

    showAppDialog(
      Obx(
        () => PopScope(
          canPop: !isLoading.value,
          child: AlertDialog(
            title: Text(slang.t.common.confirmDelete),
            content: Text(
              slang.t.favorite.removeItemConfirmWithTitle(
                title: playlist.title,
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading.value ? null : () => AppService.tryPop(),
                child: Text(slang.t.common.cancel),
              ),
              TextButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        isLoading.value = true;
                        final deleted = await controller.deletePlaylist(
                          playlist.id,
                        );
                        if (deleted) {
                          AppService.tryPop();
                          await listSourceRepository.refresh(true);
                        }
                        isLoading.value = false;
                      },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Text(slang.t.common.delete),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showCreateDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final RxBool isLoading = false.obs;

    showAppDialog(
      AlertDialog(
        title: Text(slang.t.common.createPlayList),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: slang.t.common.pleaseEnterNewTitle,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.cancel),
          ),
          Obx(
            () => TextButton(
              onPressed: isLoading.value
                  ? null
                  : () async {
                      isLoading.value = true;
                      if (textController.text.trim().isNotEmpty) {
                        final res = await controller.createPlaylist(
                          textController.text.trim(),
                        );
                        if (res) {
                          listSourceRepository.refresh();
                          AppService.tryPop();
                        }
                      }
                      isLoading.value = false;
                    },
              child: isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Text(slang.t.common.create),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showAppDialog(
      AlertDialog(
        title: Text(
          '💡 ${slang.t.playList.friendlyTips}',
          style: const TextStyle(fontSize: 18),
        ),
        content: Text(
          '${slang.t.playList.dearUser}:\n\n'
          '⚠️ ${slang.t.playList.iwaraPlayListSystemIsNotPerfectYet}\n'
          '• ${slang.t.playList.notSupportSetCover}\n'
          '• ${slang.t.playList.notSupportSetPrivate}\n\n'
          '${slang.t.playList.yesCreateListWillAlwaysExistAndVisibleToEveryone}😅\n\n'
          '💡 ${slang.t.playList.smallSuggestion}: ${slang.t.playList.useLikeToCollectContent}\n\n'
          '🤝 ${slang.t.playList.welcomeToDiscussOnGitHub}',
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(
              slang.t.playList.iUnderstand,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
