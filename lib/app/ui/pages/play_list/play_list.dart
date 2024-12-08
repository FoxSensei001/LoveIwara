import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_controller.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_repository.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';

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
        title: const Text('我的播放列表'),
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
              padding: const EdgeInsets.all(5.0),
              lastChildLayoutType: LastChildLayoutType.foot,
              indicatorBuilder: (context, status) => myLoadingMoreIndicator(
                  context, status,
                  isSliver: true, loadingMoreBase: listSourceRepository),
            ),
          )
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
            )
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
                    '${playlist.numVideos} 个视频',
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

    Get.dialog(
      AlertDialog(
        title: const Text('创建播放列表'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: '请输入播放列表标题',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.trim().isNotEmpty) {
                AppService.tryPop();
                await controller.createPlaylist(textController.text.trim());
                listSourceRepository.refresh();
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('💡 友情提示', style: TextStyle(fontSize: 18)),
        content: const ExtendedText(
          '亲爱的用户:\n\n'
          '⚠️ iwara的播放列表系统目前还不太完善...\n'
          '• 不支持设置封面\n'
          '• 不能删除列表\n'
          '• 无法设为私密\n\n'
          '没错...创建的列表会一直存在且对所有人可见 😅\n\n'
          '💡 小建议: 如果您比较注重隐私，建议使用"点赞"功能来收藏内容~\n\n'
          '🤝 如果你有其他的建议或想法，欢迎来 GitHub 讨论!',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('明白了', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
