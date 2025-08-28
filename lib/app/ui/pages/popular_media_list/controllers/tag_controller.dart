import 'package:get/get.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/tag_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';

/// 标签控制器
class TagController extends GetxController {
  final TagService _tagService = Get.find<TagService>();

  final RxBool isLoading = false.obs;
  final RxList<Tag> tags = <Tag>[].obs; // 标签列表
  final RxBool hasMore = true.obs; // 是否还有更多数据
  String searchInput = ''; // 搜索关键词

  final int pageSize = 20; // 每页数据量
  int page = 0; // 当前页码


  // 获取标签
  Future<void> getTags({bool refresh = false}) async {

    try {
      if (refresh) {
        // 刷新时重置分页和清空数据
        page = 0;
        hasMore.value = true;
      }
      if (!hasMore.value || isLoading.value) return;
      isLoading.value = true;

      final result = await _tagService.fetchTags(
          page: page, limit: pageSize, params: {
        'filter': searchInput,
      });
      if (result.isFail) {
        isLoading.value = false;
        showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error), position: ToastPosition.bottom);
        return;
      }
      List<Tag> newTags = result.data!.results;

      if (refresh) {
        tags.clear();
      }
      tags.addAll(newTags);
      page++;

      if (result.data!.results.length < pageSize) {
        hasMore.value = false;
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      showToastWidget(MDToastWidget(message: t.errors.errorWhileFetching, type: MDToastType.error), position: ToastPosition.bottom);
    }
  }

}