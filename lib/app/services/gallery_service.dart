import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';

import '../../utils/logger_utils.dart';
import '../models/page_data.model.dart';

class GalleryService extends GetxService {
  final ApiService _apiService = Get.find();

  /// 获取图库的详情
  Future<ApiResult<ImageModel>> fetchGalleryDetail(String imageModelId) async {
    try {
      var response =
          await _apiService.get(ApiConstants.imageDetail(imageModelId));
      ImageModel imageModel = ImageModel.fromJson(response.data);
      return ApiResult.success(data: imageModel);
    } catch (e) {
      LogUtils.e('获取图库详情失败', tag: 'GalleryService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 根据提供的查询参数获取图片列表。
  ///
  /// 此方法向 `/images` 端点发送带有给定查询参数的 GET 请求，并返回包含图片列表的 `ApiResult`。
  ///
  /// [params] 一个用于过滤图片的查询参数映射。
  /// - `sort` 排序方式。
  /// - `tags` 标签。
  /// - `date` 日期。
  /// - `rating` 内容评级。 general, ecchi
  /// - `user` 作者ID
  /// - `exclude` 排除的图片ID
  /// - `subscribed` 是否订阅。
  /// [page] 当前页码。
  /// [limit] 每页数据量。
  ///
  /// 返回一个包含 `ImageModel` 对象列表、消息和状态码的 `ApiResult`。
  Future<ApiResult<PageData<ImageModel>>> fetchImageModelsByParams({
    Map<String, dynamic> params = const {},
    int page = 0,
    int limit = 20,
    String? url,
  }) async {
    try {
      // [HACK_IMPLEMENT] 如果params里有的值为空字符串，则去掉key
      // 我靠，iwara站的搜索居然连空字符串都用于搜索了，哎
      params = Map<String, dynamic>.from(params)
        ..removeWhere((key, value) => value == '');

      url ??= ApiConstants.images();
      final response = await _apiService.get(url, queryParameters: {
        ...params,
        'page': page,
        'limit': limit,
      });

      final List<ImageModel> results = (response.data['results'] as List)
          .map((imageModel) => ImageModel.fromJson(imageModel))
          .toList();

      final PageData<ImageModel> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );

      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取图片列表失败', tag: 'ImageModelService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 根据图库ID获取相关图库列表。
  Future<ApiResult<PageData<ImageModel>>> fetchRelatedImagesByImageId(
      String mediaId,
      {int page = 0,
      int limit = 20}) async {
    try {
      return await fetchImageModelsByParams(
          page: page, limit: limit, url: ApiConstants.relatedImages(mediaId));
    } catch (e) {
      LogUtils.e('获取相关图库列表失败', tag: 'ImageModelService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 根据作者ID获取作者图库列表。
  Future<ApiResult<PageData<ImageModel>>> fetchAuthorImages(String userId,
      {required String excludeImageId, int limit = 6}) async {
    try {
      return await fetchImageModelsByParams(
        params: {'user': userId, 'exclude': excludeImageId},
        limit: limit,
      );
    } catch (e) {
      LogUtils.e('获取作者图库列表失败', tag: 'ImageModelService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 获取图库的点赞用户列表
  Future<ApiResult<PageData<User>>> fetchLikeImageUsers(String mediaId,
      {int page = 0, int limit = 6}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.imageLikes(mediaId),
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<User> results = (response.data['results'] as List)
          .map((userJson) => User.fromJson(userJson['user']))
          .toList();

      final PageData<User> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );

      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取点赞用户列表失败', tag: 'ImageModelService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 获取最爱
  Future<ApiResult<PageData<ImageModel>>> fetchFavoriteImages(
      {int page = 0, int limit = 20}) async {
    try {
      final response = await _apiService
          .get(ApiConstants.favoriteImages(), queryParameters: {
        'page': page,
        'limit': limit,
      });

      final List<ImageModel> results = (response.data['results'] as List)
          .map((item) => ImageModel.fromJson(item['image']))
          .toList();

      final PageData<ImageModel> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );

      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取最爱图库列表失败', tag: 'ImageModelService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 取消最爱
  Future<ApiResult<void>> cancelFavoriteImage(String mediaId) async {
    try {
      await _apiService.delete(ApiConstants.likeImage(mediaId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('取消最爱图库失败', tag: 'ImageModelService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 设为最爱
  Future<ApiResult<void>> setFavoriteImage(String mediaId) async {
    try {
      await _apiService.post(ApiConstants.likeImage(mediaId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('设为最爱图库失败', tag: 'ImageModelService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 点赞图库
  Future<ApiResult<void>> likeImage(String mediaId) async {
    try {
      await _apiService.post(ApiConstants.likeImage(mediaId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('点赞图库失败', tag: 'GalleryService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 取消点赞图库
  Future<ApiResult<void>> unlikeImage(String mediaId) async {
    try {
      await _apiService.delete(ApiConstants.likeImage(mediaId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('取消点赞图库失败', tag: 'GalleryService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }
}
