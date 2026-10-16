import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_detail_repository.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class PlayListDetailController extends GetxController {
  final PlayListService _playListService = Get.find<PlayListService>();
  late PlayListDetailRepository repository;

  /// 列表内搜索：只在本地过滤已加载的项，或另起一套请求扫完整张列表，
  /// 都不会动浏览列表的翻页游标。
  late final PagedSearchController<Video> search;

  final RxBool isMultiSelect = false.obs;
  final RxSet<String> selectedVideos = <String>{}.obs;
  final RxString playlistTitle = ''.obs;

  /// 这张播放列表是谁的。用来告诉「接着看」抽屉"这是他人的播放列表"
  /// （见 `PlaylistPlaybackQueue.owner`）。拿不到就保持 null，不影响别的。
  final Rxn<User> playlistOwner = Rxn<User>();
  final RxBool isDeleting = false.obs;

  final String playlistId;

  PlayListDetailController({required this.playlistId}) {
    search = PagedSearchController<Video>(
      fetchPage: (page, limit, token) async {
        final result = await _playListService.getPlaylistVideos(
          playlistId: playlistId,
          page: page,
          limit: limit,
          cancelToken: token,
          rethrowErrors: true,
        );
        if (!result.isSuccess || result.data == null) {
          throw Exception(result.message);
        }
        return result.data!;
      },
      idOf: (video) => video.id,
      matches: (query, video) =>
          matchesMediaSearch(query, video.title, video.user),
    );
    repository = PlayListDetailRepository(
      playlistId: playlistId,
      search: search,
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadPlaylistName();
  }

  @override
  void onClose() {
    search.dispose();
    super.onClose();
  }

  Future<void> loadPlaylistName() async {
    final result = await _playListService.getPlaylistInfo(
      playlistId: playlistId,
    );
    if (result.isSuccess) {
      playlistTitle.value = result.data!.title;
      playlistOwner.value = result.data!.user;
    }
  }

  Future<void> editTitle(String newTitle) async {
    final result = await _playListService.editPlaylistTitle(
      playlistId: playlistId,
      title: newTitle,
    );
    if (result.isSuccess) {
      playlistTitle.value = newTitle;
    } else {
      showAppToast(
        result.message,
        type: AppToastType.error,
        position: AppToastPosition.bottom,
      );
    }
  }

  void toggleMultiSelect() {
    isMultiSelect.value = !isMultiSelect.value;
    if (!isMultiSelect.value) {
      selectedVideos.clear();
    }
  }

  void toggleSelection(String videoId) {
    if (selectedVideos.contains(videoId)) {
      selectedVideos.remove(videoId);
    } else {
      selectedVideos.add(videoId);
    }
  }

  Future<void> deleteSelected() async {
    if (isDeleting.value || selectedVideos.isEmpty) return;

    isDeleting.value = true;
    final List<String> videosToDelete = selectedVideos.toList();

    try {
      // 执行删除操作
      for (var videoId in videosToDelete) {
        final result = await _playListService.removeFromPlaylist(
          videoId: videoId,
          playlistId: playlistId,
        );

        if (!result.isSuccess) {
          throw Exception(result.message);
        }
      }

      // 删除成功后清空选择状态
      selectedVideos.clear();

      // 列表刷新交给页面：分页模式下只有 MediaListView 自己 refresh 才会
      // 换掉当前显示的那一页，数据源自刷新是刷不到的。

      // 显示成功提示
      showAppToast(slang.t.common.success, type: AppToastType.success);
    } catch (error) {
      // 如果删除失败，显示错误
      showAppToast(
        'Delete failed: $error',
        type: AppToastType.error,
        position: AppToastPosition.bottom,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<bool> deletePlaylist() async {
    if (isDeleting.value) {
      return false;
    }

    isDeleting.value = true;
    try {
      final result = await _playListService.deletePlaylist(
        playlistId: playlistId,
      );
      if (!result.isSuccess) {
        showAppToast(
          result.message,
          type: AppToastType.error,
          position: AppToastPosition.bottom,
        );
        return false;
      }

      showAppToast(slang.t.common.success, type: AppToastType.success);
      return true;
    } finally {
      isDeleting.value = false;
    }
  }
}
