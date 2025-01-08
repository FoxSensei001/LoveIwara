import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_controller.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_repository.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

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
      body: LoadingMoreCustomScrollView(
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
                bottom: Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0, // 添加底部安全区域
              ),
              lastChildLayoutType: LastChildLayoutType.foot,
              indicatorBuilder: (context, status) => myLoadingMoreIndicator(
                  context, status,
                  isSliver: true, loadingMoreBase: listSourceRepository),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(() => _showBackToTop.value
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            ).paddingBottom(Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0)
          : const SizedBox()),
    );
  }

  Widget buildItem(BuildContext c, PlaylistModel playlist, int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => NaviService.navigateToPlayListDetail(playlist.id,
            isMine: widget.isMine),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 添加这行
          children: [
            // 使用 AspectRatio 来固定图片区域的宽高比
            AspectRatio(
              aspectRatio: 16 / 9, // 可以根据需要调整宽高比
              child: CachedNetworkImage(
                imageUrl: playlist.thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error),
                ),
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
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final RxBool isLoading = false.obs;

    Get.dialog(
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
          Obx(() => TextButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        isLoading.value = true;
                        if (textController.text.trim().isNotEmpty) {
                          final res = await controller
                              .createPlaylist(textController.text.trim());
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
              )),
        ],
      ),
    );
  }

  _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('💡 ${slang.t.playList.friendlyTips}',
            style: const TextStyle(fontSize: 18)),
        content: ExtendedText(
          '${slang.t.playList.dearUser}:\n\n'
          '⚠️ ${slang.t.playList.iwaraPlayListSystemIsNotPerfectYet}\n'
          '• ${slang.t.playList.notSupportSetCover}\n'
          '• ${slang.t.playList.notSupportDeleteList}\n'
          '• ${slang.t.playList.notSupportSetPrivate}\n\n'
          '${slang.t.playList.yesCreateListWillAlwaysExistAndVisibleToEveryone}😅\n\n'
          '💡 ${slang.t.playList.smallSuggestion}: ${slang.t.playList.useLikeToCollectContent}\n\n'
          '🤝 ${slang.t.playList.welcomeToDiscussOnGitHub}',
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.playList.iUnderstand,
                style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
