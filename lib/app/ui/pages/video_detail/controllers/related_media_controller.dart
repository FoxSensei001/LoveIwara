import 'package:get/get.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import '../../../../../common/enums/media_enums.dart';
import '../../../../models/image.model.dart';
import '../../../../models/video.model.dart';

// 相关xx
class RelatedMediasController extends GetxController {
  final String mediaId;
  final MediaType mediaType;
  final VideoService _videoService = Get.find();
  final GalleryService _galleryService = Get.find();

  static const int _pageLimit = 20;

  var videos = <Video>[].obs;
  var imageModels = <ImageModel>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  var errorMessage = ''.obs;

  int _currentPage = 0;

  RelatedMediasController({required this.mediaId, required this.mediaType});

  @override
  void onInit() {
    super.onInit();
    LogUtils.d('相关初始化', 'RelatedMediasController');
    fetchRelatedMedias();
  }

  Future<void> fetchRelatedMedias() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _currentPage = 0;
      hasMore.value = true;

      switch (mediaType) {
        case MediaType.VIDEO:
          final response = await _videoService.fetchRelatedVideosByVideoId(
            mediaId,
            limit: _pageLimit,
          );
          if (response.isSuccess) {
            videos.value = response.data!.results;
            if (response.data!.results.length < _pageLimit) {
              hasMore.value = false;
            }
          } else {
            LogUtils.e('相关: 获取相关视频失败', tag: 'RelatedMediasController');
            errorMessage.value = response.message;
          }
        case MediaType.IMAGE:
          final response = await _galleryService.fetchRelatedImagesByImageId(
            mediaId,
            limit: _pageLimit,
          );
          if (response.isSuccess) {
            imageModels.value = response.data!.results;
            if (response.data!.results.length < _pageLimit) {
              hasMore.value = false;
            }
          } else {
            LogUtils.e('相关: 获取相关图片失败',
                tag: 'RelatedMediasController', error: response.message);
            errorMessage.value = response.message;
          }
      }
      LogUtils.d(
          '相关: 获取到的数量有 ${videos.length}', 'RelatedMediasController');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    _currentPage++;

    try {
      switch (mediaType) {
        case MediaType.VIDEO:
          final response = await _videoService.fetchRelatedVideosByVideoId(
            mediaId,
            page: _currentPage,
            limit: _pageLimit,
          );
          if (response.isSuccess) {
            videos.addAll(response.data!.results);
            if (response.data!.results.length < _pageLimit) {
              hasMore.value = false;
            }
          } else {
            _currentPage--;
            LogUtils.e('相关: 加载更多相关视频失败', tag: 'RelatedMediasController');
          }
        case MediaType.IMAGE:
          final response = await _galleryService.fetchRelatedImagesByImageId(
            mediaId,
            page: _currentPage,
            limit: _pageLimit,
          );
          if (response.isSuccess) {
            imageModels.addAll(response.data!.results);
            if (response.data!.results.length < _pageLimit) {
              hasMore.value = false;
            }
          } else {
            _currentPage--;
            LogUtils.e('相关: 加载更多相关图片失败', tag: 'RelatedMediasController');
          }
      }
    } catch (e) {
      _currentPage--;
      LogUtils.e('相关: 加载更多失败', tag: 'RelatedMediasController', error: e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  void retry() {
    fetchRelatedMedias();
  }
}

// 作者的其他xx
class OtherAuthorzMediasController extends GetxController {
  final String mediaId;
  final MediaType mediaType;
  final String userId;
  final VideoService _videoService = Get.find();
  final GalleryService _galleryService = Get.find();

  static const int _pageLimit = 20;

  var videos = <Video>[].obs;
  var imageModels = <ImageModel>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  int _currentPage = 0;

  OtherAuthorzMediasController(
      {required this.mediaId, required this.userId, required this.mediaType});

  @override
  void onInit() {
    super.onInit();
    LogUtils.d('作者其他初始化', 'OtherAuthorzMediasController');
    fetchRelatedMedias();
  }

  Future<void> fetchRelatedMedias() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      _currentPage = 0;
      hasMore.value = true;

      switch (mediaType) {
        case MediaType.VIDEO:
          final response = await _videoService.fetchAuthorVideos(
            userId,
            excludeVideoId: mediaId,
            limit: _pageLimit,
          );
          if (response.isSuccess) {
            videos.value = response.data!.results;
            if (response.data!.results.length < _pageLimit) {
              hasMore.value = false;
            }
          } else {
            LogUtils.e('其他: 获取作者其他视频失败',
                tag: 'OtherAuthorzMediasController');
            hasError.value = true;
            errorMessage.value = response.message;
          }
        case MediaType.IMAGE:
          final response = await _galleryService.fetchAuthorImages(
            userId,
            excludeImageId: mediaId,
            limit: _pageLimit,
          );
          if (response.isSuccess) {
            imageModels.value = response.data!.results;
            if (response.data!.results.length < _pageLimit) {
              hasMore.value = false;
            }
          } else {
            LogUtils.e('其他: 获取作者其他图片失败',
                tag: 'OtherAuthorzMediasController');
            hasError.value = true;
            errorMessage.value = response.message;
          }
      }

      LogUtils.d('其他: 获取到的数量有 ${videos.length}',
          'OtherAuthorzMediasController');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    _currentPage++;

    try {
      switch (mediaType) {
        case MediaType.VIDEO:
          final response = await _videoService.fetchAuthorVideos(
            userId,
            excludeVideoId: mediaId,
            page: _currentPage,
            limit: _pageLimit,
          );
          if (response.isSuccess) {
            videos.addAll(response.data!.results);
            if (response.data!.results.length < _pageLimit) {
              hasMore.value = false;
            }
          } else {
            _currentPage--;
            LogUtils.e('其他: 加载更多作者视频失败',
                tag: 'OtherAuthorzMediasController');
          }
        case MediaType.IMAGE:
          final response = await _galleryService.fetchAuthorImages(
            userId,
            excludeImageId: mediaId,
            page: _currentPage,
            limit: _pageLimit,
          );
          if (response.isSuccess) {
            imageModels.addAll(response.data!.results);
            if (response.data!.results.length < _pageLimit) {
              hasMore.value = false;
            }
          } else {
            _currentPage--;
            LogUtils.e('其他: 加载更多作者图片失败',
                tag: 'OtherAuthorzMediasController');
          }
      }
    } catch (e) {
      _currentPage--;
      LogUtils.e('其他: 加载更多失败',
          tag: 'OtherAuthorzMediasController', error: e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  void retry() {
    fetchRelatedMedias();
  }
}
