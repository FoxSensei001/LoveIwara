import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/utils/iwara_different_site_recovery.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class PostDetailController extends GetxController {
  final String postId;
  final PostService _postService = Get.find();
  bool isInfoInitialized = false;

  PostDetailController(this.postId);

  final Rxn<String> errorMessage = Rxn<String>();
  final Rxn<PostModel> postInfo = Rxn<PostModel>();
  final RxBool isPostInfoLoading = true.obs;
  final RxBool isCommentSheetVisible = false.obs;
  final RxBool isDescriptionExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchPostDetail();
  }

  Future<void> fetchPostDetail() async {
    try {
      isPostInfoLoading.value = true;
      errorMessage.value = null;

      ApiResult<PostModel> res = await _postService.fetchPostDetail(postId);
      if (!res.isSuccess) {
        // 跨站资源：切站会退回首页并重建整棵树，本页作废，由 reopen 在新站点重新
        // 开一张干净的详情页，这里直接 return。
        if (await IwaraDifferentSiteRecovery.recover(
          res.exception,
          resourceKey: 'post:$postId',
          reopen: () => NaviService.navigateToPostDetailPage(postId, null),
        )) {
          return;
        }

        errorMessage.value = res.message;
        showGlassToast(
          res.message,
          type: GlassToastType.error,
          position: GlassToastPosition.bottom,
        );
        return;
      }

      postInfo.value = res.data;
      IwaraDifferentSiteRecovery.markResolved('post:$postId');

      try {
        final HistoryRepository historyRepository = HistoryRepository();
        await historyRepository.addRecordWithCheck(
          HistoryRecord.fromPost(postInfo.value!),
        );
      } catch (e) {
        LogUtils.e('添加历史记录失败', error: e, tag: 'PostDetailController');
      }
    } finally {
      LogUtils.d('帖子详情信息加载完成', 'PostDetailController');
      isPostInfoLoading.value = false;
      isInfoInitialized = true;
    }
  }
}
