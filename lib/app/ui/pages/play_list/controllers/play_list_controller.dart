import 'package:get/get.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';

class PlayListsController extends GetxController {
  final PlayListService _playListService = Get.find<PlayListService>();

  // 创建播放列表
  Future<bool> createPlaylist(String title) async {
    final result = await _playListService.createPlaylist(title: title);
    if (!result.isSuccess) {
      showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error), position: ToastPosition.bottom);
      return false;
    }
    return true;
  }

}
