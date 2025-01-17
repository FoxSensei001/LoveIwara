
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
class PostService extends GetxService {
  final ApiService _apiService = Get.find();

  /// 获取帖子详情
  /// @param id 帖子ID
  Future<ApiResult<PostModel>> fetchPostDetail(String id) async {
    try {
      var response = await _apiService.get(ApiConstants.post(id));
      return ApiResult.success(data: PostModel.fromJson(response.data));
    } catch (e) {
      LogUtils.e('获取帖子详情失败', tag: 'PostService', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  /// 获取帖子列表
  /// [params]
  /// `page` 页码
  /// `limit` 每页数量
  /// `subscribed` 是否订阅
  /// `user` 用户ID
  Future<ApiResult<PageData<PostModel>>> fetchPostList({
    Map<String, dynamic> params = const {},
    int page = 0,
    int limit = 20,
  }) async {
    try {
      var response = await _apiService.get(ApiConstants.posts(), queryParameters: {
        ...params,
        'page': page,
        'limit': limit,
      });
      final List<PostModel> results = (response.data['results'] as List)
          .map((postModel) => PostModel.fromJson(postModel))
          .toList();
      final PageData<PostModel> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );
      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取帖子列表失败', tag: 'PostService', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  /// 获取关注的帖子列表
  Future<ApiResult<PageData<PostModel>>> fetchSubscribedPostList({
    int page = 0,
    int limit = 20,
  }) async {
    return await fetchPostList(params: {'subscribed': true}, page: page, limit: limit);
  }

  /// 获取用户的帖子列表
  Future<ApiResult<PageData<PostModel>>> fetchUserPostList(String userId, {
    int page = 0,
    int limit = 20,
  }) async {
    return await fetchPostList(params: {'user': userId}, page: page, limit: limit);
  }

  /// 发送帖子
  /// @param title 标题
  /// @param body 内容
  Future<ApiResult<void>> postPost(String title, String body) async {
    try {
      await _apiService.post(ApiConstants.posts(), data: {'title': title, 'body': body, 'rulesAgreement': true});
      return ApiResult.success();
    } catch (e) {
      if (e is DioException) {
      String message = e.response?.data['message'];
      switch (message) {
        case "errors.tooManyRequests":
          return ApiResult.fail(slang.t.errors.tooManyRequests);
        default:
          return ApiResult.fail(message);
      }
    }
      LogUtils.e('发送帖子失败', tag: 'PostService', error: e);
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  /// 获取冷却时间，当needToCheckCoolingTime为true时，返回冷却时间
  /// /user/post/cooldown
  /// {
  ///   "limited": true,
  ///   "remaining": 3136 // 剩余时间 秒
  /// }
  Future<ApiResult<PostCooldownModel>> fetchPostCollingInfo() async {
    try {
      var response = await _apiService.get(ApiConstants.userPostCooldown());
      return ApiResult.success(data: PostCooldownModel.fromJson(response.data));
    } catch (e) {
      LogUtils.e('获取冷却时间失败', tag: 'PostService', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }
}

