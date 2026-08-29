import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_detail_repository.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class PlayListDetailController extends GetxController {
  final PlayListService _playListService = Get.find<PlayListService>();
  late PlayListDetailRepository repository;

  final RxBool isMultiSelect = false.obs;
  final RxSet<String> selectedVideos = <String>{}.obs;
  final RxString playlistTitle = ''.obs;

  /// 这张播放列表是谁的。用来告诉「接着看」抽屉"这是他人的播放列表"
  /// （见 `PlaylistPlaybackQueue.owner`）。拿不到就保持 null，不影响别的。
  final Rxn<User> playlistOwner = Rxn<User>();
  final RxBool isDeleting = false.obs;

  final String playlistId;

  PlayListDetailController({required this.playlistId}) {
    repository = PlayListDetailRepository(playlistId: playlistId);
  }

  @override
  void onInit() {
    super.onInit();
    loadPlaylistName();
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
      showGlassToast(
        result.message,
        type: GlassToastType.error,
        position: GlassToastPosition.bottom,
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
      showGlassToast(slang.t.common.success, type: GlassToastType.success);
    } catch (error) {
      // 如果删除失败，显示错误
      showGlassToast(
        'Delete failed: $error',
        type: GlassToastType.error,
        position: GlassToastPosition.bottom,
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
        showGlassToast(
          result.message,
          type: GlassToastType.error,
          position: GlassToastPosition.bottom,
        );
        return false;
      }

      showGlassToast(slang.t.common.success, type: GlassToastType.success);
      return true;
    } finally {
      isDeleting.value = false;
    }
  }
}
