import 'package:get/get.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart';

class TagBlacklistController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Tag> blacklistTags = <Tag>[].obs;
  final RxBool isSaving = false.obs;

  // 保存初始 tag 列表的 id（已保存或获取后），使用响应式变量
  final RxList<String> initialTagIds = <String>[].obs;

  // 获取当前用户的标签限制数量
  int get tagLimit => _userService.currentUser.value?.premium == true ? 30 : 8;

  // 新增：判断是否存在未保存的改动
  bool get hasUnsavedChanges {
    final currentIds = blacklistTags.map((tag) => tag.id).toSet();
    final initIds = initialTagIds.value.toSet();
    return !setEquals(currentIds, initIds);
  }

  @override
  void onInit() {
    super.onInit();
    fetchBlacklistTags();
  }

  // 获取黑名单标签
  Future<void> fetchBlacklistTags() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    try {
      final result = await _userService.fetchProfileUser();
      if (result.isSuccess && result.data != null) {
        blacklistTags.value = result.data!.tagBlacklist ?? [];
        // 记录初始的 tag 列表状态
        initialTagIds.value = blacklistTags.map((tag) => tag.id).toList();
      } else {
        hasError.value = true;
        errorMessage.value = result.message;
        showToastWidget(
          MDToastWidget(message: result.message, type: MDToastType.error),
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      showToastWidget(
        MDToastWidget(
          message: t.errors.failedToFetchData,
          type: MDToastType.error,
        ),
      );
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
        showToastWidget(
          MDToastWidget(message: t.common.success, type: MDToastType.success),
        );
        // 更新初始状态为当前保存成功的状态
        initialTagIds.value = blacklistTags.map((tag) => tag.id).toList();
      } else {
        showToastWidget(
          MDToastWidget(message: result.message, type: MDToastType.error),
        );
      }
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.failedToOperate,
          type: MDToastType.error,
        ),
      );
    } finally {
      isSaving.value = false;
    }
  }

  // 移除标签
  void removeTag(Tag tag) {
    blacklistTags.remove(tag);
  }

  // 添加标签列表，新增返回值：如果超出限制则返回 false
  bool addTags(List<Tag> tags) {
    // 检查是否超出限制
    if (blacklistTags.length + tags.length > tagLimit) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.tagLimitExceeded(limit: tagLimit),
          type: MDToastType.error,
        ),
      );
      return false;
    }

    // 添加不重复的标签
    for (var tag in tags) {
      if (!blacklistTags.contains(tag)) {
        blacklistTags.add(tag);
      }
    }
    return true;
  }
}
