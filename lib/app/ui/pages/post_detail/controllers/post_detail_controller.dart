import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';

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
  final RxBool isTranslating = false.obs;
  final Rxn<String> translatedText = Rxn<String>();
  final RxBool showTranslationMenu = false.obs;
  
  final TranslationService _translationService = Get.find();

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
        errorMessage.value = res.message;
        showToastWidget(MDToastWidget(message: res.message, type: MDToastType.error));
        return;
      }

      postInfo.value = res.data;

      try {
          final HistoryRepository historyRepository = HistoryRepository();
          await historyRepository.addRecordWithCheck(HistoryRecord.fromPost(postInfo.value!));
      } catch (e) {
        LogUtils.e('添加历史记录失败', error: e, tag: 'PostDetailController');
      }
    } finally {
      LogUtils.d('帖子详情信息加载完成', 'PostDetailController');
      isPostInfoLoading.value = false;
      isInfoInitialized = true;
    }
  }

  Future<void> handleTranslation() async {
    if (isTranslating.value) return;

    try {
      isTranslating.value = true;
      ApiResult<String> result = await _translationService.translate(
        postInfo.value?.body ?? '',
      );
      
      if (result.isSuccess) {
        translatedText.value = result.data;
      } else {
        translatedText.value = 'Translation failed. Please try again later.';
      }
    } finally {
      isTranslating.value = false;
    }
  }
} 