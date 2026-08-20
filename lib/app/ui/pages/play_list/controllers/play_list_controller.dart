import 'package:get/get.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class PlayListsController extends GetxController {
  final PlayListService _playListService = Get.find<PlayListService>();
  final RxList<String> deletingPlaylistIds = <String>[].obs;

  /// 多选态下已勾选的播放列表 id。
  final RxSet<String> selectedPlaylistIds = <String>{}.obs;

  /// 批量删除进行中（整批一把锁，避免重复提交）。
  final RxBool isBatchDeleting = false.obs;

  // 创建播放列表
  Future<bool> createPlaylist(String title) async {
    final result = await _playListService.createPlaylist(title: title);
    if (!result.isSuccess) {
      showGlassToast(
        result.message,
        type: GlassToastType.error,
        position: GlassToastPosition.bottom,
      );
      return false;
    }
    return true;
  }

  bool isDeletingPlaylist(String playlistId) =>
      deletingPlaylistIds.contains(playlistId);

  void toggleSelection(String playlistId) {
    if (selectedPlaylistIds.contains(playlistId)) {
      selectedPlaylistIds.remove(playlistId);
    } else {
      selectedPlaylistIds.add(playlistId);
    }
  }

  void clearSelection() => selectedPlaylistIds.clear();

  Future<bool> deletePlaylist(String playlistId) async {
    // 同一条正在删：静默忽略重复提交，不打扰用户
    if (isDeletingPlaylist(playlistId)) return false;

    final errorMessage = await _deletePlaylistRequest(playlistId);
    if (errorMessage != null) {
      showGlassToast(
        errorMessage,
        type: GlassToastType.error,
        position: GlassToastPosition.bottom,
      );
      return false;
    }

    showGlassToast(slang.t.common.success, type: GlassToastType.success);
    return true;
  }

  /// 批量删除已勾选的播放列表，返回删除成功的条数。
  ///
  /// 服务端没有批量接口，只能逐个删；单个失败不打断其余（否则前面已经删掉的
  /// 会让用户一脸懵），成功的即时从选中集合里摘掉，最后只汇总弹一次提示。
  Future<int> deleteSelectedPlaylists() async {
    if (isBatchDeleting.value || selectedPlaylistIds.isEmpty) return 0;

    isBatchDeleting.value = true;
    final List<String> targets = selectedPlaylistIds.toList();
    int succeeded = 0;
    String? firstError;

    try {
      for (final id in targets) {
        final errorMessage = await _deletePlaylistRequest(id);
        if (errorMessage == null) {
          succeeded++;
          selectedPlaylistIds.remove(id);
        } else {
          firstError ??= errorMessage;
        }
      }
    } finally {
      isBatchDeleting.value = false;
    }

    if (firstError != null) {
      showGlassToast(
        firstError,
        type: GlassToastType.error,
        position: GlassToastPosition.bottom,
      );
    } else if (succeeded > 0) {
      showGlassToast(slang.t.common.success, type: GlassToastType.success);
    }
    return succeeded;
  }

  /// 单条删除请求；成功返回 null，失败返回错误消息（提示交给调用方，
  /// 批量删除才能把 N 条错误收敛成一次）。
  Future<String?> _deletePlaylistRequest(String playlistId) async {
    if (isDeletingPlaylist(playlistId)) {
      return slang.t.errors.failedToOperate;
    }

    deletingPlaylistIds.add(playlistId);
    try {
      final result = await _playListService.deletePlaylist(
        playlistId: playlistId,
      );
      return result.isSuccess ? null : result.message;
    } finally {
      deletingPlaylistIds.remove(playlistId);
    }
  }
}
