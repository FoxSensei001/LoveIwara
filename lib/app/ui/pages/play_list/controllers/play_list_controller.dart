import 'package:get/get.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';

class PlayListsController extends GetxController {
  final PlayListService _playListService = Get.find<PlayListService>();
  final RxList<String> deletingPlaylistIds = <String>[].obs;

  // 创建播放列表
  Future<bool> createPlaylist(String title) async {
    final result = await _playListService.createPlaylist(title: title);
    if (!result.isSuccess) {
      showToastWidget(
        MDToastWidget(message: result.message, type: MDToastType.error),
        position: ToastPosition.bottom,
      );
      return false;
    }
    return true;
  }

  bool isDeletingPlaylist(String playlistId) =>
      deletingPlaylistIds.contains(playlistId);

  Future<bool> deletePlaylist(String playlistId) async {
    if (isDeletingPlaylist(playlistId)) {
      return false;
    }

    deletingPlaylistIds.add(playlistId);
    try {
      final result = await _playListService.deletePlaylist(
        playlistId: playlistId,
      );
      if (!result.isSuccess) {
        showToastWidget(
          MDToastWidget(message: result.message, type: MDToastType.error),
          position: ToastPosition.bottom,
        );
        return false;
      }

      showToastWidget(
        MDToastWidget(
          message: slang.t.common.success,
          type: MDToastType.success,
        ),
      );
      return true;
    } finally {
      deletingPlaylistIds.remove(playlistId);
    }
  }
}
