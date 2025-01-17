import 'package:get/get.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';

class TagBlacklistController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxList<Tag> blacklistTags = <Tag>[].obs;
  final RxBool isSaving = false.obs;

  // 获取当前用户的标签限制数量
  int get tagLimit => _userService.currentUser.value?.premium == true ? 30 : 8;

  @override
  void onInit() {
    super.onInit();
    fetchBlacklistTags();
  }

  // 获取黑名单标签
  Future<void> fetchBlacklistTags() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final result = await _userService.fetchProfileUser();
      if (result.isSuccess && result.data != null) {
        blacklistTags.value = result.data!.tagBlacklist ?? [];
      } else {
        hasError.value = true;
        showToastWidget(MDToastWidget(
          message: result.message,
          type: MDToastType.error,
        ));
      }
    } catch (e) {
      hasError.value = true;
      showToastWidget(MDToastWidget(
        message: t.errors.failedToFetchData,
        type: MDToastType.error,
      ));
    } finally {
      isLoading.value = false;
    }
  }

  // 保存黑名单标签
  Future<void> saveBlacklistTags() async {
    isSaving.value = true;
    try {
      final result = await _userService.updateUserProfile(
        blacklistTags.map((tag) => tag.id).toList(),
      );
      if (result.isSuccess) {
        showToastWidget(MDToastWidget(
          message: t.common.success,
          type: MDToastType.success,
        ));
      } else {
        showToastWidget(MDToastWidget(
          message: result.message,
          type: MDToastType.error,
        ));
      }
    } catch (e) {
      showToastWidget(MDToastWidget(
        message: t.errors.failedToOperate,
        type: MDToastType.error,
      ));
    } finally {
      isSaving.value = false;
    }
  }

  // 移除标签
  void removeTag(Tag tag) {
    blacklistTags.remove(tag);
  }

  // 添加标签列表
  void addTags(List<Tag> tags) {
    // 检查是否超出限制
    if (blacklistTags.length + tags.length > tagLimit) {
      showToastWidget(MDToastWidget(
        message: t.errors.tagLimitExceeded(limit: tagLimit),
        type: MDToastType.error,
      ));
      return;
    }

    // 添加不重复的标签
    for (var tag in tags) {
      if (!blacklistTags.contains(tag)) {
        blacklistTags.add(tag);
      }
    }
  }
} 